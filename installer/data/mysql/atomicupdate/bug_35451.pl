use Modern::Perl;

return {
    bug_number  => "35451",
    description => "Add record_table field and index to additional_field_values",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        unless ( column_exists( 'additional_field_values', 'record_table' ) ) {
            $dbh->do(
                q{
                ALTER TABLE additional_field_values ADD record_table varchar(255) NOT NULL DEFAULT '' COMMENT 'tablename of the related record' AFTER field_id
            }
            );

            $dbh->do(
                q{
                UPDATE
                    additional_field_values AS v
                INNER JOIN
                    additional_fields AS f ON f.id = v.field_id
                SET
                    v.record_table = f.tablename
            }
            );
            say $out "Added column 'additional_field_values.record_table'";
        }

        unless ( index_exists( 'additional_field_values', 'record_table' ) ) {
            $dbh->do(
                q{
                ALTER TABLE `additional_field_values`
                ADD KEY `record_table` (`record_table`)
            }
            );

            say $out "Added index 'record_table' to 'additional_field_values'";
        }
    },
};
