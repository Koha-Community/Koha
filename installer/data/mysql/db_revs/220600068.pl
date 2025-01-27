use Modern::Perl;

return {
    bug_number  => "30588",
    description => "Add an 'enforce' option for 'TwoFactorAuthentication' system preference",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        $dbh->do(
            q{
            UPDATE systempreferences
            SET options="enforced|enabled|disabled",
                value=CASE value WHEN '1' THEN 'enabled' ELSE 'disabled' END,
                type="Choice"
            WHERE variable="TwoFactorAuthentication"
        }
        );

        say $out "Updated system preference 'TwoFactorAuthentication'";
    },
};
