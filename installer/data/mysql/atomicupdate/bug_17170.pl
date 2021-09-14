use Modern::Perl;

return {
    bug_number => "17170",
    description => "Add permission for creating saved search filters",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
        $dbh->do(q{
            INSERT IGNORE INTO permissions (module_bit, code, description) VALUES
            (3, 'manage_search_filters', 'Manage custom search filters');
        });
        say $out "Added manage_search_filters permission";
        unless( TableExists( 'search_filters' ) ){
            $dbh->do(q{
                CREATE TABLE `search_filters` (
                  id int(11) NOT NULL auto_increment, -- unique identifier for each search filter
                  name varchar(255) NOT NULL, -- display name for this filter
                  query mediumtext DEFAULT NULL, -- query part of the filter, can be blank
                  limits mediumtext DEFAULT NULL, -- limits part of the filter, can be blank
                  opac tinyint(1) NOT NULL DEFAULT 0, -- whether this filter is shown on OPAC
                  staff_client tinyint(1) NOT NULL DEFAULT 0, -- whether this filter is shown in staff client
                  PRIMARY KEY (id)
                ) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
            });
            say $out "Added search_filters table";
        } else {
            say $out "search_filters table already created";
        }
        $dbh->do(q{
            INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
            ('SavedSearchFilters', '0', NULL, 'Allow staff with permission to create/edit custom search filters', 'YesNo')
        });
        say $out "Added SavedSearchFilters system preference";
    },
}
