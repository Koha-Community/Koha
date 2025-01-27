use Modern::Perl;

return {
    bug_number  => "29778",
    description => "Delete orphan additional contents",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Run this only if 230600041 has not been run before
        if ( column_exists( 'additional_contents', 'lang' ) ) {
            $dbh->do(
                q{
                DELETE FROM additional_contents
                WHERE code NOT IN (
                    SELECT code FROM (
                        SELECT code
                        FROM additional_contents
                        WHERE lang = "default"
                    ) as tmp
                );
            }
            );
        }
    },
    }
