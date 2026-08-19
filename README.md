# Codex

OpenAI's coding agent for the terminal, packaged as a cpak.

## Why it does not update itself

The package is what carries a new version. An installation that rewrites its
own binary is one the integrity ledger no longer answers for, and the agent is
the most privileged thing on a development machine.

A scheduled job follows the published release, moves the pinned tag and
checksum, and that is what rebuilds the image. `cpak update` brings it over.

## Toolchains

Every cpak SDK is offered as an addon, so the machine's owner decides which
ones come along:

```bash
cpak addon list github.com/containerpak/codex
cpak addon enable github.com/containerpak/codex github.com/containerpak/sdk-scm
```
