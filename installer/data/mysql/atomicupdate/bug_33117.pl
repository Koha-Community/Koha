use Modern::Perl;

return {
    bug_number  => "33117",
    description => "Patron checkout is not able to find patrons if using a second surname or other name during the search",
    up => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(q{
            INSERT INTO systempreferences (`variable`,`value`,`explanation`,`options`,`type`)
            VALUES ('PatronAutoCompleteSearchMethod','starts_with','Allows staff to set a default method when searching for patrons with autocomplete','starts_with|contains','Choice');
        });

        say $out "Added new system preference 'PatronAutoCompleteSearchMethod'";
    },
};
