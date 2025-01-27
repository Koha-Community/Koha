use Modern::Perl;

return {
    bug_number  => "29071",
    description => "Set HoldsQueueSplitNumbering where not set",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
            ('HoldsSplitQueueNumbering', 'actual', 'actual|virtual', 'If the holds queue is split, decide if the actual priorities should be displayed', 'Choice')
        }
        );

        say $out "Added new system preference 'HoldsSplitQueueNumbering'";
    },
};
