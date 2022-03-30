use Modern::Perl;

return {
    bug_number => '27783',
    description => 'Add background_jobs.queue',
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};

        $dbh->do(q{
            ALTER TABLE `background_jobs`
            ADD `queue` VARCHAR(191) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'default' COMMENT 'Name of the queue the job is sent to' AFTER `type`
        });
        $dbh->do(q{
            ALTER TABLE `background_jobs`
            ADD KEY `queue` (`queue`)
        });

        say $out "Added background_jobs.queue";
    },
};
