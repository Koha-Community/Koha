use Modern::Perl;

return {
    bug_number  => "31157",
    description => "Make --frombranch option (overdue_notices.pl) available as a syspref",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
                ('OverdueNoticeFrom', 'cron', 'cron|item-issuebranch|item-homebranch', 'Organize and send overdue notices by item home library or checkout library', 'Choice')
        }
        );

        say $out "Added new system preference 'OverdueNoticeFrom'";
    },
};
