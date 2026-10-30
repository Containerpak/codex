FROM ghcr.io/containerpak/base:main

ARG TARGETARCH
ARG CODEX_TAG=rust-v0.166.0
ARG CODEX_SHA256_AMD64=a0bf572d2f93f056c6712a6da348e96078dc84f3885fd7be67807ef389cb3978
ARG CODEX_SHA256_ARM64=94eb707605ec2646b2e05b7edf7c4e7b3ccf02b16237c34ae9beb8cfb7f810a9

RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates curl && \
    case "$TARGETARCH" in \
        amd64) target=x86_64-unknown-linux-musl; checksum="$CODEX_SHA256_AMD64" ;; \
        arm64) target=aarch64-unknown-linux-musl; checksum="$CODEX_SHA256_ARM64" ;; \
        *) echo "unsupported architecture: $TARGETARCH" >&2; exit 1 ;; \
    esac && \
    curl -fsSLo /tmp/codex.tar.gz \
        "https://github.com/openai/codex/releases/download/${CODEX_TAG}/codex-${target}.tar.gz" && \
    echo "${checksum}  /tmp/codex.tar.gz" | sha256sum -c - && \
    tar -C /tmp -xzf /tmp/codex.tar.gz && \
    install -m0755 "/tmp/codex-${target}" /usr/bin/codex && \
    rm -rf /tmp/codex.tar.gz "/tmp/codex-${target}" && \
    cpak-clean-junk

# The package is what gets updated. A tool that replaces its own binary is one
# the integrity ledger no longer answers for.
ENV CODEX_DISABLE_UPDATE_CHECK=1

RUN /usr/bin/codex --version
