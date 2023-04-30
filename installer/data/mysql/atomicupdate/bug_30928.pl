use Modern::Perl;
return {
    bug_number => "30928",
    description => "Add interface field to statistics table",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
        if( !column_exists( 'statistics', 'interface' ) ) {
            $dbh->do(q{
                ALTER TABLE statistics
                ADD COLUMN interface varchar(30) NULL DEFAULT NULL
                COMMENT "interface"
                AFTER categorycode
            });
            say $out "Added column 'statistics.interface'";
        }
    },
}
