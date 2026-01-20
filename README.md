# 🚀 Agent Marketplace

A curated collection of AI agents for the CrewDeck Agent Marketplace. Connect this repository to instantly access specialized development agents across all your projects.

## Quick Start

1. **Connect to CrewDeck**: Add this repository as a "Marketplace" type in CrewDeck settings
2. **Browse Agents**: View all available agents in the Marketplace tab
3. **Use Agents**: Invoke agents directly in your projects

---

## 📦 Available Agents

### Testing & Quality (10 agents)

| Agent | Description |
|-------|-------------|
| **code-reviewer** | Performs thorough code reviews focusing on security, performance, and best practices |
| **code-debugger** | Systematic bug diagnosis with root cause analysis and resolution |
| **code-standards-enforcer** | Enforces coding standards, style guides, and architectural patterns |
| **coverage-orchestrator** | Orchestrates code coverage campaigns across frontend and backend |
| **review-pr** | Comprehensive PR code review for quality, bugs, performance, and security |
| **analyze-root-cause** | Deep diagnostic analysis to identify root causes of bugs |
| **fix-bug** | Orchestrated bug investigation and resolution with specialized agents |
| **increase-coverage** | Systematic test coverage increase with parallel execution |
| **bugfix-orchestrator** | Master orchestrator for multi-domain bug investigation |
| **webapp-testing** | Playwright toolkit for testing local web applications |

### Development (6 agents)

| Agent | Description |
|-------|-------------|
| **build-feature** | Full-stack feature development with orchestrated agents |
| **feature-orchestrator** | Coordinates specialized agents for feature implementation |
| **code-refactor** | Systematic refactoring for structure, performance, and maintainability |
| **improve-code** | Evaluates codebase for modularity, patterns, and best practices |
| **split-feature** | Decomposes large features into parallelizable tasks |
| **modernize-code** | Updates code to use modern patterns and best practices |

### DevOps & Automation (5 agents)

| Agent | Description |
|-------|-------------|
| **create-pr** | Prepares branches for PR with quality checks and automation |
| **fix-github-issue** | Interactive GitHub issue fixing with clarification workflow |
| **fix-github-issue-direct** | Direct GitHub issue fixing with automated PR creation |
| **improve-pr** | Addresses PR feedback and implements review suggestions |
| **parallel-development** | Multi-feature development using Git worktrees |

### Documentation (3 agents)

| Agent | Description |
|-------|-------------|
| **code-documenter** | Creates comprehensive technical documentation and API docs |
| **init-agent** | Initializes AGENTS.md and CLAUDE.md for new projects |
| **sync-docs** | Automatically synchronizes documentation with codebase |

### Backend Development (3 agents)

| Agent | Description |
|-------|-------------|
| **backend-developer** | Develops robust backend systems with scalability and security |
| **api-developer** | Designs developer-friendly APIs with proper documentation |
| **typescript-developer** | Builds type-safe applications with advanced TypeScript |

### AI & Integration (3 agents)

| Agent | Description |
|-------|-------------|
| **refine-prompt** | Enriches AI prompts with project context |
| **skill-creator** | Guide for creating skills that extend Claude's capabilities |
| **mcp-builder** | Creates MCP servers for LLM-external service integration |

### Infrastructure (2 agents)

| Agent | Description |
|-------|-------------|
| **systems-architect** | Evidence-based system design and architectural decisions |
| **aws-consult** | Expert AWS architecture guidance and solutions |

### Specialized (3 agents)

| Agent | Description |
|-------|-------------|
| **code-security-auditor** | Comprehensive security analysis and vulnerability detection |
| **frontend-developer** | Modern, responsive frontend development with React/Vue |
| **database-designer** | Optimal database schemas, indexes, and query optimization |

---

## 📁 Repository Structure

```
agents/
├── {agent-name}/
│   ├── manifest.json      # Agent metadata (required)
│   ├── {agent-name}.md    # Agent definition
│   └── [resources/]       # Optional scripts, references, assets
└── ...

.claude/                   # Original structure (preserved)
├── agents/
├── commands/
└── skills/
```

### Manifest Format

Each agent has a `manifest.json` with this structure:

```json
{
  "name": "agent-name",
  "displayName": "Human Readable Name",
  "description": "What this agent does...",
  "author": "CloudNNJ",
  "category": "testing",
  "tags": ["tag1", "tag2"],
  "version": "1.0.0",
  "config": {
    "model": "claude-sonnet-4-20250514"
  },
  "agentFile": "agent-name.md"
}
```

---

## 🔧 Adding New Agents

1. **Create agent folder**:
   ```bash
   mkdir -p agents/my-new-agent
   ```

2. **Create manifest.json**:
   ```json
   {
     "name": "my-new-agent",
     "displayName": "My New Agent",
     "description": "Description of what the agent does",
     "author": "Your Name",
     "category": "general",
     "tags": ["relevant", "tags"],
     "version": "1.0.0",
     "agentFile": "my-new-agent.md"
   }
   ```

3. **Create agent definition** (`my-new-agent.md`):
   ```markdown
   ---
   name: my-new-agent
   description: Agent description
   model: sonnet
   ---
   
   You are an expert in...
   
   ## Capabilities
   - Capability 1
   - Capability 2
   ```

4. **Commit and push**:
   ```bash
   git add agents/my-new-agent
   git commit -m "feat: add my-new-agent"
   git push
   ```

### Validation Rules

- ✅ `name` must match folder name
- ✅ `name` uses only alphanumeric, dashes, underscores
- ✅ `version` must be semantic (e.g., "1.0.0")
- ✅ `agentFile` path must exist

### Categories

Choose one: `backend`, `frontend`, `devops`, `testing`, `documentation`, `database`, `security`, `ai`, `infrastructure`, `general`

---

## 📊 Statistics

| Metric | Count |
|--------|-------|
| Total Agents | 35 |
| Categories | 10 |
| From Agents | 16 |
| From Commands | 16 |
| From Skills | 3 |

---

## 🔗 Integration

This repository is designed to work with the **CrewDeck Agent Marketplace**. The marketplace scanner looks for JSON manifests in:

1. `agents/*.json` ✅
2. `marketplace/*.json`
3. `.claude/marketplace/*.json`
4. `marketplace/{agent-folder}/manifest.json`

---

## 📝 License

This collection is provided for use with CrewDeck and compatible AI agent systems.

---

<p align="center">
  <b>Built with ❤️ for AI-powered development</b>
</p>
