use Modern::Perl;

return {
    bug_number  => 31503,
    description => "Change patron_consent.type",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
                ALTER TABLE `patron_consent`
                    MODIFY `type` tinytext COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'consent type, could be custom type'
            }
        );
        say $out "Changed column 'patron_consent.type'";
    },
};
