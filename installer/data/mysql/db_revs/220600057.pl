use Modern::Perl;

return {
    bug_number => "29071",
    description => "Set HoldsQueueSplitNumbering where not set",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
        # Do you stuffs here
        $dbh->do(q{
            INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
            ('HoldsSplitQueueNumbering', 'actual', 'actual|virtual', 'If the holds queue is split, decide if the actual priorities should be displayed', 'Choice')
        });
        # Print useful stuff here
        say $out "Added HoldsSplitQueueNumbering if not already there";
    },
};
