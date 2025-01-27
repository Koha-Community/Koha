use Modern::Perl;

return {
    bug_number  => "14957",
    description => "Add a way to define overlay rules for incoming MARC records",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        unless ( TableExists('marc_overlay_rules') ) {
            $dbh->do(
                q{
                CREATE TABLE IF NOT EXISTS `marc_overlay_rules` (
                  `id` int(11) NOT NULL auto_increment,
                  `tag` varchar(255) NOT NULL, -- can be regexp, so need > 3 chars
                  `module` varchar(127) NOT NULL,
                  `filter` varchar(255) NOT NULL,
                  `add`    TINYINT(1) NOT NULL DEFAULT 0,
                  `append` TINYINT(1) NOT NULL DEFAULT 0,
                  `remove` TINYINT(1) NOT NULL DEFAULT 0,
                  `delete` TINYINT(1) NOT NULL DEFAULT 0,
                  PRIMARY KEY(`id`)
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
            }
            );

            say $out "Added new table 'marc_overlay_rules'";
        }

        $dbh->do(
            q{
          INSERT IGNORE INTO systempreferences (`variable`, `value`, `options`, `explanation`, `type`) VALUES (
            'MARCOverlayRules',
            '0',
            NULL,
            'Use the MARC record overlay rules system to decide what actions to take for each field when modifying records.',
            'YesNo'
          );
        }
        );
        say $out "Added new system preferences 'MARCOverlayRules'";

        $dbh->do(
            q{
          INSERT IGNORE INTO permissions (module_bit, code, description) VALUES (
            3,
            'manage_marc_overlay_rules',
            'Manage MARC overlay rules configuration'
          );
        }
        );
        say $out "Added new permissions 'manage_marc_overlay_rules'";
    },
    }
