use Modern::Perl;

return {
    bug_number => "29200",
    description => "Remove Adlibris cover service integration",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
        # Do you stuffs here
        $dbh->do(q{DELETE FROM systempreferences WHERE variable LIKE 'AdlibrisCovers%'});
        # Print useful stuff here
        say $out "AdlibrisCoversEnabled and AdlibrisCoversURL preferences removed.";
    },
}
