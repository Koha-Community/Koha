use Modern::Perl;

return {
    bug_number  => "24857",
    description => "Add ability to group items on a record",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
            ('EnableItemGroups','0','','Enable the item groups feature','YesNo');
        }
        );

        say $out "Added new system preference 'EnableItemGroups'";

        $dbh->do(
            q{
            INSERT IGNORE INTO permissions (module_bit, code, description) VALUES
            ( 9, 'manage_item_groups', 'Create, update and delete item groups, add or remove items from a item groups');
        }
        );

        say $out "Added new permission 'manage_item_groups'";

        unless ( TableExists('item_groups') ) {
            $dbh->do(
                q{
                CREATE TABLE `item_groups` (
                    `item_group_id` INT(11) NOT NULL auto_increment COMMENT "id for the items group",
                    `biblio_id` INT(11) NOT NULL DEFAULT 0 COMMENT "id for the bibliographic record the group belongs to",
                    `display_order` INT(4) NOT NULL DEFAULT 0 COMMENT "The 'sort order' for item_groups",
                    `description` MEDIUMTEXT default NULL COMMENT "A group description",
                    `created_on` TIMESTAMP NULL COMMENT "Time and date the group was created",
                    `updated_on` TIMESTAMP NOT NULL ON UPDATE CURRENT_TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT "Time and date of the latest change on the group",
                    PRIMARY KEY  (`item_group_id`),
                    CONSTRAINT `item_groups_ibfk_1` FOREIGN KEY (`biblio_id`) REFERENCES `biblio` (`biblionumber`) ON DELETE CASCADE ON UPDATE CASCADE
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
            }
            );

            say $out "Added new table 'item_groups'";
        }

        unless ( TableExists('item_group_items') ) {
            $dbh->do(
                q{
                CREATE TABLE `item_group_items` (
                    `item_group_items_id` int(11) NOT NULL auto_increment COMMENT "id for the group/item link",
                    `item_group_id` INT(11) NOT NULL DEFAULT 0 COMMENT "foreign key making this table a 1 to 1 join from items to item groups",
                    `item_id` INT(11) NOT NULL DEFAULT 0 COMMENT "foreign key linking this table to the items table",
                    PRIMARY KEY  (`item_group_items_id`),
                    UNIQUE KEY (`item_id`),
                    CONSTRAINT `item_group_items_iifk_1` FOREIGN KEY (`item_id`) REFERENCES `items` (`itemnumber`) ON DELETE CASCADE ON UPDATE CASCADE,
                    CONSTRAINT `item_group_items_gifk_1` FOREIGN KEY (`item_group_id`) REFERENCES `item_groups` (`item_group_id`) ON DELETE CASCADE ON UPDATE CASCADE
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
            }
            );

            say $out "Added new table 'item_group_items'";
        }
    },
    }
