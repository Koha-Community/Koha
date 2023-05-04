use Modern::Perl;

return {
    bug_number => 30472,
    description => "borrower_relationships.guarantor_id NOT NULL",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};

        # Delete 'empty' guarantors. No longer possible to add them via interface. Have no use.
        $dbh->do(q{
DELETE FROM borrower_relationships WHERE guarantor_id IS NULL
        });
        $dbh->do(q{
ALTER TABLE borrower_relationships CHANGE COLUMN guarantor_id guarantor_id int(11) NOT NULL
        });
    },
};
