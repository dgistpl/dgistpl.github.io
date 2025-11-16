# Use Ruby base image
FROM ruby:3.2

# Install Node.js and npm
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /site

# Copy Gemfile and package.json first for better caching
COPY Gemfile Gemfile.lock* ./
COPY package.json package-lock.json* ./

# Install Ruby and Node.js dependencies
RUN bundle install
RUN npm install

# Copy the rest of the site
COPY . .

# Build JavaScript assets
RUN npm run build:js

# Expose Jekyll's default port
EXPOSE 4000

# Run Jekyll server
# --host 0.0.0.0 allows access from outside the container
# --livereload enables live reloading on file changes
# --force_polling is needed for file watching in Docker
CMD ["bundle", "exec", "jekyll", "serve", "--host", "0.0.0.0", "--livereload", "--force_polling"]
