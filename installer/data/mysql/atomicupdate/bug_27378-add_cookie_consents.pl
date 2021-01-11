use Modern::Perl;

return {
    bug_number  => "27378",
    description => "Adds the sysprefs for cookie consents",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q| INSERT IGNORE INTO systempreferences (variable, value, explanation, options, type) VALUES ('CookieConsentedJS', '', 'Add Javascript code that will run if cookie consent is provided (e.g. tracking code).', '', 'Free'); |
        );
        say $out "Added new system preference 'CookieConsentedJS'";

        $dbh->do(
            q| INSERT IGNORE INTO systempreferences (variable, value, explanation, options, type) VALUES ('CookieConsent', '0', 'Require cookie consent to be displayed', '', 'YesNo'); |
        );
        say $out "Added new system preference 'CookieConsent'";
    },
};
