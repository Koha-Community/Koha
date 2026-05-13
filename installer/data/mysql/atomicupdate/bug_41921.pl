use Modern::Perl;
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
            VALUES ('ReportsRunInBackground', 'user_choice',
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
    },
};
