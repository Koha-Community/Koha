use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "37292",
    description => "Add index on 'oauth_access_tokens.expires'",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        if ( !index_exists( 'oauth_access_tokens', 'expires' ) ) {
            $dbh->do(
                q{
            ALTER TABLE `oauth_access_tokens` ADD INDEX `expires` (`expires`)
            }
            );
            say_success( $out, "Added index on 'oauth_access_tokens.expires'" );
        }
    },
};
