use Modern::Perl;

return {
    bug_number  => "32057",
    description => "Bug 32057 - Add optional stack trace to action logs",
    up          => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};

        if ( !column_exists( 'action_logs', 'trace' ) ) {
            $dbh->do(q{
              ALTER TABLE action_logs
                ADD COLUMN `trace` TEXT DEFAULT NULL COMMENT 'An optional stack trace enabled by ActionLogsTraceDepth' AFTER `script`
            });
            say $out "Added column 'action_logs.trace'";
        }

        $dbh->do(q{
            INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
            ('ActionLogsTraceDepth', '0', '', 'Sets the maximum depth of the action logs stack trace', 'Integer')
        });
        say $out "Added new system preference 'ActionLogsTraceDepth'";
    },
};
