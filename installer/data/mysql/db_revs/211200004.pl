use Modern::Perl;

return {
    bug_number  => "26296",
    description => "Replace comma with pipe in OPACSuggestion field preferences",
    up          => sub {
        my ($args) = @_;
        my $dbh = $args->{dbh};

        $dbh->do(
            q{
            UPDATE systempreferences SET value = REPLACE(value, ',', '|')
            WHERE variable IN ('OPACSuggestionMandatoryFields','OPACSuggestionUnwantedFields')
        }
        );
    },
    }
