use Modern::Perl;

return {
    bug_number  => 30483,
    description => "Make issues.borrowernumber and issues.itemnumber NOT NULL",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
        $dbh->do(q{
            ALTER TABLE issues
                MODIFY COLUMN borrowernumber int(11) NOT NULL COMMENT 'foreign key, linking this to the borrowers table for the patron this item was checked out to',
                MODIFY COLUMN itemnumber int(11) NOT NULL COMMENT 'foreign key, linking this to the items table for the item that was checked out'
        });
    },
};
