use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "36153",
    description => "Increase allowed length of authorised value descriptions",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        if ( column_exists( 'authorised_values', 'lib' ) ) {

            $dbh->do(
                q{
                ALTER TABLE authorised_values
                MODIFY COLUMN `lib` varchar(400) DEFAULT NULL COMMENT 'authorized value description as printed in the staff interface'
            }
            );

            say_success( $out, "Modified column 'authorised_values.lib' to accept 400 characters" );

        } else {
            say_info( $out, "Column 'authorised_values.lib' does not exist!" );
        }

        if ( column_exists( 'authorised_values', 'lib_opac' ) ) {

            $dbh->do(
                q{
                ALTER TABLE authorised_values
                MODIFY COLUMN `lib_opac` varchar(400) DEFAULT NULL COMMENT 'authorized value description as printed in the OPAC'
            }
            );

            say_success( $out, "Modified column 'authorised_values.lib_opac' to accept 400 characters" );

        } else {
            say_info( $out, "Column 'authorised_values.lib_opac' does not exist!" );
        }
    },
};
