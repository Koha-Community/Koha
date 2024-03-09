use Modern::Perl;

return {
    bug_number  => "35169",
    description => "Add new system preferences for longoverdue.pl borrowers categories",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Do you stuffs here
        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences (variable, value, options, explanation, type) VALUES
            ('DefaultLongOverdueBorrowerCategories', '', NULL, 'Set the borrower categories that will be listed when longoverdue cronjob is executed', 'choice'),
            ('DefaultLongOverdueSkipBorrowerCategories', '', NULL, 'Set the borrower categories that will not be listed when longoverdue cronjob is executed', 'choice');
        }
        );

        # sysprefs
        say $out "Added new system preference 'DefaultLongOverdueBorrowerCategories'";
        say $out "Added new system preference 'DefaultLongOverdueSkipBorrowerCategories'";
    },
};
