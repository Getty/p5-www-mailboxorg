# NAME

WWW::MailboxOrg - Perl client for Mailbox.org API

# SYNOPSIS

    use WWW::MailboxOrg;

    my $api = WWW::MailboxOrg->new(
        user     => 'user@example.com',
        password => 'secret123',
    );

    # Authenticate and get session
    $api->login;

    # List accounts
    my $accounts = $api->account->list;

    # Get domain info
    my $domain = $api->domain->get(domain => 'example.com');

# DESCRIPTION

WWW::MailboxOrg provides a Perl interface to the [Mailbox.org API](https://api.mailbox.org/v1/doc/methods/index.html).
Uses JSON-RPC 2.0 over HTTPS with session-based authentication.

# INSTALLATION

    cpanm WWW::MailboxOrg

Or from source:

    dzil install

# CONFIGURATION

Create a `~/.mailboxrc` config file:

    user=user@example.com
    password=secret
    base_url=https://api.mailbox.org/v1

Or use environment variables:

    MAILBOX_USER=user@example.com MAILBOX_PASSWORD=secret mborg login

# CLI USAGE

The `mborg` command-line tool is included:

    mborg --user=user@example.com --password=secret login

    # Read credentials from environment
    MAILBOX_USER=user@example.com MAILBOX_PASSWORD=secret mborg login

    # Read credentials from config file
    mborg login

    # Run commands
    mborg account list
    mborg domain list
    mborg mail find "from:user@example.com"

# API METHODS

## Account

- `account->list` - List all accounts
- `account->get(account => 'user@example.com')` - Get account details
- `account->add(...)` - Add new account
- `account->set(...)` - Update account
- `account->del(...)` - Delete account

## Domain

- `domain->list` - List domains
- `domain->get(domain => 'example.com')` - Get domain details
- `domain->add(...)` - Add domain
- `domain->set(...)` - Update domain
- `domain->del(...)` - Delete domain

## Mail

- `mail->list(folder => 'INBOX', unseen_only => 1)` - List emails in a folder
- `mail->find(query => 'from:user@example.com')` - Search emails

## System

- `system->hello` - Get API hello response
- `system->test` - Test API connection
- `system->capabilities` - Get API capabilities

## More APIs

- `mailinglist` - Mailing list management
- `blacklist` - Blacklist management
- `spamprotect` - Spam protection settings
- `videochat` - Video chat rooms
- `backup` - Backup operations
- `invoice` - Invoice access
- `passwordreset` - Password reset
- `validate` - Email validation
- `utils` - Utility functions (parse_headers, parse_date, generate_message_id)

# SEE ALSO

- [Mailbox.org API Documentation](https://api.mailbox.org/v1/doc/methods/index.html)
- [Source on GitHub](https://github.com/Getty/p5-www-mailbox)

# AUTHOR

Torsten Raudssus `<getty@cpan.org>`

# COPYRIGHT AND LICENSE

This software is copyright (c) 2026 by Torsten Raudssus.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.