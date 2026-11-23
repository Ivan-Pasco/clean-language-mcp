#!/usr/bin/env node
// Starts the Clean Language MCP server (`cln mcp-server`) over stdio.
// The compiler binary comes from the platform package npm installed next to
// this one (@cleanlanguage/mcp-<os>-<cpu>); nothing is downloaded at run time.
"use strict";

const { spawn } = require("node:child_process");
const path = require("node:path");

const platformPackage = `@cleanlanguage/mcp-${process.platform}-${process.arch}`;
const binaryName = process.platform === "win32" ? "cln.exe" : "cln";

let binary;
try {
  binary = path.join(path.dirname(require.resolve(`${platformPackage}/package.json`)), "bin", binaryName);
} catch {
  console.error(
    `Clean Language MCP: no compiler build for ${process.platform}-${process.arch}.\n` +
      "Supported: macOS (arm64, x64), Linux x64, Windows x64.\n" +
      "If you installed with --no-optional, reinstall without it."
  );
  process.exit(1);
}

const child = spawn(binary, ["mcp-server", ...process.argv.slice(2)], { stdio: "inherit" });

for (const signal of ["SIGINT", "SIGTERM", "SIGHUP"]) {
  process.on(signal, () => child.kill(signal));
}

child.on("error", (err) => {
  console.error(`Clean Language MCP: could not start ${binary}: ${err.message}`);
  process.exit(1);
});

child.on("exit", (code, signal) => {
  if (signal) {
    process.kill(process.pid, signal);
  } else {
    process.exit(code ?? 0);
  }
});
