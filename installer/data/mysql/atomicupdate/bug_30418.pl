use Modern::Perl;

return {
    bug_number => "30418",
    description => "Add new list permission and new column to virtualshelves",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};

	if( !column_exists( 'virtualshelves', 'allow_change_from_permitted_staff' ) ) {
	    $dbh->do(q{ALTER TABLE virtualshelves ADD COLUMN `allow_change_from_permitted_staff` tinyint(1) DEFAULT '0' COMMENT 'can staff with edit_public_list_contents permission change contents?'});
        }

	$dbh->do(q{ INSERT IGNORE INTO permissions (module_bit, code, description) VALUES (20, 'edit_public_list_contents', 'Edit public list contents') });
    },
};
