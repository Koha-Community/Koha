use Modern::Perl;

return {
    bug_number => "24239",
    description => "Add due_date to illrequests",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
        # Do you stuffs here
        $dbh->do(q{
            ALTER TABLE `illrequests`
            ADD `due_date` datetime DEFAULT NULL AFTER `biblio_id`
        });
    },
};
