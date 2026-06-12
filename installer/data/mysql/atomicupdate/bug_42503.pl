use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "42503",
    description => "Add materialized description columns to tmp_holdsqueue",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        unless ( column_exists( 'tmp_holdsqueue', 'itype_description' ) ) {
            $dbh->do(
                q{
                ALTER TABLE tmp_holdsqueue
                    ADD COLUMN `itype_description` varchar(255) DEFAULT NULL AFTER `local_holdgroup_match`
            }
            );
            say_success( $out, "Added column 'tmp_holdsqueue.itype_description'" );
        }

        unless ( column_exists( 'tmp_holdsqueue', 'ccode_description' ) ) {
            $dbh->do(
                q{
                ALTER TABLE tmp_holdsqueue
                    ADD COLUMN `ccode_description` varchar(255) DEFAULT NULL AFTER `itype_description`
            }
            );
            say_success( $out, "Added column 'tmp_holdsqueue.ccode_description'" );
        }

        unless ( column_exists( 'tmp_holdsqueue', 'location_description' ) ) {
            $dbh->do(
                q{
                ALTER TABLE tmp_holdsqueue
                    ADD COLUMN `location_description` varchar(255) DEFAULT NULL AFTER `ccode_description`
            }
            );
            say_success( $out, "Added column 'tmp_holdsqueue.location_description'" );
        }
    },
};
