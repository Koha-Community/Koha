use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_failure say_success say_info);

return {
    bug_number  => "35635",
    description => "Add opac_mandatory column to borrower_attribute_type table",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        if ( !column_exists( 'borrower_attribute_types', 'opac_mandatory' ) ) {

            $dbh->do(
                q{
                    ALTER TABLE borrower_attribute_types
                    MODIFY COLUMN `mandatory` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'defines if the attribute is mandatory or not in the staff interface'
                }
            );
            say_success( $out, "Modified column 'borrower_attribute_types.mandatory'" );

            $dbh->do(
                q{
                    ALTER TABLE borrower_attribute_types
                    ADD COLUMN `opac_mandatory` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'defines if the attribute is mandatory or not in the OPAC'
                    AFTER `mandatory`
                }
            );
            say_success( $out, "Added column 'borrower_attribute_types.opac_mandatory'" );

            $dbh->do(
                q{
                UPDATE borrower_attribute_types
                SET opac_mandatory = 1 WHERE mandatory = 1;
            }
            );
            say_success( $out, "Update opac_mandatory to match mandatory column" );
        }
    },

};
