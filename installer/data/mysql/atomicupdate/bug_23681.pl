use Modern::Perl;

return {
    bug_number => "23681",
    description => "Add customisable patron restriction types",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};

        $dbh->do(q{
            CREATE TABLE IF NOT EXISTS debarment_types (
                code varchar(50) NOT NULL PRIMARY KEY,
                display_text text NOT NULL,
                is_system tinyint(1) NOT NULL DEFAULT 0,
                default_value tinyint(1) NOT NULL DEFAULT 0,
                can_be_added_manually tinyint(1) NOT NULL DEFAULT 0
            ) ENGINE=InnoDB  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        });
        say $out "Added debarment_types table";

        $dbh->do(q{
            INSERT IGNORE INTO debarment_types (code, display_text, is_system, default_value, can_be_added_manually) VALUES
            ('MANUAL', 'Manual', 1, 1, 0),
            ('OVERDUES', 'Overdues', 1, 0, 0),
            ('SUSPENSION', 'Suspension', 1, 0, 0),
            ('DISCHARGE', 'Discharge', 1, 0, 0);
        });
        say $out "Added system debarment_types";

        unless ( foreign_key_exists('borrower_debarments', 'borrower_debarments_ibfk_2') ) {
            $dbh->do(q{
                ALTER TABLE borrower_debarments
                MODIFY COLUMN type varchar(50) NOT NULL
            });
            $dbh->do(q{
                ALTER TABLE borrower_debarments
                ADD CONSTRAINT borrower_debarments_ibfk_2 FOREIGN KEY (type) REFERENCES debarment_types(code) ON DELETE NO ACTION ON UPDATE CASCADE;
            });
            say $out "Added borrower_debarments relation";
        }

        $dbh->do(q{ INSERT IGNORE INTO permissions (module_bit, code, description) VALUES ( 3, 'manage_patron_restrictions', 'Manage patron restrictions')});
        say $out "Added manage_patron_restrictions permission";

        $dbh->do(q{INSERT IGNORE INTO systempreferences (variable, value, explanation, options, type) VALUES ('PatronRestrictionTypes', '0', 'If enabled, it is possible to specify the "type" of patron restriction being applied.', '', 'YesNo');});
        say $out "Added PatronRestrictionTypes preference";
    },
};
