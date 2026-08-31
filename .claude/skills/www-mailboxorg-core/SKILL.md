---
name: www-mailboxorg-core
description: Use when working on WWW::MailboxOrg — the Moo JSON-RPC client for the mailbox.org API, its session auth, API controllers, entity objects, or the mborg CLI.
---

# WWW::MailboxOrg — architecture & invariants

Perl client for the mailbox.org business API. Moo throughout; JSON-RPC 2.0 over
HTTPS with a session token. Object-system and house-Perl rules live in
`getty-perl-moo` / `getty-perl-core`; POD commands, dzil build/release and
next-version semantics live in `getty-perl-release-author-getty`. This skill is
only the domain shape those skills do not carry.

## Composition

```
WWW::MailboxOrg (Moo client, with Role::HTTP)
├── Role::HTTP → Role::RPC       JSON-RPC over the IO backend
│   └── Role::IO                 pluggable transport
│       ├── LWPIO                Mojo::UserAgent sync backend (production)
│       └── MockIO (t/lib)       records calls, returns canned responses (tests)
├── API::* controllers           one per API namespace, each with Role::API
└── Entity::Account, Entity::Domain
```

The client `has` one lazy accessor per controller (`account`, `domain`, `mail`,
… `system`, `base`), each building `API::<Name>->new( client => $self )`.
Controllers are **plain per-client Moo objects**, not singletons — they hold a
`weak_ref` `client` and reach the wire through `Role::API::_rpc`. (Any older note
calling them `MooX::Singleton` is stale; the code uses `with 'Role::API'`.)

## JSON-RPC protocol

- Method names, not REST paths. Most controllers namespace them:
  `_rpc('account.add', \%params)`, `_rpc('mail.find', …)`. **Exceptions:**
  `API::Base` uses bare `auth` / `deauth` / `search`, and `API::System` uses bare
  `hello` / `test` / `capabilities`.
- Named parameters, passed as a single hashref.
- Every controller method validates params up front with
  `Params::ValidationCompiler` (`validation_for`) against `Types::Standard` plus
  the custom `WWW::MailboxOrg::Types` (e.g. `EmailAddress`). Invalid or missing
  required params `die` before any call is made — the controller tests assert this
  with `dies_ok`. Adding a method means adding its validator alongside it.

## Session auth

- Login is `base->auth(user, pass)` (the client's `login` wraps it); the returned
  `session` is stored as the client `token` (`is => 'rwp'`, `clear_token`).
- Authenticated calls send the token in the **`HPLS-AUTH` request header** — not a
  Bearer token. `_set_auth_header` adds it whenever a token is set.
- `logout` calls `deauth` and clears the token; `DEMOLISH` logs out automatically
  if a token is still set.

## Constructor & environment

Attributes: `user` (required), `password` (required), `token`, `base_url`
(default `https://api.mailbox.org/v1`). `around BUILDARGS` fills any unset value
from the environment; an explicit argument always wins.

```
WWW_MAILBOXORG_USER      → user
WWW_MAILBOXORG_PASSWORD  → password
WWW_MAILBOXORG_BASE_URL  → base_url
WWW_MAILBOXORG_TOKEN     → token   (reuse an existing session, skip login)
```

Env vars are namespaced with the module name (`WWW_MAILBOXORG_`). Live tests use a
separate `TEST_WWW_MAILBOXORG_*` set and skip unless it is present.

## Controllers and their methods

| Controller | Methods |
|---|---|
| `API::Base` | `auth`, `deauth`, `search` (bare method names) |
| `API::System` | `hello`, `test`, `capabilities` (bare method names) |
| `API::Account` | `list`, `get`, `add`, `set`, `del` (`plan` ∈ basic/profi/profixl/reseller) |
| `API::Domain` | `list`, `get`, `add`, `set`, `del` |
| `API::Mail` | `find(query)`, `list(folder, unseen_only)` |
| `API::Mailinglist` | `list`, `get`, `add`, `set`, `del`, `add_member`, `del_member`, `list_members` |
| `API::Blacklist` | `list(account)`, `add`, `del` |
| `API::Spamprotect` | `status`, `set` |
| `API::Videochat` | `status`, `create_room`, `list_rooms`, `delete_room` |
| `API::Backup` | `list`, `create`, `restore`, `delete` |
| `API::Invoice` | `list`, `get`, `download` |
| `API::Passwordreset` | `request`, `set` |
| `API::Validate` | `email` |
| `API::Utils` | `parse_headers`, `parse_date`, `generate_message_id` |

## CLI — `bin/mborg`

```bash
mborg login                                   # creds from env or config
mborg account list
mborg domain list
mborg mail find "from:user@example.com"
mborg mail list --folder INBOX --unseen-only
```

Credentials come from `WWW_MAILBOXORG_*` env vars or a config file
(`~/.mailboxrc`).

## Key files

- `lib/WWW/MailboxOrg.pm` — client: attributes, env fallback, login/logout, controller accessors
- `lib/WWW/MailboxOrg/Role/HTTP.pm`, `Role/RPC.pm`, `Role/IO.pm` — transport stack
- `lib/WWW/MailboxOrg/LWPIO.pm` — production Mojo::UserAgent backend
- `lib/WWW/MailboxOrg/Role/API.pm` — shared `_rpc` for controllers
- `lib/WWW/MailboxOrg/API/*.pm` — one controller per namespace
- `lib/WWW/MailboxOrg/Types.pm` — custom type constraints (`EmailAddress`, …)
- `lib/WWW/MailboxOrg/Entity/{Account,Domain}.pm` — entity objects
- `bin/mborg` — CLI
- `t/lib/WWW/MailboxOrg/MockIO.pm` — test transport backend

## Reference

API docs: L<https://api.mailbox.org/v1/doc/methods/index.html>.
Architecture model: WWW::Hetzner.
