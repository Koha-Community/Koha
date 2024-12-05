use Modern::Perl;

return {
    bug_number  => "37856",
    description => "Add service_platform column to erm_usage_data_providers",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        if ( !column_exists( 'erm_usage_data_providers', 'service_platform' ) ) {
            $dbh->do(
                q{
              ALTER TABLE erm_usage_data_providers ADD COLUMN `service_platform` varchar(80) DEFAULT NULL COMMENT 'platform if provider requires it' AFTER `report_types`
          }
            );
            say $out "Bug 37856 - Added service_platform column to table 'erm_usage_data_providers'";
        }
        say $out "Bug 37856 - Done";
    },
};
