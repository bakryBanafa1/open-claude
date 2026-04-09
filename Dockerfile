# =====================================================
# Open-Claude Dockerfile جاهزة
# =====================================================

FROM node:22-slim AS base

# تثبيت المتطلبات
RUN apt-get update && apt-get install -y \
    python3 python3-pip python3-venv \
    curl git jq screen \
    && rm -rf /var/lib/apt/lists/*

# تثبيت uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:$PATH"

# تثبيت Claude Code CLI
RUN npm install -g @anthropic-ai/claude-code

# تثبيت GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update && apt-get install -y gh && rm -rf /var/lib/apt/lists/*

# تثبيت Todoist CLI
RUN npm install -g todoist-ts-cli

# تحديد مجلد العمل
WORKDIR /workspace

# نسخ كل المشروع أولًا
COPY . .

# إنشاء البيئة الافتراضية وتثبيت البايثون dependencies
RUN uv venv .venv && uv sync

# ضبط التوقيت
ENV TZ=America/Sao_Paulo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# مجلدات بيانات دائمة
VOLUME ["/workspace/workspace/daily-logs",
        "/workspace/workspace/projects",
        "/workspace/workspace/community",
        "/workspace/workspace/finance",
        "/workspace/workspace/personal",
        "/workspace/workspace/meetings",
        "/workspace/workspace/strategy",
        "/workspace/memory",
        "/workspace/ADWs/logs",
        "/workspace/.claude/agent-memory"]

# أمر التشغيل الافتراضي
ENTRYPOINT ["uv", "run", "python"]
