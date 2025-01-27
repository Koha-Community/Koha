use Modern::Perl;

return {
    bug_number  => "30135",
    description => "Add EdifactLSQ mapping system preference",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
            ('EdifactLSQ', 'location', 'location|ccode', "Map EDI sequence code (GIR+LSQ) to Koha Item field", 'Choice')
        }
        );
    },
};
