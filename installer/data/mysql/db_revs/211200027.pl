use Modern::Perl;

return {
    bug_number  => "26346",
    description => "Add allow_change_from_staff to virtualshelves table",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        if ( !column_exists( 'virtualshelves', 'allow_change_from_staff' ) ) {
            $dbh->do(
                q{
                ALTER TABLE virtualshelves ADD COLUMN `allow_change_from_staff` tinyint(1) DEFAULT '0' COMMENT 'can staff change contents?'
            }
            );
        }
        $dbh->do(
            q{
            INSERT IGNORE INTO permissions (module_bit, code, description) VALUES (20, 'edit_public_lists', 'Edit public lists')
        }
        );
    },
};
