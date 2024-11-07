use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "13888",
    description => "'Lists' permission should allow/disallow using the lists module in staff",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{ INSERT IGNORE INTO permissions (module_bit,code,description) VALUES (20, 'use_public_lists', 'Use public lists') }
            ) == 1
            ? say_success( $out, "Added permission 'use_public_lists'" )
            : say_info( $out, "Permission 'use_public_lists' already exists" );

        $dbh->do(
            q{ INSERT IGNORE INTO permissions (module_bit,code,description) VALUES (20, 'create_public_lists', 'Create public lists') }
            ) == 1
            ? say_success( $out, "Added permission 'create_public_lists'" )
            : say_info( $out, "Permission 'create_public_lists' already exists" );

    },
};
