use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "99999",
    description => "NUKAT permissions",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(q{INSERT IGNORE INTO userflags (bit,flag,flagdesc,defaulton) VALUES (50, 'nukat', 'NUKAT permissions', 0)});

        $dbh->do(q{INSERT IGNORE INTO permissions (module_bit,code,description) VALUES (50, 'all_symbols', 'Manage symbols for all libraries')});
        $dbh->do(q{INSERT IGNORE INTO permissions (module_bit,code,description) VALUES (50, 'delete_auth', 'Delete authority records')});
        $dbh->do(q{INSERT IGNORE INTO permissions (module_bit,code,description) VALUES (50, 'delete_biblio', 'Delete bibliographic records')});
        $dbh->do(q{INSERT IGNORE INTO permissions (module_bit,code,description) VALUES (50, 'edit_dbn_mesh', 'Edit dbn / mesh auth records')});
        $dbh->do(q{INSERT IGNORE INTO permissions (module_bit,code,description) VALUES (50, 'merge_auth', 'Merge authority records')});
        $dbh->do(q{INSERT IGNORE INTO permissions (module_bit,code,description) VALUES (50, 'merge_biblio', 'Merge bibliographic records')});
        $dbh->do(q{INSERT IGNORE INTO permissions (module_bit,code,description) VALUES (50, 'own_symbols', 'Manage symbols for own library')});
        $dbh->do(q{INSERT IGNORE INTO permissions (module_bit,code,description) VALUES (50, 'z3950', 'Use Z59.50 service')});

        say_success( $out, "NUKAT permissions created/updated" );
    },
};
