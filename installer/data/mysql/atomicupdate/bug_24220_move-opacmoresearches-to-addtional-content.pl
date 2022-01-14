use Modern::Perl;

return {
    bug_number => "24220",
    description => "Move OpacMoreSearches to additional contents",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
        # Get any existing value from the OpacMoreSearches system preference
        my ( $opacmoresearches ) = $dbh->selectrow_array( q|
            SELECT value FROM systempreferences WHERE variable='OpacMoreSearches';
        |);
        if( $opacmoresearches ){
            # Insert any values found from system preference into additional_contents
            foreach my $lang ( 'default' ) {
                $dbh->do( "INSERT INTO additional_contents ( category, code, location, branchcode, title, content, lang, published_on ) VALUES ('html_customizations', 'OpacMoreSearches', 'OpacMoreSearches', NULL, ?, ?, ?, CAST(NOW() AS date) )", undef, "OpacMoreSearches $lang", $opacmoresearches, $lang );
            }
            # Remove old system preference
            $dbh->do("DELETE FROM systempreferences WHERE variable='OpacMoreSearches'");
            say $out "Bug 24220 update done";
        }
    }
}
