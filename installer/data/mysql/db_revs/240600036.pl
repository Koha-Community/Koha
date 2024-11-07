use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "37954",
    description => "Move holdings_barcodes setting to holdings_barcode",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        my ($existing_holdings_barcode_setting) = $dbh->selectrow_array(
            q{
                SELECT COUNT(*) FROM columns_settings WHERE module='catalogue' AND page='detail' AND tablename='holdings_table' AND columnname='holdings_barcode'
        }
        );
        if ($existing_holdings_barcode_setting) {
            say_info( $out, "Settings already exist" );
        } else {
            my ( $cannot_be_toggled, $is_hidden ) = $dbh->selectrow_array(
                q{
                    SELECT cannot_be_toggled,is_hidden FROM columns_settings WHERE module='catalogue' AND page='detail' AND tablename='holdings_table' AND columnname='holdings_barcodes'
            }
            );

            if ( defined $cannot_be_toggled || defined $is_hidden ) {
                $dbh->do(
                    qq{
                    INSERT IGNORE INTO columns_settings VALUES
                    ('catalogue', 'detail', 'holdings_table', 'holdings_barcode', $cannot_be_toggled, $is_hidden )
                }
                );
                say_success( $out, "Settings moved to holdings_barcode" );
            } else {
                say_info( $out, "No settings for holdings_barcodes found" );
            }
        }
        $dbh->do(
            q{
            DELETE FROM columns_settings WHERE module='catalogue' AND page='detail' AND tablename='holdings_table' AND columnname='holdings_barcodes'
        }
        );
        say $out "Removed settings for holdings_barcodes";
    },
};
