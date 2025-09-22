# intentionally-vulnerable Dockerfile
FROM debian:10 as builder

# purposefully use older packages (Debian 10/buster) and pin old versions
ENV LANG=C.UTF-8

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      curl=7.64.0-4 \
      git=1:2.20.1-2+deb10u3 \
      python3=3.7.3-1 \
      python3-pip=18.1-5 \
      nodejs=10.19.0~dfsg-3 \
      npm=6.9.0~dfsg-3 \
      openssh-client=1:7.9p1-10+deb10u2 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Add a small Python project with pinned (old) packages
COPY requirements.txt /app/requirements.txt
RUN pip3 --no-cache-dir install -r /app/requirements.txt

# Add a JS project with older deps
COPY package.json package-lock.json /app/
RUN npm ci --no-audit --no-fund

# Copy a simple vulnerable web app (no exploits — just sample code)
COPY webapp /app/webapp

# Final image (keep all build artifacts so SBOM includes them)
FROM debian:10
COPY --from=builder /app /app
WORKDIR /app
EXPOSE 8080
CMD ["python3", "/app/webapp/app.py"]
