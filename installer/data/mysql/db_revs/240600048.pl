use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "33484",
    description => "Add state save as an option to datatables",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        if ( !column_exists( 'tables_settings', 'default_save_state' ) ) {
            $dbh->do(
                q{
                ALTER TABLE tables_settings
                  ADD COLUMN default_save_state tinyint(1) DEFAULT 1 AFTER default_sort_order
            }
            );
            say_success( $out, "Added column 'tables_settings.default_save_state'" );
        }
        if ( !column_exists( 'tables_settings', 'default_save_state_search' ) ) {
            $dbh->do(
                q{
                ALTER TABLE tables_settings
                  ADD COLUMN default_save_state_search tinyint(1) DEFAULT 0 AFTER default_save_state
            }
            );
            say_success( $out, "Added column 'tables_settings.default_save_state_search'" );
        }
    },
};
