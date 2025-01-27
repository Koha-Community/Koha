use Modern::Perl;

return {
    bug_number  => '30036',
    description => 'Add XSLT for authority results view in OPAC',
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences (`variable`, `value`, `options`, `explanation`, `type`)
            VALUES ('AuthorityXSLTOpacResultsDisplay','','','Enable XSL stylesheet control over authority results page in the OPAC','Free')
        }
        );

        say $out "Added new system preference 'AuthorityXSLTOpacResultsDisplay'";
    },
};
