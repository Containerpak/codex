FROM ubuntu:26.04

COPY cpak-apt.conf /etc/apt/apt.conf.d/90cpak
COPY --chmod=0755 cpak-clean-junk /usr/bin/cpak-clean-junk

ARG TARGETARCH
ARG CODEX_TAG=rust-v0.148.0
ARG CODEX_SHA256_AMD64=1a36f762f6b3bef533bb86345ad9517661c2d84d53996a250cf2ca89d2cfee5a
ARG CODEX_SHA256_ARM64=410c6ae0c763eb39c6da17665e63f9aa4a98e6ee663d81f8e8b779c97cb175ac

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
