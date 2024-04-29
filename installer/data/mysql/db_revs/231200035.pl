use Modern::Perl;

return {
    bug_number  => "29393",
    description => "Add permission borrowers:send_messages_to_borrowers",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{INSERT IGNORE INTO permissions (module_bit, code, description)
            VALUES (4, 'send_messages_to_borrowers', 'Send messages to patrons')}
        );
        say $out "Added new permission 'send_messages_to_borrowers'";
    },
    }
