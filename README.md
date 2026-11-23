# Clean Language for AI assistants

[Clean Language](https://cleanlanguage.dev) is a type-safe language that compiles to
WebAssembly. This MCP server lets your AI assistant write Clean code correctly: it reads
the language reference and specification, type-checks code and compiles it to WebAssembly.

The compiler is included. Nothing else needs to be installed.

> **Preview.** Clean Language is still young and some syntax will change in the next
> release. The bundle updates automatically when it does.

## Install

**As a plugin** (assistants that support plugin marketplaces):

```
/plugin marketplace add Ivan-Pasco/clean-language-mcp
/plugin install clean-language@clean-language
```

**As an MCP bundle** (apps that open `.mcpb` files): download
[clean-language-mcp.mcpb](https://github.com/Ivan-Pasco/clean-language-mcp/releases/latest/download/clean-language-mcp.mcpb)
and open it.

**With npm** (any MCP client):

```json
{
  "mcpServers": {
    "clean-language": {
      "command": "npx",
      "args": ["-y", "@cleanlanguage/mcp"]
    }
  }
}
```

**From the MCP Registry:** search for `Clean Language`, or use the name
`dev.cleanlanguage/clean-language`.

**Manual setup:** if you already have the Clean toolchain installed, add this to your
MCP configuration:

```json
{
  "mcpServers": {
    "clean-language": {
      "command": "cln",
      "args": ["mcp-server"]
    }
  }
}
```

## Tools

| Tool | What it does |
|------|--------------|
| `get_quick_reference` | Syntax, types and patterns. The assistant calls this first. |
| `get_specification` | Any section of the language specification |
| `check` | Type-check code without compiling |
| `compile` | Compile code to WebAssembly |
| `run` | Compile and validate a program in one step (it does not execute it) |
| `explain_error` | Explain an error code and how to fix it |
| `list_builtins`, `list_types`, `list_functions` | Built-in names and signatures |
| `list_plugins`, `get_plugin_examples` | Framework plugins and examples |

## Platforms

macOS (Apple Silicon and Intel), Linux x86-64, Windows x86-64.

## How this repo works

This repo holds no compiler code. A daily job takes the latest compiler release and
publishes it three ways: as `clean-language-mcp.mcpb` in this repo's releases
(`scripts/build-bundle.sh`), as the npm package `@cleanlanguage/mcp` with one package per
platform (`scripts/build-npm.sh`), and as the MCP Registry entry. It then pins the plugin to
the new npm version.

## Support

Report problems at [github.com/Ivan-Pasco/clean-language-mcp/issues](https://github.com/Ivan-Pasco/clean-language-mcp/issues).

mcp-name: dev.cleanlanguage/clean-language
