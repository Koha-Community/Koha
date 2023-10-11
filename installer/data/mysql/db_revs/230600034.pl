use Modern::Perl;

return {
    bug_number  => "21246",
    description => "A preference to specify how many previous patrons to show for showLastPatron",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
            ('showLastPatronCount', '1', NULL, 'How many patrons should showLastPatron remember', 'Integer')
        }
        );
        say $out "Added new system preference 'showLastPatronCount'";
    },
};
