FROM debian:bullseye-slim

RUN apt-get update && \
    apt-get install -y \
    curl \
    nmap && \
    rm -rf /var/lib/apt/lists/*

# 証明書のインストール
COPY .keys/rootCA.crt /usr/local/share/ca-certificates/
RUN chmod 644 /usr/local/share/ca-certificates/rootCA.crt && \
    update-ca-certificates
