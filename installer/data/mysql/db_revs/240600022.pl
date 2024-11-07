use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "37419",
    description => "Replace FK constraint to avoid data loss",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Drop table constraint
        if ( foreign_key_exists( 'biblio_metadata', 'record_metadata_fk_2' ) ) {
            $dbh->do(
                q{
            ALTER TABLE biblio_metadata DROP FOREIGN KEY record_metadata_fk_2
            }
            );
        }

        $dbh->do(
            q{
            ALTER TABLE biblio_metadata
            ADD CONSTRAINT `record_metadata_fk_2` FOREIGN KEY (`record_source_id`) REFERENCES `record_sources` (`record_source_id`) ON DELETE RESTRICT ON UPDATE CASCADE
        }
        );

        say_success( $out, "Updated foreign key 'biblio_metadata.record_metadata_fk_2'" );
    },
};
