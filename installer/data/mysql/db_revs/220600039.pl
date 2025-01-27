use Modern::Perl;

return {
    bug_number  => "31374",
    description => "Add a non-public note column to the suggestions table",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        if ( !column_exists( 'suggestions', 'staff_note' ) ) {
            $dbh->do(
                q{
                    ALTER TABLE suggestions
                    ADD COLUMN staff_note longtext NULL DEFAULT NULL
                    COMMENT "suggestions table non-public note"
                    AFTER note
            }
            );
        }

        say $out "Added column 'suggestions.staff_note'";
    },
};
