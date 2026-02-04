# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is the PLX Lab website at DGIST (Daegu Gyeongbuk Institute of Science and Technology), led by Professor Minseok Jeon. Built with Jekyll using the Minimal Mistakes theme, the site serves as both a research group homepage and academic blog, showcasing research publications (focusing on PL4SE and PL4ML), lab member profiles, academic activities, and course materials.

## Development Commands

### Docker Setup (Recommended)
```bash
docker build -t dgistpl-jekyll .                                    # Build Docker image
docker run -p 4000:4000 -p 35729:35729 -v $(pwd):/site dgistpl-jekyll  # Run with live reload
```
The Docker setup includes both Jekyll (port 4000) and LiveReload (port 35729) with automatic file watching.

### Native Setup
```bash
bundle install    # Install Ruby gems (Jekyll dependencies)
npm install      # Install Node.js dependencies (for JavaScript build tools)
```

### Build and Serve
```bash
bundle exec jekyll serve    # Start development server at http://localhost:4000
bundle exec jekyll build    # Build the site for production (outputs to _site/)
```

### JavaScript Development
```bash
npm run build:js    # Build and minify JavaScript files (runs uglify + add-banner)
npm run uglify      # Minify JavaScript assets only
npm run add-banner  # Add banner to JavaScript files using banner.js
npm run watch:js    # Watch JavaScript files for changes and auto-rebuild
```

### LaTeX CV Compilation
```bash
cd cv/
pdflatex main.tex   # Compile CV from LaTeX source to PDF
```

### Testing and Validation
- **No automated test suite** - this site relies on manual testing via local server
- Test Firebase view counter functionality on localhost:4000 with real page loads
- Validate JavaScript minification with `npm run build:js` before deployment

## Architecture

### Jekyll Site Structure
- **Theme**: Uses Minimal Mistakes Jekyll theme with extensive customizations
- **Content Types**:
  - Academic homepage (`index.md`)
  - Blog posts in `_posts/` (research updates and experiences, with Korean title "연구 이야기")
  - Course materials in `courses/` directory
  - Static assets (papers, slides) in dedicated folders

### Custom Features

#### Firebase View Counter
Custom view tracking system using Firebase Realtime Database:
- **Configuration**:
  - Firebase config in `_config.yml` under `firebase:` section
  - Hardcoded config in `_includes/firebase-config.html` (Jekyll variable processing workaround)
- **Implementation**:
  - `_includes/firebase-config.html`: Firebase SDK v12.0.0 initialization using ES modules
  - `_includes/view-counter.html`: View counting logic with localStorage fallback
  - Firebase globals exposed via `window.firebaseDatabase`, `window.firebaseRef`, etc.
- **Features**:
  - Session-based counting (one count per session per page using sessionStorage)
  - Automatic fallback to localStorage if Firebase unavailable
  - Integration with Google Analytics event tracking
  - Real-time view count display with number formatting
  - URL cleaning for Firebase keys (removes special characters like `.#$[]`)

#### JavaScript Build Pipeline
- **Source files**: Located in `assets/js/vendor/` and `assets/js/plugins/`, plus `assets/js/_main.js`
- **Build process**: uglifyjs bundles all source files → Uglification → Banner addition (via banner.js)
- **Output**: `assets/js/main.min.js` with MIT license banner
- **banner.js**: Node script that adds Minimal Mistakes theme license header
- **Watch mode**: `npm run watch:js` uses `onchange` to auto-rebuild on file changes

### Key Customizations
- **Author Profile**: Enhanced author profile with post-specific version (`_includes/author-profile-post.html`)
- **View Counter Integration**: Included in `_layouts/default.html` via `{% include firebase-config.html %}`
- **Google Analytics**: Configured with gtag.js (tracking ID: G-KTKXXC6BCQ)

