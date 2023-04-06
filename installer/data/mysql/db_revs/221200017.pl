use Modern::Perl;

return {
    bug_number => "31123",
    description => "Add `ContentWarningField` preference",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
        $dbh->do(q{
            INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` )
            VALUES ('ContentWarningField', '', NULL, 'MARC field to use for content warnings', 'Free')
        });
    },
};
