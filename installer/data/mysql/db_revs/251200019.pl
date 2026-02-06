use Modern::Perl;

return {
    bug_number  => "36466",
    description => "Fix the incorrect 0000-00-00 date in planneddate and publisheddate field",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Do you stuffs here
        $dbh->do(q{update serial set planneddate=null where planneddate='0000-00-00';});
        $dbh->do(q{update serial set publisheddate=null where publisheddate='0000-00-00';});

        # Print useful stuff here
        # sysprefs
        say $out "incorrect date inplanneddate and publisheddate fixed";
    },
};
