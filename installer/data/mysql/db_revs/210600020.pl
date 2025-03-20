use Modern::Perl;

return {
    bug_number  => "28373",
    description => "Add new system preference PassItemMarcToXSLT",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
            ('PassItemMarcToXSLT','0',NULL,'If enabled, item fields in the MARC record will be made available to XSLT sheets. Otherwise they will be removed.','YesNo');
        }
        );
        foreach my $pref (
            'XSLTDetailsDisplay',   'XSLTListsDisplay', 'XSLTResultsDisplay', 'OPACXSLTDetailsDisplay',
            'OPACXSLTListsDisplay', 'OPACXSLTResultsDisplay'
            )
        {
            if ( C4::Context->preference($pref) ne 'default' ) {
                say $out
                    "NOTE: You have defined a custom stylesheet for '$pref'. If it is utilizing item fields you must enable the system preference 'PassItemMarcToXSLT'";
            }
        }
    },
    }
