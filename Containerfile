FROM ghcr.io/containerpak/base:main

ARG TARGETARCH
ARG CODEX_TAG=rust-v0.150.1
ARG CODEX_SHA256_AMD64=ab308870bc7fc048c23dc49d03f6b8af9ce7fc99b9da882d6688be7a90155c7a
ARG CODEX_SHA256_ARM64=5bb1f75e1a1588845b4a31f2c98fb2b394be5c2a8d90a24a8ab0ebbae1169264

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
