use Modern::Perl;

return {
    bug_number  => "24860",
    description => "Add ability to place item group level holds",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        unless ( column_exists( 'reserves', 'item_group_id' ) ) {
            $dbh->do(
                q{
                ALTER TABLE reserves
                ADD COLUMN `item_group_id` int(11) NULL default NULL AFTER biblionumber,
                ADD CONSTRAINT `reserves_ibfk_ig` FOREIGN KEY (`item_group_id`) REFERENCES `item_groups` (`item_group_id`) ON DELETE SET NULL ON UPDATE CASCADE;
            }
            );
        }

        unless ( column_exists( 'old_reserves', 'item_group_id' ) ) {
            $dbh->do(
                q{
                ALTER TABLE old_reserves
                ADD COLUMN `item_group_id` int(11) NULL default NULL AFTER biblionumber,
                ADD CONSTRAINT `old_reserves_ibfk_ig` FOREIGN KEY (`item_group_id`) REFERENCES `item_groups` (`item_group_id`) ON DELETE SET NULL ON UPDATE SET NULL;
            }
            );
        }

        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
            ('EnableItemGroupHolds','0','','Enable item group holds feature','YesNo')
        }
        );

        say $out "Added new system preference 'EnableItemGroupHolds'";
    },
};
