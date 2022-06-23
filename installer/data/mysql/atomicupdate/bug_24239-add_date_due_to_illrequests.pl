use Modern::Perl;

return {
    bug_number  => "24239",
    description => "Add due_date to illrequests",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};

        unless ( column_exists( 'illrequests', 'due_date' ) ) {
            $dbh->do(q{
                ALTER TABLE `illrequests`
                    ADD COLUMN `due_date` datetime DEFAULT NULL COMMENT 'Custom date due specified by backend, leave NULL for default date_due calculation'
                    AFTER `biblio_id`
            });
        }
    },
};
