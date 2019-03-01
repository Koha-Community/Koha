package Koha::Auth::PermissionMaintainer;

# Copyright 2017 Koha-Suomi Oy
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;
use utf8;
binmode STDOUT, ':encoding(UTF-8)';
binmode STDERR, ':encoding(UTF-8)';
use Try::Tiny;
use Scalar::Util qw(blessed);

use SQL::Parser;
use Data::Dumper;
use File::Slurp;
use Storable;
use Struct::Diff;

use C4::Letters;
use Koha::Auth::PermissionManager;
use Koha::Auth::PermissionModule;
use Koha::Auth::Permission;

use Koha::Exception::BadParameter;
use Koha::Exception::UnknownObject;

use Koha::Logger;
my $l = Koha::Logger->get();

=head NAME Koha::Auth::PermissionMaintainer

=head SYNOPSIS

Checks if the permissions configured in userpermissions.pl and userflags.pl match those that are in the DB.
Helps sync changes to DB.

=head new

=cut

sub new {
  my ($class) = @_;
  my $self = bless({}, $class);

  $self->{kohaPerms}   = undef; #Permissions in Koha's DB are put here
  $self->{neededPerms} = undef; #Permissions in kohapermissions.sql are put here

  return $self;
}

sub _getKohaPermissionsAsHASH {
  my ($self) = @_;
  my $pm = Koha::Auth::PermissionManager->new();
  $self->{kohaPerms} = Storable::dclone($pm->listKohaPermissionsAsHASH()); #Permissions in Koha's DB are put here
  return $self->{kohaPerms};
}


=head2 parseKohasPermissionFiles

@PARAM1 Absolute path or path relative to the $ENV{KOHA_PATH}, of the dir where to find the Koha's permission file sqls
@RETURNS HASH of permission modules and sub-permisions, in the same format as Koha::Auth::PermissionManager->listKohaPermissionsAsHASH()

=cut

sub parseKohasPermissionFiles {
  my ($self, $path) = @_;
  $path = $ENV{KOHA_PATH}.'/installer/data/mysql/' unless $path;

  my @files;
  my @tries = ($path, $ENV{KOHA_PATH}.'/installer/data/mysql/');
  my ($userflags, $userpermissions);
  foreach my $pathCandidate (@tries) {
    $l->trace("Looking permission files from '$pathCandidate'") if $l->is_trace();
    if (-d $pathCandidate) {
      $userflags       = glob("$path/userflags*.sql");
      $userpermissions = glob("$path/userpermissions*.sql");
      last if ($userflags && $userpermissions);
    }
  }

  unless ($userflags && $userpermissions) {
    Koha::Exception::BadParameter->throw(error => "No userflags.sql or userpermissions.sql found from the given directory '$path'. Looking from directories '@tries'.");
  }
  else {
    $l->debug("Permission files found: '$userflags', '$userpermissions'") if $l->is_debug();
  }

  my $sql = File::Slurp::read_file($userpermissions);
  my $parserUserpermissions = SQL::Parser->new('AnyData');
  $parserUserpermissions->parse($sql);
  my $structureUserpermissions = Storable::dclone($parserUserpermissions->structure);

  $sql = File::Slurp::read_file($userflags);
  my $parserUserflags = SQL::Parser->new('AnyData');
  $parserUserflags->parse($sql);
  my $structureUserflags = Storable::dclone($parserUserflags->structure);

  return $self->_transformSQLParserToKohaInternalPermissions($structureUserflags, $structureUserpermissions);
}

#Mangle permissions fetched using SQL::Parser to the format Koha uses internally.
sub _transformSQLParserToKohaInternalPermissions {
  my ($self, $structureUserflags, $structureUserpermissions) = @_;

  my %neededPerms;
  foreach my $s (@{$structureUserflags->{values}}) {
    my $module      = $s->[0]->{fullorg};
    my $description = $s->[1]->{fullorg};
    $neededPerms{ $module } = {};
    $neededPerms{ $module }->{ description } = $description;
    $neededPerms{ $module }->{ module }      = $module;
    $neededPerms{ $module }->{ permissions } = {};
  }
  foreach my $s (@{$structureUserpermissions->{values}}) {
    my $module      = $s->[0]->{fullorg};
    my $permission  = $s->[1]->{fullorg};
    my $description = $s->[2]->{fullorg};
    $neededPerms{ $module }->{ permissions }->{ $permission } = {
      description   => $description,
      module        => $module,
      code          => $permission,
      #permission_id => undef,  #This is ignored in comparison, since we cannot get this from the SQL file.
    };
  }
  $self->{neededPerms} = \%neededPerms;
  return $self->{neededPerms};
}

#Remove excess DB columns not present in the userpermissions.sql-file so the entries in db and in the *.sql -files can be compared.
sub _dropDBcolumns {
  my ($self) = @_;

  my $neededPerms = $self->{neededPerms};
  my $kohaPerms   = $self->{kohaPerms};

  while (my ($module, $permsModule) = each %$kohaPerms) {

    delete $permsModule->{permission_module_id};

    while (my ($permission, $p) = each %{$permsModule->{permissions}}) {
      delete $p->{permission_id};
    }
  }
}

