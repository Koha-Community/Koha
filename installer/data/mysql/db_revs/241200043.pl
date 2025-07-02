use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "39837",
    description => "Rename interface_id -> vendor_interface_id",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        if ( TableExists('aqbookseller_interfaces') ) {
            if ( column_exists( 'aqbookseller_interfaces', 'interface_id' ) ) {
                $dbh->do(
                    q{
                        ALTER TABLE aqbookseller_interfaces CHANGE COLUMN interface_id vendor_interface_id INT(11);
                    }
                );
                say_success(
                    $out,
                    q{Column 'aqbookseller_interfaces.interface_id' renamed to 'aqbookseller_interfaces.vendor_interface_id'}
                );
            }
        }
    },
};
