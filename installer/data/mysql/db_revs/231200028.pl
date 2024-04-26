use Modern::Perl;
return {
    bug_number  => "16122",
    description => "Add localuse column to items table and deleted items table",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        if ( !column_exists( 'items', 'localuse' ) ) {
            $dbh->do(
                q{
                ALTER TABLE items
                ADD COLUMN localuse smallint(6) NULL DEFAULT NULL
                COMMENT "item's local use count"
                AFTER renewals
            }
            );
            say $out "Added column 'items.localuse'";
        }
        if ( !column_exists( 'deleteditems', 'localuse' ) ) {
            $dbh->do(
                q{
                ALTER TABLE deleteditems
                ADD COLUMN localuse smallint(6) NULL DEFAULT NULL
                COMMENT "deleteditems local use count"
                AFTER renewals
            }
            );
            say $out "Added column 'deleteditems.localuse'";
        }
        say $out
            "You may use the new /misc/maintenance/update_localuse_from_statistics.pl script to populate the new field from the existing statistics data";
    },
    }
