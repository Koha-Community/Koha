use Modern::Perl;

return {
    bug_number  => "29137",
    description => "Add system preference CreateAVFromCataloguing",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences (variable, value, options, explanation, type)
            VALUES ('CreateAVFromCataloguing', '1', '', 'Ability to create authorized values from the cataloguing module', 'YesNo')
        }
        );
    },
    }
