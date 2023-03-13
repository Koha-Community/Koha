use Modern::Perl;

return {
    bug_number => "33192",
    description => "Rename `AutoEmailPrimaryAddress` to `EmailFieldPrimary`",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
        $dbh->do(q{
            UPDATE systempreferences SET variable = 'EmailFieldPrimary', explanation = 'Defines the default email address field where patron email notices are sent.' WHERE variable = 'AutoEmailPrimaryAddress'
        });
        say $out "Updated system preference 'AutoEmailPrimaryAddress'";
    },
};
