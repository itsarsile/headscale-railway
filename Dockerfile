# Use a temporary stage to prepare the configuration
FROM debian:bookworm-slim AS preparer

# Install sed
RUN apt-get update && apt-get install -y sed && rm -rf /var/lib/apt/lists/*

# Copy the local configuration
COPY ./headscale_data/config.yml /etc/headscale/config.yaml

# Adjust the listen addresses to 0.0.0.0 so they are accessible within Railway
RUN sed -i 's/listen_addr: 127.0.0.1:8080/listen_addr: 0.0.0.0:8080/g' /etc/headscale/config.yaml && \
    sed -i 's/metrics_listen_addr: 127.0.0.1:9090/metrics_listen_addr: 0.0.0.0:9090/g' /etc/headscale/config.yaml && \
    sed -i 's/grpc_listen_addr: 127.0.0.1:50443/grpc_listen_addr: 0.0.0.0:50443/g' /etc/headscale/config.yaml

# Final stage
FROM debian:bookworm-slim

# Install dependencies
RUN apt-get update && apt-get install -y ca-certificates curl && rm -rf /var/lib/apt/lists/*

# Copy the headscale binary from the official image
COPY --from=headscale/headscale:0.28.0 /ko-app/headscale /usr/local/bin/headscale

# Copy the prepared configuration
COPY --from=preparer /etc/headscale/config.yaml /etc/headscale/config.yaml

# Copy initial data for seeding the volume
COPY ./headscale_data /tmp/headscale_data

# Copy and prepare the startup script
COPY start.sh /usr/local/bin/start.sh
RUN apt-get update && apt-get install -y dos2unix && dos2unix /usr/local/bin/start.sh && apt-get purge -y dos2unix && rm -rf /var/lib/apt/lists/*
RUN chmod +x /usr/local/bin/start.sh

# Expose the main port
EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/start.sh"]
CMD ["serve", "-c", "/etc/headscale/config.yaml"]
