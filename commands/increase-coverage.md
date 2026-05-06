---
title: "Increase Coverage"
description: "Orchestrated code coverage campaign with specialized agents for frontend, backend, and infrastructure testing in parallel"
category: "Testing"
tags: [testing, coverage, orchestration, agents, parallel, vitest, playwright]
version: "2.0"
examples:
  - "/increase-coverage"
  - "/increase-coverage frontend"
  - "/increase-coverage backend/shared/services"
  - "/increase-coverage coverage-targets.md"
---

# Increase Coverage

@"coverage-orchestrator (agent)" I need you to orchestrate a code coverage campaign: $ARGUMENTS

## Orchestrated Coverage Protocol

### Phase 0: Git Setup (Mandatory)

1. **Branch Verification**
   - Check current branch status
   - If not on a coverage branch, create: `coverage/<scope-description>`
   - Never commit directly to `main`

2. **Parallel Worktree Setup** (For full campaigns)
   ```bash
   # Create worktrees for parallel coverage work
   git worktree add -b coverage/frontend ../<project>-coverage-frontend
   git worktree add -b coverage/backend ../<project>-coverage-backend
   git worktree add -b coverage/infrastructure ../<project>-coverage-infra
   ```

### Phase 1: Deterministic Data Collection

> **IMPORTANT**: Phase 1 is purely mechanical data collection. Execute every command
> and capture the FULL output. Do NOT skip commands based on assumptions. Do NOT begin
> analysis, classification, or fixes until Phase 2. This reduces token waste from
> re-reading and backtracking.

1. **Run test coverage** and capture the full output:
   ```bash
   npm run test:coverage 2>&1
   ```

2. **Read coverage summary JSON** (if present):
   ```bash
   cat coverage/coverage-summary.json 2>/dev/null || echo "file not found"
   ```

3. **Read coverage thresholds**:
   Read `.github/coverage-thresholds.json`

4. **Read vitest config** for exclusion patterns:
   Read `vitest.config.ts` — specifically the `coverage.exclude` array

5. **Parse scope** from `$ARGUMENTS`:
   | Argument | Scope |
   |----------|-------|
   | (empty) | Full campaign - all domains |
   | `frontend` | Frontend components + hooks |
   | `backend` | Backend handlers + services |
   | `backend/shared/services` | Specific directory |
   | `infrastructure` | Infrastructure + workflow tests |
   | `file.md` | Custom target list |

6. **Enumerate files in scope** using Glob:
   - Source files matching the determined scope
   - Existing test files (`*.test.ts`, `*.test.tsx`) in the same scope

#### Coverage Data Summary (populate before proceeding)

```
## Test + Coverage Output (`npm run test:coverage`)
[paste full output here]

## Coverage Summary JSON (`coverage/coverage-summary.json`)
[paste JSON contents or "file not found"]

## Coverage Thresholds (`.github/coverage-thresholds.json`)
[paste JSON contents here]

## Vitest Config Exclusions (`vitest.config.ts`)
[list all coverage.exclude patterns here]

## Scope
- Arguments: [raw $ARGUMENTS value]
- Interpreted scope: [full campaign / frontend / backend / specific directory / custom target list]

## Source Files in Scope
[list file paths from glob]

## Existing Test Files in Scope
[list test file paths from glob]
```

### Phase 2: Analysis and Planning

Using the data collected in Phase 1, analyze coverage gaps and plan test assignments.

1. **Output Coverage Summary**
   ```
   📊 Current Coverage State
   
   | Domain     | Branches | Functions | Lines | Target | Gap    |
   |------------|----------|-----------|-------|--------|--------|
   | All        | X%       | X%        | X%    | (from Phase 1 thresholds) | -Y% |
   
   📁 Priority Files (Lowest Coverage)
   1. path/to/file.ts - X% (missing: branches, functions)
   2. path/to/file2.ts - X% (missing: edge cases)
   ...
   ```

2. **Categorize Files by Domain**
   ```
   ## Parallel Assignments
   
   ### Track 1: Frontend (@"frontend-developer (agent)")
   - components/ComponentA/__tests__/ - needs: unit tests
   - hooks/useHookA.test.ts - needs: edge cases
   
   ### Track 2: Backend (@"backend-developer (agent)")
   - shared/services/ServiceA.test.ts - needs: unit tests
   - functions/courses/handlers/ - needs: handler tests
   
   ### Track 3: Infrastructure (@"backend-developer (agent)")
   - tests/infrastructure/ - needs: config tests
   - tests/workflows/ - needs: CI tests
   ```

