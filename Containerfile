FROM ghcr.io/containerpak/base:main

ARG TARGETARCH
ARG CODEX_TAG=rust-v0.155.0
ARG CODEX_SHA256_AMD64=e415cc3adb94ade16e8d44b4dd58a9201cc34b2ee51a5d6eddf2a3a00aecb6c0
ARG CODEX_SHA256_ARM64=8b4a9c356916c515f7c93f918a01b8fa1371bcc9758addbfa723b85fbec5694b

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
