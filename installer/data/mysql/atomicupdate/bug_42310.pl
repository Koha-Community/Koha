use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "42310",
    description => "Normalize calendar tables into Koha::Library::Calendar::* schema",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # The new tables introduce UNIQUE constraints that did not exist on
        # repeatable_holidays / special_holidays. INSERT IGNORE silently drops
        # any legacy duplicates (same library_id + weekday, (day, month), or
        # date). Compare source vs destination counts and warn the operator
        # when rows are dropped so they can recover titles/descriptions from
        # the pre-upgrade database dump if needed.

        if ( !TableExists('library_weekly_closures') ) {
            $dbh->do(
                q{
                CREATE TABLE `library_weekly_closures` (
                    `library_weekly_closure_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'unique identifier',
                    `library_id` varchar(10) NOT NULL COMMENT 'foreign key from the branches table',
                    `weekday` smallint(6) NOT NULL COMMENT 'day of the week (0=Sunday, 1=Monday, etc)',
                    `title` varchar(50) NOT NULL DEFAULT '' COMMENT 'title of this closing',
                    `description` mediumtext NOT NULL COMMENT 'description for this closing',
                    PRIMARY KEY (`library_weekly_closure_id`),
                    UNIQUE KEY `library_id_weekday` (`library_id`, `weekday`),
                    CONSTRAINT `library_weekly_closures_ibfk_1` FOREIGN KEY (`library_id`)
                        REFERENCES `branches` (`branchcode`) ON DELETE CASCADE ON UPDATE CASCADE
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
            }
            );

            my ($src_weekly) =
                $dbh->selectrow_array(q{ SELECT COUNT(*) FROM repeatable_holidays WHERE weekday IS NOT NULL });

            $dbh->do(
                q{
                INSERT IGNORE INTO library_weekly_closures (library_id, weekday, title, description)
                SELECT branchcode, weekday, title, description
                FROM repeatable_holidays WHERE weekday IS NOT NULL
            }
            );

            my ($dst_weekly) = $dbh->selectrow_array(q{ SELECT COUNT(*) FROM library_weekly_closures });

            say_success( $out, "Added new table 'library_weekly_closures' ($dst_weekly row(s) migrated)" );
            if ( $src_weekly > $dst_weekly ) {
                my $skipped = $src_weekly - $dst_weekly;
                say_warning(
                    $out,
                    sprintf(
                        "%d duplicate weekly-closure row(s) skipped by UNIQUE(library_id, weekday); inspect repeatable_holidays in your pre-upgrade backup if titles/descriptions need recovering",
                        $skipped
                    )
                );
            }
        }

        if ( !TableExists('library_repeating_closures') ) {
            $dbh->do(
                q{
                CREATE TABLE `library_repeating_closures` (
                    `library_repeating_closure_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'unique identifier',
                    `library_id` varchar(10) NOT NULL COMMENT 'foreign key from the branches table',
                    `day` smallint(6) NOT NULL COMMENT 'day of the month this closing is on',
                    `month` smallint(6) NOT NULL COMMENT 'month this closing is in',
                    `title` varchar(50) NOT NULL DEFAULT '' COMMENT 'title of this closing',
                    `description` mediumtext NOT NULL COMMENT 'description for this closing',
                    PRIMARY KEY (`library_repeating_closure_id`),
                    UNIQUE KEY `library_id_day_month` (`library_id`, `day`, `month`),
                    CONSTRAINT `library_repeating_closures_ibfk_1` FOREIGN KEY (`library_id`)
                        REFERENCES `branches` (`branchcode`) ON DELETE CASCADE ON UPDATE CASCADE
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
            }
            );

            my ($src_rep) = $dbh->selectrow_array(q{ SELECT COUNT(*) FROM repeatable_holidays WHERE weekday IS NULL });

            $dbh->do(
                q{
                INSERT IGNORE INTO library_repeating_closures (library_id, day, month, title, description)
                SELECT branchcode, day, month, title, description
                FROM repeatable_holidays WHERE weekday IS NULL
            }
            );

            my ($dst_rep) = $dbh->selectrow_array(q{ SELECT COUNT(*) FROM library_repeating_closures });

            say_success( $out, "Added new table 'library_repeating_closures' ($dst_rep row(s) migrated)" );
            if ( $src_rep > $dst_rep ) {
                my $skipped = $src_rep - $dst_rep;
                say_warning(
                    $out,
                    sprintf(
                        "%d duplicate repeating-closure row(s) skipped by UNIQUE(library_id, day, month); inspect repeatable_holidays in your pre-upgrade backup if titles/descriptions need recovering",
                        $skipped
                    )
                );
            }
        }

        if ( !TableExists('library_single_closures') ) {
            $dbh->do(
                q{
                CREATE TABLE `library_single_closures` (
                    `library_single_closure_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'unique identifier',
                    `library_id` varchar(10) NOT NULL COMMENT 'foreign key from the branches table',
                    `date` date NOT NULL COMMENT 'date of the closure',
                    `title` varchar(50) NOT NULL DEFAULT '' COMMENT 'title for this closing',
                    `description` mediumtext NOT NULL COMMENT 'description of this closing',
                    PRIMARY KEY (`library_single_closure_id`),
                    UNIQUE KEY `library_id_date` (`library_id`, `date`),
                    CONSTRAINT `library_single_closures_ibfk_1` FOREIGN KEY (`library_id`)
                        REFERENCES `branches` (`branchcode`) ON DELETE CASCADE ON UPDATE CASCADE
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
            }
            );

            my ($src_single) = $dbh->selectrow_array(q{ SELECT COUNT(*) FROM special_holidays WHERE isexception = 0 });

            $dbh->do(
                q{
                INSERT IGNORE INTO library_single_closures (library_id, date, title, description)
                SELECT branchcode,
                       CONCAT(year, '-', LPAD(month, 2, '0'), '-', LPAD(day, 2, '0')),
                       title, description
                FROM special_holidays WHERE isexception = 0
            }
            );

            my ($dst_single) = $dbh->selectrow_array(q{ SELECT COUNT(*) FROM library_single_closures });

            say_success( $out, "Added new table 'library_single_closures' ($dst_single row(s) migrated)" );
            if ( $src_single > $dst_single ) {
                my $skipped = $src_single - $dst_single;
                say_warning(
                    $out,
                    sprintf(
                        "%d duplicate single-closure row(s) skipped by UNIQUE(library_id, date); inspect special_holidays in your pre-upgrade backup if titles/descriptions need recovering",
                        $skipped
                    )
                );
            }
        }

        if ( !TableExists('library_closure_exceptions') ) {
            $dbh->do(
                q{
                CREATE TABLE `library_closure_exceptions` (
                    `library_closure_exception_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'unique identifier',
                    `library_id` varchar(10) NOT NULL COMMENT 'foreign key from the branches table',
                    `date` date NOT NULL COMMENT 'date of the exception (library is open despite a closure rule)',
                    `title` varchar(50) NOT NULL DEFAULT '' COMMENT 'title for this exception',
                    `description` mediumtext NOT NULL COMMENT 'description of this exception',
                    PRIMARY KEY (`library_closure_exception_id`),
                    UNIQUE KEY `library_id_date` (`library_id`, `date`),
                    CONSTRAINT `library_closure_exceptions_ibfk_1` FOREIGN KEY (`library_id`)
                        REFERENCES `branches` (`branchcode`) ON DELETE CASCADE ON UPDATE CASCADE
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
            }
            );

            my ($src_exc) = $dbh->selectrow_array(q{ SELECT COUNT(*) FROM special_holidays WHERE isexception = 1 });

            $dbh->do(
                q{
                INSERT IGNORE INTO library_closure_exceptions (library_id, date, title, description)
                SELECT branchcode,
                       CONCAT(year, '-', LPAD(month, 2, '0'), '-', LPAD(day, 2, '0')),
                       title, description
                FROM special_holidays WHERE isexception = 1
            }
            );

            my ($dst_exc) = $dbh->selectrow_array(q{ SELECT COUNT(*) FROM library_closure_exceptions });

            say_success( $out, "Added new table 'library_closure_exceptions' ($dst_exc row(s) migrated)" );
            if ( $src_exc > $dst_exc ) {
                my $skipped = $src_exc - $dst_exc;
                say_warning(
                    $out,
                    sprintf(
                        "%d duplicate closure-exception row(s) skipped by UNIQUE(library_id, date); inspect special_holidays in your pre-upgrade backup if titles/descriptions need recovering",
                        $skipped
                    )
                );
            }
        }

        if ( TableExists('repeatable_holidays') ) {
            $dbh->do(q{ DROP TABLE `repeatable_holidays` });
            say_success( $out, "Dropped legacy table 'repeatable_holidays'" );
        }

        if ( TableExists('special_holidays') ) {
            $dbh->do(q{ DROP TABLE `special_holidays` });
            say_success( $out, "Dropped legacy table 'special_holidays'" );
        }
    },
};
