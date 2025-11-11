# 🚀 AI Coding Assistants on Yale SOM HPC

This repo shows how to safely run AI coding assistants like Claude
Code in autonomous mode inside containerized environments on Yale SOM's
High-Performance Computing cluster.

Why should you run those assistants in containers? Because they're dangerous!
If you don't run them inside containers they can, to a first approximation, do
anything that _you_ can do on your system. If you want to do that on your laptop,
_fine_. On the shared HPC, the blast radius for AI misstep is a lot bigger.
Imagine, e.g. your AI buddy doing `rm -rf` on some shared data. That's the
fast path to not having collaborators! 😉 A container is basically a
sandbox that the AI cannot escape. You can lock it down so the damage is
limited if it does something silly.

The Yale SOM HPC and the central campus HPC both use [Apptainer](https://apptainer.org/),
which is slightly different than docker/podman/OCI containers. You can
see an example container definition at [./dev/bookworm.def](./dev/bookworm.def).
You can see we're starting from a Debian base and installing all sorts of useful
stuff including a variety of code assistants:

-  **Claude Code** by Anthropic
-  **GitHub Copilot CLI**
-  **Google Gemini CLI**
-  **OpenAI Codex**
-  **Go 1.23** (Bookworm-based)
-  **Node.js LTS** (via nvm)
-  **Python 3** with `uv` package manager

You can have AI adjust that container definition to fit your needs.


## Quick Start

```bash
# 1. Clone this repository
git clone https://github.com/kljensen/yale-som-hpc-apptainer-example.git
cd yale-som-hpc-apptainer-example

# 2. Build the container (this takes ~10-15 minutes)
./container.sh build

# 3. Launch an interactive session on a compute node
./container.sh shell

# 4. Inside the container, run Claude Code in autonomous mode
claude --dangerously-skip-permissions
```

That's it! You're now running Claude Code with full autonomy inside a safe,
containerized environment. Yolo!

