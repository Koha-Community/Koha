use Modern::Perl;

return {
    bug_number => "29393",
    description => "Add permission borrowers:send_messages_to_borrowers",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};

        $dbh->do(q{INSERT INTO permissions (module_bit, code, description)
            VALUES (4, 'send_messages_to_borrowers', 'Send messages to patrons')});
        say $out "Update is going well so far";
    },
}
