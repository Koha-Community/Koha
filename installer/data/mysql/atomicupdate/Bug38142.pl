use Modern::Perl;

return {
    bug_number  => "38142",
    description => "LanguageToReportOnMerge",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences (variable, value, options, explanation, type) VALUES
           ('LanguageToReportOnMerge','','','If set, the authority field having the given language code in its $7 subfield will be reported to the bibliographic record if it exists, rather than the first field. The code can be in a short, 2 characters long form (example: ba for latin) or in a long, 8 characters long form, with the short form in position 5 and 6 starting from 1 (example: ba0yba0y for latin). A list of available codes can be found here: https://documentation.abes.fr/sudoc/formats/unmb/DonneesCodees/CodesZone104.htm#$d','Free');
        }
        );

        say $out "Added new syspref 'LanguageToReportOnMerge'";
    }
};
