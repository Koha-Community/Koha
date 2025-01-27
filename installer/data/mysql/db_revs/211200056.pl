use Modern::Perl;

return {
    bug_number  => "30728",
    description => "Allow opting out of real-time holds queue updating possible",
    up          => sub {
        my ($args) = @_;
        my ($dbh)  = @$args{qw(dbh)};

        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
            ('RealTimeHoldsQueue', '0', NULL, 'Enable updating the holds queue in real time', 'YesNo')
        }
        );
    },
};
