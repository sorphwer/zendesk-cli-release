# Zendesk CLI

A command-line tool for browsing and searching Zendesk tickets and Help Center docs.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/sorphwer/zendesk-cli-release/main/install.sh | sh
```

This auto-detects your OS (macOS / Linux), downloads the latest release, and installs to `~/.zendesk-cli/`.

After install, open a **new terminal** and run:

```bash
zendesk init       # Enter your Zendesk credentials
zendesk tickets -n 5   # Verify it works
```

## Usage

```bash
zendesk tickets -n 10                     # List recent tickets
zendesk ticket 12345                      # View a single ticket
zendesk tickets --status open             # Filter by status
zendesk tickets --assignee me             # My assigned tickets
zendesk attachment list --ticket 12345    # List attachments
zendesk docs search --query "password"    # Search Help Center
```

## Output format

Default is `table` (rich). Change globally:

```bash
zendesk set-env ZENDESK_OUTPUT text    # plain text, good for piping and LLM input
```

Or override per command: `zendesk tickets -n 5 -o json`

## Platform

| Asset | Platform |
|-------|----------|
| `zendesk-cli-*-macos-arm64.dmg` | macOS Apple Silicon (Intel via Rosetta 2) |
| `zendesk-cli-*-linux-amd64.tar.gz` | Linux x86_64 |

Python is **not** required.
