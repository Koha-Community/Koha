use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "16631",
    description => "Add library limits to reports",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{CREATE TABLE IF NOT EXISTS `reports_branches` (
            `report_id` int(11) NOT NULL,
            `branchcode` varchar(10) NOT NULL,
            KEY `report_id` (`report_id`),
            KEY `branchcode` (`branchcode`),
            CONSTRAINT `reports_branches_ibfk_1` FOREIGN KEY (`report_id`) REFERENCES `saved_sql` (`id`) ON DELETE CASCADE,
            CONSTRAINT `reports_branches_ibfk_2` FOREIGN KEY (`branchcode`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci}
        );

        say $out "Added new table 'reports_branches'";

        $dbh->do(
            q{INSERT IGNORE INTO systempreferences
            (variable,value,options,explanation,type) VALUES ('LimitReportsByLibrary', '0', NULL, 'Enable ability for staff to limit report access based on home library.', 'YesNo')}
        );

        say $out "Added new system preference 'LimitReportsByLibrary'";

        $dbh->do(
            q{INSERT IGNORE INTO permissions
            (module_bit, code, description) VALUES (16, 'manage_report_limits', 'Manage report limits')}
        );

        say $out "Added new permission 'manage_report_limits'";

    },
};
