use Modern::Perl;

return {
    bug_number => '21330',
    description => 'Add syspref AuthorityXSLTOpacDetailsDisplay',
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};

        $dbh->do(q{
            INSERT IGNORE INTO systempreferences (`variable`, `value`, `options`, `explanation`, `type`)
            VALUES ('AuthorityXSLTOpacDetailsDisplay','','','Enable XSL stylesheet control over authority results page display on intranet','Free')
        });
    },
};
