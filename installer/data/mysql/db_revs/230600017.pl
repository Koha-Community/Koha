use Modern::Perl;

return {
    bug_number => "32911",
    description => "Remove ILL partner_code config from koha-conf.xml and turn it into a system preference",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};

        my $xml_config = C4::Context->config("interlibrary_loans");
        my $existing_partner_code = $xml_config->{partner_code};

        if ( $existing_partner_code ) {
            $dbh->do(
                qq{
                    INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type)
                    VALUES ('ILLPartnerCode', '$existing_partner_code', NULL, 'Patrons from this patron category will be used as partners to place ILL requests with', 'free');
                }
            );
            say $out "Moved value of partner_code in koha-conf.xml into new system preference 'ILLPartnerCode'";
        }
    }
};
