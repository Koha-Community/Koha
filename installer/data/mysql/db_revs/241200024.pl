use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_failure say_success say_info);

return {
    bug_number  => "37211",
    description => "Add new permission for editing accountline notes",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Do you stuffs here
        $dbh->do(
            q{
            INSERT IGNORE INTO permissions (module_bit, code, description)
            VALUES (10, 'edit_accountline_notes', 'Edit accountline notes')
        }
        );

        # permissions
        say_success( $out, "Added new permission 'updatecharges:edit_accountline_notes'" );

    },
};
