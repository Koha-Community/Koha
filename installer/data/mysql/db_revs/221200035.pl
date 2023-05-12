use Modern::Perl;

return {
    bug_number => 33567,
    description => "Replace empty Reference_NFL_Statuses pref",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};

        my $rv = $dbh->do(q{
            UPDATE systempreferences SET value='1|2'
            WHERE variable = 'Reference_NFL_Statuses' AND COALESCE(value,'')=''
        });
        say $out "Updated preference Reference_NFL_Statuses to default"
            if $rv && $rv == 1;
    },
};
