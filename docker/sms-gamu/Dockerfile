FROM debian:13.7-slim
RUN apt-get update && apt-get install -y --no-install-recommends gammu python3-gammu \
    && rm -rf /var/lib/apt/lists/*
ENTRYPOINT ["gammu"]
CMD ["--help"]
