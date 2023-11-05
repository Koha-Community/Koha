use Modern::Perl;

return {
    bug_number  => "33217",
    description => "Add option to specify sorting for author links",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
            ('AuthorLinkSortBy','default','call_number|pubdate|acqdate|title','Specify the default field used for sorting when click author links','Choice'),
            ('AuthorLinkSortOrder','asc','asc|dsc|az|za','Specify the default sort order for author links','Choice')
        }
        );
        say $out "Added new system preferences 'AuthorLinkSortBy' and 'AuthorLinkSortOrder'";
    },
};
