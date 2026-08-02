---
name: box-finish
description: Reviews completed Box ticket work against acceptance criteria, verifies code is the source of truth, archives the ticket into the epic Summary, updates tickets.tsv, and deletes the ticket file. Resolves target from ticket letter (W=workspace, M=mobile, B=bff) or paths. Use when the user says a box-todo ticket is done/finished/complete or asks to close/archive via box-finish (e.g. W001-T1.1, B001-T1.1).
---

# box-finish

Close out a completed ticket in Box `docs/todos/` (parent repo or submodule). Pair with [box-todo](../box-todo/SKILL.md).

**Source of truth:** actual code changes (git diff, files on disk). The ticket `.md` is reference only.

**AI Harness:** do not archive without AC evidence + QA Playbook evidence (when the ticket has / requires a playbook). See workspace [`.cursor/rules/feature-development.mdc`](../../../.cursor/rules/feature-development.mdc) §1.

## 0. Resolve target project

| Id | Root | Letter | Automated verify (when code touched) |
| ---- | ---- | ------ | ------------------------------------ |
| `box-workspace` | `.` (repo root) | `W` | Per touched submodule (below); docs/skills-only → AC file-check |
| `box-mobile` | `apps/box-mobile` | `M` | `bun run test` |
| `box-bff` | `apps/box-bff` | `B` | `bun run type-check` (+ `bun run test` when a test script / tests exist) |

Infer from ticket id letter (`W001-T1.1` → workspace, `B001-T1.1` → bff), path, or ask.

Run git and verification with cwd = `{root}` for `M`/`B`. For `W`, inspect parent git **and** each touched submodule.

**`W` verification:**

- Docs / skills / `AGENTS.md` / conventions only → no app test suite; confirm files match AC checklist.
- Code in one or more submodules → run that submodule’s automated verify for each touched app **and** collect QA evidence for behavior changes.

## Workflow

### 1. Resolve the ticket

- Ticket ID: `{L}{nnn}-T{s}.{t}`
- Or path: `{root}/docs/todos/epics/{L}{nnn}-{slug}/{L}{nnn}-T{s}.{t}-{slug}.md`

Read ticket `.md`, `Summary-{L}{nnn}.md`, `tickets.tsv`. If missing or `file` is `-`, stop and report.

### 2. Review code against acceptance criteria

1. `git diff` / `git status` in `{root}` (and touched submodules when `L=W`)
2. Read affected source files
3. CodeGraph with `projectPath` = each relevant root when tracing cross-file flows

| AC | Met? | Evidence |
| ---- | ---- | -------- |
| … | yes / no / partial | file:line, command output, or behavior |

**Do not archive if** any AC is no/partial without user sign-off, verification failed, or code materially contradicts intent. Report gaps first.

### 3. Run verification

1. Run the automated verify command(s) for the target (table above).
2. **QA Playbook / e2e evidence (required for user-visible or API-visible behavior):**
   - Execute the ticket’s `## QA Playbook (human)` (or AC steps if they are the playbook).
   - Record evidence: command output, HTTP status/body excerpts, Maestro result, or screenshot note.
   - **`box-bff`:** `type-check` alone is **not** enough to archive behavior changes. Need HTTP/`curl` (or equivalent) playbook evidence for API-visible AC.
   - **`box-mobile`:** `bun run test` alone is **not** enough for UI-visible AC. Need Maestro and/or manual UI playbook evidence.
   - **Docs/skills-only:** file-check AC evidence is enough (no HTTP/UI).
3. If playbook missing for user/API-visible work → do not archive; ask user to add playbook or explicitly waive.

Note evidence in the finish report (and optionally one line in Summary Completed).

### 4. Archive into epic Summary

Edit `{root}/docs/todos/epics/{L}{nnn}-{slug}/Summary-{L}{nnn}.md`.

Under `## Completed` (create after `## Tickets` if missing), newest first:

```markdown
## Completed

### {L}{nnn}-T{s}.{t} · {Title}

{One sentence, plain English: what shipped. Name key symbols when helpful. No file lists, no test counts.}
```

### 5. Update `tickets.tsv`

Set `status` = `done`, `file` = `-`. Leave priority/id/title. Do not reorder.

### 6. Delete the ticket markdown

Remove the ticket `.md`. Permanent record = Summary + TSV.

### 6b. Clean up Superpowers design/plan (default: delete)

Under `{root}/docs/superpowers/specs/` and `plans/` only:

1. Glob related files (slug / feature / date).
2. Default: delete on finish.
3. If a durable decision isn’t in code or Summary, fold 1–3 sentences into Completed, then delete.
4. Fix broken links to deleted ticket/superpowers docs.

### 7. Verify docs

- [ ] Every AC assessed with evidence
- [ ] QA Playbook evidence recorded (or N/A docs-only / user waiver noted)
- [ ] Automated verify ran for code-touching targets (`type-check`≠done for bff behavior; tests≠done for mobile UI)
- [ ] Summary has `## Completed` entry
- [ ] TSV: `done` / `-`
- [ ] Ticket `.md` deleted
- [ ] Related superpowers docs cleaned under `{root}`
- [ ] Files live under the correct target’s `docs/todos/` (`W` → workspace root; `M`/`B` → submodule)

## Examples

**Finish W001-T1.1:** review under workspace `docs/todos/`, walk AC file-checks, archive, TSV done, delete md.

**Finish B001-T1.1 (API change):** run `type-check`, `test` **and** HTTP playbook evidence (e.g. login → `GET /users/me` expected fields).

**Finish M001-T1.1 (UI change):** `bun run test` **and** Maestro/manual UI playbook evidence.

**AC or playbook not met:** report failures; do not archive.

## Reference

- Target `CONVENTIONS.md`
- Add tickets: [box-todo](../box-todo/SKILL.md)
