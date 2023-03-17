use Modern::Perl;

return {
    bug_number => "33197",
    description => "Rename GDPR_Policy system preference",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
        $dbh->do(q{UPDATE systempreferences set variable = "PrivacyPolicyConsent" WHERE variable = "GDPR_Policy"});
        say $out "Rename system preference GDPR_Policy to PrivacyPolicyConsent";
    },
};
