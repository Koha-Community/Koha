use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_failure say_success say_info);

return {
    bug_number  => "36819",
    description => "Change barcode width value if it still has the wrong default value",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(q{UPDATE creator_layouts SET scale_width = '0.800000' WHERE scale_width = '0.080000';});

        say $out "Changed the barcode width in patron card creator default layout to 80% if it was 8%";

    },
};
