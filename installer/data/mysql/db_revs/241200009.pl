use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "36954",
    description => "Adjustment for logfiles in koha-sip",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        say_warning(
            $out,
            "IMPORTANT: If you use SIP, please edit your /etc/koha/sites/[CLONE]/log4perl.conf at upgrade time."
        );
        say_warning( $out, "Replace sip.log there by sip-output.log." );
    },
};
