use Modern::Perl;

return {
    bug_number  => 30497,
    description => "Recreate old_reserves_ibfk_4 if cascading",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        my @info = $dbh->selectrow_array(q|SHOW CREATE TABLE old_reserves|);
        if ( $info[1] =~ /^\s*CONSTRAINT .old_reserves_ibfk_4.*CASCADE$/m ) {
            $dbh->do(q|ALTER TABLE old_reserves DROP FOREIGN KEY old_reserves_ibfk_4|);
            $dbh->do(
                q|ALTER TABLE old_reserves ADD FOREIGN KEY old_reserves_ibfk_4 (itemtype) REFERENCES itemtypes (itemtype) ON DELETE SET NULL ON UPDATE SET NULL|
            );
        }
    },
};
