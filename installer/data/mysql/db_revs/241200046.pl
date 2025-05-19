use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "30301",
    description => "Add a flag to enforce expiry notices",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        unless ( column_exists( 'categories', 'enforce_expiry_notice' ) ) {
            $dbh->do(
                q{
                ALTER TABLE categories ADD COLUMN `enforce_expiry_notice` tinyint(1) NOT NULL DEFAULT 0
                COMMENT "enforce the patron expiry notice for this category"
                AFTER `noissueschargeguarantorswithguarantees`
                }
            );

            say_success( $out, "Added column 'enforce_expiry_notice' to categories" );
        }
    },
};
