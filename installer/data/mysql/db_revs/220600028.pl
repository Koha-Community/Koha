use Modern::Perl;

return {
    bug_number  => "30077",
    description => "Add option for library dropdown in search function for staff interface",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences (`variable`,`value`,`options`,`explanation`,`type`)
            VALUES ('IntranetAddMastheadLibraryPulldown','0','','Add a library select pulldown menu on the staff header search','YesNo ')
        }
        );

        say $out "Added new system preference 'IntranetAddMastheadLibraryPulldown'";
    },
};
