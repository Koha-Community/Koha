use Modern::Perl;

return {
    bug_number => "23681",
    description => "Add debarment_types",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
        # Do you stuffs here
        $dbh->do(q{
            CREATE TABLE IF NOT EXISTS debarment_types (
                code varchar(50) NOT NULL PRIMARY KEY,
                display_text text NOT NULL,
                is_system tinyint(1) NOT NULL DEFAULT 0,
                default_value tinyint(1) NOT NULL DEFAULT 0,
                can_be_added_manually tinyint(1) NOT NULL DEFAULT 0
            ) ENGINE=InnoDB  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        });
        $dbh->do(q{
            INSERT IGNORE INTO debarment_types (code, display_text, is_system, default_value, can_be_added_manually) VALUES
            ('MANUAL', 'Manual', 1, 1, 0),
            ('OVERDUES', 'Overdues', 1, 0, 0),
            ('SUSPENSION', 'Suspension', 1, 0, 0),
            ('DISCHARGE', 'Discharge', 1, 0, 0);
        });
        $dbh->do(q{
            ALTER TABLE borrower_debarments
            MODIFY COLUMN type varchar(50) NOT NULL
        });
        $dbh->do(q{
            ALTER TABLE borrower_debarments
            ADD CONSTRAINT borrower_debarments_ibfk_2 FOREIGN KEY (type) REFERENCES debarment_types(code) ON DELETE NO ACTION ON UPDATE CASCADE;
        });
        # Print useful stuff here
        say $out "Update is going well so far";
    },
};