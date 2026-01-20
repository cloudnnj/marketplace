---
title: "Fix Bug (Orchestrated)"
description: "Orchestrated bug investigation and resolution with specialized agents for root cause analysis, implementation, and verification"
category: "Bug Fixing"
tags: [bugfix, orchestration, debugging, agents, root-cause, workflow]
version: "1.0"
examples:
  - "/fix-bug The enrollment button returns 403 Preflight error"
  - "/fix-bug @bug-report.md"
  - "/fix-bug Course video generation fails silently"
  - "/fix-bug 500 error when uploading PDF in admin/generate"
---

# Fix Bug (Orchestrated)

@bugfix-orchestrator I need you to orchestrate the investigation and resolution of the following bug: $ARGUMENTS

## Orchestrated Bug Fix Protocol

### Phase 0: Git Setup (Mandatory)

1. **Branch Verification**
   - Check current branch status
   - If not on a bugfix branch, create: `bugfix/<issue-short-description>`
   - Never commit directly to `main`
   - If `$ARGUMENTS` is a `.md` file, commit it to the branch first

2. **Pre-flight**
   - Verify clean working directory or stash changes
   - Note recent deployments or changes that might be related

### Phase 1: Evidence Collection

1. **Parse Bug Report** from `$ARGUMENTS`
   - Extract: Symptom, Error Messages, Reproduction Steps
   - Identify: Environment, Frequency, Timeline

2. **Gather Additional Evidence**
   - Check CloudWatch Logs (if backend)
   - Check Browser Console (if frontend)
   - Check recent commits/deployments

3. **Output Evidence Summary**
   ```
   🐛 Bug: [Short description]
   📍 Symptom: [What user sees]
   ❌ Error: [Error message/code]
   🔄 Repro: [Steps to reproduce]
   🌍 Environment: [Dev/Prod/Local]
   ⏱️ Timeline: [When did it start]
   ```

### Phase 2: Root Cause Analysis (@code-debugger)

1. **Clarification Loop**
   - If information is insufficient, ask ONE clarifying question
   - Wait for response
   - Repeat until root cause can be identified

2. **Systematic Investigation**
   - Form hypothesis based on evidence
   - Trace code path from symptom to source
   - Identify exact location of bug

3. **Root Cause Documentation**
   ```
   ## Root Cause Identified
   
   **Classification**
   - Severity: P0 (Critical) / P1 (High) / P2 (Medium) / P3 (Low)
   - Domain: Frontend / Backend / API / Database / Infrastructure / Auth
   
   **Location**
   - File: `path/to/file.ts`
   - Lines: X-Y
   - Function: `functionName()`
   
   **Cause**
   [Technical explanation of why bug occurs]
   
   **Evidence**
   [Code snippet or log showing the issue]
   ```

### Phase 3: Fix Strategy

1. **Plan the Fix**
   ```
   ## Fix Strategy
   
   **Approach**: [How we'll fix it]
   
   **Files to Modify**:
   - `path/to/file1.ts` - [Change description]
   - `path/to/file2.ts` - [Change description]
   
   **Risk Assessment**:
   - Complexity: Low / Medium / High
   - Regression Risk: Low / Medium / High
   - Requires Deployment: Frontend / Backend / Infrastructure / All
   ```

2. **Select Fix Agent** based on domain:
   | Domain | Primary Agent | Support Agent |
   |--------|--------------|---------------|
   | Frontend | @frontend-developer | @typescript-developer |
   | Backend | @backend-developer | @typescript-developer |
   | API | @api-developer | @backend-developer |
   | Database | @database-designer | @backend-developer |
   | Infrastructure | @backend-developer | - |
   | Auth/Security | @code-security-auditor | @backend-developer |

### Phase 4: Fix Implementation

1. **Implement Fix** (Domain-specific agent)
   - Make minimal changes to fix the root cause
   - Follow existing project patterns
   - Add defensive coding where appropriate

2. **Pattern Enforcement**
   ```typescript
   // Backend Lambda - Use response utilities
   import { createSuccessResponse, createErrorResponse } from '@/shared/utils/lambda-response';
   
   // Frontend - Handle all states
   if (isLoading) return <LoadingSkeleton />;
   if (error) return <ErrorDisplay error={error} />;
   
   // API - Validate inputs
   if (!requiredField) {
     return createErrorResponse({ code: 'INVALID_INPUT', message: 'Field required' });
   }
   ```

3. **Write Regression Test**
   ```typescript
   describe('Bug Fix: [description]', () => {
     it('should not [reproduce the bug scenario]', async () => {
       // Setup that previously caused the bug
       // Assert bug no longer occurs
     });
   });
   ```

### Phase 5: Security Review (If Applicable)

