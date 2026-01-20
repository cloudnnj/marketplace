---
title: "Build Feature"
description: "Orchestrated full-stack feature development with specialized agents, parallel execution, testing, deployment, and PR creation"
category: "Development"
tags: [feature, orchestration, full-stack, agents, workflow, parallel]
version: "1.0"
examples:
  - "/build-feature Add user profile editing with avatar upload"
  - "/build-feature @feature-spec.md"
  - "/build-feature Implement course recommendations engine"
---

# Build Feature

@feature-orchestrator I want you to orchestrate the implementation of the following feature: $ARGUMENTS

## Orchestration Protocol

### Phase 0: Git Setup (Mandatory)

1. **Branch Verification**
   - Check current branch status
   - If not on a feature branch, create: `feature/<feature-short-name>`
   - Never commit directly to `main`
   - If `$ARGUMENTS` is a `.md` file, commit it to the feature branch first

2. **Pre-flight Checks**
   - Verify clean working directory or stash changes
   - Ensure all dependencies are installed
   - Validate environment configuration

### Phase 1: Analysis & Planning

1. **Scope Analysis**
   - Parse the feature requirements from `$ARGUMENTS`
   - Identify affected layers: Database | API | Backend | Frontend | Infrastructure
   - Map to existing project patterns and components

2. **Execution Plan Creation**
   - Select appropriate agent sequence (A, B, C, D, or E from orchestrator)
   - Identify parallel execution opportunities
   - Estimate complexity and duration
   - Document dependencies and blockers

3. **Output**
   ```
   📋 Feature: [Name]
   📊 Scope: [DB | API | Backend | Frontend | Infra]
   🔄 Sequence: [Selected sequence letter]
   ⏱️ Estimate: [Duration]
   🔀 Parallel: [Yes/No - what can run simultaneously]
   ```

### Phase 2: Data & API Layer (If Applicable)

1. **Database Changes** (@database-designer)
   - Create migration file: `backend/migrations/0XX_description.sql`
   - Define indexes for query patterns
   - Update `backend/shared/types/database.ts` if needed

2. **API Contract Definition** (@api-developer)
   - Define endpoints in REST convention
   - Document request/response types
   - Specify authentication requirements
   - Update `infrastructure/terraform/api-gateway.tf` if needed

3. **Handoff Artifact**: API contract document for implementation phase

### Phase 3: Implementation

**Backend Track** (@backend-developer + @typescript-developer)
1. Create Lambda handler in `backend/functions/<domain>/`
2. Implement service in `backend/shared/services/`
3. Add repository if data access needed in `backend/shared/repositories/`
4. Write unit tests with 80%+ coverage
5. Follow existing patterns:
   ```typescript
   import { createSuccessResponse, createErrorResponse } from '@/shared/utils/lambda-response';
   ```

**Frontend Track** (@frontend-developer + @typescript-developer) - Can run in parallel
1. Create components in `frontend/components/`
2. Add page in `frontend/app/` if needed
3. Implement hooks in `frontend/hooks/`
4. Update API client in `frontend/lib/api/`
5. Follow component patterns:
   - Main component < 250 lines
   - Extract state logic to hooks
   - Extract UI sections to sub-components

**Parallel Execution** (When dependencies allow)
```bash
# Create worktrees for true parallel development
git worktree add -b feature/backend ../momentum-feature-backend
git worktree add -b feature/frontend ../momentum-feature-frontend
```

### Phase 4: Quality Assurance

1. **Standards Enforcement** (@code-standards-enforcer)
   - Run ESLint: `npm run lint`
   - Verify TypeScript strict compliance
   - Check naming conventions and patterns

2. **Security Audit** (@code-security-auditor)
   - Review authentication/authorization
   - Check for injection vulnerabilities
   - Validate input sanitization
   - Review secrets handling

3. **Code Review** (@code-reviewer)
   - Comprehensive review against project standards
   - Performance assessment
   - Test coverage verification
   - Documentation check

### Phase 5: Testing & Validation

1. **Unit Tests**
   - Backend: `cd backend && npm test`
   - Frontend: `cd frontend && npm test`
   - Target: 80%+ coverage on new code

2. **Integration Tests** (If applicable)
   - API endpoint testing
   - Database operation verification

3. **Manual Verification**
   - Test the feature end-to-end
   - Verify responsive design (frontend)
   - Check error handling paths

### Phase 6: Documentation (@code-documenter)

1. **Code Documentation**
   - TSDoc comments on public APIs
   - Inline comments for complex logic

2. **Project Documentation** (If significant feature)
   - Create doc in `docs/features/` with front matter:
     ```yaml
     ---
     layout: default
     title: "Feature Name"
     parent: Features
     nav_order: X
     ---
     ```
   - Update relevant existing docs

3. **API Documentation** (If new endpoints)
   - Update Postman collection in `docs/postman/`

### Phase 7: Deployment (If Backend/Infrastructure Changes)

1. **Infrastructure Deployment** (If Terraform changes)
   ```bash
   cd infrastructure/terraform
   terraform plan
   terraform apply
   ```

2. **Backend Deployment**
   ```bash
   ./scripts/deployment/deploy-backend.sh
   ```

3. **Verify Deployment**
   - Check CloudWatch logs
   - Test deployed endpoints
   - Monitor for errors

### Phase 8: Completion

1. **Final Commits**
   - Stage all changes
   - Commit with conventional format:
     ```
     feat(<scope>): <description>
     
     - Detail 1
     - Detail 2
     
     Closes #<issue-number>
     ```

2. **Create Pull Request**
   - Push feature branch
   - Create PR with:
     - Clear description of changes
     - Testing instructions
     - Screenshots (if UI changes)
     - Deployment notes

3. **Post-PR Actions**
   - Request review
   - Address feedback
   - Monitor CI/CD pipeline

4. **Suggest Next Steps**
   - Related features to consider
   - Technical debt identified
   - Enhancement opportunities

## Quality Gates Checklist

Before completing, verify:

- [ ] Feature branch created and used
- [ ] All affected layers implemented
- [ ] TypeScript strict mode passing
- [ ] No `any` types introduced
- [ ] Unit tests written (80%+ coverage)
- [ ] ESLint passing
- [ ] Security review complete
- [ ] Code review approved
- [ ] Documentation updated
- [ ] Deployment successful (if applicable)
- [ ] PR created with proper description

## Troubleshooting Protocol

If issues arise during any phase:

1. **Implementation Blocker** → Invoke @code-debugger for root cause analysis
2. **Pattern Uncertainty** → Check existing code in same domain
3. **Security Concern** → Escalate to @code-security-auditor
4. **Tech Debt Discovered** → Note for follow-up, don't block feature
5. **Scope Creep** → Return to Phase 1 for re-analysis

## Agent Invocation Summary

| Phase | Primary Agent | Support Agent |
|-------|--------------|---------------|
| Planning | @feature-orchestrator | - |
| Database | @database-designer | @typescript-developer |
| API | @api-developer | - |
| Backend | @backend-developer | @typescript-developer |
| Frontend | @frontend-developer | @typescript-developer |
| Standards | @code-standards-enforcer | - |
| Security | @code-security-auditor | - |
| Review | @code-reviewer | - |
| Docs | @code-documenter | - |
| Debug | @code-debugger | @code-refactor |

---

**Execute this workflow to build production-ready features with confidence.**

