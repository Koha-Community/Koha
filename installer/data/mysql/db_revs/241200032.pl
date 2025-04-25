use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "39518",
    description => "Add a field to define the basket name in the MARC order account for a vendor",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        if ( !column_exists( 'marc_order_accounts', 'basket_name_field' ) ) {
            $dbh->do(
                q{ ALTER TABLE marc_order_accounts ADD COLUMN `basket_name_field` varchar(10) DEFAULT NULL COMMENT 'the field that a vendor can use to include a basket name that will be used to create the basket for the file' AFTER match_value}
            );
            say_success( $out, "Added column 'marc_order_accounts.basket_name_field'" );
        }
    },
};