2. **Estimate Effort**
   | Priority | File | Complexity | Est. Tests |
   |----------|------|------------|------------|
   | P1 | path/to/critical.ts | High | 15-20 |
   | P2 | path/to/utility.ts | Medium | 8-10 |
   | P3 | path/to/simple.ts | Low | 3-5 |

### Phase 3: Parallel Test Implementation

**PARALLEL EXECUTION** - Different domains run simultaneously:

#### Track 1: Frontend Tests (@"frontend-developer (agent)" + @"typescript-developer (agent)")

**Location**: `../<project>-coverage-frontend` worktree

1. **Component Tests**
   ```
   frontend/components/[Name]/__tests__/[Name].test.tsx
   ```
   - Rendering tests
   - User interaction tests
   - Edge case tests
   - Accessibility tests

2. **Hook Tests**
   ```
   frontend/hooks/__tests__/use[Name].test.ts
   ```
   - Initialization tests
   - State update tests
   - Effect tests
   - Error handling tests

3. **Run & Verify**
   ```bash
   cd frontend && npm run test:coverage
   # Verify thresholds pass — check vitest.config.ts for exact values
   ```

---

#### Track 2: Backend Tests (@"backend-developer (agent)" + @"typescript-developer (agent)")

**Location**: `../<project>-coverage-backend` worktree

1. **Service Tests**
   ```
   backend/shared/services/__tests__/[Name]Service.test.ts
   ```
   - Happy path tests
   - Error scenario tests
   - Edge case tests

2. **Repository Tests**
   ```
   backend/__tests__/repositories/[Name]Repository.test.ts
   ```
   - Query tests
   - Data transformation tests
   - Not found scenarios

3. **Handler Tests**
   ```
   backend/functions/[domain]/src/__tests__/handlers/[name].test.ts
   ```
   - Valid request tests
   - Invalid request tests
   - Auth tests

4. **Run & Verify**
   ```bash
   npm run test:backend:coverage
   # Verify thresholds pass — check vitest.config.ts for exact values
   ```

---

#### Track 3: Infrastructure Tests (@"backend-developer (agent)")

**Location**: `../<project>-coverage-infra` worktree

1. **Infrastructure Tests**
   ```
   tests/infrastructure/*.test.ts
   ```
   - Infrastructure config tests
   - API/endpoint tests
   - Deployment trigger tests

2. **Workflow Tests**
   ```
   tests/workflows/*.test.ts
   ```
   - CI/CD workflow tests
   - Change detection tests
   - Script validation tests

3. **Run & Verify**
   ```bash
   npm run test:infrastructure:coverage
   npm run test:workflows:coverage
   ```

### Phase 4: Test Quality Review

1. **Code Review** (@"quality-reviewer (agent)")
   - [ ] Tests follow project patterns
   - [ ] Meaningful assertions (not just snapshot)
   - [ ] Proper mocking of dependencies
   - [ ] No skipped or commented tests
   - [ ] Descriptive test names
   - [ ] Arrange-Act-Assert pattern

2. **Standards Check** (@"quality-reviewer (agent)")
   - [ ] Test file naming conventions
   - [ ] Consistent describe/it structure
   - [ ] No implementation testing
   - [ ] Proper cleanup in afterEach

### Phase 5: Merge & Validate

1. **Merge Coverage Branches**
   ```bash
   # Merge all tracks back
   git checkout coverage/main  # or feature branch
   git merge coverage/frontend
   git merge coverage/backend
   git merge coverage/infrastructure
   ```

2. **Final Coverage Validation**
   ```bash
   # Run all tests with coverage
   npm run test:unit:coverage
   npm run test:backend:coverage
   
   # Verify thresholds met
   ```

3. **Generate Report**
   ```markdown
   ## Coverage Campaign Results
   
   | Domain | Before | After | Change | Target Met |
   |--------|--------|-------|--------|------------|
   | Frontend | X% | Y% | +Z% | ✅ |
   | Backend | X% | Y% | +Z% | ✅ |
   
   ### Tests Added
   - Total: N new tests
   - Frontend: N tests (X files)
   - Backend: N tests (X files)
   - Infrastructure: N tests
   ```

### Phase 6: Documentation & Completion

1. **Update Test Documentation** (If significant)
   - Add to relevant `__tests__/README.md` files
   - Update `frontend/TESTING_GUIDE.md` if patterns changed

