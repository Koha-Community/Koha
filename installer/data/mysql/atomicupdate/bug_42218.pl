use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "42218",
    description => "Rebuild erm_usage_yus from erm_usage_mus",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(q{DELETE FROM erm_usage_yus});

        my $rows = $dbh->do(
            q{
                INSERT INTO erm_usage_yus (
                    title_id, platform_id, database_id, item_id,
                    usage_data_provider_id, year, totalcount,
                    metric_type, access_type, yop, report_type
                )
                SELECT
                    title_id, platform_id, database_id, item_id,
                    usage_data_provider_id, year,
                    CAST(SUM(usage_count) AS SIGNED),
                    metric_type, access_type, yop, report_type
                FROM erm_usage_mus
                GROUP BY
                    title_id, platform_id, database_id, item_id,
                    usage_data_provider_id, year,
                    metric_type, access_type, yop, report_type
            }
        );

        say_success( $out, sprintf( "Rebuilt erm_usage_yus from erm_usage_mus (%d rows)", $rows + 0 ) );
    },
};
