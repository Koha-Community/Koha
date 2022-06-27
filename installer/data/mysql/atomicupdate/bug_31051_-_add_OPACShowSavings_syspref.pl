use Modern::Perl;

return {
    bug_number => "31051",
    description => "Add new system preference OPACShowSavings",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};

        $dbh->do(q{INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) VALUES ('OPACShowSavings', '', 'checkouthistory|summary|user', 'Show on the OPAC the total amount a patron has saved by using a library instead of purchasing, based on replacement prices', 'multiple') });
    },
};
