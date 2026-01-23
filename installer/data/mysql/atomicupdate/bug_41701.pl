use Modern::Perl;

return {
    bug_number  => "41701",
    description => "Fix values of OAI-PMH:DeletedRecord options and explanation columns",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        $dbh->do(
            q{UPDATE systempreferences SET options = 'transient|persistent|no', explanation = 'Koha\'s deletedbiblio table will never be deleted (persistent), might be deleted (transient), or will never have any data in it (no)' WHERE variable = 'OAI-PMH:DeletedRecord'}
        );
    },
    }
