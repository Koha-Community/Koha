use Modern::Perl;

return {
    bug_number  => "16258",
    description => "A preference to enabled/disable edifact",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
            ('EDIFACT', '1', NULL, 'Enables EDIFACT acquisitions functions', 'YesNo')
        }
        );
    },
};
