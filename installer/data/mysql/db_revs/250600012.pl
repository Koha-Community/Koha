use Modern::Perl;

return {
    bug_number  => "15516",
    description => "Add new table hold_groups",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        unless ( TableExists('hold_groups') ) {
            $dbh->do(
                q{CREATE TABLE hold_groups (
                hold_group_id int(10) unsigned NOT NULL AUTO_INCREMENT,
                PRIMARY KEY (hold_group_id)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci}
            );
        }

        unless ( column_exists( 'reserves', 'hold_group_id' ) ) {
            $dbh->do(
                q{ALTER TABLE reserves ADD COLUMN hold_group_id int(10) unsigned NULL DEFAULT NULL COMMENT 'The id of a group of titles reservations fulfilled when one title is picked' AFTER non_priority}
            );
            $dbh->do(q{ALTER TABLE reserves ADD KEY reserves_ibfk_hg (hold_group_id)});
            $dbh->do(
                q{ALTER TABLE reserves ADD CONSTRAINT reserves_ibfk_hg FOREIGN KEY (hold_group_id) REFERENCES hold_groups (hold_group_id) ON DELETE SET NULL ON UPDATE CASCADE}
            );
        }

        unless ( column_exists( 'old_reserves', 'hold_group_id' ) ) {
            $dbh->do(
                q{ALTER TABLE old_reserves ADD COLUMN hold_group_id int(10) unsigned NULL DEFAULT NULL COMMENT 'The id of a group of titles reservations fulfilled when one title is picked' AFTER non_priority}
            );
            $dbh->do(q{ALTER TABLE old_reserves ADD KEY old_reserves_ibfk_hg (hold_group_id)});
            $dbh->do(
                q{ALTER TABLE old_reserves ADD CONSTRAINT old_reserves_ibfk_hg FOREIGN KEY (hold_group_id) REFERENCES hold_groups (hold_group_id) ON DELETE SET NULL ON UPDATE SET NULL}
            );
        }
        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences (`variable`,`value`,`options`,`explanation`,`type`)
            VALUES ('DisplayAddHoldGroups','0','','Display the ability to create hold groups which are fulfilled by one item','YesNo')
        }
        );
    },
};
