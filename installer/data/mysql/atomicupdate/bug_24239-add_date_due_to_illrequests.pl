use Modern::Perl;

return {
    bug_number => "24239",
    description => "Add date_due to illrequests",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
        # Do you stuffs here
        $dbh->do(q{
            ALTER TABLE `illrequests`
            ADD `date_due` datetime DEFAULT NULL AFTER `biblio_id`
        });
    },
};
