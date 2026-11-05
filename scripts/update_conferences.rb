#!/usr/bin/env ruby
# frozen_string_literal: true
#
# Builds _data/conference_deadlines.yml from
#   - _data/conferences.yml       (which venues to track + manual entries)
#   - a local clone of https://github.com/ccfddl/ccf-deadlines
#
# Usage: ruby scripts/update_conferences.rb PATH_TO_CCF_DEADLINES_CLONE
#
# Only Ruby's standard library is used, so no gems are needed.

require "yaml"
require "date"
require "time"

ROOT   = File.expand_path("..", __dir__)
CONFIG = File.join(ROOT, "_data", "conferences.yml")
OUTPUT = File.join(ROOT, "_data", "conference_deadlines.yml")

ccf_root = ARGV[0] or abort("usage: #{$PROGRAM_NAME} PATH_TO_CCF_DEADLINES_CLONE")
ccf_conf = File.join(ccf_root, "conference")
abort("not a ccf-deadlines clone: #{ccf_root}") unless Dir.exist?(ccf_conf)

# --- time handling -----------------------------------------------------------

# Convert "YYYY-MM-DD HH:mm[:ss]" in the given timezone to a UTC ISO string.
# Returns nil for TBD/TBA/unparseable values.
def to_utc(raw, tz)
  m = /\A(\d{4})-(\d{2})-(\d{2})(?:[ T](\d{2}):(\d{2})(?::(\d{2}))?)?\z/.match(raw.to_s.strip)
  return nil unless m

  y, mo, d = m[1].to_i, m[2].to_i, m[3].to_i
  h  = (m[4] || 23).to_i
  mi = (m[5] || 59).to_i
  s  = m[6] ? m[6].to_i : (mi == 59 ? 59 : 0)

  tz = (tz || "AoE").to_s.strip
  t =
    case tz
    when /\AAoE\z/i then Time.new(y, mo, d, h, mi, s, "-12:00")
    when /\AUTC\z/i, /\AGMT\z/i then Time.new(y, mo, d, h, mi, s, "+00:00")
    when /\A(?:UTC|GMT)([+-])(\d{1,2})(?::?(\d{2}))?\z/i
      Time.new(y, mo, d, h, mi, s, format("%s%02d:%02d", Regexp.last_match(1), Regexp.last_match(2).to_i, Regexp.last_match(3).to_i))
    when /\A(PT|PST|PDT)\z/i then in_zone("America/Los_Angeles") { Time.local(y, mo, d, h, mi, s) }
    when /\A(ET|EST|EDT)\z/i then in_zone("America/New_York") { Time.local(y, mo, d, h, mi, s) }
    when %r{\A[A-Za-z_]+/[A-Za-z_]+\z} then in_zone(tz) { Time.local(y, mo, d, h, mi, s) }
    else
      warn "  ! unknown timezone #{tz.inspect}, assuming AoE"
      Time.new(y, mo, d, h, mi, s, "-12:00")
    end
  t.utc.iso8601
end

def in_zone(zone)
  old = ENV["TZ"]
  ENV["TZ"] = zone
  yield
ensure
  ENV["TZ"] = old
end

# --- ccf-deadlines -----------------------------------------------------------

def load_ccf(path)
  data = YAML.safe_load(File.read(path), permitted_classes: [Date, Time]) || []
  data.is_a?(Array) ? data.first : data
end

# Pick the newest edition; returns [edition, previous_edition_with_dates]
def pick_edition(confs)
  sorted = confs.sort_by { |c| c["year"].to_i }
  latest = sorted.last
  dated  = sorted.reverse.find { |c| (c["timeline"] || []).any? { |t| to_utc(t["deadline"], c["timezone"]) } }
  [latest, dated]
end

def from_ccf(name, info, ccf_conf)
  path = File.join(ccf_conf, info["ccfddl"])
  unless File.exist?(path)
    warn "  ! #{name}: #{info['ccfddl']} not found in ccf-deadlines"
    return nil
  end
  venue = load_ccf(path)
  confs = venue["confs"] || []
  return nil if confs.empty?

  filter = info["ccfddl_comment"] && Regexp.new(info["ccfddl_comment"], Regexp::IGNORECASE)
  keep = ->(t) { filter.nil? || filter.match?(t["comment"].to_s) }

  latest, last_dated = pick_edition(confs)
  tz = latest["timezone"] || "AoE"
  deadlines = (latest["timeline"] || []).select(&keep).map do |t|
    {
      "utc" => to_utc(t["deadline"], tz) || "TBA",
      "abstract_utc" => to_utc(t["abstract_deadline"], tz),
      "label" => (filter || t["comment"].to_s.length > 40) ? nil : t["comment"],
      "raw" => "#{t['deadline']} #{tz}",
    }.compact
  end
  deadlines = [{ "utc" => "TBA", "raw" => "TBA" }] if deadlines.empty?

  note = nil
  if deadlines.all? { |d| d["utc"] == "TBA" } && last_dated && last_dated != latest
    prev = (last_dated["timeline"] || []).select(&keep).map { |t| t["deadline"].to_s[0, 10] }.join(", ")
    note = "Not announced yet. Last edition (#{last_dated['year']}): #{prev}." unless prev.empty?
  end

  {
    "name" => name,
    "year" => latest["year"].to_i,
    "link" => latest["link"],
    "date" => latest["date"].to_s,
    "place" => latest["place"].to_s,
    "note" => note,
    "deadlines" => deadlines,
    "source" => "ccfddl",
  }.compact
end

def from_manual(entry)
  tz = entry["timezone"] || "AoE"
  {
    "name" => entry["name"],
    "year" => entry["year"].to_i,
    "link" => entry["link"],
    "date" => entry["date"].to_s,
    "place" => entry["place"].to_s,
    "note" => entry["note"],
    "deadlines" => Array(entry["deadline"]).map { |d| { "utc" => to_utc(d, tz) || "TBA", "raw" => "#{d} #{tz}" } },
    "source" => "manual",
  }.compact
end

# --- main --------------------------------------------------------------------

config  = YAML.safe_load(File.read(CONFIG)) || {}
infos   = config["infos"] || {}
manual  = (config["manual"] || []).map { |e| from_manual(e) }
by_name = manual.group_by { |e| e["name"] }

list = []
infos.each do |name, info|
  if by_name[name]
    list.concat(by_name[name])
  elsif info["ccfddl"]
    entry = from_ccf(name, info, ccf_conf)
    entry ? list << entry : warn("  ! #{name}: no data")
  else
    warn "  ! #{name}: no ccfddl source and no manual entry"
  end
end
(by_name.keys - infos.keys).each { |n| warn "  ! manual entry #{n} has no infos entry (ignored)" }

body = { "list" => list }
old  = File.exist?(OUTPUT) ? (YAML.safe_load(File.read(OUTPUT)) || {}) : {}
if old["list"] == list
  puts "No changes."
  exit 0
end

header = <<~H
  # AUTO-GENERATED by scripts/update_conferences.rb from ccf-deadlines
  # (https://github.com/ccfddl/ccf-deadlines). Do not edit by hand:
  # edit _data/conferences.yml instead (use `manual:` to override).
H
body = { "last_update" => Date.today.iso8601 }.merge(body)
File.write(OUTPUT, header + body.to_yaml.sub(/\A---\n/, ""))
puts "Wrote #{list.size} venues to #{OUTPUT.sub(ROOT + '/', '')}"
