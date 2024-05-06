use Modern::Perl;

return {
    bug_number  => "32256",
    description => "Self checkout batch mode",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{ INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) VALUES ('SCOBatchCheckoutsValidCategories','',NULL,'Patron categories allowed to checkout in a batch while logged into Self Checkout','Free') }
        );

        say $out "Added system preference 'SCOBatchCheckoutsValidCategories'";
    },
};
