use Modern::Perl;

return {
    bug_number  => "20256",
    description => "Add ability to limit editing of items to home library",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};

        my $permission_added = $dbh->do(q{
            INSERT IGNORE INTO permissions (module_bit, code, description) VALUES ( 9, 'edit_any_item', 'Edit any item reguardless of home library');
        });

        if( $permission_added == 1 ){
            say $out "Added new permission 'edit_any_item'";

            $dbh->do(q{
                INSERT IGNORE INTO user_permissions ( borrowernumber, module_bit, code )
                SELECT borrowernumber, '9', 'edit_any_item'
                FROM user_permissions
                WHERE module_bit = '9'
                AND code = 'edit_items'
            });
            say $out "Added 'edit_any_item' permission to users with edit items permission";
        }

        if ( !column_exists( 'library_groups', 'ft_limit_item_editing' ) ) {
            $dbh->do(q{
                ALTER TABLE library_groups
                  ADD COLUMN ft_limit_item_editing tinyint(1) NOT NULL DEFAULT 0 AFTER ft_hide_patron_info
            });
    
            say $out "Added column 'library_groups.ft_limit_item_editing'";
        }
    },
};
