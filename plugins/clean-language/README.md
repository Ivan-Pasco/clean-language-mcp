# Clean Language

Helps your AI assistant write correct [Clean Language](https://cleanlanguage.dev) code.
Clean Language is a type-safe programming language that compiles to WebAssembly, with
JavaScript-like readability and Rust-like safety.

## What it adds

- **A skill** that tells the assistant to load the Clean syntax reference before writing
  code, look up the specification when unsure, and type-check every piece of code before
  showing it.
- **The Clean Language MCP server**, with tools to read the language reference and
  specification, list built-in functions and types, type-check code, explain error codes
  and compile code to WebAssembly.

## What it runs and fetches

The MCP server is the Clean Language compiler (`cln mcp-server`), started through the
npm package [`@cleanlanguage/mcp`](https://www.npmjs.com/package/@cleanlanguage/mcp),
pinned to an exact version. On first start, npm downloads that package and the compiler
build for your computer (macOS arm64/x64, Linux x64 or Windows x64) from the npm registry.

The server works only on your computer, over standard input and output. It reads the code
you give it and the Clean project files in your workspace. It makes no network requests
and sends no data anywhere.

## Source

Compiler: [github.com/Ivan-Pasco/clean-language-compiler-old](https://github.com/Ivan-Pasco/clean-language-compiler-old).
Packaging: [github.com/Ivan-Pasco/clean-language-mcp](https://github.com/Ivan-Pasco/clean-language-mcp).
License: MIT.
