use Modern::Perl;

return {
    bug_number => '30036',
    description => 'Add syspref AuthorityXSLTOpacResultsDisplay',
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};

        $dbh->do(q{
            INSERT IGNORE INTO systempreferences (`variable`, `value`, `options`, `explanation`, `type`)
            VALUES ('AuthorityXSLTOpacResultsDisplay','','','Enable XSL stylesheet control over authority results page display on opac','Free')
        });
    },
};
