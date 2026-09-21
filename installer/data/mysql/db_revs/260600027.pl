use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "42667",
    description => "Split the ability to edit other librarian's reports into a separate permission",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            INSERT IGNORE INTO permissions (module_bit, code, description)
            VALUES (16, 'edit_all_reports', 'Edit SQL reports created by other librarians')
        }
        );
        say $out "Added new permission 'edit_all_reports'";

        $dbh->do(
            q{
            INSERT IGNORE INTO user_permissions (borrowernumber, module_bit, code)
            SELECT borrowernumber, 16, 'edit_all_reports'
              FROM user_permissions WHERE code = 'create_reports'
        }
        );
        say $out "Granted 'edit_all_reports' to all patrons who already have 'create_reports'";
    },
};
