use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "31097",
    description => "Change default 'Manual' restriction test",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(q{ UPDATE restriction_types SET display_text = "Manual restriction" WHERE display_text = "Manual"});

        say_info(
            $out,
            "Updated patron restriction types display for MANUAL restrictions from 'Manual' to 'Manual restriction'"
        );
    },
};
