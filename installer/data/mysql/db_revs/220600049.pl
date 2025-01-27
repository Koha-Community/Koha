use Modern::Perl;

return {
    bug_number  => 30490,
    description => "Adjust FK constraint for parent item type",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        if ( foreign_key_exists( 'itemtypes', 'itemtypes_ibfk_1' ) ) {
            $dbh->do(
                q{
alter table itemtypes drop foreign key itemtypes_ibfk_1;
            }
            );
        }
        $dbh->do(
            q{
alter table itemtypes add foreign key itemtypes_ibfk_1 (`parent_type`) REFERENCES `itemtypes` (`itemtype`);
        }
        );
    },
};
