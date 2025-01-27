use Modern::Perl;

return {
    bug_number  => 30481,
    description => "DB schema sync for deleteditems",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        my $sql =
            "ALTER TABLE deleteditems MODIFY COLUMN `stocknumber` varchar(32) default NULL";    # removes comment in db
        $dbh->do($sql);
        if ( unique_key_exists( 'deleteditems', 'deleteditemsstocknumberidx' ) ) {
            $sql = "ALTER TABLE deleteditems DROP KEY deleteditemsstocknumberidx";
            $dbh->do($sql);
        }
        if ( !index_exists( 'deleteditems', 'delitemstocknumberidx' ) ) {
            $sql = "ALTER TABLE deleteditems ADD INDEX `delitemstocknumberidx` (`stocknumber`)";
            $dbh->do($sql);
        }
    },
};
