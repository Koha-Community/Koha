use Modern::Perl;

return {
    bug_number  => '27783',
    description => 'Add background_jobs.queue',
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        unless ( column_exists( 'background_jobs', 'queue' ) ) {
            $dbh->do(
                q{
                ALTER TABLE `background_jobs`
                ADD COLUMN `queue` VARCHAR(191) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'default' COMMENT 'Name of the queue the job is sent to' AFTER `type`
            }
            );
        }

        unless ( index_exists( 'background_jobs', 'queue' ) ) {
            $dbh->do(
                q{
                ALTER TABLE `background_jobs`
                ADD KEY `queue` (`queue`)
            }
            );
        }

        say $out "Added background_jobs.queue";
    },
};
