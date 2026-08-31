# WWW::MailboxOrg House Rules

Apply to every task in this repository unless explicitly overridden. Bias: caution
over speed on non-trivial work; use judgment on trivial tasks. Loaded automatically
at launch (same priority as `CLAUDE.md`). Subagents get their discipline from the
skills force-loaded via `briefing.skills` — this file is for the orchestrating agent.

## Engineering discipline

1. **Think before coding** — State assumptions. When uncertain, ask rather than
   guess. Push back when a simpler approach exists. Stop when confused; name what's
   unclear.
2. **Simplicity first** — Minimum code that solves the problem. Nothing speculative.
3. **Surgical changes** — Touch only what you must. Don't "improve" adjacent code or
   formatting. Match existing style.
4. **Surface conflicts, don't average them** — Contradicting patterns: pick one
   (more recent / more tested), explain why, flag the other. Don't blend.
5. **Read before you write** — Before new code, read the controller you touch, its
   validator, `Role::API`, and `Types.pm`. "Looks orthogonal" is dangerous.
6. **Tests verify intent** — A test that can't fail when the logic changes is wrong.
   Reproduce a bug before fixing it; leave a regression test behind.
7. **Fail loud** — "Done" is wrong if anything was skipped silently; "tests pass" is
   wrong if any were skipped. Surface uncertainty, don't hide it.

## Delegation

This rule depends on whether the Agent/Task tool is available to you.

- **You can spawn subagents** (orchestrating main agent): Do NOT touch
  behavior-relevant code yourself — delegate to `www-mailboxorg-worker`. Your lane:
  coordinate, inspect, plan, review diffs, run tests, manage git, edit non-behavioral
  docs. When in doubt, delegate. Why: only the `www-mailboxorg-*` agents get their
  skills force-loaded via `briefing.skills`; you get no briefing and would touch
  internals with too little context. Specialist lanes:

  | Task | Agent |
  |---|---|
  | Implement / refactor / debug behavior-relevant code | `www-mailboxorg-worker` (default) |
  | Write/extend tests | `www-mailboxorg-test-writer` |
  | Pre-release audit | `www-mailboxorg-release-checker` |

- **You cannot spawn subagents** (you ARE a `www-mailboxorg-*` agent): The delegation
  lock does not apply to you — implement, refactor, debug, and test per these rules.

Behavior-relevant = the client, the API::* controllers and their param validators,
the IO/RPC/HTTP role stack, entity objects, the `mborg` CLI, error handling, and
tests. Pure prose docs and `Changes` notes are not.

## Coordination — karr board (always in scope)

Ticket coordination is the orchestrating agent's job, so `karr` is always in scope —
just use it. Git-native kanban; state lives in `refs/karr/*`; this repo has its own
board. Day-to-day:

- `karr list --compact` / `karr board` — open work · `karr show ID` — detail
- `karr create "Title" --priority high --tags a,b --body '…'` — new ticket
- `karr move ID in-progress --claim NAME` — start · `karr handoff ID --claim NAME --note "…"` — to review
- mutating commands auto-sync. Full command surface: skill `kanban-issues-karr-cli`.

**Serialize board mutations when fanning out.** Keep implementation work parallel if
you like, but collect the results and then loop `karr move`/`handoff`/`sync`
sequentially — N of them landing at once is a resource event, not a cheap command.

## Release — never without permission

`dzil build` / `dzil test` / `prove -lr t/` are fine anytime. `dzil release` and any
upload to CPAN are STRICTLY forbidden without the maintainer's explicit go-ahead —
even if a plan or STATUS document lists "release" as the next step. Stop and ask.

## Project-specific hazards

- **`t/05-live.t` talks to the real mailbox.org API.** It self-skips unless
  `TEST_WWW_MAILBOXORG_USER`/`_PASSWORD` are set. Never wire real credentials into a
  change to force it green, and never add a test that hits the wire — the whole suite
  is deterministic because it runs through the `MockIO` backend and unsets
  `WWW_MAILBOXORG_*` first.
- **`prove` here must be recursive** (`prove -lr t/`) — `t/lib/` holds the MockIO
  harness and a non-recursive run silently changes what loads.
- **Validators are the contract.** A controller method without a matching
  `Params::ValidationCompiler` validator will happily send a malformed call; the
  green happy-path test hides it. Every method change carries its validator.

## Perl / Moo specifics — reference, don't restate

House Perl style, module loading, `cpanfile`/`Changes`, Moo class/role patterns,
POD commands (`=method`/`=attr`/`=env`), dist.ini and the dzil release workflow live
in skills `getty-perl-core`, `getty-perl-moo`, `getty-perl-release-author-getty`,
`perl-release-dist-ini`, and the domain shape in `www-mailboxorg-core` — all
force-loaded for `www-mailboxorg-*` agents. Do not duplicate that content here.
