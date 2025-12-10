use Modern::Perl;

return {
    bug_number  => "35830",
    description => "Add permission borrowers:merge_borrowers",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{INSERT IGNORE INTO permissions (module_bit, code, description)
            VALUES (4, 'merge_borrowers', 'Merge patrons')}
        );

        say $out "Added new permission 'merge_borrowers'";

        $dbh->do(
            q{INSERT IGNORE INTO user_permissions (borrowernumber, module_bit, code) SELECT  borrowernumber, module_bit, 'merge_borrowers' FROM user_permissions where module_bit = 4 and code = 'edit_borrowers';}
        );

        say $out "Added 'merge_borrowers' permission to existing users with 'edit_borrowers'";
    },
};
