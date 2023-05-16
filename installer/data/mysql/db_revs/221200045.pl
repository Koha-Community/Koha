use Modern::Perl;

return {
    bug_number => "33297",
    description => "Fix missing 's' in system preference 'RetainPatronSearchTerms'",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
        my ($wrong_syspref_exists) = $dbh->selectrow_array(q{
            SELECT COUNT(*) FROM systempreferences WHERE variable='RetainPatronSearchTerms'
        });
        if ($wrong_syspref_exists) {
            # Correct preference may have been generated via interface
            my ($correct_syspref_exists) = $dbh->selectrow_array(q{
                SELECT COUNT(*) FROM systempreferences WHERE variable='RetainPatronsSearchTerms'
            });
            if ( $correct_syspref_exists ) {
                $dbh->do(q{
                    DELETE FROM systempreferences WHERE variable='RetainPatronSearchTerms'
                });
                say $out "Wrong system preference 'RetainPatronSearchTerms' deleted";
            } else {
                $dbh->do(q{
                    UPDATE systempreferences SET variable='RetainPatronsSearchTerms' WHERE variable='RetainPatronSearchTerms'
                });
                say $out "Wrong system preference 'RetainPatronSearchTerms' renamed 'RetainPatronsSearchTerms'";
            }
        }
    },
};
