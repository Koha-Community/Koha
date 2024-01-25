use Modern::Perl;

return {
    bug_number  => "35906",
    description => "Add bookable column on itemtypes table",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(q{
            INSERT IGNORE INTO systempreferences (`variable`, `value`, `options`, `explanation`, `type`) VALUES  ('item-level_booking', 1, '', 'enables item type level for future booking', 'YesNo');
        });

        $dbh->do(q{
            ALTER TABLE itemtypes ADD IF NOT EXISTS bookable INT(1) DEFAULT 0
        });

        say $out "Added new system preference 'item-level_booking'";
        say $out "Added column 'itemtypes.bookable'";
    },
};
