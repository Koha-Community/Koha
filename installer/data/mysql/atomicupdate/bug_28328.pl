use Modern::Perl;

return {
    bug_number => "28328",
    description => "Extend biblioitems.lccn",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
        # Do you stuffs here
        $dbh->do(q{
            ALTER TABLE `biblioitems`
            MODIFY COLUMN `lccn` longtext DEFAULT NULL COMMENT 'library of congress control number (MARC21 010$a)'
        });
        $dbh->do(q{
            ALTER TABLE `deletedbiblioitems`
            MODIFY COLUMN `lccn` longtext DEFAULT NULL COMMENT 'library of congress control number (MARC21 010$a)'
        });
    },
};
