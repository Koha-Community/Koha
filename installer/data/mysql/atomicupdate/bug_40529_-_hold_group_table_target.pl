use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "40529",
    description => "Add 'hold_groups_target_hold_id' column to hold_groups",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        unless ( TableExists('hold_groups_target_holds') ) {
            $dbh->do(
                q{
                    CREATE TABLE `hold_groups_target_holds` (
                        `hold_group_id` int(10) unsigned NOT NULL COMMENT 'foreign key, linking this to the hold_groups table',
                        `reserve_id` int(11) NOT NULL COMMENT 'foreign key, linking this to the reserves table',
                        PRIMARY KEY (`hold_group_id`,`reserve_id`),
                        UNIQUE KEY `uq_hold_group_target_holds_hold_group_id` (`hold_group_id`),
                        UNIQUE KEY `uq_hold_group_target_holds_reserve_id` (`reserve_id`),
                        CONSTRAINT `hold_group_target_holds_ibfk_1` FOREIGN KEY (`hold_group_id`) REFERENCES `hold_groups` (`hold_group_id`) ON DELETE CASCADE,
                        CONSTRAINT `hold_group_target_holds_ibfk_2` FOREIGN KEY (`reserve_id`) REFERENCES `reserves` (`reserve_id`) ON DELETE CASCADE
                    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
                }
            );
            say_success( $out, "Added table 'hold_groups_target_holds'" );
        }
    },
};
