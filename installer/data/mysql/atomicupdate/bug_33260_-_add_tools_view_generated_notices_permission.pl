use Modern::Perl;

return {
    bug_number  => "33260",
    description => "Show message queue on staff interface and make notices printable",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{ INSERT IGNORE INTO permissions (module_bit, code, description) VALUES (13, 'view_generated_notices', 'View and print generated notices') }
        );

        say $out "Added user permission view_generated_notices";
    },
};
