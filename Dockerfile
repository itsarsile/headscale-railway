FROM debian:bookworm-slim

# Install dependencies
RUN apt-get update && apt-get install -y ca-certificates curl && rm -rf /var/lib/apt/lists/*

# Copy the headscale binary from the official image
COPY --from=headscale/headscale:0.28.0 /ko-app/headscale /usr/local/bin/headscale

# Copy the local configuration directly (Ensure your config.yaml uses listen_addr: :8080)
COPY ./headscale_data/config.yml /etc/headscale/config.yaml

# Copy initial data for seeding the volume
COPY ./headscale_data /tmp/headscale_data

# Copy and prepare the startup script
COPY start.sh /usr/local/bin/start.sh
RUN apt-get update && apt-get install -y dos2unix && dos2unix /usr/local/bin/start.sh && apt-get purge -y dos2unix && rm -rf /var/lib/apt/lists/*
RUN chmod +x /usr/local/bin/start.sh

# Force root execution so your start.sh can write permissions to the Railway Volume
USER root

# Expose the main port
EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/start.sh"]
CMD ["serve", "-c", "/etc/headscale/config.yaml"]