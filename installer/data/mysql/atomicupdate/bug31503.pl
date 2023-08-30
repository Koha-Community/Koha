use Modern::Perl;

return {
    bug_number  => 31503,
    description => "Change patron_consent.type, add pref OPACCustomConsentTypes",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{ALTER TABLE `patron_consent` MODIFY `type` tinytext COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'consent type, could be custom type'}
        );
        say $out "Changed column 'patron_consent.type'";

        $dbh->do(
            q{INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
('OPACCustomConsentTypes', '0', NULL, 'If enabled, custom consent types can be registered on account page', 'YesNo')}
        );
        say $out "Addedd preference 'OPACCustomConsentTypes'";
    },
};
