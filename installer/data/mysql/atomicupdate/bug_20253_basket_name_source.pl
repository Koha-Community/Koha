use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "20253",
    description => "Add purchase order number configuration option to vendor_edi_accounts",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        unless ( column_exists( 'vendor_edi_accounts', 'po_is_basketname' ) ) {
            $dbh->do(
                q{
                ALTER TABLE vendor_edi_accounts
                ADD COLUMN `po_is_basketname` tinyint(1) NOT NULL DEFAULT 0
                AFTER `plugin`
                }
            );
            say_success( $out, "Added column 'vendor_edi_accounts.po_is_basketname'" );
        }
    },
};
