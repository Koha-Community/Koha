use Modern::Perl;

return {
    bug_number  => "35380",
    description =>
        "Add new unique name to record sources, add default record sources, add is_system column to default record sources.",
    up => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # change name to be unique
        if ( !unique_key_exists( 'record_sources', 'name' ) ) {
            $dbh->do(
                q{
                ALTER TABLE record_sources
                ADD UNIQUE KEY name (`name`)
            }
            );
            say $out "Added unique key 'name' ";
        }

        # add column is system
        unless ( column_exists( 'record_sources', 'is_system' ) ) {
            $dbh->do(
                q{ ALTER TABLE record_sources ADD COLUMN `is_system` TINYINT(1) NOT NULL DEFAULT 0 AFTER can_be_edited }
            );
            say $out "Added column 'record_sources.is_system'";
        }

        $dbh->do(
            q{
            INSERT IGNORE INTO record_sources ( name, can_be_edited, is_system )
            VALUES
            ('batchmod', 1, 1 ),
            ('intranet', 1, 1 ),
            ('batchimport', 1, 1 ),
            ('z3950', 1, 1 ),
            ('bulkmarcimport', 1, 1 ),
            ('import_lexile', 1, 1 )
        }
        );

        # Ensure pre-existing rows with these names are also marked as system records.
        # INSERT IGNORE above skips duplicate names, so existing rows would retain is_system=0.
        $dbh->do(
            q{
            UPDATE record_sources SET is_system = 1
            WHERE name IN ('batchmod', 'intranet', 'batchimport', 'z3950', 'bulkmarcimport', 'import_lexile')
        }
        );
        say $out "Marked system record sources with is_system=1";
    },
};
