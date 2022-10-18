use Modern::Perl;

return {
    bug_number => "31557",
    description => "Add syspref HoldsQueuePrioritizeBranch",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
        $dbh->do(q{
            INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
            ('HoldsQueuePrioritizeBranch','homebranch','holdingbranch|homebranch','Decides if holds queue builder patron home library match to home or holding branch','Choice')
        });
    },
};
