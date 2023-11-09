use Modern::Perl;

return {
    bug_number  => "35305",
    description => "Add XSLT for authority details display in staff interface",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        $dbh->do(q{
            INSERT IGNORE INTO systempreferences (`variable`, `value`, `options`, `explanation`, `type`)
            VALUES ('AuthorityXSLTDetailsDisplay','','','Enable XSL stylesheet control over authority details page display on intranet','Free')
        });
        say $out "Added new system preference 'AuthorityXSLTDetailsDisplay'";
    },
};
