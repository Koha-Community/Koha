use Modern::Perl;

return {
    bug_number => 30933,
    description => "Add pref ListOwnerDesignated",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
        $dbh->do(q{
INSERT IGNORE INTO systempreferences (variable, value, options, explanation, type)
VALUES ('ListOwnerDesignated', NULL, NULL, 'Designated list owner at patron deletion', 'Free')
        });
        $dbh->do(q{
UPDATE systempreferences SET explanation='Defines the action on their public or shared lists when patron is deleted'
WHERE variable = 'ListOwnershipUponPatronDeletion'
        });
    },
};
