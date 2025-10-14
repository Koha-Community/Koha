use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "40983",
    description => "Warn about removed pre-payload parameters of after_biblio_action hooks",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        say_warning(
            $out,
            "WARNING: A few deprecated parameters for after_biblio_action plugins have been removed now. If you still use them in your plugins, adjust your plugins right away to use the payload hash and prevent issues!"
        );
    },
};
