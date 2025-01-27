use Modern::Perl;

return {
    bug_number  => "32330",
    description => "Add indexes to background_jobs table",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        unless ( index_exists( 'background_jobs', 'borrowernumber' ) ) {
            $dbh->do(
                q{
                ALTER TABLE `background_jobs` ADD INDEX `borrowernumber` (`borrowernumber`)
            }
            );
        }
        unless ( index_exists( 'background_jobs', 'queue' ) ) {
            $dbh->do(
                q{
                ALTER TABLE `background_jobs` ADD INDEX `queue` (`queue`)
            }
            );
        }
        unless ( index_exists( 'background_jobs', 'status' ) ) {
            $dbh->do(
                q{
                ALTER TABLE `background_jobs` ADD INDEX `status` (`status`)
            }
            );
        }
    },
};
