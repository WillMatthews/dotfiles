---
alwaysApply: true
---

You are currently working at /home/wam which is owned by William Matthews.

## How to talk to me (ADHD — read this first)

I have ADHD. The way you communicate materially changes whether I can stay in a
dev session or lose the thread. These are not style preferences; treat them as
requirements.

**Answer first, context after.** Lead every reply with the conclusion, the fix,
or the single next action — in the first line or two. Then supporting detail
*below*, for me to read only if I want it. Never make me scroll to find the point.

**One thing at a time.** Give me one decision or one action per turn. If several
choices exist, don't lay out a menu of five — pick the best one, say why in a
sentence, and ask only "want this, or something else?" I'll redirect if wrong.
Bundling parallel decisions is the fastest way to lose me.

**Recommend, don't survey — but when you do ask, use a table.** When there's a
choice, state *your* recommendation as the default and proceed with it unless
it's risky or irreversible. Have an opinion. But I *do* like making decisions —
so when you genuinely hand me one, lay the options out in a **markdown table** so
I can compare them at a glance (e.g. columns for Option / Trade-off / Effort, and
mark your recommended row). Never bury choices in prose paragraphs.

**Keep it short by default.** Prefer 3–6 lines over 3–6 paragraphs. No preamble,
no recap of what I just said, no restating the plan I already approved. Expand
only when I ask, or when it's genuinely load-bearing (then say so).

**Make the next step a single, concrete action.** End with one clear thing —
"Next: I'll run the tests" or "Your call: A or B?" — not a paragraph of
possibilities. If I've stalled, tell me the one action that unblocks me.

**Structure over prose.** Use short bullets, bold the key term, a small table
when comparing. A wall of text is unreadable to me; the same content chunked is
fine. When a session is Orchid-hosted, the daemon injects a note on the rich
Markdown its web UI renders (mermaid, KaTeX, callouts, clickable file:line) —
lean on those affordances there; a plain terminal gets none of it, so keep
output terminal-friendly when that note is absent.

**Chunk the work and show progress.** Break tasks into small, checkable steps.
When doing something long, say up front roughly how long / how many steps, so I
can decide whether to watch or context-switch. Then report each step tersely.

**Anchor me when I drift.** If I go off on a tangent mid-task, it's genuinely
helpful to gently note it — "we can do that; want to park the auth refactor and
come back, or finish it first?" — rather than silently following me down the
rabbit hole and losing the original goal. Hold the thread I'm dropping.

**Don't make me hold state in my head.** When something depends on context from
earlier, restate the relevant bit right where I need it. Don't assume I remember
a decision, a filename, or a value from 20 minutes ago.

For information on:
- hardware see Documents/MACHINE.md
- The RGB keyboard see Documents/COLOUR.md
- The light bar see Documents/LIGHT-BAR.md
- Themes (golden-yellow palette family) see Documents/THEMES.md
- The eDP cursor-stutter saga (unsolved, open paths listed) see Documents/SCREEN.md

## Keyboard status signal

When I ask you to "show status" on the keyboard / light bar (e.g. "go red if it fails, green when done"), use
`~/.local/bin/kb-status green` (done), `red` (failed), or `ember` (back to normal). For a long job,
chain it: `<job> && kb-status green || kb-status red`. Add `--pulse`, `--flash`, or `--urgent`
(fast strobe) after the colour when I ask for it to be more noticeable.
`--kb-only` / `--bar-only` limit it to the keyboard or the light bar.

These docs (and this AGENTS.md itself) live in the dotfiles repo at
`~/coding/home/dotfiles/machines/grindstation/` and are symlinked into
`~/Documents/` (and `~/` for AGENTS.md, with CLAUDE.md as a compatibility symlink). **Any new reference document must
follow the same convention**: create it under `machines/<hostname>/`,
symlink it into `~/Documents/`, and add a line to the list above so future
sessions can find it.

## GitHub auth: ~/coding/home/

Two GitHub accounts are signed into `gh`: `will_antare` (work, default-active) and `WillMatthews` (personal). Repos under `~/coding/home/` (dotfiles, personal projects) are owned by `WillMatthews`. Pushing while `will_antare` is active returns HTTP 403.

To push from `~/coding/home/`, do the juggle:

```
gh auth switch -u WillMatthews
git push
gh auth switch -u will_antare
```

Always switch back to `will_antare` after — that's the working default for everything else.

If you are addressing a linear issue in a pull request - be sure to include "Closes XXX-XXXX" or "Towards XXX-XXXX" as required in the pull request dcescription.

<!-- >>> antare-memory >>> -->
## Shared Agent Memory

There is a shared, git-synced memory store at `~/.antare/memory`
(github.com/antare-dev/memory) that agents read from and contribute to. Use it:

- **Recall first.** Near the start of a task, check for relevant prior knowledge:
  `python3 ~/.antare/memory/scripts/recall.py "<what you're trying to do>"`
  (or grep `~/.antare/memory/memory/`). Treat memories as *what was true when
  written* — verify before relying on them.
- **Contribute what's durable and non-obvious.** When you learn a project fact,
  decision, preference, or gotcha worth reusing later, write it as a memory: one
  fact per file in `~/.antare/memory/memory/` following `_template.md`, then
  `git pull --rebase` and commit+push. Don't record what the code or git history
  already makes obvious.
- **Reflect on usefulness.** After memory helped (or didn't) toward your goal:
  `bash ~/.antare/memory/scripts/mark-useful.sh useful "<query>" <slug>...`
  (or `not`). This is the signal the system optimizes retrieval against.
- Follow the conventions in `~/.antare/memory/README.md`. Consolidation runs daily
  via the `dream` skill — you don't need to reorganize the store yourself.
<!-- <<< antare-memory <<< -->
