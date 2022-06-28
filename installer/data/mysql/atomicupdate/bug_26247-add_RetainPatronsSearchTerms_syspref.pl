use Modern::Perl;

return {
    bug_number => "26247",
    description => "Add new system preference RetainPatronsSearchTerms",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};

        $dbh->do(q{INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) VALUES ('RetainPatronSearchTerms', '1', NULL, 'If enabled, searches entered into the checkout and patrons search bars will be retained', 'YesNo') });
    },
};
