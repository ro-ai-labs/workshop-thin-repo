# itss-plugins

Internal Claude Code plugin marketplace owned by **ITSS**. Houses workflow plugins the team relies on for common engineering tasks.

## Plugins

| Plugin | Purpose |
|--------|---------|
| [`architecture-html`](./plugins/architecture-html) | Generate a self-contained interactive HTML architecture page for any repo, with clickable `file://` links to actual source files at `file:line` precision. Maps the agent loop, tools, permissions, sandbox, plugins, MCP, memory, subagents, and any additional agentic-runtime primitives the codebase implements. |

## Installation

### 1 - register the marketplace

In any Claude Code session:

```
/plugin marketplace add ~/workshop/itss-plugins
```

Or from a Git source once this repo is published:

```
/plugin marketplace add itss/itss-plugins
```

Claude Code reads `.claude-plugin-marketplace.json` at the marketplace root to discover available plugins.

### 2 - install a plugin

```
/plugin install architecture-html@itss-plugins
```

That pulls the plugin's `skills/`, `agents/`, `hooks/`, and `commands/` (where applicable) into your session.

### 3 - verify

```
/plugin list
```

You should see `architecture-html` enabled. The skill is now discoverable when you ask Claude to "generate an architecture HTML" or "map this repo's architecture".

## Usage

After install, just ask:

> Generate an interactive HTML architecture page for this repo.

…or invoke the skill explicitly. The skill will:

1. Survey the repo's top-level layout, README, and primary manifest.
2. Dispatch parallel Explore subagents (one per agentic-runtime primitive).
3. Verify every cited file/line exists on disk.
4. Write `./demo-examples/<repo>-architecture.html` - a single self-contained HTML file with embedded CSS, no external dependencies.
5. Walk every `file://` link in the output and report the resolve rate.

Open the result by double-clicking it (or `xdg-open` / `open`).

> **Browser caveat.** Chrome and Edge block `file://`-to-`file://` link clicks by default. To clickthrough to the cited source files, launch with:
> ```bash
> google-chrome --allow-file-access-from-files --user-data-dir=/tmp/arch-profile path/to/<repo>-architecture.html
> ```
> Firefox and Safari follow `file://` links to local files without flags.

## Marketplace structure

```
itss-plugins/
├── .claude-plugin-marketplace.json   # marketplace manifest
├── README.md                          # this file
└── plugins/
    └── architecture-html/
        ├── .claude-plugin/
        │   └── plugin.json            # plugin manifest
        └── skills/
            └── architecture-html/
                └── SKILL.md           # the live prompt, wrapped as a skill
```

## Contributing

To add a new plugin:

1. Create `plugins/<name>/` with `.claude-plugin/plugin.json`.
2. Add components under `plugins/<name>/skills/`, `agents/`, `hooks/`, `commands/`, or `.mcp.json` as needed.
3. Register the plugin in `.claude-plugin-marketplace.json` under the `plugins` array.
4. Open a PR.

See the [Claude Code plugin docs](https://docs.claude.com/en/docs/claude-code/plugins) for component schemas.

## License

Internal - ITSS use only.
