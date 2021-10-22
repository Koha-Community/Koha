use Modern::Perl;

return {
    bug_number  => '35028',
    description => 'Add system preference PatronSelfRegistrationAlert',
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do( "
            INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
            ('PatronSelfRegistrationAlert','0',NULL,'If enabled, an alter will be shown on staff interface home page when there are self-registered patrons.','YesNo')
        " );
    },
};
