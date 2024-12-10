use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "38663",
    description => "Add additional fields to libraries",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(q{ ALTER TABLE additional_field_values ADD COLUMN new_record_id VARCHAR(11) NOT NULL DEFAULT ''; });

        $dbh->do(q{ UPDATE additional_field_values SET new_record_id = CAST(record_id AS CHAR(11)); });

        $dbh->do(q{ ALTER TABLE additional_field_values DROP COLUMN record_id; });

        $dbh->do(q{ ALTER TABLE additional_field_values RENAME COLUMN new_record_id TO record_id; });

        say_success( $out, "Converted record_id to VARCHAR" );
    },
};
