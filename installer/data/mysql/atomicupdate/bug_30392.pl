use Modern::Perl;

return {
    bug_number => "30392",
    description => "Add deleteditems.deleted_on",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
        unless ( column_exists('items', 'deleted_on') ) {
            $dbh->do(q{
                ALTER TABLE items
                ADD COLUMN deleted_on DATETIME DEFAULT NULL COMMENT 'date of the deletion'
                AFTER timestamp
            });
        }
        unless ( column_exists('deleteditems', 'deleted_on') ) {
            $dbh->do(q{
                ALTER TABLE deleteditems
                ADD COLUMN deleted_on DATETIME DEFAULT NULL COMMENT 'date of the deletion'
                AFTER timestamp
            });
        }
    },
};
