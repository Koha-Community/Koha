use Modern::Perl;

return {
    bug_number  => "13412",
    description => "Add GenerateAuthorityField667 and GenerateAuthorityField670 system preferences",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
            ( 'GenerateAuthorityField667', 'Machine generated authority record', NULL, 'When BiblioAddsAuthorities and AutoCreateAuthorities are enabled, use this as a default value for the 667$a field of MARC21 records', 'free' ),
            ( 'GenerateAuthorityField670', 'Work cat.', NULL, 'When BiblioAddsAuthorities and AutoCreateAuthorities are enabled, use this as a default value for the 670$a field of MARC21 records', 'free' )
         }
        );
    },
};
