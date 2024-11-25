use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "28924",
    description => "Adds columns to patron categories to allow category level values for the no issue charge sysprefs",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        unless ( column_exists( 'categories', 'noissuescharge' ) ) {
            $dbh->do(
                q{
                ALTER TABLE categories ADD COLUMN `noissuescharge` int(11)
                COMMENT "define maximum amount outstanding before checkouts are blocked"
                AFTER `exclude_from_local_holds_priority`
                }
            );

            say_success( $out, "Added column 'noissuescharge' to categories" );
        }
        unless ( column_exists( 'categories', 'noissueschargeguarantees' ) ) {
            $dbh->do(
                q{
                ALTER TABLE categories ADD COLUMN `noissueschargeguarantees` int(11)
                COMMENT "define maximum amount that the guarantees of a patron in this category can have outstanding before checkouts are blocked"
                AFTER `noissuescharge`
                }
            );

            say_success( $out, "Added column 'noissueschargeguarantees' to categories" );
        }
        unless ( column_exists( 'categories', 'noissueschargeguarantorswithguarantees' ) ) {
            $dbh->do(
                q{
                ALTER TABLE categories ADD COLUMN `noissueschargeguarantorswithguarantees` int(11)
                COMMENT "define maximum amount that the guarantors with guarantees of a patron in this category can have outstanding before checkouts are blocked"
                AFTER `noissueschargeguarantees`
                }
            );

            say_success( $out, "Added column 'noissueschargeguarantorswithguarantees' to categories" );
        }
    },
};
