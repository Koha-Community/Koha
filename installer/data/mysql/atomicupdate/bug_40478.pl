use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "40478",
    description => "Add barcode justification option to label creator",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        unless ( column_exists( 'creator_layouts', 'barcode_justify' ) ) {
            $dbh->do(
                q{
                    ALTER TABLE creator_layouts
                    ADD COLUMN barcode_justify CHAR(1) DEFAULT 'L'
                    AFTER text_justify
                }
            );
        }
        say_success( $out, "barcode_justify column added to creator_layouts" );
    },
};
