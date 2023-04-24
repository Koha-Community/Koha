use Modern::Perl;

return {
    bug_number => "33300",
    description => "Fix missing wrong system preference 'AutomaticWrongTransfer'",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
        my ($wrong_syspref_exists) = $dbh->selectrow_array(q{
            SELECT COUNT(*) FROM systempreferences WHERE variable='AutomaticWrongTransfer'
        });
        if ($wrong_syspref_exists) {
            # Correct preference may have been generated via interface
            my ($correct_syspref_exists) = $dbh->selectrow_array(q{
                SELECT COUNT(*) FROM systempreferences WHERE variable='AutomaticConfirmTransfer'
            });
            if ( $correct_syspref_exists ) {
                $dbh->do(q{
                    DELETE FROM systempreferences WHERE variable='AutomaticWrongTransfer'
                });
                say $out "Wrong system preference 'AutomaticWrongTransfer' deleted";
            } else {
                $dbh->do(q{
                    UPDATE systempreferences SET variable='AutomaticConfirmTransfer' WHERE variable='AutomaticWrongTransfer'
                });
                say $out "Wrong system preference 'AutomaticWrongTransfer' renamed 'AutomaticConfirmTransfer'";
            }
        } else {
            say $out "Wrong system preference 'AutomaticWrongTransfer' does not exist";
        }
    },
};
