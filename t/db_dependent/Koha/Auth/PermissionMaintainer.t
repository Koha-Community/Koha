#!/usr/bin/perl

# Copyright 2017 Koha-Suomi Oy
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#

use Modern::Perl;
use utf8;
binmode STDOUT, ':encoding(UTF-8)';
binmode STDERR, ':encoding(UTF-8)';
use Try::Tiny;
use Scalar::Util qw(blessed);


use Test::More;

use Koha::Database;
use Koha::Auth::PermissionManager;
use Koha::Auth::PermissionMaintainer;


use Koha::Logger;
Koha::Logger->setConsoleVerbosity('TRACE');

##Setting up the test context
my $schema  = Koha::Database->new->schema;
my $testPermissionFilesDir = 't/db_dependent/Koha/Auth/';
my $testContext = {};

subtest "Feature: Parse Koha-Suomi permission files", \&parser;
sub parser {
  my ($permissions);
  eval {

    ok($permissions = Koha::Auth::PermissionMaintainer->new()->parseKohasPermissionFiles($testPermissionFilesDir),
      "Given PermissionMaintainer has parsed Koha's permission files");

    is($permissions->{circulate}->{permissions}->{circulate_remaining_permissions}->{code}, 'circulate_remaining_permissions',
       "Then a permission is parsed");

    is($permissions->{catalogue}->{permissions}->{staff_login}->{code}, 'staff_login',
       "And another permission is parsed");

  }; if ($@) { ok(0, $@); }
}



subtest "Feature: Compare installed permissions and available permissions", \&comparison;
sub comparison {
  my ($pmaint, $availablePermissions, $installedPermissions, $diff);
  eval {
    $pmaint = Koha::Auth::PermissionMaintainer->new();

    ok($availablePermissions = $pmaint->parseKohasPermissionFiles($testPermissionFilesDir),
      "Given PermissionMaintainer has parsed Koha's permission files");

    ok($installedPermissions = $pmaint->_getKohaPermissionsAsHASH(),
      "And PermissionManager has fetched all permissions in the DB");

    ok($diff = $pmaint->dataDiff(),
      "When available and installed permissions are compared");

    is($diff->{D}->{lols}->{A}->{module}, 'lols',
       "Then the 'lols'-module is present in the userflags.sql, but not defined in the Koha's DB");

    is($diff->{D}->{lols}->{A}->{permissions}->{"all your base"}->{code}, 'all your base',
       "Then the 'lols'-module's permission 'all your base' is present in the userpermissions.sql, but not defined in the Koha's DB");


  }; if ($@) { ok(0, $@); }
}



subtest "Feature: Comparison found DB has too many permissions, forcibly removing them", \&forceRemoval;
sub forceRemoval {
  my ($pman, $pmaint, $availablePermissions, $installedPermissions, $diff, $pmodule, @p, $report);

  $schema->storage->txn_begin;
  eval {
    $pmaint = Koha::Auth::PermissionMaintainer->new();
    $pman   = Koha::Auth::PermissionManager->new();

    ok($availablePermissions = $pmaint->parseKohasPermissionFiles($testPermissionFilesDir),
      "Given PermissionMaintainer has parsed Koha's permission files");

    $pmodule = $pman->addPermissionModule({module => 'test', description => 'Just testing this module.'});
    $p[0]    = $pman->addPermission(      {module => 'test', code => 'testperm', description => 'Just testing this subpermission.'});
    $pmodule = $pman->addPermissionModule({module => 'circulate', description => 'Circulate stuff.'});
    $p[1]    = $pman->addPermission(      {module => 'circulate', code => 'testcircperm', description => 'Just testing this circulation subpermission.'});
    ok($pmodule && @p,
      "And some excess permissions are added to the DB");

    ok($installedPermissions = $pmaint->_getKohaPermissionsAsHASH(),
      "And PermissionManager has fetched all permissions in the DB");

    ok($diff = $pmaint->dataDiff(),
      "When available and installed permissions are compared");

    is($diff->{D}->{test}->{R}->{module}, 'test',
      "Then an excess permission module in the Koha's DB is detected");

    is($diff->{D}->{test}->{R}->{permissions}->{testperm}->{code}, 'testperm',
      "And an excess 'testperm' permission in the Koha's DB is detected");

    is($diff->{D}->{circulate}->{D}->{permissions}->{D}->{testcircperm}->{R}->{code}, 'testcircperm',
      "And an excess 'testcircperm' permission in the Koha's DB is detected");

    ok($report = $pmaint->removeExcessPermissions($diff),
      "When excess permissions are removed");

    ok(! $pman->getPermission('testperm'),
      "Then testperm is removed from the Koha's DB");

    ok(! $pman->getPermission('testcircperm'),
      "Then testcircperm is removed from the Koha's DB");

    ok(scalar(@$report) > 1,
       "And we get a bunch of report rows");

  }; if ($@) { ok(0, $@); }
  #finally tear down
  $schema->storage->txn_rollback;
}



subtest "Feature: Comparison found DB has too few permissions, installing missing permissions", \&addMissing;
sub addMissing {
  my ($pman, $pmaint, $availablePermissions, $installedPermissions, $diff, $pmodule, @p, $report, $email);

  $schema->storage->txn_begin;
  eval {
    $pmaint = Koha::Auth::PermissionMaintainer->new();
    $pman   = Koha::Auth::PermissionManager->new();

    ok($availablePermissions = $pmaint->parseKohasPermissionFiles($testPermissionFilesDir),
      "Given PermissionMaintainer has parsed Koha's permission files");

    $pmodule = eval {
      $pman->delPermissionModule('circulate')
    }; if ($@) {
      warn $@;
    }
    $p[0]    = eval {
      $pman->delPermission('manage_circ_rules');
    }; if ($@) {
      warn $@;
    }

    ok(1,
      "And some existing permissions are removed from the DB");

    ok($installedPermissions = $pmaint->_getKohaPermissionsAsHASH(),
      "And PermissionManager has fetched all permissions in the DB");

    ok($diff = $pmaint->dataDiff(),
      "When available and installed permissions are compared");

    is($diff->{D}->{lols}->{A}->{permissions}->{"all your base"}->{code}, 'all your base',
      "Then the 'lols'-module's permission 'all your base' is present in the userpermissions.sql, but not defined in the Koha's DB");

    ok($report = $pmaint->installMissingPermissions($diff),
      "When missing permissions are installed");

    ok($pman->getPermission("all your base"),
      "Then the permission 'all your base' is installed");

    ok(scalar(@$report) > 5,
      "And we get a bunch of report rows");

    ok($email = C4::Letters::_get_unsent_messages(),
      "And we sent some email");

    my $m = join("\n", @$report);
    is(index($email->[-1]->{content}, $m), 0,
      "And the latest email contains our report");

  }; if ($@) { ok(0, $@); }
  #finally tear down
  $schema->storage->txn_rollback;
}

done_testing;
