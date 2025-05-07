use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => '39579',
    description => "Add system preference 'patronSelfRegistrationAgeRestriction'",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do( "
            INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
            ('PatronSelfRegistrationAgeRestriction', '', NULL, 'Patron''s maximum age during self registration. If empty, no age restriction is applied.', 'Integer')
        " );
        say_success( $out, "Added new system preference 'PatronSelfRegistrationAgeRestriction'" );
    },
};
