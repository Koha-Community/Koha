use Modern::Perl;

return {
    bug_number  => "30230",
    description => "Add new list_borrowers permission",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            "INSERT IGNORE INTO permissions (module_bit, code, description) VALUES (4, 'list_borrowers', 'Search, list and view patrons')"
        );

        say $out "Added new permission 'list_borrowers'";
    },
};
