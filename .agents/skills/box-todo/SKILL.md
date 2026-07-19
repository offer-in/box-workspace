---
name: box-todo
description: Adds project TODOs to a Box submodule’s docs/todos/ as epics and tickets (TSV registry + markdown). Resolves target project (box-mobile=M, box-bff=B), asks clarifying questions, picks or creates the right epic, and updates Summary, tickets.tsv, ticket files, and README. Use when the user wants a workspace todo, ticket, backlog item, or epic via box-todo (not the mobile-only add-project-todo skill).
---

# box-todo

Workspace skill for Box submodule project TODOs. Pair with [box-finish](../box-finish/SKILL.md).

## 0. Resolve target project

Before any file I/O, pick exactly one target:

| Id | Root (from workspace) | Letter | Conventions |
| ---- | --------------------- | ------ | ----------- |
| `box-mobile` | `apps/box-mobile` | `M` | `apps/box-mobile/docs/todos/CONVENTIONS.md` |
| `box-bff` | `apps/box-bff` | `B` | `apps/box-bff/docs/todos/CONVENTIONS.md` |

**Resolution order:**

1. User named the project (`bff`, `box-bff`, `mobile`, ticket id `B…` / `M…`, path under `apps/<id>/`).
2. Else infer from focused files / conversation paths under `apps/<id>/`.
3. Else ask — do **not** guess.

**Hard rules:**

- All paths below are under `{root}/docs/todos/` for the chosen target.
- Never create `docs/todos/` at the workspace root.
- Read that target’s `CONVENTIONS.md` and existing epics before placing work.
- Use letter `{L}` from the table (`M` or `B`) everywhere mobile skills used `M`.

## Workflow

### 1. Classify the request

| Destination | When |
| ----------- | ---- |
| Epic + ticket | Feature work, project docs, tracked deliverables |
| `README.md` only | Deps to learn, To Reads, SDK follow-ups, Ref projects |

If unclear, ask. Do **not** create epic tickets for reading lists or dependency notes.

### 2. Gather requirements (ask proactively)

Use **AskQuestion** when available; otherwise ask conversationally. Do not create files until placement and core fields are clear.

**Always ask (project tickets):**

1. **Epic** — existing or new? If new, slug (`{L}{nnn}-{slug}`) and one-line summary for the index.
2. **Title** — short human-readable name.
3. **Description** — at least one sentence.
4. **Priority** — `1`–`5`; default **`3`**.
5. **Status** — default **`backlog`** unless `in-progress`, `done`, or `blocked`.

**Ask when useful:** acceptance criteria, links, Summary updates, fuller new-epic description.

Batch related questions; skip what the user already answered.

### 3. Resolve IDs and paths

Work inside `{root}/docs/todos/`.

**Existing epic** — read `epics/{L}{nnn}-{slug}/tickets.tsv`:

- Next ticket: increment from highest `T{s}.{t}` in that epic (after `T1.2` → `T1.3`; empty → `T1.1`).
- Slug: kebab-case from title unless user gives one.
- Filename: `{L}{nnn}-T{s}.{t}-{slug}.md`

**New epic** — scan `epics/` for highest `{L}{nnn}`; use next zero-padded number.

Create:

```
{root}/docs/todos/epics/{L}{nnn}-{slug}/
  Summary-{L}{nnn}.md
  tickets.tsv
  {L}{nnn}-T1.1-{slug}.md
```

### 4. Write / update files

**Ticket file:**

```markdown
# {L}{nnn}-T{s}.{t} · {Title}

|            |                                      |
| ---------- | ------------------------------------ |
| **Epic**   | [{L}{nnn}-{slug}](./Summary-{L}{nnn}.md) |
| **Status** | {status}                             |

## Description

{description}

## Acceptance criteria

- {criterion}

## Notes

{notes}
```

Omit Acceptance criteria / Notes sections if empty.

**`tickets.tsv`** — append one tab-separated row at the **end**:

```tsv
{priority}	{L}{nnn}-T{s}.{t}	{Title}	{status}	{L}{nnn}-T{s}.{t}-{slug}.md
```

**`Summary-{L}{nnn}.md`** — update when scope/context changed; keep link to `./tickets.tsv`.

**`docs/todos/README.md`** — for a **new** epic only, add:

```markdown
| [{L}{nnn}-{slug}](./epics/{L}{nnn}-{slug}/Summary-{L}{nnn}.md) | {one-line summary} |
```

### 5. Verify

- [ ] Ticket ID matches epic prefix and filename
- [ ] `tickets.tsv` row matches ticket file and metadata
- [ ] New row is last data row (or file re-sorted by `T{s}.{t}`)
- [ ] Epic link points to `Summary-{L}{nnn}.md`
- [ ] Priority `1`–`5`; default `3`
- [ ] New epic has Summary, tickets.tsv, README index row
- [ ] All files under `{root}/docs/todos/` (not workspace root)

## Examples

**BFF ticket:**

User: "box-todo: add JWT refresh hardening under a new auth epic in bff"

→ Target `box-bff`, `L=B` → create `B001-auth/`, first ticket, update bff README.

**Mobile via workspace skill:**

User: "box-todo for mobile: offline playback cache in M001"

→ Target `box-mobile`, `L=M` → append under `apps/box-mobile/docs/todos/epics/M001-audio-play/`.

**Not a project ticket:**

→ Append under the target README’s To Reads / Deps section only.

## Reference

- Target `CONVENTIONS.md` under `{root}/docs/todos/`
- Finish: [box-finish](../box-finish/SKILL.md)
