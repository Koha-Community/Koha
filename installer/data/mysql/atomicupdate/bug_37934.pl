use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "37934",
    description => "Extend storable data for customer ID, requestor ID and API Key for ERM data providers",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{ALTER TABLE erm_usage_data_providers MODIFY COLUMN customer_id text DEFAULT NULL COMMENT 'SUSHI customer ID'}
        );
        say_success( $out, "Updated erm_usage_data_providers.customer_id to datatype text" );

        $dbh->do(
            q{ALTER TABLE erm_usage_data_providers MODIFY COLUMN requestor_id text DEFAULT NULL COMMENT 'SUSHI requestor ID'}
        );
        say_success( $out, "Updated erm_usage_data_providers.requestor_id to datatype text" );

        $dbh->do(
            q{ALTER TABLE erm_usage_data_providers MODIFY COLUMN api_key text DEFAULT NULL COMMENT 'SUSHI API key'});
        say_success( $out, "Updated erm_usage_data_providers.api_key to datatype text" );

    },
};
