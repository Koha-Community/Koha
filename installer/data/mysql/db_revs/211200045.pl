use Modern::Perl;

return {
    bug_number  => "14242",
    description => "Add OPACSuggestionAutoFill system preference",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences (`variable`, `value`, `options`, `explanation`,`type`)
            VALUES ('OPACSuggestionAutoFill', '0', NULL, 'Automatically fill OPAC suggestion form with data from Google Books API', 'YesNo')
        }
        );
    },
};
