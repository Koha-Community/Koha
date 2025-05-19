use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "38457",
    description => "Add additional fields to debit types",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{ ALTER TABLE additional_field_values MODIFY record_id VARCHAR(80) NOT NULL DEFAULT '' COMMENT 'record_id' }
        );

        say_success( $out, "Converted additional_field_values.record_id to VARCHAR(80)" );
    },
};
