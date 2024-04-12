use Modern::Perl;

return {
    bug_number  => "6796",
    description => "Overnight checkouts taking into account opening and closing hours",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        unless ( TableExists('library_hours') ) {
            $dbh->do(
                q{
                CREATE TABLE library_hours (
                    library_id varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
                    day enum('0','1','2','3','4','5','6') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '0',
                    open_time time COLLATE utf8mb4_unicode_ci DEFAULT NULL,
                    close_time time COLLATE utf8mb4_unicode_ci DEFAULT NULL,
                    PRIMARY KEY (library_id, day),
                    CONSTRAINT library_hours FOREIGN KEY (library_id) REFERENCES branches (branchcode) ON DELETE CASCADE ON UPDATE CASCADE
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
            }
            );

            my $branches =
                $dbh->selectall_arrayref( "SELECT branchcode FROM branches", { Slice => {} } );
            for my $branch (@$branches) {
                my $branchcode = $branch->{branchcode};

                my @indexes = ( 0 .. 6 );
                for my $i (@indexes) {
                    $dbh->do(
                        q{ INSERT INTO library_hours (library_id, day) VALUES ( ?, ? ) }, undef, $branchcode,
                        $i
                    );
                }
            }

            say $out "Added table 'library_hours'";

            $dbh->do(
                q{ INSERT IGNORE INTO systempreferences ( variable, value, options, explanation, type ) VALUES ( 'ConsiderLibraryHoursInCirculation', 'ignore', 'close|open|ignore', "Take library opening hours into consideration to calculate due date when circulating.", 'Choice' ) }
            );

            say $out "Added system preference 'ConsiderLibraryHoursInCirculation'";
        }
    },
};
