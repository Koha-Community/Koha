use Modern::Perl;

return {
    bug_number  => "23681",
    description => "Add customisable patron restriction types",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        unless ( TableExists('restriction_types') ) {
            $dbh->do(
                q{
                CREATE TABLE `restriction_types` (
                    `code` varchar(50) NOT NULL,
                    `display_text` text NOT NULL,
                    `is_system` tinyint(1) NOT NULL DEFAULT 0,
                    `is_default` tinyint(1) NOT NULL DEFAULT 0,
                    PRIMARY KEY (`code`)
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
            }
            );

            say $out "Added new table 'restriction_types'";
        }

        $dbh->do(
            q{
            INSERT IGNORE INTO restriction_types (code, display_text, is_system, is_default) VALUES
            ('MANUAL',     'Manual',     0, 1),
            ('OVERDUES',   'Overdues',   1, 0),
            ('SUSPENSION', 'Suspension', 1, 0),
            ('DISCHARGE',  'Discharge',  1, 0);
        }
        );
        say $out "Added system restriction_types";

        unless ( foreign_key_exists( 'borrower_debarments', 'borrower_debarments_ibfk_2' ) ) {
            $dbh->do(
                q{
                ALTER TABLE borrower_debarments
                MODIFY COLUMN type varchar(50) NOT NULL
            }
            );
            $dbh->do(
                q{
                ALTER TABLE borrower_debarments
                ADD CONSTRAINT `borrower_debarments_ibfk_2` FOREIGN KEY (`type`)  REFERENCES `restriction_types` (`code`) ON DELETE NO ACTION ON UPDATE CASCADE;
            }
            );

            say $out "Added borrower_debarments relation";
        }

        $dbh->do(
            q{ INSERT IGNORE INTO permissions (module_bit, code, description) VALUES ( 3, 'manage_patron_restrictions', 'Manage patron restrictions')}
        );
        say $out "Added new permission 'manage_patron_restrictions'";

        $dbh->do(
            q{INSERT IGNORE INTO systempreferences (variable, value, explanation, options, type) VALUES ('PatronRestrictionTypes', '0', 'If enabled, it is possible to specify the "type" of patron restriction being applied.', '', 'YesNo');}
        );
        say $out "Added new system preference 'PatronRestrictionTypes'";
    },
};
