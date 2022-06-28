use Modern::Perl;

return {
    bug_number => "26247",
    description => "Add new system preference RetainCatalogSearchTerms",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};

        $dbh->do(q{INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) VALUES ('RetainCatalogSearchTerms', '1', NULL, 'If enabled, searches entered into the catalog search bar will be retained', 'YesNo') });
    },
};
