# ============================================================
# Dockerfile — OpenClaude Complete Setup
# ============================================================

FROM node:22-slim AS base

# ------------------ System deps ------------------
RUN apt-get update && apt-get install -y \
    python3 python3-pip python3-venv \
    curl git jq screen \
    && rm -rf /var/lib/apt/lists/*

# ------------------ Install uv ------------------
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:$PATH"

# ------------------ Install CLIs ------------------
# Claude Code CLI
RUN npm install -g @anthropic-ai/claude-code

# GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update && apt-get install -y gh && rm -rf /var/lib/apt/lists/*

# Todoist CLI
RUN npm install -g todoist-ts-cli

# ------------------ Workspace ------------------
WORKDIR /workspace

# ------------------ Copy project files ------------------
COPY pyproject.toml uv.lock ./
COPY open-claude/ ./open-claude/

# ------------------ Setup Python environment ------------------
RUN uv venv .venv && uv sync
RUN .venv/bin/pip install -e ./open-claude

# ------------------ Copy remaining workspace ------------------
COPY . .

# ------------------ Timezone ------------------
ENV TZ=America/Sao_Paulo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# ------------------ Volumes ------------------
VOLUME ["/workspace/workspace/daily-logs", \
        "/workspace/workspace/projects", \
        "/workspace/workspace/community", \
        "/workspace/workspace/finance", \
        "/workspace/workspace/personal", \
        "/workspace/workspace/meetings", \
        "/workspace/workspace/strategy", \
        "/workspace/workspace/memory", \
        "/workspace/ADWs/logs", \
        "/workspace/.claude/agent-memory"]

# ------------------ Entrypoint ------------------
ENTRYPOINT ["/workspace/.venv/bin/python", "-m", "open-claude"]
