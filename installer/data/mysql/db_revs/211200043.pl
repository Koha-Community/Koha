use Modern::Perl;

return {
    bug_number  => 30108,
    description => "Add preference OPACMandatoryHoldDates",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        $dbh->do(
            q{
INSERT IGNORE INTO systempreferences (`variable`, `value`, `options`, `explanation`, `type` ) VALUES
('OPACMandatoryHoldDates', '', '|start|end|both', 'Define which hold dates are required on OPAC reserve form', 'Choice')
        }
        );
    },
};
