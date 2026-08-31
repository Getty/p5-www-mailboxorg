# CLAUDE.md

WWW::MailboxOrg — Perl JSON-RPC client for the mailbox.org API (Moo; session auth
via the `HPLS-AUTH` header), with the `mborg` CLI.

## Delegation

Delegate behavior-relevant code to the right agent instead of touching it yourself —
the principle and the lanes are in `.claude/rules/www-mailboxorg-rules.md`.

| Task | Agent |
|---|---|
| Implement / refactor / debug behavior-relevant code | `www-mailboxorg-worker` (default) |
| Write/extend tests | `www-mailboxorg-test-writer` |
| Pre-release audit | `www-mailboxorg-release-checker` |

The agents carry their skills via `briefing.skills` (see `.claude/agents/`); the main
agent delegates rather than loading them. Domain knowledge lives in skill
`www-mailboxorg-core`; house Perl/Moo/release conventions in the `getty-perl-*` and
`perl-release-dist-ini` skills under `.claude/skills/`.
