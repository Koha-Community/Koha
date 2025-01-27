use Modern::Perl;

return {
    bug_number  => "12561",
    description => "Remove system preferences HighlightOwnItemsOnOPAC and HighlightOwnItemsOnOPACWhich",
    up          => sub {
        my ($args) = @_;
        my $dbh = $args->{dbh};

        $dbh->do(
            q{ DELETE FROM systempreferences WHERE variable IN ('HighlightOwnItemsOnOPAC', 'HighlightOwnItemsOnOPACWhich')}
        );
    },
    }
