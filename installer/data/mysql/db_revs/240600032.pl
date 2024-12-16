use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "37856",
    description => "Add column 'erm_usage_data_providers.service_platform'",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        if ( !column_exists( 'erm_usage_data_providers', 'service_platform' ) ) {
            $dbh->do(
                q{
              ALTER TABLE erm_usage_data_providers ADD COLUMN `service_platform` varchar(80) DEFAULT NULL COMMENT 'platform if provider requires it' AFTER `report_types`
          }
            );
            say_success( $out, "Added column 'service_platformerm_usage_data_providers'" );
        }
    },
};
