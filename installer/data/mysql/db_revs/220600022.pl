use Modern::Perl;

return {
    bug_number  => "30650",
    description => "Add Curbside pickup feature",
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

            say $out "Added new table 'curbside_pickup_policy'";
        }

        unless ( TableExists('curbside_pickup_opening_slots') ) {
            $dbh->do(
                q{
                CREATE TABLE `curbside_pickup_opening_slots` (
                    `id` INT(11) NOT NULL AUTO_INCREMENT,
                    `curbside_pickup_policy_id` INT(11) NOT NULL,
                    `day` TINYINT(1) NOT NULL,
                    `start_hour` INT(2) NOT NULL,
                    `start_minute` INT(2) NOT NULL,
                    `end_hour` INT(2) NOT NULL,
                    `end_minute` INT(2) NOT NULL,
                    PRIMARY KEY (`id`),
                    FOREIGN KEY (curbside_pickup_policy_id) REFERENCES curbside_pickup_policy(id) ON DELETE CASCADE ON UPDATE CASCADE
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
            }
            );

            say $out "Added new table 'curbside_pickup_opening_slots'";

            my $existing_slots = $dbh->selectall_arrayref( q{SELECT * FROM curbside_pickup_policy}, { Slice => {} } );
            my $insert_sth     = $dbh->prepare(
                q{INSERT INTO curbside_pickup_opening_slots ( curbside_pickup_policy_id, day, start_hour, start_minute, end_hour, end_minute ) VALUES (?, ?, ?, ?, ?, ?)}
            );
            for my $slot (@$existing_slots) {
                my $day_i = 0;
                for my $day (qw( sunday monday tuesday wednesday thursday friday saturday )) {
                    my $start_hour   = $slot->{ $day . '_start_hour' };
                    my $start_minute = $slot->{ $day . '_start_minute' };
                    my $end_hour     = $slot->{ $day . '_end_hour' };
                    my $end_minute   = $slot->{ $day . '_end_minute' };
                    next unless $start_hour && $start_minute && $end_hour && $end_minute;
                    $insert_sth->execute( $slot->{id}, $day_i, $start_hour, $start_minute, $end_hour, $end_minute );
                    $day_i++;
                }
            }
            $dbh->do(
                q{
                ALTER TABLE curbside_pickup_policy
                DROP COLUMN sunday_start_hour,
                DROP COLUMN sunday_start_minute,
                DROP COLUMN sunday_end_hour,
                DROP COLUMN sunday_end_minute,

                DROP COLUMN monday_start_hour,
                DROP COLUMN monday_start_minute,
                DROP COLUMN monday_end_hour,
                DROP COLUMN monday_end_minute,

                DROP COLUMN tuesday_start_hour,
                DROP COLUMN tuesday_start_minute,
                DROP COLUMN tuesday_end_hour,
                DROP COLUMN tuesday_end_minute,

                DROP COLUMN wednesday_start_hour,
                DROP COLUMN wednesday_start_minute,
                DROP COLUMN wednesday_end_hour,
                DROP COLUMN wednesday_end_minute,

                DROP COLUMN thursday_start_hour,
                DROP COLUMN thursday_start_minute,
                DROP COLUMN thursday_end_hour,
                DROP COLUMN thursday_end_minute,

                DROP COLUMN friday_start_hour,
                DROP COLUMN friday_start_minute,
                DROP COLUMN friday_end_hour,
                DROP COLUMN friday_end_minute,

                DROP COLUMN saturday_start_hour,
                DROP COLUMN saturday_start_minute,
                DROP COLUMN saturday_end_hour,
                DROP COLUMN saturday_end_minute
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

            say $out "Added new table 'curbside_pickups'";
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

            say $out "Added new table 'curbside_pickup_issues'";
        }
        $dbh->do(
            q{
                INSERT IGNORE INTO `letter` (`module`, `code`, `branchcode`, `name`, `is_html`, `title`, `content`, `message_transport_type`, `lang`) VALUES ('reserves','NEW_CURBSIDE_PICKUP','','New curbside pickup',0,"You have scheduled a curbside pickup for [% branch.branchname %]","[%- USE KohaDates -%]\n[%- SET cp = curbside_pickup -%]\n\nYou have a curbside pickup scheduled for [% cp.scheduled_pickup_datetime | $KohaDates with_hours => 1 %] at [% cp.library.branchname %].\n\nAny holds waiting for you at the pickup time will be included in this pickup. At this time, that list includes:\n[%- FOREACH h IN cp.patron.holds %]\n    [%- IF h.branchcode == cp.branchcode && h.found == 'W' %]\n* [% h.biblio.title %], [% h.biblio.author %] ([% h.item.barcode %])\n    [%- END %]\n[%- END %]\n\nOnce you have arrived, please call your library or log into your account and click the \"Alert staff of your arrival\" button to let them know you are there.",'email','default');
            }
        );

        say $out "Added new letter 'NEW_CURBSIDE_PICKUP' (email)";

        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences (`variable`, `value`, `options`, `explanation`, `type` )
            VALUES
            ('CurbsidePickup', '0', NULL, 'Enable curbside pickup', 'YesNo')
        }
        );

        say $out "Added new system preference 'CurbsidePickup'";

        $dbh->do(
            qq{
            INSERT IGNORE permissions (module_bit, code, description)
            VALUES
            (1, 'manage_curbside_pickups', 'Manage curbside pickups (circulation)')
        }
        );

        say $out "Added new permission 'manage_curbside_pickups' (circulation)";

        $dbh->do(
            qq{
            INSERT IGNORE permissions (module_bit, code, description)
            VALUES
            (3, 'manage_curbside_pickups', 'Manage curbside pickups (admin)')
        }
        );

        say $out "Added new permission 'manage_curbside_pickups' (admin)";

        unless ( column_exists( 'curbside_pickup_policy', 'enable_waiting_holds_only' ) ) {
            $dbh->do(
                q{
                ALTER table curbside_pickup_policy
                ADD COLUMN enable_waiting_holds_only TINYINT(1) NOT NULL DEFAULT 0 AFTER enabled
            }
            );

            say $out "Added column 'curbside_pickup_policy.enable_waiting_holds_only'";
        }
    }
    }
