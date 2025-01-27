use Modern::Perl;

return {
    bug_number  => "29200",
    description => "Remove Adlibris cover service integration",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        $dbh->do(q{DELETE FROM systempreferences WHERE variable LIKE 'AdlibrisCovers%'});
        say $out "AdlibrisCoversEnabled and AdlibrisCoversURL preferences removed.";
    },
    }
