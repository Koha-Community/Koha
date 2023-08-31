use Modern::Perl;

return {
    bug_number  => "29129",
    description => "Update the DisplayClearnScreenButton system pref to allow for a choice between ISSUESLIP and ISSUEQSLIP",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};

        $dbh->do(q{
            UPDATE systempreferences
            SET
                options = 'no|issueslip|issueqslip',
                   type = 'Choice',
                  value = CASE value
                              WHEN "1" THEN 'issueslip'
                              ELSE 'no'
                          END
            WHERE variable = 'DisplayClearScreenButton';
        });
    },
};
