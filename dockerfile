# large-sbom-repo/Dockerfile
FROM debian:12-slim AS base

# Add many OS packages (creates many package entries)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      build-essential curl wget git ca-certificates python3 python3-pip ruby-full nodejs npm \
      libssl-dev libxml2-dev libxslt1-dev zlib1g-dev libpq-dev && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy three ecosystems' dependency manifests to force many SBOM entries
COPY package.json package-lock.json* /app/
COPY requirements.txt /app/
COPY Gemfile Gemfile.lock* /app/

# Install Node deps (creates node_modules at image build-time)
RUN if [ -f package.json ]; then npm install --package-lock --no-audit --no-fund; fi

# Install Python deps
RUN if [ -f requirements.txt ]; then python3 -m pip install --no-cache-dir -r requirements.txt; fi

# Install Ruby deps
RUN if [ -f Gemfile ]; then gem install bundler && bundle install --jobs=4 --retry=3; fi

# Add a small app file
COPY . /app

CMD ["sleep","infinity"]
