use Modern::Perl;

return {
    bug_number  => "33393",
    description => "Modify sentence above the order table in English 1-page order PDF",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) VALUES ('1PageOrderPDFText', '', NULL, 'Text to be used above the order table in the 1-page order PDF file', 'textarea') }
        );

        say $out "Added system preference '1PageOrderPDFText'";
    },
};
