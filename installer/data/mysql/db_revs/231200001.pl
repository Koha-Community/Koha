use Modern::Perl;

return {
    bug_number  => "35413",
    description => "Terminology: Manage issues (issue_manage)",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            UPDATE permissions
            SET description='Manage vendor issues'
            WHERE code='issue_manage'
        }
        );

        say $out "Updated permission 'issue_manage' description with 'Manage vendor issues'";
    },
};
