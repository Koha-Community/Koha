use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "42310",
    description => "Normalize calendar tables into Koha::Calendar::* schema",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        unless ( TableExists('library_weekly_closures') ) {
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

            $dbh->do(
                q{
                INSERT IGNORE INTO library_weekly_closures (library_id, weekday, title, description)
                SELECT branchcode, weekday, title, description
                FROM repeatable_holidays WHERE weekday IS NOT NULL
            }
            );

            say $out "Added new table 'library_weekly_closures'";
        }

        unless ( TableExists('library_repeating_closures') ) {
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

            $dbh->do(
                q{
                INSERT IGNORE INTO library_repeating_closures (library_id, day, month, title, description)
                SELECT branchcode, day, month, title, description
                FROM repeatable_holidays WHERE weekday IS NULL
            }
            );

            say $out "Added new table 'library_repeating_closures'";
        }

        unless ( TableExists('library_single_closures') ) {
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

            $dbh->do(
                q{
                INSERT IGNORE INTO library_single_closures (library_id, date, title, description)
                SELECT branchcode,
                       CONCAT(year, '-', LPAD(month, 2, '0'), '-', LPAD(day, 2, '0')),
                       title, description
                FROM special_holidays WHERE isexception = 0
            }
            );

            say $out "Added new table 'library_single_closures'";
        }

        unless ( TableExists('library_closure_exceptions') ) {
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

            $dbh->do(
                q{
                INSERT IGNORE INTO library_closure_exceptions (library_id, date, title, description)
                SELECT branchcode,
                       CONCAT(year, '-', LPAD(month, 2, '0'), '-', LPAD(day, 2, '0')),
                       title, description
                FROM special_holidays WHERE isexception = 1
            }
            );

            say $out "Added new table 'library_closure_exceptions'";
        }

        $dbh->do(q{ DROP TABLE IF EXISTS `repeatable_holidays` });
        say $out "Dropped table 'repeatable_holidays'";

        $dbh->do(q{ DROP TABLE IF EXISTS `special_holidays` });
        say $out "Dropped table 'special_holidays'";
    },
};
