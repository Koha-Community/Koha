use Modern::Perl;

return {
    bug_number  => "35044",
    description => "Add repeatable option to additional_fields",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        unless ( column_exists( 'additional_fields', 'repeatable' ) ) {
            $dbh->do(
                q{
                    ALTER TABLE additional_fields ADD COLUMN `repeatable` tinyint(1) NOT NULL DEFAULT 0 COMMENT
                        'does the field allow more than one option?' AFTER searchable
                }
            );
            say $out "Added repeatable column to additional_fields table";
        }

        if ( unique_key_exists ('additional_field_values', 'field_record') ) {
            # Need to drop foreign key so that we can then drop the unique key
            $dbh->do(
                q{
                    ALTER TABLE additional_field_values DROP FOREIGN KEY afv_fk
                }
            );

            # Drop the unique key
            $dbh->do(
                q{
                    ALTER TABLE additional_field_values DROP INDEX field_record;
                }
            );

            # Restore foreign key constraint
            $dbh->do(
                q{
                    ALTER TABLE additional_field_values ADD CONSTRAINT `afv_fk` FOREIGN KEY(`field_id`) REFERENCES
                        `additional_fields` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
                }
            );
            say $out "Removed UNIQUE KEY `field_record` (`field_id`,`record_id`) from the additional_field_values table";
        }
    },
};
