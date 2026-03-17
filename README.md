# Zendesk CLI

A command-line tool for browsing and searching Zendesk tickets and Help Center docs.

## Download

Go to [Releases](https://github.com/sorphwer/zendesk-cli-release/releases) and download the latest DMG for your platform.

## Install (macOS)

1. Download the `.dmg` from the latest release
2. Open the DMG and double-click **install.command**
3. Open a **new terminal** window
4. Run `zendesk init` and enter your Zendesk credentials
5. Try `zendesk tickets -n 5`

## What the installer does

- Copies `zendesk` binary to `~/.zendesk-cli/`
- Adds `~/.zendesk-cli` to your PATH (in `~/.zshrc`)
- Copies Cursor Agent Skills to `~/.zendesk-cli/skills/`

## Usage

```bash
zendesk tickets -n 10                     # List recent tickets
zendesk ticket 12345                      # View a single ticket
zendesk tickets --status open             # Filter by status
zendesk tickets --assignee me             # My assigned tickets
zendesk attachment list --ticket 12345    # List attachments
zendesk docs search --query "password"    # Search Help Center
```

## Default output format

The default output is `table` (rich). To change it globally, add to your `~/.zshrc`:

```bash
export ZENDESK_OUTPUT=text    # plain text, good for piping and LLM input
# other options: json, csv
```

Or override per command with `-o`:

```bash
zendesk tickets -n 5 -o json
```

## Platform

| Platform | Status |
|----------|--------|
| macOS arm64 (Apple Silicon) | Available |
| macOS Intel | Not yet |
| Linux x86_64 | Not yet |
| Windows | Not yet |
