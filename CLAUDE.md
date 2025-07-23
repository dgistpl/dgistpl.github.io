# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is Minseok Jeon's personal academic homepage built with Jekyll using the Minimal Mistakes theme. The site serves as both a portfolio and blog for a research professor at Korea University, showcasing research publications, academic activities, and course materials.

## Development Commands

### Build and Serve
- `bundle exec jekyll serve` - Start development server (standard Jekyll command)
- `bundle exec jekyll build` - Build the site for production

### JavaScript Development  
- `npm run build:js` - Build and minify JavaScript files (runs uglify + add-banner)
- `npm run uglify` - Minify JavaScript assets
- `npm run add-banner` - Add banner to JavaScript files
- `npm run watch:js` - Watch JavaScript files for changes and auto-rebuild

### Dependencies
- `bundle install` - Install Ruby gems (Jekyll dependencies)
- `npm install` - Install Node.js dependencies (for JavaScript build tools)

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
  - Implementation in `_includes/firebase-config.html` and `_includes/view-counter.html`
  - Fallback to localStorage if Firebase unavailable
  - Session-based counting to prevent multiple counts per session

### Key Customizations
- **Author Profile**: Enhanced author profile with post-specific version (`_includes/author-profile-post.html`)
- **View Counter Integration**: Added to page meta information and post layouts
- **Google Analytics**: Configured with gtag.js (tracking ID: G-KTKXXC6BCQ)

### File Organization
- `_includes/`: Custom HTML includes for modular components
- `_layouts/`: Page layout templates (customized default.html)
- `_sass/`: SCSS stylesheets (inherits from Minimal Mistakes)
- `assets/`: Static assets including custom JavaScript and images
- `courses/`: Course-specific content and materials
- `papers/`: PDF files for research papers and slides
- `images/`: Image assets for posts and pages

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
- Research publications listed in `index.md`
- Papers and slides stored in `/papers/` directory
- CV maintained as LaTeX source in `new_cv/` directory

## Theme Integration

This site extends the Minimal Mistakes theme:
- Configuration in `_config.yml` follows MM conventions
- Custom includes override theme defaults
- SCSS customizations in `_sass/` directory
- JavaScript enhancements for Firebase integration

## Important Notes

- The site is designed for GitHub Pages deployment
- Firebase API keys are intentionally public (database has restrictive read/write rules)
- JavaScript build process handles asset minification and banner addition
- All paper PDFs and academic materials are version-controlled