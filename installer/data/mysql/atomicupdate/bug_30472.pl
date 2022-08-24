use Modern::Perl;

return {
    bug_number => 30472,
    description => "borrower_relationships.guarantor_id NOT NULL",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
        $dbh->do(q{
ALTER TABLE borrower_relationships CHANGE COLUMN guarantor_id guarantor_id int(11) NOT NULL
        });
    },
};
