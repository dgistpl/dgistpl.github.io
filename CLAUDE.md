# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is Minseok Jeon's personal academic homepage built with Jekyll using the Minimal Mistakes theme. The site serves as both a portfolio and blog for a research professor at Korea University, showcasing research publications, academic activities, and course materials.

## Development Commands

### Setup
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
  - Blog posts in `_posts/` (research updates and experiences)
  - Course materials in `courses/` directory
  - Static assets (papers, slides) in dedicated folders

### Custom Features
- **Firebase View Counter**: Custom view tracking system using Firebase Realtime Database
  - Configuration in `_config.yml` under `firebase:` section  
  - Implementation files:
    - `_includes/firebase-config.html`: Firebase SDK initialization and global setup
    - `_includes/view-counter.html`: View counting logic with localStorage fallback
  - Features:
    - Session-based counting (one count per session per page)
    - Automatic fallback to localStorage if Firebase unavailable
    - Integration with Google Analytics event tracking
    - Real-time view count display with number formatting

### Key Customizations
- **Author Profile**: Enhanced author profile with post-specific version (`_includes/author-profile-post.html`)
- **View Counter Integration**: Added to page meta information and post layouts
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
- `publications/`, `research/`, `talks/`: Academic content sections

## Firebase Configuration

The site uses Firebase for view counting functionality:
- Database: Firebase Realtime Database
- Configuration stored in `_config.yml` 
- API keys and configuration are public (read-only database rules)
- Setup documentation available in `FIREBASE_SETUP.md`

## Content Management

### Adding Blog Posts
- Create files in `_posts/` with format: `YYYY-MM-DD-title.md`
- Use `layout: single` for consistency
- Include appropriate front matter for author profile and metadata

### Adding Course Materials
- Organize by course code and year in `courses/` directory
- Use markdown files with proper navigation structure
- Store slides/PDFs in course-specific subdirectories

### Academic Content
- Research publications listed in `index.md` and structured data in `_data/publications.yml`
- Papers and slides stored in `/papers/` directory
- CV maintained as LaTeX source in `cv/` directory (main.tex -> main.pdf)
- Member profiles in `members/` directory (markdown files)
- Talks and presentations data in `_data/talks.yml`

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
3. Test locally with `bundle exec jekyll serve`
4. Build production assets with `npm run build:js` before committing
5. Commit changes (site auto-deploys via GitHub Pages)

### Firebase View Counter Development
- Firebase config is in both `_config.yml` and hardcoded in `_includes/firebase-config.html`
- Test view counter functionality requires actual page loads (not just Jekyll compilation)
- View counts are stored with cleaned URLs as keys (special chars removed)
- Session storage prevents multiple counts per browser session

## Important Notes

- **Deployment**: Site auto-deploys to GitHub Pages on push to master branch
- **Firebase**: API keys are intentionally public (database has read-only rules)
- **Assets**: JavaScript build process handles minification and banner addition
- **Content**: All paper PDFs and academic materials are version-controlled
- **Theme**: Extends Minimal Mistakes theme - avoid overriding core theme files when possible