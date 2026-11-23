---
name: clean-language
description: Use when writing, reading, fixing or explaining Clean Language code (.cln files, package.clean.toml), or when the user asks about the Clean programming language.
---

# Writing Clean Language

Clean Language is a type-safe language that compiles to WebAssembly. Its syntax is
its own: do not write it from memory or from what JavaScript, Python or Rust would do.

1. Before writing any Clean code, call the `get_quick_reference` tool from the
   `clean-language` MCP server. It returns the exact syntax rules.
2. For a detail the quick reference does not cover, call `get_specification`
   with the topic, or `list_builtins` / `list_types` for built-in names.
3. Run `check` on every piece of code you write before showing it. Fix every
   error it reports; use `explain_error` when an error code is unclear.
4. Use `compile` to produce WebAssembly and `run` to execute a program and see
   its output.

The language website is https://cleanlanguage.dev.
