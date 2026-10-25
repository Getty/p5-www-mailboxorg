# WWW::MailboxOrg House Rules

The shared house rules come from skilletor — bundle `getty-cpan-dist@getty`: engineering
discipline, the delegation lock, the publish gate, karr coordination, CPAN release. They load
as `.claude/rules/.local.*.md`; if they are missing, run `skilletor sync` and publish nothing
until they load. This file adds what is true only here, and wins where it differs.

## What this repo is

Perl client for the Mailbox.org API. Read first: the controller you touch, its validator,
`Role::API` and `Types.pm`.

## Agent team

| Task | Agent |
|---|---|
| Implement / refactor / debug behavior-relevant code | `www-mailboxorg-worker` (default) |
| Write/extend tests | `www-mailboxorg-test-writer` |
| Commits, `Changes`, card → done, pre-release audit | `www-mailboxorg-release-manager` |
| Read-only research, audit, gap analysis | `www-mailboxorg-worker` ("read-only, change nothing") |

Behavior-relevant = the client, the API::* controllers and their param validators, the
IO/RPC/HTTP role stack, entity objects, the `mborg` CLI, error handling, and tests. Pure
prose docs and `Changes` notes are not.

## Hazards

- **`t/05-live.t` talks to the real mailbox.org API.** It self-skips unless
  `TEST_WWW_MAILBOXORG_USER`/`_PASSWORD` are set. Never wire real credentials into a
  change to force it green, and never add a test that hits the wire.
- **`prove` here must be recursive** (`prove -lr t/`) — `t/lib/` holds the MockIO
  harness and a non-recursive run silently changes what loads.
- **Validators are the contract.** A controller method without a matching
  `Params::ValidationCompiler` validator will happily send a malformed call; the
  green happy-path test hides it. Every method change carries its validator.

## Perl / Moo specifics — reference, don't restate

House Perl style, module loading, `cpanfile`/`Changes`, Moo class/role patterns, POD
commands and the dzil release workflow live in skills `getty-perl-core`,
`getty-perl-moo`, `getty-perl-release-author-getty`, `perl-release-dist-ini`; the
domain shape in `www-mailboxorg-core` — all force-loaded.
