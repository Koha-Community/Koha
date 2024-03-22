use Modern::Perl;

return {
    bug_number  => "35873",
    description => "Biblio.RecallsCount is deprecated",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Do you stuffs here
        my ($count) = $dbh->selectrow_array(
            q{
            SELECT COUNT(*)
            FROM letter
            WHERE content LIKE "%Biblio.RecallsCount%";
        }
        );

        if ($count) {
            say $out "WARNING - Biblio.RecallsCount is used in at least one notice template.";
            say $out "It is deprecated and will be removed in a future version of Koha.";
            say $out "Replace it with biblio.recalls.search( completed => 0 ).count";
        }
    },
};
