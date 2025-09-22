# syntax = docker/dockerfile:1.5

FROM ubuntu:22.04 AS base

# Install many OS-level dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
         build-essential \
         python3 \
         python3-pip \
         nodejs \
         npm \
         openjdk-17-jdk \
         git \
    && rm -rf /var/lib/apt/lists/*

# Create a work dir
WORKDIR /app

# Add many Python dependencies
COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

# Add many Node dependencies
COPY package.json package-lock.json ./
RUN npm install

# Clone some large repositories to include many files / packages
RUN git clone https://github.com/apache/spark.git \
    && git clone https://github.com/kubernetes/kubernetes.git

# Build something from one of those repos (will pull in build tools, etc.)
RUN cd spark && \
    ./build/mvn -DskipTests clean package

# Final stage: reduce image size (optional)
FROM ubuntu:22.04 AS final

WORKDIR /app

# Copy everything from base
COPY --from=base /app /app

CMD ["bash"]
