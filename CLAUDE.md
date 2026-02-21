# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

PLX Lab website at DGIST, led by Professor Minseok Jeon. Jekyll site using Minimal Mistakes theme — academic homepage, research publications (PL4SE and PL4ML), member profiles, course materials, and blog ("연구 이야기").

**Live site:** https://dgistpl.github.io

## Development Commands

### Docker Setup (Recommended)
```bash
docker build -t dgistpl-jekyll .
docker run -p 4000:4000 -p 35729:35729 -v $(pwd):/site dgistpl-jekyll
```

### Native Setup
Requires Ruby 3.x, Node.js 18+, Bundler.
```bash
bundle install && npm install
```

### Build and Serve
```bash
bundle exec jekyll serve       # Dev server at http://localhost:4000
bundle exec jekyll build       # Production build (outputs to _site/)
```

### JavaScript Build
```bash
npm run build:js    # Minify + add banner (must run before committing JS changes)
npm run watch:js    # Watch mode for development
```

### LaTeX CV
```bash
cd cv/ && pdflatex main.tex
```

### Testing
No automated test suite. Test manually via local server. Validate JS with `npm run build:js`.

## Architecture

### Key Architectural Decisions

- **Theme**: Minimal Mistakes Jekyll theme — prefer custom includes/layouts over modifying core theme files. No custom SCSS exists; page-specific styling uses inline `<style>` blocks in Markdown files.
- **Deployment**: Auto-deploys to GitHub Pages on push to `master`
- **`_config.yml` changes require server restart** (standard Jekyll behavior)
- **Permalink structure**: `/:categories/:title/` (set in `_config.yml`)

### Page Organization

Content pages live in **root-level directories** (not `_pages/`). This is non-standard for Jekyll but works because each directory has its own `index.md`:

- `index.md` — Homepage (`archive` layout, pulls from `site.data.authors.minseok_jeon` for contact info)
- `research/index.md` — Research areas
- `publications/index.md` — Loops over `_data/publications.yml` by year
- `members/index.md` — Loops over `_data/authors.yml`, filters by `position` field
- `talks/index.md` — Loops over `_data/talks.yml` by year
- `trips/index.md`, `courses/index.md`

The only file in `_pages/` is `tag-archive.md`. Navigation links are defined in `_data/navigation.yml`.

### Data-Driven Content

Most dynamic pages use Liquid loops over `_data/*.yml` files:

**`_data/publications.yml`** — Grouped by year, each paper has:
```yaml
- year: 2025
  papers:
    - title: "Paper Title"
      authors: "<u>Name</u>, Name"  # HTML markup for underlines
      venue: "Conference 2025"
      links:
        - type: "PDF"
          url: "/papers/filename.pdf"
        - type: "Slides"
          url: "/papers/slides.pdf"
```

**`_data/authors.yml`** — Keyed by ID (e.g., `minseok_jeon`), each entry has `name`, `ko-name`, `avatar`, `position`, `email`, `scholar`, etc. The `members/index.md` page filters by position to display members in sections (Professor, PhD, MS, Undergraduate Intern).

**`_data/talks.yml`** — List of `{title, venue, date, year, slides}` entries.

### Firebase View Counter

Custom page view tracking using Firebase Realtime Database (SDK v12.0.0 via ES modules).

**Critical: dual-config issue** — Firebase config is duplicated in both `_config.yml` (under `firebase:`) and hardcoded in `_includes/firebase-config.html` because Jekyll variables don't process correctly in the module script. When updating Firebase config, **both files must be changed**.

How it works:
- `_includes/firebase-config.html`: Initializes Firebase, exposes globals (`window.firebaseDatabase`, `window.firebaseRef`, etc.). Included in `_layouts/default.html`.
- `_includes/view-counter.html`: Polls for Firebase availability (up to 50 attempts), increments view count, falls back to localStorage if unavailable.
- Session-based counting via `sessionStorage` (key: `firebase_viewed_{cleanUrl}`)
- URLs cleaned for Firebase keys by removing `.#$[]` characters
- Firebase API keys are intentionally public (database has read-only security rules)

### JavaScript Build Pipeline

Source: `assets/js/vendor/jquery/`, `assets/js/plugins/`, `assets/js/_main.js`
→ uglifyjs bundles and minifies → `banner.js` adds MIT license header
→ Output: `assets/js/main.min.js`

## Content Management

### Blog Posts
Create in `_posts/` as `YYYY-MM-DD-title.md` with `layout: single`.

### Course Materials
Organize as `courses/{course_code}/{year}/` with slides in `slides/` subdirectory. Course pages use `layout: splash` for full-width display. Course index at `courses/index.md`.

### Adding Publications
Add entries to `_data/publications.yml` under the appropriate year. Store PDFs/slides in `papers/`. Use HTML in the `authors` field for formatting (e.g., `<u>Name</u>` to underline).

### Adding Members
Add an entry to `_data/authors.yml` with a unique key. The `position` field determines which section the member appears in on the members page. Store avatar images in `images/members/`.

### Other Data Files
- **Navigation**: `_data/navigation.yml`
- **CV**: LaTeX source in `cv/main.tex`
