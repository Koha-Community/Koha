use Modern::Perl;

return {
    bug_number  => "30650",
    description => "Curbside pickup tables",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        unless ( TableExists('curbside_pickup_policy') ) {
            $dbh->do(
                q{
            CREATE TABLE `curbside_pickup_policy` (
              `id` int(11) NOT NULL auto_increment,
              `branchcode` varchar(10) NOT NULL,
              `enabled` TINYINT(1) NOT NULL DEFAULT 0,
              `pickup_interval` INT(2) NOT NULL DEFAULT 0,
              `patrons_per_interval` INT(2) NOT NULL DEFAULT 0,
              `patron_scheduled_pickup` TINYINT(1) NOT NULL DEFAULT 0,
              `sunday_start_hour` INT(2) NULL DEFAULT NULL,
              `sunday_start_minute` INT(2) NULL DEFAULT NULL,
              `sunday_end_hour` INT(2) NULL DEFAULT NULL,
              `sunday_end_minute` INT(2) NULL DEFAULT NULL,
              `monday_start_hour` INT(2) NULL DEFAULT NULL,
              `monday_start_minute` INT(2) NULL DEFAULT NULL,
              `monday_end_hour` INT(2) NULL DEFAULT NULL,
              `monday_end_minute` INT(2) NULL DEFAULT NULL,
              `tuesday_start_hour` INT(2) NULL DEFAULT NULL,
              `tuesday_start_minute` INT(2) NULL DEFAULT NULL,
              `tuesday_end_hour` INT(2) NULL DEFAULT NULL,
              `tuesday_end_minute` INT(2) NULL DEFAULT NULL,
              `wednesday_start_hour` INT(2) NULL DEFAULT NULL,
              `wednesday_start_minute` INT(2) NULL DEFAULT NULL,
              `wednesday_end_hour` INT(2) NULL DEFAULT NULL,
              `wednesday_end_minute` INT(2) NULL DEFAULT NULL,
              `thursday_start_hour` INT(2) NULL DEFAULT NULL,
              `thursday_start_minute` INT(2) NULL DEFAULT NULL,
              `thursday_end_hour` INT(2) NULL DEFAULT NULL,
              `thursday_end_minute` INT(2) NULL DEFAULT NULL,
              `friday_start_hour` INT(2) NULL DEFAULT NULL,
              `friday_start_minute` INT(2) NULL DEFAULT NULL,
              `friday_end_hour` INT(2) NULL DEFAULT NULL,
              `friday_end_minute` INT(2) NULL DEFAULT NULL,
              `saturday_start_hour` INT(2) NULL DEFAULT NULL,
              `saturday_start_minute` INT(2) NULL DEFAULT NULL,
              `saturday_end_hour` INT(2) NULL DEFAULT NULL,
              `saturday_end_minute` INT(2) NULL DEFAULT NULL,
              PRIMARY KEY (`id`),
              UNIQUE KEY (`branchcode`),
              FOREIGN KEY (branchcode) REFERENCES branches(branchcode) ON DELETE CASCADE ON UPDATE CASCADE
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        }
            );
        }
        unless ( TableExists('curbside_pickups') ) {

            $dbh->do(
                q{
            CREATE TABLE `curbside_pickups` (
              `id` int(11) NOT NULL auto_increment,
              `borrowernumber` int(11) NOT NULL,
              `branchcode` varchar(10) NOT NULL,
              `scheduled_pickup_datetime` datetime NOT NULL,
              `staged_datetime` datetime NULL DEFAULT NULL,
              `staged_by` int(11) NULL DEFAULT NULL,
              `arrival_datetime` datetime NULL DEFAULT NULL,
              `delivered_datetime` datetime NULL DEFAULT NULL,
              `delivered_by` int(11) NULL DEFAULT NULL,
              `notes` text NULL DEFAULT NULL,
              PRIMARY KEY (`id`),
              FOREIGN KEY (branchcode) REFERENCES branches(branchcode) ON DELETE CASCADE ON UPDATE CASCADE,
              FOREIGN KEY (borrowernumber) REFERENCES borrowers(borrowernumber) ON DELETE CASCADE ON UPDATE CASCADE,
              FOREIGN KEY (staged_by) REFERENCES borrowers(borrowernumber) ON DELETE SET NULL ON UPDATE CASCADE
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
            }
            );
        }
        unless ( TableExists('curbside_pickup_issues') ) {
            $dbh->do(
                q{
            CREATE TABLE `curbside_pickup_issues` (
              `id` int(11) NOT NULL auto_increment,
              `curbside_pickup_id` int(11) NOT NULL,
              `issue_id` int(11) NOT NULL,
              `reserve_id` int(11) NOT NULL,
              PRIMARY KEY (`id`),
              FOREIGN KEY (curbside_pickup_id) REFERENCES curbside_pickups(id) ON DELETE CASCADE ON UPDATE CASCADE
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
                }
            );
        }

        $dbh->do(q{
            INSERT IGNORE INTO systempreferences (`variable`, `value`, `options`, `explanation`, `type` )
            VALUES
            ('CurbsidePickup', '0', NULL, 'Enable curbside pickup', 'YesNo')
        });
    }
  }
