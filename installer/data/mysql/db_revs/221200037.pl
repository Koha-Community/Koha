use Modern::Perl;

return {
    bug_number => "31212",
    description => "Update items.datelastseen and deleteditems.datelastseen to datetime data format",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
        $dbh->do(q{
            ALTER TABLE `items` MODIFY COLUMN `datelastseen` DATETIME DEFAULT NULL
        });
        $dbh->do(q{
            ALTER TABLE `deleteditems` MODIFY COLUMN `datelastseen` DATETIME DEFAULT NULL
        });
        say $out "items and deleteditems table updated";
    },
};
