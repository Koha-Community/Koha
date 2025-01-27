use Modern::Perl;

return {
    bug_number  => "17170",
    description => "Add saved search filters feature",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        $dbh->do(
            q{
            INSERT IGNORE INTO permissions (module_bit, code, description) VALUES
            (3, 'manage_search_filters', 'Manage custom search filters');
        }
        );

        say $out "Added new permission 'manage_search_filters'";

        unless ( TableExists('search_filters') ) {
            $dbh->do(
                q{
                CREATE TABLE `search_filters` (
                `search_filter_id` int(11) NOT NULL AUTO_INCREMENT,
                `name` varchar(255) NOT NULL COMMENT 'filter name',
                `query` mediumtext NULL DEFAULT NULL COMMENT 'filter query part',
                `limits` mediumtext NULL DEFAULT NULL COMMENT 'filter limits part',
                `opac` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'whether this filter is shown on OPAC',
                `staff_client` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'whether this filter is shown in staff client',
                PRIMARY KEY (`search_filter_id`)
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
            }
            );
            say $out "Added new table 'search_filters'";
        }
        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
            ('SavedSearchFilters', '0', NULL, 'Allow staff with permission to create/edit custom search filters', 'YesNo')
        }
        );

        say $out "Added new system preference 'SavedSearchFilters'";
    },
    }
