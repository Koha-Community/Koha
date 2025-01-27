use Modern::Perl;

return {
    bug_number  => "30407",
    description => "Add ability to syspref UpdateNotForLoanStatusOnCheckin to show only the notforloan values message",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{UPDATE IGNORE systempreferences SET explanation = "This is a list of value pairs. When an item is checked in, if the not for loan value on the left matches the items not for loan value it will be updated to the right-hand value. E.g. '-1: 0' will cause an item that was set to 'Ordered' to now be available for loan. Can be used for showing only the not for loan description. E.g. '-1: ONLYMESSAGE'. Each pair of values should be on a separate line." WHERE variable = "UpdateNotForLoanStatusOnCheckin"}
        );
    },
};
