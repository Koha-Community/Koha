use Modern::Perl;

return {
    bug_number => "31374",
    description => "Add a non-public note cololumn to the suggestions table",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
        if( !column_exists( 'suggestions', 'privatenote' ) ) {
            $dbh->do(q{
                    ALTER TABLE suggestions
                    ADD COLUMN privatenote longtext NULL DEFAULT NULL
                    COMMENT "suggestions table non-public note"
                    AFTER note
            });
        }
        # Print useful stuff here
        say $out "Add privatenote column to suggestions table";
    },
};
