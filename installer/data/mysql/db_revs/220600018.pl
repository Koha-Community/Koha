use Modern::Perl;

return {
    bug_number => 11889,
    description => "Add pref ListOwnershipUponPatronDeletion",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
        $dbh->do(q{
INSERT IGNORE INTO systempreferences (`variable`,`value`,`options`,`explanation`,`type`) VALUES ('ListOwnershipUponPatronDeletion', 'delete', 'delete|transfer', 'When deleting a patron who owns public lists, either delete the public lists or transfer ownership to the patron who deleted the owner', 'Choice');
        });
    },
};