**Trigger if fix touches**:
- Authentication/Authorization logic
- User input handling
- Data access patterns
- API endpoints
- Secrets/credentials

1. **Invoke @code-security-auditor**
   - Review fix for security implications
   - Verify no new vulnerabilities introduced
   - Check input validation and sanitization

### Phase 6: Code Review (@code-reviewer)

1. **Fix Quality Check**
   - [ ] Fix addresses root cause (not just symptoms)
   - [ ] No `any` types introduced
   - [ ] Follows existing project patterns
   - [ ] Minimal changes (no scope creep)
   - [ ] Regression test included

2. **Code Standards Verification**
   - Run ESLint: `npm run lint`
   - TypeScript compilation: `npm run build`
   - Unit tests: `npm test`

### Phase 7: Testing & Verification

1. **Automated Tests**
   ```bash
   # Backend tests
   cd backend && npm test
   
   # Frontend tests
   cd frontend && npm test
   ```

2. **Manual Verification**
   - Reproduce original bug steps → Verify bug no longer occurs
   - Test related functionality → Verify no regressions
   - Test edge cases → Verify defensive coding works

3. **Verification Checklist**
   - [ ] Original bug no longer reproducible
   - [ ] All automated tests passing
   - [ ] No new errors in console/logs
   - [ ] Related features still work

### Phase 8: Deployment (If Backend/Infrastructure Changes)

1. **Infrastructure Deployment** (If Terraform changes)
   ```bash
   cd infrastructure/terraform
   terraform plan   # Review changes
   terraform apply  # Deploy
   ```

2. **Backend Deployment** (If Lambda changes)
   ```bash
   ./scripts/deployment/deploy-backend.sh
   ```

3. **Post-Deployment Verification**
   - Check CloudWatch Logs for errors
   - Test deployed endpoints
   - Monitor for 5-10 minutes

### Phase 9: Documentation

1. **Create Bug Fix Documentation**
   If significant bug, create `docs/bugfix/XX-bug-description.md`:
   ```yaml
   ---
   layout: default
   title: "Bug: [Short Description]"
   parent: Bug Fixes
   nav_order: XX
   ---
   ```

2. **Content Requirements**
   - Problem Summary
   - Root Cause
   - Fix Applied
   - Files Changed
   - Prevention Recommendations

### Phase 10: Completion

1. **Final Commits**
   ```bash
   git add .
   git commit -m "fix(<scope>): <description>
   
   Root Cause: <brief explanation>
   
   - <change 1>
   - <change 2>
   
   Closes #<issue-number>"
   ```

2. **Create Pull Request**
   - Push bugfix branch
   - Create PR with:
     - Clear description of the bug
     - Root cause explanation
     - Fix summary
     - Testing performed
     - Screenshots (if UI bug)

3. **Suggest Improvements**
   - Related issues that might exist
   - Preventive measures to add
   - Technical debt to address later

## Quality Gates

### Before Marking Complete
- [ ] Bugfix branch created and used
- [ ] Root cause identified and documented
- [ ] Fix is minimal and focused
- [ ] Unit test covers the bug scenario
- [ ] All tests passing
- [ ] Security review complete (if applicable)
- [ ] Manual verification successful
- [ ] Deployment successful (if applicable)
- [ ] PR created with proper description

## Troubleshooting During Fix

### If Root Cause Unclear
1. Add more logging/tracing
2. Create minimal reproduction case
3. Check version control history for related changes
4. Review similar bugs in `docs/bugfix/`

### If Fix Introduces Regressions
1. Stop and reassess root cause
2. May need different approach
3. Consider if fix scope needs expansion

### If Deployment Fails
1. Check CloudWatch for specific errors
2. Verify Lambda packaging
3. Check Terraform state
4. Review IAM permissions

## Agent Invocation Summary

| Phase | Primary Agent | When |
|-------|--------------|------|
| Investigation | @code-debugger | Always first |
| Frontend Fix | @frontend-developer | UI/React bugs |
| Backend Fix | @backend-developer | Lambda/service bugs |
| Type Fix | @typescript-developer | Type errors |
| API Fix | @api-developer | Request/response bugs |
| Database Fix | @database-designer | Query/schema bugs |
| Security Review | @code-security-auditor | Auth/data bugs |
| Final Review | @code-reviewer | Always before completion |
| Documentation | @code-documenter | Significant bugs |
| Cleanup | @code-refactor | If tech debt exposed |

## Comparison with Other Bug Commands

| Command | Use Case |
|---------|----------|
| `/fix-bug` | Complex bugs requiring investigation, multi-domain issues |
| `/bugfix` | Simple, straightforward bugs with clear root cause |
| `/analyze-root-cause` | When you only want analysis, not implementation |

---

**Execute this workflow to fix bugs systematically with confidence.**

