# PLX Lab Website

The official website for the Programming Languages and eXperience (PLX) Lab at DGIST (Daegu Gyeongbuk Institute of Science and Technology), led by Professor Minseok Jeon.

**Live site:** [https://dgistpl.github.io](https://dgistpl.github.io)

## Overview

This is a Jekyll-based academic website built with the Minimal Mistakes theme, serving as both a research group homepage and academic blog. The site showcases:

- Research publications (PL4SE and PL4ML)
- Lab member profiles and activities
- Academic blog posts and experiences
- Course materials and teaching resources
- Talks and presentations

## Repository Structure

```
.
├── _data/                  # Structured data files
│   ├── authors.yml         # Author information
│   ├── navigation.yml      # Site navigation structure
│   ├── publications.yml    # Research publications
│   └── talks.yml           # Talks and presentations
├── _includes/              # Custom HTML includes
│   ├── firebase-config.html       # Firebase SDK initialization
│   ├── view-counter.html          # View counting logic
│   └── author-profile-post.html   # Enhanced author profile
├── _layouts/               # Page layout templates
├── _posts/                 # Blog posts (YYYY-MM-DD-title.md format)
├── _sass/                  # SCSS stylesheets
├── assets/                 # Static assets
│   ├── js/                 # JavaScript files
│   └── images/             # Images
├── courses/                # Course materials and content
├── cv/                     # LaTeX CV source (main.tex)
├── images/                 # Image assets for posts
├── members/                # Lab member profile pages
├── papers/                 # PDF files (papers and slides)
├── publications/           # Publications section
├── research/               # Research content
├── talks/                  # Talks section
├── _config.yml            # Jekyll configuration
├── Gemfile                # Ruby dependencies
├── package.json           # Node.js dependencies
└── index.md               # Homepage
```

## Quick Start with Docker

The easiest way to run this site locally is using Docker.

### Prerequisites

- [Docker](https://docs.docker.com/get-docker/) installed on your system

### Running with Docker

1. **Clone the repository:**
   ```bash
   git clone https://github.com/dgistpl/dgistpl.github.io.git
   cd dgistpl.github.io
   ```

2. **Build the Docker image:**
   ```bash
   docker build -t dgistpl-jekyll .
   ```

3. **Run the container:**
   ```bash
   docker run -p 4000:4000 -p 35729:35729 -v $(pwd):/site dgistpl-jekyll
   ```

4. **Access the site:**
   Open your browser and navigate to `http://localhost:4000`

### Docker Commands Explained

- `-p 4000:4000` - Maps port 4000 (Jekyll server)
- `-p 35729:35729` - Maps port 35729 (LiveReload)
- `-v $(pwd):/site` - Mounts your local directory into the container for live editing

The site will automatically reload when you make changes to files.

## Native Development Setup

If you prefer to run Jekyll without Docker:

### Prerequisites

- Ruby 3.x
- Node.js 18+
- Bundler (`gem install bundler`)

### Installation

```bash
# Install Ruby dependencies
bundle install

# Install Node.js dependencies
npm install

# Build JavaScript assets
npm run build:js
```

### Running the Development Server

```bash
bundle exec jekyll serve
```

The site will be available at `http://localhost:4000`

### Build Commands

```bash
# Build the site for production
bundle exec jekyll build

# Build and watch JavaScript files
npm run watch:js

# Build JavaScript assets (minify + banner)
npm run build:js
```

## Key Features

### Custom View Counter

The site includes a custom Firebase-based view counter that tracks page views:
- Session-based counting (one view per session)
- Automatic fallback to localStorage if Firebase is unavailable
- Integration with Google Analytics
- Real-time view count display

### Academic Content Management

- **Blog Posts:** Create markdown files in `_posts/` with format `YYYY-MM-DD-title.md`
- **Publications:** Manage in `_data/publications.yml` and display on homepage
- **Courses:** Organize materials by course code in `courses/` directory
- **Member Profiles:** Individual pages in `members/` directory

### JavaScript Build Process

The site uses a build pipeline for JavaScript:
- Minification with UglifyJS
- Banner addition for licensing
- Watch mode for development (`npm run watch:js`)

## LaTeX CV Compilation

The CV is maintained as LaTeX source in the `cv/` directory:

```bash
cd cv/
pdflatex main.tex
```

## Deployment

The site automatically deploys to GitHub Pages when changes are pushed to the `master` branch. No manual deployment steps are required.

### Before Committing

1. Build JavaScript assets: `npm run build:js`
2. Test locally with `bundle exec jekyll serve` or Docker
3. Verify all links and functionality

## Theme

This site uses the [Minimal Mistakes](https://mmistakes.github.io/minimal-mistakes/) Jekyll theme with custom modifications:
- Enhanced author profiles
- Firebase view counter integration
- Custom includes and layouts
- Google Analytics (gtag.js)

## Firebase Configuration

The site uses Firebase Realtime Database for view counting:
- Configuration in `_config.yml` and `_includes/firebase-config.html`
- API keys are public (database has read-only security rules)
- View counts stored with cleaned URLs as keys

## Contributing

When adding new content or features:

1. Create a new branch for your changes
2. Test locally using Docker or native setup
3. Build production JavaScript assets if modified
4. Commit changes with descriptive messages
5. Push to GitHub (auto-deploys to GitHub Pages)

## License

This site uses the Minimal Mistakes theme (MIT License). Please refer to the theme's [license](https://github.com/mmistakes/minimal-mistakes/blob/master/LICENSE) for details.

## Contact

For questions or issues related to this website:
- Visit the [PLX Lab homepage](https://dgistpl.github.io)
- Contact Professor Minseok Jeon

---

Built with Jekyll and the Minimal Mistakes theme.