sub dataDiff {
  my ($self, $path) = @_;
  $self->parseKohasPermissionFiles($path) if ($path || not($self->{neededPerms}));

  $self->_getKohaPermissionsAsHASH() unless ($self->{kohaPerms});
  $self->_dropDBcolumns();

  #Looking at the manual of
  #  https://metacpan.org/pod/Struct::Diff#DIFF-FORMAT
  #Compared to the permissions in Koha,
  #    any extra permissions in neededPerms (loaded from the userpermissions.sql) compared to permissions in Koha's DB are considered to be something which were (A)dded
  #    any missing permissions in neededPerms are considered to be (R)emoved
  my $diff = Struct::Diff::diff( $self->{kohaPerms}, $self->{neededPerms}, noO => 1, noU => 1 );

  return $diff;
}

=head2 removeExcessPermissions

  $self->removeExcessPermissions(
    $self->dataDiff()
  );

Removes permissions that are present in the Koha's DB but missing from userpermissions.sql

 @returns ARRAYRef of Strings, a report of the list of actions performed.

=cut

sub removeExcessPermissions {
  my ($self, $diff) = @_;
  return $self->_actOnStructDiffResult($diff, undef, 'remove');
}


sub installMissingPermissions {
  my ($self, $diff) = @_;
  return $self->_actOnStructDiffResult($diff, 'install', undef);
}

## _actOnStructDiffResult
#
# Walks through the Struct::Diff output and detects changes.
# Installs and/or removes permissions as requested.
# Queues email to the KohaAdminEmail when changes to permissions are done.
#
##

sub _actOnStructDiffResult {
  my ($self, $diff, $install, $remove, $nomail) = @_;
  $diff = $self->dataDiff() unless $diff;

  my $pm = Koha::Auth::PermissionManager->new();
  my @report;

  #Biting into the Struct::Diff -tree. Bear with me my men!
  if (my $d1 = $diff->{D}) {
    $l->trace("Diff(1)") if $l->is_trace();

    while (my ($key2, $d2) = each (%{$diff->{D}})) {
      $l->trace("Diff(2): \$key2='$key2'") if $l->is_trace();

      if (my $removableModule = $d2->{R}) { #A complete module is missing from the userflags.sql
        $l->debug("Diff(3): \$removableModule='".Data::Dumper::Dumper($removableModule)."'") if $l->is_debug();

        if ($remove) {
          $l->info("Diff(3): Removing module '".$removableModule->{module}."'") if $l->is_info();
          $pm->delPermissionModule($removableModule);
          push(@report, "*Removed an excess permission module:\n".Data::Dumper::Dumper($removableModule));
        }
      }
      elsif (my $neededModule = $d2->{A}) { #We found the permission module details that are missing from the Koha's DB
        $l->debug("Diff(3): \$neededModule='".Data::Dumper::Dumper($neededModule)."'") if $l->is_debug();

        if ($install) {
          $l->info("Diff(3): Adding module '".$neededModule->{module}."'") if $l->is_info();
          my $m = {
            module      => $neededModule->{module},
            description => $neededModule->{description},
          };
          $pm->addPermissionModule($m);
          push(@report, "*Added a new permission module:\n".Data::Dumper::Dumper($m));

          while (my ($permCode, $p) = each (%{$neededModule->{permissions}})) {
            $l->info("Diff(3): Adding permission '$permCode'") if $l->is_info();
            $pm->addPermission($p);
            push(@report, "*Added a new permission:\n".Data::Dumper::Dumper($p));
          }
        }
      }
      elsif (my $d3 = $d2->{D}) { #A change was detected deeper than on the module level
        $l->trace("Diff(3)") if $l->is_trace();

        if (my $permissions = $d3->{permissions}->{D}) {
          $l->trace("Diff(4)") if $l->is_trace();

          while (my ($key5, $d5) = each (%{$permissions})) {
            $l->trace("Diff(5): \$key5='$key5'") if $l->is_trace();

            if (my $removablePermission = $d5->{R}) { #We found the permission details that are missing from the userpermissions.sql
              $l->debug("Diff(6): \$removablePermission='".Data::Dumper::Dumper($removablePermission)."'") if $l->is_debug();

              if ($remove) {
                $l->info("Diff(6): Removing permission '".$removablePermission->{code}."'") if $l->is_info();
                $pm->delPermission($removablePermission);
                push(@report, "*Removed an excess permission:\n".Data::Dumper::Dumper($removablePermission));
              }
            }
            elsif (my $neededPermission = $d5->{A}) { #We found the permission details that are missing from the Koha's DB
              $l->debug("Diff(6): \$neededPermission='".Data::Dumper::Dumper($neededPermission)."'") if $l->is_debug();

              if ($install) {
                $l->info("Diff(6): Adding permission '".$neededPermission->{code}."'") if $l->is_info();
                $pm->addPermission($neededPermission);
                push(@report, "*Added a new permission:\n".Data::Dumper::Dumper($neededPermission));
              }
            }
            else {
              $l->warn("Diff(6): Unexpected data structure: ".Data::Dumper::Dumper($d5)) if $l->is_warn();
            }
          }
        }
        else {
          $l->warn("Diff(4): Unexpected data structure: ".Data::Dumper::Dumper($permissions)) if $l->is_warn();
        }
      }
      else {
        $l->warn("Diff(3): Unexpected data structure: ".Data::Dumper::Dumper($d2)) if $l->is_warn();
      }
    }
  }
  #Done parsing the Struct::Diff -tree. That was a mouthful.


  #Send mail to KohaAdmin
  C4::Letters::EnqueueLetter({
    letter => {
      title   => 'Permissions changed in your Koha',
      content => join("\n", @report),
    },
    message_transport_type => 'email',
    to_address             => C4::Context->preference('KohaAdminEmailAddress'),
    from_address           => C4::Context->preference('KohaAdminEmailAddress'),
  }) unless $nomail;

  return \@report;
}

1;
