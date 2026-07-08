use Modern::Perl;
use Koha::Installer::Output qw(say_success);

return {
    bug_number  => "30557",
    description => "Add tables for item lists",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        unless ( TableExists('item_lists') ) {
            $dbh->do(
                q{
                CREATE TABLE IF NOT EXISTS item_lists (
                  id             INT(11)      NOT NULL AUTO_INCREMENT COMMENT 'unique id for the item list',
                  name           VARCHAR(255) NOT NULL COMMENT 'name of the item list',
                  owner          INT(11)      NULL COMMENT 'borrowernumber of the item list owner',
                  visibility     ENUM('private','group','public') NOT NULL DEFAULT 'private' COMMENT 'visibility determining ability to read the item list',
                  created_on     TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'when the item list was created',
                  updated_on     TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'when the item list was last updated',
                  PRIMARY KEY (id),
                  UNIQUE (name),
                  CONSTRAINT il_owner FOREIGN KEY (owner)    REFERENCES borrowers(borrowernumber)  ON DELETE SET NULL ON UPDATE CASCADE
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
            }
            );
            say_success( $out, 'Created item_lists table' );
        }

        unless ( TableExists('item_list_contents') ) {
            $dbh->do(
                q{
                CREATE TABLE IF NOT EXISTS item_list_contents (
                  item_list_id   INT(11)   NOT NULL COMMENT 'the item list this item belongs to',
                  itemnumber     INT(11)   NOT NULL COMMENT 'the item contained in the item list',
                  created_on     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'when this item was added to the list',
                  PRIMARY KEY (item_list_id, itemnumber),
                  CONSTRAINT ilc_list   FOREIGN KEY (item_list_id)   REFERENCES item_lists(id)             ON DELETE CASCADE,
                  CONSTRAINT ilc_item   FOREIGN KEY (itemnumber)     REFERENCES items(itemnumber)          ON DELETE CASCADE
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
            }
            );
            say_success( $out, 'Created item_list_contents table' );
        }

        unless ( TableExists('item_list_shares') ) {
            $dbh->do(
                q{
                CREATE TABLE IF NOT EXISTS item_list_shares (
                  item_list_id   INT(11)   NOT NULL COMMENT 'the item list being shared',
                  borrowernumber INT(11)   NOT NULL COMMENT 'the patron that the item list is being shared with',
                  permission     ENUM('view','edit') NOT NULL DEFAULT 'view' COMMENT 'what level of permission is being granted',
                  created_on     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'when the share was created',
                  PRIMARY KEY (item_list_id, borrowernumber),
                  CONSTRAINT ils_list   FOREIGN KEY (item_list_id)   REFERENCES item_lists(id)            ON DELETE CASCADE,
                  CONSTRAINT ils_patron FOREIGN KEY (borrowernumber) REFERENCES borrowers(borrowernumber) ON DELETE CASCADE
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
            }
            );
            say_success( $out, 'Created item_list_shares table' );
        }

        $dbh->do(
            q{
                INSERT IGNORE INTO userflags (bit, flag, flagdesc, defaulton)
                  VALUES (33, 'item_lists', 'Manage item lists', 0);
            }
        );
        say_success( $out, 'Added item_lists user flag' );

        $dbh->do(
            q{
                INSERT IGNORE INTO permissions (module_bit, code, description)
                  VALUES
                    (33, 'create_item_lists', 'Create item lists'),
                    (33, 'edit_item_lists', 'Edit item lists owned by others / public'),
                    (33, 'delete_item_lists', 'Delete item lists owned by others / public'),
                    (33, 'manage_item_list_contents', 'Add/remove items in public or group lists');
            }
        );
        say_success( $out, 'Added item list permissions' );
    },
};
