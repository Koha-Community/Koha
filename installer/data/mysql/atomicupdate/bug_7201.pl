use Modern::Perl;

return {
    bug_number => "7021",
    description => "Add patron category to the statistics table",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};

        if( !column_exists( 'statistics', 'categorycode' ) ) {
            $dbh->do(
                "ALTER TABLE statistics ADD COLUMN categorycode varchar(10) AFTER ccode"
            );
        }
    },
};
