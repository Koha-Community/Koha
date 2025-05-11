use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "39618",
    description => "Add index to borrowers.preferred_name",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        unless ( index_exists( 'borrowers', 'preferred_name_idx' ) ) {
            $dbh->do(
                q{
                ALTER TABLE `borrowers`
                ADD KEY `preferred_name_idx` (`preferred_name`(768))
            }
            );
            say_success( $out, "Added index to borrowers.preferred_name" );
        }
    },
};
