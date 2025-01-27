use Modern::Perl;

return {
    bug_number  => "24606",
    description => "Add new table item_editor_templates",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        unless ( TableExists('item_editor_templates') ) {
            $dbh->do(
                q{
                CREATE TABLE `item_editor_templates` (
                  `id` INT(11) NOT NULL auto_increment COMMENT "id for the template",
                  `patron_id` int(11) DEFAULT NULL COMMENT "creator of this template",
                  `name` MEDIUMTEXT NOT NULL COMMENT "template name",
                  `is_shared` TINYINT(1) NOT NULL DEFAULT 0 COMMENT "controls if template is shared",
                  `contents` LONGTEXT NOT NULL COMMENT "json encoded template data",
                  PRIMARY KEY  (`id`),
                  CONSTRAINT `bn` FOREIGN KEY (`patron_id`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE CASCADE
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
            }
            );

            say $out "Added new table 'item_editor_templates'";

            $dbh->do(
                q{
                INSERT IGNORE INTO permissions (module_bit, code, description) VALUES
                ( 9, 'manage_item_editor_templates', 'Update and delete item editor template owned by others');
            }
            );

            say $out "Added new permission 'manage_item_editor_templates'";
        }
    },
};
