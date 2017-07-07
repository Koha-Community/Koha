#!/usr/bin/perl

use Modern::Perl;
use Test::More tests => 2;

use Git;

subtest 'Check Koha-Suomi has all upstream permission modules' => sub {
    my $modules = _getUpstreamPermissionModules();
    my $ksmodules = _getKohaSuomiPermissionModules();
    if (my $tests = scalar keys %$modules) {
        plan tests => $tests;
    } else {
        plan skip_all => 'Could not get upstream permission modules';
    }

    foreach my $module (keys %$modules) {
        ok(exists $ksmodules->{$module}, "Contains module $module");
    }
};

subtest 'Check Koha-Suomi has all upstream permissions' => sub {
    my $permissions = _getUpstreamPermissions();
    my $kspermissions = _getKohaSuomiPermissions();

    if (my $tests = scalar keys %$permissions) {
        plan tests => $tests;
    } else {
        plan skip_all => 'Could not get upstream permissions';
    }

    foreach my $permission (keys %$permissions) {
        ok(exists $kspermissions->{$permission},
           "Contains permission $permission");
    }
};

sub _getUpstreamPermissionModules {
    my $repo = Git->repository(Directory => $ENV{KOHA_PATH});
    my $data = eval {
        $repo->command('show', 'master:installer/data/mysql/userflags.sql');
    };
    if ($@) {
        return {};
    }

    my $modules;
    foreach my $line (split(/\n/, $data)) {
        if ($line =~ /^\((\d+?),'(.*?)'/) {
          $modules->{$2} = $1;
        }
    }
    return $modules;
}

sub _getUpstreamPermissions {
    my $repo = Git->repository(Directory => $ENV{KOHA_PATH});
    my $data = eval {
        $repo->command('show', 'master:installer/data/mysql/userpermissions.sql');
    };
    if ($@) {
        return {};
    }

    my $permissions;
    foreach my $line (split(/\n/, $data)) {
        if ($line =~ /^\s*\(\d+,\s'(.*?)'/) {
          $permissions->{$1} = 1;
        }
    }
    return $permissions;
}

sub _getKohaSuomiPermissions {
    open my $data, $ENV{KOHA_PATH}.'/installer/data/mysql/userpermissions.sql'
        or die "Couldn't open file installer/data/mysql/userpermissions.sql";
    my $permissions;
    while (my $line = <$data>) {
        if ($line =~ /^\s*?\(\s*?'(?:.*)',\s*?'(\w*?)', '/) {
          $permissions->{$+} = 1;
        }
    }
    return $permissions;
}

sub _getKohaSuomiPermissionModules {
    open my $data, $ENV{KOHA_PATH}.'/installer/data/mysql/userflags.sql'
        or die "Couldn't open file installer/data/mysql/userflags.sql";
    my $modules;
    while (my $line = <$data>) {
        if ($line =~ /^\('(.*?)',/) {
          $modules->{$+} = 1;
        }
    }
    return $modules;
}

1;
