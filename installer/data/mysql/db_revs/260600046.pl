use Modern::Perl;
use C4::Installer           qw(index_exists column_exists foreign_key_exists);
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "41921",
    description =>
        "Add ReportsRunInBackground system preference and split execute_reports permission into foreground and background",
    up => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences (variable, value, explanation, options, type)
            VALUES ('ReportsRunInBackground', 'never',
                    'Control whether saved SQL reports run as a background job, in the foreground, or let the user choose.',
                    'always|never|user_choice', 'Choice')
        }
        );
        say $out "Added new system preference 'ReportsRunInBackground'";

        $dbh->do(
            q{
            INSERT IGNORE INTO permissions (module_bit, code, description) VALUES
            (16, 'execute_reports_foreground', 'Execute SQL reports in the foreground'),
            (16, 'execute_reports_background', 'Execute SQL reports as a background job')
        }
        );
        say $out "Added new permissions 'execute_reports_foreground' and 'execute_reports_background'";

        $dbh->do(
            q{
            INSERT IGNORE INTO user_permissions (borrowernumber, module_bit, code)
            SELECT borrowernumber, 16, 'execute_reports_foreground'
              FROM user_permissions WHERE code = 'execute_reports'
        }
        );
        $dbh->do(
            q{
            INSERT IGNORE INTO user_permissions (borrowernumber, module_bit, code)
            SELECT borrowernumber, 16, 'execute_reports_background'
              FROM user_permissions WHERE code = 'execute_reports'
        }
        );
        $dbh->do(q{ DELETE FROM user_permissions WHERE code = 'execute_reports' });
        $dbh->do(q{ DELETE FROM permissions      WHERE code = 'execute_reports' });
        say $out "Migrated 'execute_reports' permission to new foreground/background permissions";

        unless ( index_exists( 'background_jobs', 'type_enqueued_on' ) ) {
            $dbh->do(q{ ALTER TABLE background_jobs ADD KEY type_enqueued_on (type, enqueued_on) });
            say $out "Added index 'type_enqueued_on' to background_jobs";
        }

        unless ( index_exists( 'background_jobs', 'type_status' ) ) {
            $dbh->do(q{ ALTER TABLE background_jobs ADD KEY type_status (type, status) });
            say $out "Added index 'type_status' to background_jobs";
        }

        unless ( column_exists( 'background_jobs', 'report_id' ) ) {
            $dbh->do(
                q{ ALTER TABLE background_jobs
                     ADD COLUMN report_id INT(11) DEFAULT NULL
                     COMMENT 'foreign key to saved_sql.id for run_report jobs' }
            );
            $dbh->do(q{ ALTER TABLE background_jobs ADD KEY report_id (report_id) });
            say $out "Added column 'report_id' to background_jobs";
        }

        unless ( foreign_key_exists( 'background_jobs', 'background_jobs_report_id_fk' ) ) {
            $dbh->do(
                q{ ALTER TABLE background_jobs
                     ADD CONSTRAINT background_jobs_report_id_fk
                     FOREIGN KEY (report_id) REFERENCES saved_sql (id) ON DELETE SET NULL }
            );
            say $out "Added foreign key 'background_jobs_report_id_fk' to background_jobs";
        }
    },
};
