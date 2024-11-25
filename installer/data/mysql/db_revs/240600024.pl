use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

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
                        'is the field repeatable?' AFTER searchable
                }
            );
            say_success( $out, "Added repeatable column to additional_fields table" );
        }

        if ( unique_key_exists( 'additional_field_values', 'field_record' ) ) {

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
            say_success(
                $out,
                "Removed UNIQUE KEY `field_record` (`field_id`,`record_id`) from the additional_field_values table"
            );
        }

        my $number_of_entries = $dbh->do(q{DELETE FROM additional_field_values WHERE value = ''});
        if ( defined $number_of_entries && $number_of_entries > 0 ) {
            say_info( $out, "Removed $number_of_entries redundant additional_field_values entries with empty value" );
        }
    },
};
