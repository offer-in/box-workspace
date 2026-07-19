---
name: box-finish
description: Reviews completed Box submodule ticket work against acceptance criteria, verifies code is the source of truth, archives the ticket into the epic Summary, updates tickets.tsv, and deletes the ticket file. Resolves target from ticket letter (M=mobile, B=bff) or paths. Use when the user says a box-todo ticket is done/finished/complete or asks to close/archive via box-finish (e.g. B001-T1.1).
---

# box-finish

Close out a completed ticket in a Box submodule’s `docs/todos/`. Pair with [box-todo](../box-todo/SKILL.md).

**Source of truth:** actual code changes (git diff, files on disk). The ticket `.md` is reference only.

## 0. Resolve target project

| Id | Root | Letter | Verify (when code touched) |
| ---- | ---- | ------ | -------------------------- |
| `box-mobile` | `apps/box-mobile` | `M` | `bun run test` |
| `box-bff` | `apps/box-bff` | `B` | `bunx tsc --noEmit` |

Infer from ticket id letter (`B001-T1.1` → bff), path, or ask. Never write under workspace-root `docs/todos/`.

Run git and verification with cwd = `{root}` (the submodule).

## Workflow

### 1. Resolve the ticket

- Ticket ID: `{L}{nnn}-T{s}.{t}`
- Or path: `{root}/docs/todos/epics/{L}{nnn}-{slug}/{L}{nnn}-T{s}.{t}-{slug}.md`

Read ticket `.md`, `Summary-{L}{nnn}.md`, `tickets.tsv`. If missing or `file` is `-`, stop and report.

### 2. Review code against acceptance criteria

1. `git diff` / `git status` in `{root}`
2. Read affected source files
3. CodeGraph with `projectPath` = `{root}` when tracing cross-file flows

| AC | Met? | Evidence |
| ---- | ---- | -------- |
| … | yes / no / partial | file:line or behavior |

**Do not archive if** any AC is no/partial without user sign-off, verification failed, or code materially contradicts intent. Report gaps first.

### 3. Run verification

Run the verify command for the target (table above). Note extras in the Summary entry.

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
- [ ] Summary has `## Completed` entry
- [ ] TSV: `done` / `-`
- [ ] Ticket `.md` deleted
- [ ] Related superpowers docs cleaned under `{root}`
- [ ] No workspace-root `docs/todos/` writes

## Examples

**Finish B001-T1.1:** review in `apps/box-bff`, run `bunx tsc --noEmit`, archive, TSV done, delete md.

**AC not met:** report failures; do not archive.

## Reference

- Target `CONVENTIONS.md`
- Add tickets: [box-todo](../box-todo/SKILL.md)
