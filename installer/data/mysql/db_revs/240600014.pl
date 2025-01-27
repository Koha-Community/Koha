use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "33363",
    description =>
        "Split suggestions_manage into three separate permissions for creating, updating, and deleting suggetions",
    up => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{INSERT IGNORE INTO permissions (module_bit, code, description) VALUES (12, 'suggestions_create', 'Create purchase suggestions')}
        ) && say_success( $out, "Added new permissions suggestions_create" );
        $dbh->do(
            q{INSERT IGNORE INTO permissions (module_bit, code, description) VALUES (12, 'suggestions_delete', 'Update purchase suggestions')}
        ) && say_success( $out, "Added new permissions suggestions_delete" );

        $dbh->do(
            q{INSERT IGNORE INTO user_permissions (borrowernumber, module_bit, code) SELECT borrowernumber, 12, 'suggestions_create' FROM borrowers WHERE flags & (1 << 2)}
        ) && say_success( $out, "Added new permissions suggestions_create to patrons with suggestions_manage" );
        $dbh->do(
            q{INSERT IGNORE INTO user_permissions (borrowernumber, module_bit, code) SELECT borrowernumber, 12, 'suggestions_delete' FROM borrowers WHERE flags & (1 << 2)}
        ) && say_success( $out, "Added new permissions suggestions_delete to patrons with suggestions_manage" );

    },
};
