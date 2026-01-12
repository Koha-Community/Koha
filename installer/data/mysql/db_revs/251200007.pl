use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "40391",
    description => "Add EdifactLSL system preference for GIR:LSL (Library Sub-Location) field mapping",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Update existing EdifactLSQ preference to include empty option
        $dbh->do(
            q{
            UPDATE systempreferences
            SET options = 'location|ccode|', explanation = 'Map EDI sequence code (GIR+LSQ) to Koha Item field, empty to ignore'
            WHERE variable = 'EdifactLSQ'
        }
        );

        # Add new EdifactLSL preference
        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences (variable, value, options, explanation, type)
            VALUES ('EdifactLSL', '', 'location|ccode|', 'Map EDI sub-location code (GIR+LSL) to Koha Item field, empty to ignore', 'Choice')
        }
        );

        say_success( $out, "Updated EdifactLSQ system preference to include empty option" );
        say_success( $out, "Added EdifactLSL system preference for GIR:LSL field mapping" );
    },
};
