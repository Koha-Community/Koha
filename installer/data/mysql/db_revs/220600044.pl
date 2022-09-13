use Modern::Perl;

return {
    bug_number => "26247",
    description => "Add new retain search terms preferences",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};

        $dbh->do(q{INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) VALUES ('RetainCatalogSearchTerms', '1', NULL, 'If enabled, searches entered into the catalog search bar will be retained', 'YesNo') });
        say $out "Added `RetainCatalogSearchTerms` preference";

        $dbh->do(q{INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) VALUES ('RetainPatronSearchTerms', '1', NULL, 'If enabled, searches entered into the checkout and patrons search bars will be retained', 'YesNo') });
        say $out "Added `RetainPatronsSearchTerms` preference";
    },
};
