use Modern::Perl;

return {
    bug_number => "33368",
    description => "Extend borrowers.flags to bigint",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
        $dbh->do(q{
            ALTER TABLE borrower_modifications
            MODIFY COLUMN `flags` bigint(11)
        });
        $dbh->do(q{
            ALTER TABLE borrowers
            MODIFY COLUMN `flags` bigint(11) DEFAULT NULL COMMENT 'will include a number associated with the staff member''s permissions'
        });
        $dbh->do(q{
            ALTER TABLE deletedborrowers
            MODIFY COLUMN `flags` bigint(11) DEFAULT NULL COMMENT 'will include a number associated with the staff member''s permissions'
        });
    },
};
