use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "26777",
    description => "Adds new system preferences 'OPACVirtualCard and 'OPACVirtualCardBarcode'",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
            ('OPACVirtualCard', '0', NULL,'Enable virtual library cards for patrons on the OPAC.', 'YesNo')
            }
        );
        say_success( $out, "Added new system preference 'OPACVirtualCard'" );

        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
            ('OPACVirtualCardBarcode', 'code39', 'code39|code128|ean13|upca|upce|ean8|itf14|qrcode|matrix2of5|industrial2of5|iata2of5|coop2of5','Specify the type of barcode to be used in the patron virtual library card tab in the OPAC.', 'Choice')
            }
        );
        say_success( $out, "Added new system preference 'OPACVirtualCardBarcode'" );

    },
};
