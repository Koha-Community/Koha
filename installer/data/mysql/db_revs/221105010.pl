use Modern::Perl;

return {
    bug_number => "33489",
    description => "Add indices to default patron search fields",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
        # Do you stuffs here
        unless ( index_exists( 'borrowers', 'cardnumber_idx' ) ) {
            $dbh->do(q{CREATE INDEX cardnumber_idx ON borrowers ( cardnumber )});
            say $out "Added new index on borrowers.cardnumber";
        }
        unless ( index_exists( 'borrowers', 'userid_idx' ) ) {
            $dbh->do(q{CREATE INDEX userid_idx ON borrowers ( userid )});
            say $out "Added new index on borrowers.userid";
        }
        unless ( index_exists( 'borrowers', 'middle_name_idx' ) ) {
            $dbh->do(q{CREATE INDEX middle_name_idx ON borrowers ( middle_name(768) )});
            say $out "Added new index on borrowers.midddle_name";
        }
    },
};
