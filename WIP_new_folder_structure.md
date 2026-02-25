📦.devcontainer (instructions)

📦.pnpm-store (openclaw pnpm packages)

📦openclaw_data
 ┗ 📂.openclaw                         ← Root config & state dir (equivalent to ~/.openclaw)
 ┃ ┣ 📂agents                          ← All agent instances live here
 ┃ ┃ ┗ 📂main                          ← Your default agent (named "main")
 ┃ ┃ ┃ ┣ 📂agent                       ← Agent runtime config & credentials
 ┃ ┃ ┃ ┃ ┣ 📜auth.json                 ← Auth tokens for connected platforms (Slack, Telegram, etc.)
 ┃ ┃ ┃ ┃ ┗ 📜models.json               ← Which LLMs this agent uses (Claude, GPT-4, Ollama, etc.)
 ┃ ┃ ┃ ┗ 📂sessions                    ← Conversation history
 ┃ ┃ ┃ ┃ ┣ 📜3c681c13-...26.jsonl      ← A single session's message log (one file per session)
 ┃ ┃ ┃ ┃ ┗ 📜sessions.json             ← Index/manifest of all sessions
 ┃ ┣ 📂canvas                          ← Web UI served by the Gateway daemon
 ┃ ┃ ┗ 📜index.html                    ← The local browser interface for OpenClaw
 ┃ ┣ 📂completions                     ← Shell tab-completion scripts
 ┃ ┃ ┣ 📜openclaw.bash                 ← Bash completions
 ┃ ┃ ┣ 📜openclaw.fish                 ← Fish completions
 ┃ ┃ ┣ 📜openclaw.ps1                  ← PowerShell completions
 ┃ ┃ ┗ 📜openclaw.zsh                  ← Zsh completions
 ┃ ┣ 📂cron                            ← Scheduled autonomous jobs (distinct from heartbeats)
 ┃ ┃ ┣ 📜jobs.json                     ← Active cron job definitions
 ┃ ┃ ┗ 📜jobs.json.bak                 ← Auto-backup of jobs before last edit
 ┃ ┣ 📂devices                         ← Device pairing for messaging platforms
 ┃ ┃ ┣ 📜paired.json                   ← Successfully paired devices (phones, bots, etc.)
 ┃ ┃ ┗ 📜pending.json                  ← Devices awaiting pairing confirmation
 ┃ ┣ 📂identity                        ← This installation's unique identity
 ┃ ┃ ┗ 📜device.json                   ← Device ID, keys, registration metadata
 ┃ ┣ 📂logs                            ← Audit & diagnostic logs
 ┃ ┃ ┗ 📜config-audit.jsonl            ← Append-only log of every config change (who/what/when)
 ┃ ┣ 📂workspace                       ← The agent's "home folder" — everything it reads & writes
 ┃ ┃ ┣ 📂.git                          ← Git repo — workspace is version-controlled by default
 ┃ ┃ ┃ ┣ 📂branches
 ┃ ┃ ┃ ┣ 📂hooks                       ← Standard Git hooks (all samples, none active yet)
 ┃ ┃ ┃ ┣ 📂info
 ┃ ┃ ┃ ┃ ┗ 📜exclude                   ← Workspace-local .gitignore
 ┃ ┃ ┃ ┣ 📂objects                     ← Git object store
 ┃ ┃ ┃ ┣ 📂refs
 ┃ ┃ ┃ ┣ 📜HEAD
 ┃ ┃ ┃ ┣ 📜config
 ┃ ┃ ┃ ┗ 📜description
 ┃ ┃ ┣ 📂.openclaw                     ← Workspace-level runtime state (separate from root .openclaw)
 ┃ ┃ ┃ ┗ 📜workspace-state.json        ← Tracks task progress so agent can resume after restart
 ┃ ┃ ┣ 📂.pi                           ← Prompt Injection guard folder (stores sanitization rules/logs)
 ┃ ┃ ┣ 📜AGENTS.md                     ← Core instructions loaded every session — the agent's rulebook
 ┃ ┃ ┣ 📜BOOTSTRAP.md                  ← First-run "birth certificate"; onboarding instructions
 ┃ ┃ ┣ 📜HEARTBEAT.md                  ← Proactive checklist the agent reads every ~30 min autonomously
 ┃ ┃ ┣ 📜IDENTITY.md                   ← The agent's name, role, and self-concept
 ┃ ┃ ┣ 📜MEMORY.md                     ← Long-term curated memory — facts that persist across all sessions
 ┃ ┃ ┣ 📜SOUL.md                       ← Personality, tone, communication style — "who" the agent is
 ┃ ┃ ┣ 📜TOOLS.md                      ← Notes on available tools/integrations (user-editable reference)
 ┃ ┃ ┗ 📜USER.md                       ← Profile of you — your preferences, context, how you like to work
 ┃ ┣ 📜.env                            ← API keys & secrets — never commit this (chmod 600)
 ┃ ┣ 📜openclaw.json                   ← Main config file (models, heartbeat interval, platform settings)
 ┃ ┣ 📜openclaw.json.bak               ← Auto-backup before last config change
 ┃ ┣ 📜openclaw.json.bak.1             ← One-older backup (rolling)
 ┃ ┗ 📜update-check.json               ← Tracks last version check so it doesn't ping on every run

 📦openclaw_install
 ┣ 📂.agent/workflows        ← CI-style automation workflows for the agent itself (pnpm tasks, etc.)
 ┣ 📂.agents                 ← Maintainer-curated skills definitions (recently moved from /skills)
 ┣ 📂.github                 ← GitHub Actions CI/CD pipelines (lint, test, skills-python job, etc.)
 ┣ 📂.pi                     ← Prompt Injection defense rules & guidance (also mirrored into workspace)
 ┣ 📂.vscode                 ← VS Code workspace settings (Oxlint/Oxfmt integration, recommended extensions)
 ┣ 📂Swabble                 ← Legacy name remnant — pre-rename artefact (was the old project name)
 ┣ 📂apps                    ← Platform-specific app bundles (Android UI, iOS, etc.)
 ┣ 📂assets                  ← Static assets (browser relay, icons, shared test fixtures)
 ┣ 📂docs                    ← User-facing documentation source
 ┣ 📂extensions              ← Browser/platform extensions (Matrix, etc.)
 ┣ 📂git-hooks               ← Git hooks installed into the repo (pre-commit guards, etc.)
 ┣ 📂packages                ← Internal shared packages (monorepo libs consumed by apps/src)
 ┣ 📂patches                 ← Patches applied to vendored deps at install time (e.g. mac model catalog fix)
 ┣ 📂scripts                 ← Dev tooling scripts (release helpers, changelog, etc.)
 ┣ 📂skills                  ← Built-in skills shipped with OpenClaw (SKILL.md files, Python scripts)
 ┣ 📂src                     ← Core source code (gateway daemon, sandbox, agent runtime)
 ┣ 📂test                    ← Test suites (unit, e2e, live)
 ┣ 📂ui                      ← Frontend UI source (the canvas/web interface)
 ┣ 📂vendor/a2ui             ← Vendored a2ui renderer (kept in-tree for typings alignment)
 ┃
 ┣ 📜AGENTS.md               ← Instructions for AI agents working ON this repo (meta-level)
 ┣ 📜CHANGELOG.md            ← Release history
 ┣ 📜CLAUDE.md               ← Symlink or alias to AGENTS.md for Claude-specific tooling
 ┣ 📜CONTRIBUTING.md         ← Contributor guide (maintainers list, PR process)
 ┣ 📜VISION.md               ← Product philosophy and scope guardrails for contributors
 ┣ 📜PR_STATUS.md            ← Live status board for open PRs and their CI state
 ┣ 📜SECURITY.md             ← Security policy and responsible disclosure
 ┃
 ┣ 📜Dockerfile              ← Main production image (includes Playwright Chromium)
 ┣ 📜Dockerfile.sandbox      ← Sandboxed agent execution environment (pinned SHA digests)
 ┣ 📜Dockerfile.sandbox-browser ← Browser-capable sandbox variant
 ┣ 📜Dockerfile.sandbox-common  ← Shared base layer for sandbox images
 ┣ 📜docker-compose.yml      ← Local dev stack (gateway + sandbox + UI wired together)
 ┣ 📜docker-setup.sh         ← Bootstrap script for first-time Docker setup
 ┃
 ┣ 📜openclaw.mjs            ← Entry point / CLI launcher (Node.js ESM)
 ┣ 📜openclaw.podman.env     ← Podman-specific env overrides (alternative to Docker)
 ┣ 📜setup-podman.sh         ← First-time Podman setup script
 ┃
 ┣ 📜.env.example            ← Template for your .env (API keys, provider config)
 ┣ 📜.dockerignore           ← Files excluded from Docker build context
 ┣ 📜.gitignore
 ┣ 📜.gitattributes          ← Git line-ending and diff rules
 ┣ 📜.mailmap                ← Normalizes contributor names/emails in git log
 ┣ 📜.detect-secrets.cfg     ← Config for secrets scanning in pre-commit hooks
 ┣ 📜.secrets.baseline       ← Known-safe secrets baseline (prevents false positives)
 ┣ 📜.pre-commit-config.yaml ← Pre-commit hook definitions (security, lint, format)
 ┣ 📜.shellcheckrc           ← Shell script linting config
 ┃
 ┣ 📜.oxlintrc.json          ← Oxlint (JS/TS linter) config
 ┣ 📜.oxfmtrc.jsonc          ← Oxfmt (JS/TS formatter) config
 ┣ 📜.markdownlint-cli2.jsonc ← Markdown linting rules
 ┣ 📜.swiftformat            ← Swift formatter config (iOS app)
 ┣ 📜.swiftlint.yml          ← Swift linter config (iOS app)
 ┃
 ┣ 📜package.json            ← Root monorepo package manifest
 ┣ 📜pnpm-lock.yaml          ← Lockfile (pnpm is the package manager)
 ┣ 📜pnpm-workspace.yaml     ← Monorepo workspace package paths
 ┣ 📜pyproject.toml          ← Python tooling config (for skills scripts linting/testing)
 ┣ 📜tsconfig.json           ← Root TypeScript config
 ┣ 📜tsconfig.plugin-sdk.dts.json ← DTS generation config for the plugin SDK
 ┣ 📜tsdown.config.ts        ← Build bundler config (tsdown)
 ┃
 ┣ 📜vitest.config.ts        ← Root Vitest config
 ┣ 📜vitest.e2e.config.ts    ← End-to-end test config
 ┣ 📜vitest.extensions.config.ts ← Extensions-specific test config
 ┣ 📜vitest.gateway.config.ts ← Gateway daemon test config
 ┣ 📜vitest.live.config.ts   ← Live/integration test config
 ┣ 📜vitest.unit.config.ts   ← Unit test config
 ┃
 ┣ 📜appcast.xml             ← Sparkle auto-update feed (macOS app updates)
 ┣ 📜fly.toml                ← Fly.io deployment config (public relay/gateway)
 ┣ 📜fly.private.toml        ← Fly.io config for private/self-hosted deployments
 ┣ 📜render.yaml             ← Render.com deployment config
 ┣ 📜docs.acp.md             ← ACP (Agent Communication Protocol) documentation
 ┣ 📜zizmor.yml              ← Zizmor GitHub Actions security audit config
 ┗ 📜LICENSE

📦projetos 

📦.env

.gitattributes

.gitignore

LICENSE

README.md