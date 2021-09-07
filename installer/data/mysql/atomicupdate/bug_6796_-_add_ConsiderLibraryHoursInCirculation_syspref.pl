use Modern::Perl;

return {
    bug_number  => "6796",
    description => "Overnight checkouts taking into account opening and closing hours",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{ INSERT IGNORE INTO systempreferences ( variable, value, options, explanation, type ) VALUES ( 'ConsiderLibraryHoursInCirculation', 'ignore', 'close|open|ignore', "Take library opening hours into consideration to calculate due date when circulating.", 'Choice' ) }
        );

        say $out "Added system preference 'ConsiderLibraryHoursInCirculation'";
    },
};
