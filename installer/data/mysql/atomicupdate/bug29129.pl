use Modern::Perl;

return {
    bug_number => "29129",
    description => "Update the DisplayClearnScreenButton system pref to allow for a choice between ISSUESLIP and ISSUEQSLIP",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
        # Do you stuffs here
        $dbh->do(q{
                    UPDATE systempreferences SET options = 'no|issueslip|issueqslip', type = 'Choice', value = REPLACE( value, 0, 'no'), value =  REPLACE( value, 1, 'issueslip') WHERE variable = 'DisplayClearScreenButton';
                });
        # Print useful stuff here
        say $out "Database updated for Bug 29129";
    },
};
