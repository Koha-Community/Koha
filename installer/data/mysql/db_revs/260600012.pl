use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "41649",
    description => "Add sip_magnetic column to itemtypes table for SIP media handling",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Add sip_magnetic column to itemtypes table
        unless ( column_exists( 'itemtypes', 'sip_magnetic' ) ) {
            $dbh->do(
                q{
                ALTER TABLE itemtypes
                ADD COLUMN sip_magnetic TINYINT(1) NOT NULL DEFAULT 0
                COMMENT 'Indicates if items of this type are magnetic media for SIP'
                AFTER sip_media_type
            }
            );
            say_success( $out, "Added column 'itemtypes.sip_magnetic'" );
        }
    },
};
