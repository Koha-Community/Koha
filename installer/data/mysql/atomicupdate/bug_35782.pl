use Modern::Perl;

return {
    bug_number  => "35872",
    description => "Biblio.HoldsCount is deprecated",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Do you stuffs here
        my ($count) = $dbh->selectrow_array(
            q{
            SELECT COUNT(*)
            FROM letter
            WHERE content LIKE "%Biblio.HoldsCount%";
        }
        );

        if ($count) {
            say $out "WARNING - Biblio.HoldsCount is used in at least one notice template";
            say $out "It is deprecated and will be remove in a future version of Koha.";
            say $out "Replace it with biblio.holds.count instead";
        }
    },
};
