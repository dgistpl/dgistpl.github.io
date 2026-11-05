---
layout: single
title: "Conference Deadlines"
author_profile: false
permalink: /conferences/
---

<style>
#conf-page .conf-legend { display: flex; flex-wrap: wrap; gap: 24px; margin-bottom: 10px; font-size: 0.8em; }
#conf-page .conf-legend ul { margin: 0; }
#conf-page .tag-filter { display: flex; flex-wrap: wrap; gap: 6px; align-items: center; }
#conf-page .tag-filter button {
  border: 1px solid #ccc; background: #fff; border-radius: 16px; padding: 2px 12px;
  cursor: pointer; font-size: 0.9em; display: inline-flex; align-items: center; gap: 6px;
}
#conf-page .tag-filter button.active { background: #e3f2fd; border-color: #2196F3; }
#conf-page .past-toggle { font-size: 0.9em; margin-left: 8px; cursor: pointer; }
#conf-page .cal-link { margin-left: 6px; color: #888; text-decoration: none; }
#conf-page .cal-link:hover { color: #2196F3; }
#conf-page.hide-past .conf.past { display: none !important; }
#conf-page .tag {
  display: inline-block; color: #fff; padding: 0 6px; border-radius: 6px;
  font-size: 0.75em; font-weight: bold; text-transform: uppercase; background: #555;
}
#conf-page .tag.pl { background: darkblue; }
#conf-page .tag.se { background: darkgreen; }
#conf-page .tag.sec { background: darkred; }
#conf-page .tag.ml { background: #8e44ad; }
#conf-page .tag.arch { background: #a0522d; }
#conf-page .tag.logic { background: #00838f; }
#conf-page .top-strip { background: #2196F3; height: 3px; margin: 15px 0 10px; }
#conf-page .conf {
  display: flex; flex-wrap: wrap; justify-content: space-between; gap: 8px;
  padding: 10px 0; border-bottom: 1px solid #eee;
}
#conf-page .conf.past { opacity: 0.45; }
#conf-page .conf-left { flex: 1 1 340px; }
#conf-page .conf-right { flex: 0 1 300px; text-align: right; }
#conf-page .conf-name { font-size: 1.1em; font-weight: 600; text-decoration: none; }
#conf-page .rank, #conf-page .meta, #conf-page .deadline, #conf-page .note { font-size: 0.75em; color: #555; }
#conf-page .note { font-style: italic; }
#conf-page .timer { font-size: 1.1em; font-weight: 600; font-variant-numeric: tabular-nums; }
#conf-page .conf.soon .timer { color: #d32f2f; }
@media (max-width: 600px) { #conf-page .conf-right { text-align: left; } }
</style>

<div id="conf-page">

<p style="font-size:0.8em">Last update: {{ site.data.conference_deadlines.last_update }} (auto-synced weekly from <a href="https://github.com/ccfddl/ccf-deadlines" target="_blank" rel="noopener">ccf-deadlines</a>) · Deadlines are shown in your local time zone; hover a date for the original. Always double-check the official website.</p>

<div class="conf-legend">
  <div class="tag-filter" id="tag-filter">
    <strong style="font-size:0.9em">Filter:</strong>
    {% assign all_tags = "" | split: "" %}
    {% for pair in site.data.conferences.infos %}{% assign all_tags = all_tags | concat: pair[1].tags %}{% endfor %}
    {% assign all_tags = all_tags | uniq %}
    {% for t in all_tags %}
    <button type="button" data-tag="{{ t }}"><span class="tag {{ t | downcase }}">{{ t }}</span></button>
    {% endfor %}
    <label class="past-toggle"><input type="checkbox" id="hide-past"> Hide past</label>
  </div>
  <ul>
    <li><a href="https://www.kiise.or.kr/TopConferences/data/BK21%ED%94%8C%EB%9F%AC%EC%8A%A4%EC%82%AC%EC%97%85_CS%EB%B6%84%EC%95%BC_%EC%9A%B0%EC%88%98%EA%B5%AD%EC%A0%9C%ED%95%99%EC%88%A0%EB%8C%80%ED%9A%8C%EB%AA%A9%EB%A1%9D_2018.pdf">BK21</a> — IF 1–4</li>
    <li><a href="https://www.kiise.or.kr/TopConferences/data/SW%EB%B6%84%EC%95%BC%EC%9A%B0%EC%88%98%ED%95%99%EC%88%A0%EB%8C%80%ED%9A%8C%EB%AA%A9%EB%A1%9D_2024.pdf">KIISE</a> — 최우수 / 우수</li>
    <li><a href="https://portal.core.edu.au/conf-ranks/">CORE</a> — A* / A / B / C</li>
  </ul>
</div>

<div class="top-strip"></div>

<div id="conf-list">
{% for conf in site.data.conference_deadlines.list %}
{% assign info = site.data.conferences.infos[conf.name] %}
{% assign n = conf.deadlines.size %}
{% for dl in conf.deadlines %}
<div class="conf" data-deadline="{{ dl.utc }}" data-abstract="{{ dl.abstract_utc }}" data-raw="{{ dl.raw }}" data-tags="{{ info.tags | join: ',' }}" data-title="{{ conf.name }} {{ conf.year }}{% if n > 1 %} (round {{ forloop.index }}){% endif %} deadline" data-link="{{ conf.link }}">
  <div class="conf-left">
    <a class="conf-name" href="{{ conf.link }}" target="_blank" rel="noopener">{{ conf.name }} {{ conf.year }}</a>
    {% for tag in info.tags %}<span class="tag {{ tag | downcase }}">{{ tag }}</span> {% endfor %}
    <div class="rank">
      BK21 {% if info.bk21 == '-' %}-{% else %}IF{{ info.bk21 }}{% endif %} · KIISE {{ info.kiise }} ·
      {% if info.rank-id %}<a href="https://portal.core.edu.au/conf-ranks/{{ info.rank-id }}/" target="_blank" rel="noopener">CORE {{ info.rank }}</a>{% else %}<a href="https://portal.core.edu.au/conf-ranks/?search={{ conf.name | url_encode }}&by=acronym&source=all" target="_blank" rel="noopener">CORE {{ info.rank }}</a>{% endif %}
    </div>
    <div class="meta">
      {{ conf.date }} ·
      {{ conf.place }}
    </div>
    {% if conf.note %}<div class="note">{{ conf.note }}</div>{% endif %}
  </div>
  <div class="conf-right">
    <div class="timer">&nbsp;</div>
    <div class="deadline">
      {% if dl.label %}{{ dl.label }}{% else %}Deadline{% if n > 1 %} ({{ forloop.index }}/{{ n }}){% endif %}{% endif %}:
      <span class="deadline-time">{{ dl.utc }}</span><a class="cal-link" href="#" target="_blank" rel="noopener" title="Add to Google Calendar" hidden><i class="far fa-calendar-plus"></i></a>
    </div>
    <div class="deadline abstract-time" hidden></div>
  </div>
</div>
{% endfor %}
{% endfor %}
</div>

</div>

<script>
(function () {
  var list = document.getElementById('conf-list');
  var confs = Array.prototype.slice.call(list.querySelectorAll('.conf'));
  var localTz = '';
  try { localTz = Intl.DateTimeFormat().resolvedOptions().timeZone; } catch (e) {}

  // ISO 8601 UTC timestamp (generated by scripts/update_conferences.rb) -> epoch ms, null if TBA
  function parseDeadline(s) {
    var t = Date.parse(s || '');
    return isNaN(t) ? null : t;
  }
  function fmt(ms) {
    return new Date(ms).toLocaleString(undefined, {
      year: 'numeric', month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit'
    }) + (localTz ? ' (' + localTz + ')' : '');
  }

  function pad(n) { return n < 10 ? '0' + n : '' + n; }

  function ago(ms) {
    var d = Math.floor(ms / 86400000);
    if (d >= 30) return Math.round(d / 30) + ' month' + (Math.round(d / 30) > 1 ? 's' : '') + ' ago';
    if (d >= 1) return d + ' day' + (d > 1 ? 's' : '') + ' ago';
    var h = Math.floor(ms / 3600000);
    return h >= 1 ? h + ' hour' + (h > 1 ? 's' : '') + ' ago' : 'just now';
  }

  confs.forEach(function (el) {
    var raw = el.getAttribute('data-raw');
    el._deadline = parseDeadline(el.getAttribute('data-deadline'));
    var abs = parseDeadline(el.getAttribute('data-abstract'));
    if (abs !== null) {
      var at = el.querySelector('.abstract-time');
      at.textContent = 'Abstract: ' + fmt(abs);
      at.hidden = false;
    }
    var dt = el.querySelector('.deadline-time');
    if (el._deadline === null) {
      el.querySelector('.timer').textContent = 'TBA';
      dt.textContent = 'TBA';
    } else {
      dt.textContent = fmt(el._deadline);
      dt.title = raw;
      var cal = el.querySelector('.cal-link');
      var stamp = new Date(el._deadline).toISOString().replace(/[-:]|\.\d{3}/g, '');
      cal.href = 'https://calendar.google.com/calendar/render?action=TEMPLATE' +
        '&text=' + encodeURIComponent(el.getAttribute('data-title')) +
        '&dates=' + stamp + '/' + stamp +
        '&details=' + encodeURIComponent(el.getAttribute('data-link') + '\n' + raw);
      cal.hidden = false;
    }
  });

  // Upcoming first (nearest first), then TBA, then past (most recent first)
  var now = Date.now();
  function rank(el) {
    var d = el._deadline;
    if (d === null) return [1, 0];
    return d >= now ? [0, d - now] : [2, now - d];
  }
  confs.sort(function (a, b) {
    var ra = rank(a), rb = rank(b);
    return ra[0] - rb[0] || ra[1] - rb[1];
  }).forEach(function (el) { list.appendChild(el); });

  function tick() {
    var now = Date.now();
    confs.forEach(function (el) {
      if (el._deadline === null) return;
      var diff = el._deadline - now;
      var timer = el.querySelector('.timer');
      if (diff > 0) {
        var s = Math.floor(diff / 1000);
        timer.textContent = Math.floor(s / 86400) + ' days ' + pad(Math.floor(s / 3600) % 24) + 'h ' +
          pad(Math.floor(s / 60) % 60) + 'm ' + pad(s % 60) + 's';
        el.classList.remove('past');
        el.classList.toggle('soon', diff < 7 * 86400000);
      } else {
        timer.textContent = ago(-diff);
        el.classList.add('past');
        el.classList.remove('soon');
      }
    });
  }
  tick();
  setInterval(tick, 1000);

  // Tag filter (multi-select; none selected = show all) + hide-past, remembered across visits
  var page = document.getElementById('conf-page');
  var hidePast = document.getElementById('hide-past');
  var buttons = Array.prototype.slice.call(document.querySelectorAll('#tag-filter button'));
  var KEY = 'conf-deadlines-prefs';
  var prefs = {};
  try { prefs = JSON.parse(localStorage.getItem(KEY)) || {}; } catch (e) {}

  function apply() {
    var selected = buttons.filter(function (b) { return b.classList.contains('active'); })
                          .map(function (b) { return b.getAttribute('data-tag'); });
    confs.forEach(function (el) {
      var tags = (el.getAttribute('data-tags') || '').split(',');
      var show = selected.length === 0 || tags.some(function (t) { return selected.indexOf(t) >= 0; });
      el.style.display = show ? '' : 'none';
    });
    page.classList.toggle('hide-past', hidePast.checked);
    try { localStorage.setItem(KEY, JSON.stringify({ tags: selected, hidePast: hidePast.checked })); } catch (e) {}
  }

  buttons.forEach(function (btn) {
    if ((prefs.tags || []).indexOf(btn.getAttribute('data-tag')) >= 0) btn.classList.add('active');
    btn.addEventListener('click', function () { btn.classList.toggle('active'); apply(); });
  });
  hidePast.checked = !!prefs.hidePast;
  hidePast.addEventListener('change', apply);
  apply();
})();
</script>
