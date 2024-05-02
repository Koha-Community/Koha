use Modern::Perl;

return {
    bug_number  => "15565",
    description => "Add DisplayMultiItemHolds system preference",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
            ('DisplayMultiItemHolds','0','','Display the ability to place holds on different items at the same time in staff interface and OPAC','YesNo')
        }
        );

        say $out "Added new system preference 'DisplayMultiItemHolds'";
    }
};
