use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "36819",
    description => "Change barcode width value if it still has the wrong default value",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        my $affected = $dbh->do(q{UPDATE creator_layouts SET scale_width = '0.800000' WHERE scale_width = '0.080000';});

        if ($affected) {
            say_warning( $out, "Changed the barcode width in patron card creator default layout from 8% to 80%." );
        } else {
            say_info( $out, "No patron card creator layouts found with 8% width, no changes required." );
        }
    },
};
