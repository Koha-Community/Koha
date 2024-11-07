use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "33317",
    description => "Add new system preference OpacMetaRobots",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{INSERT IGNORE INTO systempreferences (variable, value, options, explanation, type) VALUES ('OpacMetaRobots','','','Improve search engine crawling.', 'Multiple') }
        );

        say_success( $out, "Added system preference 'OpacMetaRobots'" );
    },
};