2. **Commit with Coverage Metrics**
   ```bash
   git commit -m "test(coverage): increase coverage across frontend and backend
   
   Frontend: 75% → 82% (+7%)
   Backend: 68% → 73% (+5%)
   
   Added:
   - Component tests for X, Y, Z
   - Service tests for A, B, C
   - Handler tests for D, E, F
   
   All thresholds now passing."
   ```

3. **Create Pull Request**
   - Include before/after coverage metrics
   - List all new test files
   - Note any patterns established

4. **Cleanup Worktrees**
   ```bash
   git worktree remove ../<project>-coverage-frontend
   git worktree remove ../<project>-coverage-backend
   git worktree remove ../<project>-coverage-infra
   ```

## Test Patterns Reference

### Frontend Component Test
```typescript
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { ComponentName } from '../ComponentName';

describe('ComponentName', () => {
  const defaultProps = { /* minimal required props */ };

  describe('rendering', () => {
    it('should render with required props', () => {
      render(<ComponentName {...defaultProps} />);
      expect(screen.getByRole('button')).toBeInTheDocument();
    });
  });

  describe('interactions', () => {
    it('should handle click events', async () => {
      const user = userEvent.setup();
      const onClick = vi.fn();
      
      render(<ComponentName {...defaultProps} onClick={onClick} />);
      await user.click(screen.getByRole('button'));
      
      expect(onClick).toHaveBeenCalled();
    });
  });

  describe('edge cases', () => {
    it('should handle empty data', () => {
      render(<ComponentName {...defaultProps} data={[]} />);
      expect(screen.getByText(/no items/i)).toBeInTheDocument();
    });
  });
});
```

### Backend Service Test
```typescript
import { MyService } from '../MyService';

describe('MyService', () => {
  let service: MyService;
  
  beforeEach(() => {
    service = new MyService();
    vi.clearAllMocks();
  });

  describe('methodName', () => {
    it('should return result for valid input', async () => {
      const result = await service.methodName('valid');
      expect(result).toEqual(expectedValue);
    });

    it('should throw for invalid input', async () => {
      await expect(service.methodName('invalid'))
        .rejects.toThrow('Expected error');
    });
  });
});
```

### Backend Handler Test
```typescript
import { handler } from '../handler';

describe('Handler', () => {
  it('should return 200 for valid request', async () => {
    const event = { body: JSON.stringify({ data: 'test' }) };
    const result = await handler(event as any, {} as any);

    expect(result.statusCode).toBe(200);
  });

  it('should return 400 for invalid body', async () => {
    const event = { body: 'not json' };
    const result = await handler(event as any, {} as any);

    expect(result.statusCode).toBe(400);
  });
});
```

## Quality Gates

### Before Completing
- [ ] All coverage thresholds met (check `vitest.config.ts` or `.github/coverage-thresholds.json` for exact values)
- [ ] All tests pass (`npm test`)
- [ ] No flaky tests (run 3x to verify)
- [ ] Tests follow project patterns
- [ ] Proper mocking (no real API calls)
- [ ] Coverage report generated
- [ ] PR created with metrics

## Troubleshooting

### Coverage Not Increasing
1. Check if file is in `include` patterns in vitest.config.ts
2. Verify tests actually exercise the code paths
3. Check for conditional branches not tested

### Flaky Tests
1. Remove any timing dependencies
2. Use `waitFor` instead of hardcoded delays
3. Mock all external dependencies
4. Check for state leaking between tests

### Slow Tests
1. Move setup to `beforeAll` where safe
2. Use lighter mocks
3. Split into smaller test files

## Agent Invocation Summary

| Phase | Agents | Domain |
|-------|--------|--------|
| Analysis | @"coverage-orchestrator (agent)" | All |
| Frontend Tests | @"frontend-developer (agent)", @"typescript-developer (agent)" | Components, Hooks |
| Backend Tests | @"backend-developer (agent)", @"typescript-developer (agent)" | Services, Handlers |
| Infra Tests | @"backend-developer (agent)" | Config, Workflows |
| Review | @"quality-reviewer (agent)" | All |

## Comparison with Manual Testing

| Approach | Use Case |
|----------|----------|
| `/increase-coverage` | Systematic campaign with parallel execution |
| Manual tests | Quick one-off test additions |
| CI coverage gate | Prevent coverage regression |

---

**Execute this workflow to systematically increase test coverage with quality.**

