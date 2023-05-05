use Modern::Perl;

return {
    bug_number => "33053",
    description => "Remove default from biblio_id for item_groups and recalls tables",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
        $dbh->do(q{
            ALTER TABLE item_groups CHANGE COLUMN `biblio_id` `biblio_id` int(11) NOT NULL COMMENT 'id for the bibliographic record the group belongs to'
        });
        $dbh->do(q{
            ALTER TABLE recalls CHANGE COLUMN `biblio_id` `biblio_id` int(11) NOT NULL COMMENT 'Identifier for bibliographic record that has been recalled'
        });
    },
};
