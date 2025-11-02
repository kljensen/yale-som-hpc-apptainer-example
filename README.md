# 🚀 AI Coding Assistants on Yale SOM HPC

> Safely run AI coding assistants like Claude Code in autonomous mode inside containerized environments on Yale SOM's High-Performance Computing cluster.

---

## 📋 Table of Contents

- [Overview](#overview)
- [Why Containers?](#why-containers)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Usage](#usage)
  - [Running Claude Code](#running-claude-code)
  - [Available AI Tools](#available-ai-tools)
- [Configuration](#configuration)
  - [Customizing Resource Allocation](#customizing-resource-allocation)
  - [Disabling Home Directory Mount](#disabling-home-directory-mount)
- [What's Inside](#whats-inside)
- [Contributing](#contributing)
- [License](#license)

---

## Overview

This repository provides a pre-configured Apptainer container for Yale SOM HPC users who want to leverage AI coding assistants with full autonomy (`--dangerously-skip-permissions` mode). By running these tools inside an isolated container, you can safely give AI assistants the freedom to modify files, run commands, and perform complex operations without risking your home directory or critical system files.

**The container includes:**
- 🤖 **Claude Code** by Anthropic
- 🐙 **GitHub Copilot CLI**
- 🔮 **Google Gemini CLI**
- 🧠 **OpenAI Codex**
- 🐹 **Go 1.23** (Bookworm-based)
- 🟢 **Node.js LTS** (via nvm)
- 🐍 **Python 3** with `uv` package manager

---

## Why Containers?

Running AI coding assistants in "YOLO mode" (without permission prompts) can dramatically accelerate development, but it comes with risks:

- ⚠️ **File modifications**: AI might inadvertently delete or overwrite important files
- ⚠️ **Command execution**: Autonomous commands could affect your system
- ⚠️ **Configuration changes**: Potential modifications to dotfiles or system configs

**Containers solve this by:**
- ✅ **Isolation**: Work happens in a controlled environment
- ✅ **Reproducibility**: Same environment across all cluster nodes
- ✅ **Safety**: Limit exposure to only the directories you bind-mount
- ✅ **Cleanup**: Simply exit the container to leave no trace

---

## Prerequisites

### 1. Access to Yale SOM HPC

You need an active account on the Yale SOM HPC cluster with access to SLURM.

### 2. Install `just` Command Runner

> **Note:** `just` is like `make`, but better. It's a command runner that simplifies common tasks.

<details>
<summary><b>📦 Installing <code>just</code> in your PATH</b></summary>

<br>

Since you likely don't have root access on the HPC, install `just` to your local user directory:

```bash
# Create a local bin directory if it doesn't exist
mkdir -p ~/.local/bin

# Download the latest just binary
curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to ~/.local/bin

# Add to your PATH (add this to your ~/.bashrc to make it permanent)
export PATH="$HOME/.local/bin:$PATH"

# Verify installation
just --version
```

**Make it permanent:** Add this line to your `~/.bashrc`:
```bash
export PATH="$HOME/.local/bin:$PATH"
```

Then reload your shell:
```bash
source ~/.bashrc
```

For more installation options, see the [just documentation](https://github.com/casey/just#installation).

</details>

---

## Quick Start

```bash
# 1. Clone this repository
git clone https://github.com/kljensen/yale-som-hpc-apptainer-example.git
cd yale-som-hpc-apptainer-example

# 2. Build the container (this takes ~10-15 minutes)
just apptainer build

# 3. Launch an interactive session on a compute node
just apptainer shell-slurm

# 4. Inside the container, run Claude Code in autonomous mode
claude --dangerously-skip-permissions
```

That's it! You're now running Claude Code with full autonomy inside a safe, containerized environment.

---

## Usage

### Running Claude Code

Once inside the container (after `just apptainer shell-slurm`), you can run Claude Code in autonomous mode:

```bash
# Run Claude Code with full autonomy (no permission prompts)
claude --dangerously-skip-permissions

# Or run with a specific prompt
claude --dangerously-skip-permissions "Refactor this Go code to use goroutines"

# Check Claude Code version
claude --version
```

**Why `--dangerously-skip-permissions`?**

This flag disables permission prompts, allowing Claude to:
- Create, modify, and delete files autonomously
- Run shell commands without asking
- Install packages and dependencies
- Make multiple changes in rapid succession

It's "dangerous" on your host system, but **perfectly safe inside this container** where you control what's mounted.

### Available AI Tools

The container includes multiple AI coding assistants. Test them all:

```bash
# GitHub Copilot
gh copilot suggest "write a function to parse CSV"

# OpenAI Codex
codex "generate unit tests for main.go"

# Google Gemini CLI
gemini chat
```

### Working with Your Code

Your current directory is automatically mounted at `/workspace` inside the container:

```bash
# Before entering container
cd ~/my-project

# Enter container
just apptainer shell-slurm

# Inside container - you're in /workspace which maps to ~/my-project
ls  # Shows your project files
claude --dangerously-skip-permissions
```

---

## Configuration

### Customizing Resource Allocation

By default, `shell-slurm` requests **4 CPUs** and **12GB RAM**. Customize this:

```bash
# Request 8 CPUs and 32GB RAM
just apptainer shell-slurm 8 32G

# Request specific partition
just apptainer shell-slurm 4 12G "" gpunormal

# Request specific node
just apptainer shell-slurm 4 12G node042 cpunormal
```

**Available parameters:**
- `CPUS`: Number of CPU cores (default: `4`)
- `MEM`: Memory allocation (default: `12G`)
- `NODE`: Specific node name (default: `""` for auto-select)
- `PARTITION`: SLURM partition (default: `cpunormal`)

### Disabling Home Directory Mount

By default, your home directory (`$HOME`) is mounted inside the container. This allows the AI to access your SSH keys, git config, and other credentials. **If you want maximum isolation**, disable the home mount:

<details>
<summary><b>🔒 Remove Home Directory Access</b></summary>

<br>

Edit `apptainer.just` and remove the `--bind $HOME` line:

**Original (lines 38-42):**
```bash
apptainer shell \
    --bind $PWD:/workspace \
    --bind $HOME \              # ← Remove this line
    --pwd /workspace \
    {{sif_image}}
```

**Modified:**
```bash
apptainer shell \
    --bind $PWD:/workspace \
    --pwd /workspace \
    {{sif_image}}
```

Do the same for the `shell-slurm` command (lines 64-68).

**After this change:**
- ❌ No access to `~/.ssh`, `~/.gitconfig`, or other home directory files
- ❌ Git operations requiring SSH keys won't work
- ✅ Maximum isolation - AI can only affect `/workspace`
- ✅ Your home directory remains completely untouched

**Trade-off:** You may need to configure git inside the container:
```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@yale.edu"
```

</details>

---

## What's Inside

### Development Tools

| Tool | Version | Purpose |
|------|---------|---------|
| Go | 1.23 | Systems programming |
| Node.js | LTS (via nvm) | JavaScript/TypeScript development |
| Python | 3.x | Scripting and data science |
| Git | Latest | Version control |
| uv | 0.9.7 | Fast Python package installer |

### AI Coding Assistants

| Assistant | Package | Description |
|-----------|---------|-------------|
| **Claude Code** | `@anthropic-ai/claude-code` | Anthropic's autonomous coding assistant |
| **GitHub Copilot** | `@github/copilot` | AI pair programmer by GitHub |
| **Gemini CLI** | `@google/gemini-cli` | Google's AI assistant |
| **OpenAI Codex** | `@openai/codex` | OpenAI's code generation model |

### Container Details

- **Base Image**: `golang:1.23-bookworm` (Debian 12)
- **Architecture**: `x86_64`
- **Locale**: `en_US.UTF-8`
- **Working Directory**: `/workspace` (bound to your current directory)

---

## Advanced Usage

### Building Locally (Without SLURM)

```bash
# Build the container on the login node
just apptainer build

# Launch shell without SLURM (for quick tests)
just apptainer shell
```

### Running Commands Directly

```bash
# Run a single command in the container
just apptainer run "go version"

# Run via SLURM with custom resources
just apptainer run-slurm "npm install" 8 16G
```

### Testing the Container

```bash
# Verify all tools are installed correctly
just apptainer test
```

Expected output:
```
Go: go version go1.23.x linux/amd64
Node.js: v20.x.x
npm: 10.x.x
Git: git version 2.39.x
Claude Code: @anthropic-ai/claude-code@x.x.x
...
```

### Inspecting Container Metadata

```bash
# View container labels and environment
just apptainer info
```

---

## Troubleshooting

<details>
<summary><b>Build fails with "fchown" errors</b></summary>

This is a known issue with Apptainer's fakeroot environment. The current container definition includes workarounds (`--no-same-owner` flags) that should prevent this. If you still encounter issues, ensure you're using Apptainer 1.4.1 or later:

```bash
module load apptainer/1.4.1-nkna
```
</details>

<details>
<summary><b>Claude Code says "command not found"</b></summary>

The PATH may not be set correctly. Inside the container, manually source nvm:

```bash
export NVM_DIR="/root/.nvm"
source "$NVM_DIR/nvm.sh"
claude --version
```

If this works, the issue is with the container's `%environment` section. Please open an issue.
</details>

<details>
<summary><b>SLURM job won't start</b></summary>

Check the queue and your resource request:

```bash
squeue -u $USER  # View your jobs
sinfo            # View cluster status
```

Try requesting fewer resources:
```bash
just apptainer shell-slurm 2 8G
```
</details>

---

## Contributing

Contributions are welcome! If you'd like to:

- 🐛 Report bugs
- 💡 Suggest new features
- 🔧 Submit improvements to the container definition
- 📖 Improve documentation

Please open an issue or pull request on GitHub.

---

## License

This project is provided as-is for educational and research purposes at Yale SOM. Feel free to adapt and modify for your needs.

**Author**: [Kyle Jensen](https://github.com/kljensen)
**Institution**: Yale School of Management

---

## Acknowledgments

- Built with [Apptainer](https://apptainer.org/) (formerly Singularity)
- Task automation powered by [just](https://github.com/casey/just)
- AI tools by Anthropic, GitHub, Google, and OpenAI
- Container base image from the official [Go Docker images](https://hub.docker.com/_/golang)

---

**Happy coding with AI! 🤖✨**

For questions or support, contact Yale SOM HPC support or open an issue on this repository.
