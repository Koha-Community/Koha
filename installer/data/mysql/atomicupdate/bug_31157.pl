use Modern::Perl;

return {
    bug_number => "31157",
    description => "Add OverdueNoticeFrom preference",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};

        $dbh->do(q{
            INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
                ('OverdueNoticeFrom', 'cron', 'cron|item-issuebranch|item-homebranch', 'Use the choice as the from address when generating overdue notices', 'Choice')
        });
    },
};
