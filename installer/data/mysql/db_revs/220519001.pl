use Modern::Perl;

return {
    bug_number  => "36244",
    description => "Template Toolkit syntax not escaped in letter templates",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        my $query = q{SELECT * FROM letter WHERE content LIKE "[|%%SET%<<%|%]" ESCAPE '|'};
        my $sth   = $dbh->prepare($query);
        $sth->execute();
        if ( $sth->rows ) {
            say $out "You have one or more templates that have been affected by bug 36244.";
            say $out "These templates assign template toolkit variables values";
            say $out "using the double arrows syntax. E.g. [% SET name = '<<branches.branchname>>' %]";
            say $out
                "This will no longer function correctly as Template Toolkit is now rendered before the double arrow syntax.";
            say $out "The following notices will need to be updated:";

            while ( my $row = $sth->fetchrow_hashref() ) {
                say $out
                    "ID: $row->{id} / MODULE: $row->{module} / CODE: $row->{code} / BRANCHCODE: $row->{branchcode} / NAME: $row->{name}";
            }
        }
    },
};