### File Organization
- `_data/`: Structured data files (publications.yml, talks.yml, authors.yml, navigation.yml)
- `_includes/`: Custom HTML includes for modular components
- `_layouts/`: Page layout templates (customized default.html)
- `_sass/`: SCSS stylesheets (inherits from Minimal Mistakes)
- `assets/`: Static assets including custom JavaScript and images
- `courses/`: Course-specific content and materials
- `papers/`: PDF files for research papers and slides
- `images/`: Image assets for posts and pages
- `members/`: Individual member profile pages
- `publications/`, `research/`, `talks/`, `trips/`: Academic content sections
- `_pages/`: Static pages
- `about.md` / `about.html`: About page (root-level)

## Firebase Configuration

The site uses Firebase for view counting functionality:
- Database: Firebase Realtime Database
- Configuration stored in both `_config.yml` and hardcoded in `_includes/firebase-config.html`
- API keys and configuration are public (read-only database rules)

## Content Management

### Adding Blog Posts
- Create files in `_posts/` with format: `YYYY-MM-DD-title.md`
- Use `layout: single` for consistency
- Include appropriate front matter for author profile and metadata
- Posts appear under "연구 이야기" (Research Stories) in navigation

### Adding Course Materials
- Organize by course code and year in `courses/` directory structure: `courses/{course_code}/{year}/`
- Examples: `courses/cose213/2024/`, `courses/ai_ds/2025/`, `courses/ic637/2025/`
- Use markdown files with proper navigation structure
- Store slides/PDFs in course-specific subdirectories (`slides/`)
- Some courses include a `book/` subdirectory with topic-based markdown files (e.g., `ai_ds/2025/book/topics/`)
- Course index at `courses/index.md` lists all courses

### Academic Content
- **Publications**: Listed in `index.md` and structured data in `_data/publications.yml`
- **Papers and Slides**: Stored in `/papers/` directory as PDFs
- **CV**: LaTeX source in `cv/` directory (main.tex compiles to main.pdf)
- **Member Profiles**: Individual markdown files in `members/` directory (e.g., `members/minseok.jeon.md`)
- **Talks**: Structured data in `_data/talks.yml`
- **Navigation**: Site navigation configured in `_data/navigation.yml` (main menu links)
- **Authors**: Author metadata in `_data/authors.yml` for multi-author support

## Theme Integration

This site extends the Minimal Mistakes theme:
- Configuration in `_config.yml` follows MM conventions
- Custom includes override theme defaults
- SCSS customizations in `_sass/` directory
- JavaScript enhancements for Firebase integration

## Development Workflow

### Making Changes
1. Edit content files (markdown in `_posts/`, `courses/`, etc.)
2. For JavaScript changes: run `npm run watch:js` during development
3. Test locally with `bundle exec jekyll serve` or Docker
4. Build production assets with `npm run build:js` before committing JavaScript changes
5. Commit changes (site auto-deploys via GitHub Pages on push to master)

### Firebase View Counter Development
- Firebase config duplicated in `_config.yml` and `_includes/firebase-config.html` (due to Jekyll variable processing issues)
- Testing requires actual page loads in browser at localhost:4000 (not just Jekyll compilation)
- View counts stored in Firebase with cleaned URLs as keys (special chars like `.#$[]` removed)
- Session storage prevents multiple counts per browser session (key format: `firebase_viewed_{cleanUrl}`)
- If Firebase unavailable, automatically falls back to localStorage with similar session logic

### Jekyll Configuration Notes
- Site uses `minimal-mistakes-jekyll` gem (not `github-pages` gem)
- Pagination set to 5 posts per page
- Markdown processor: kramdown with GFM input
- Permalink format: `/:categories/:title/`
- Default layouts configured in `_config.yml` under `defaults:` section

## Important Notes

- **Deployment**: Site auto-deploys to GitHub Pages on push to master branch
- **Firebase**: API keys are intentionally public (database has read-only security rules)
- **Assets**: JavaScript build process handles minification and banner addition
- **Content**: All paper PDFs and academic materials are version-controlled in repository
- **Theme**: Extends Minimal Mistakes theme - prefer custom includes/layouts over modifying core theme files
- **Comments**: `staticman.yml` at the root configures the Staticman comment backend (one of several comment providers available via `_includes/comments-providers/`)
- **LiveReload**: Docker setup includes LiveReload on port 35729 for automatic browser refresh
- **File Watching**: Docker uses `--force_polling` flag for reliable file change detection in containers