use Modern::Perl;
use Koha::Installer::Output qw(say_success);

return {
    bug_number  => "39532",
    description => "Add FINES restriction type for debar_patrons_with_fines.pl script",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Add the new FINES restriction type
        $dbh->do(
            q{
            INSERT IGNORE INTO restriction_types (code, display_text, is_system, is_default)
            VALUES ('FINES', 'Fines suspension', 1, 0)
        }
        );

        say_success( $out, "Added new system restriction type 'FINES'" );
    },
};
