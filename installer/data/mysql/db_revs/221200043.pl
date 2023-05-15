use Modern::Perl;

return {
    bug_number => '21330',
    description => 'Add XSLT for authority details view in OPAC',
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};

        $dbh->do(q{
            INSERT IGNORE INTO systempreferences (`variable`, `value`, `options`, `explanation`, `type`)
            VALUES ('AuthorityXSLTOpacDetailsDisplay','','','Enable XSL stylesheet control over authority details page in the OPAC','Free')
        });

        say $out "Added new system preference 'AuthorityXSLTOpacDetailsDisplay'";
    },
};
