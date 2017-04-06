package Koha::Auth::PermissionManager;

# Copyright 2015 Vaara-kirjastot
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
use Scalar::Util qw(blessed);
use Try::Tiny;

use Koha::Database;
use Koha::Auth::Permission;
use Koha::Auth::PermissionModule;
use Koha::Auth::BorrowerPermission;
use Koha::Auth::BorrowerPermissions;

use Koha::Exception::BadParameter;
use Koha::Exception::NoPermission;
use Koha::Exception::UnknownProgramState;

=head NAME Koha::Auth::PermissionManager

=head SYNOPSIS

PermissionManager is a gateway to all Koha's permission operations. You shouldn't
need to touch individual Koha::Auth::Permission* -objects.

=head USAGE

See t::db_dependent::Koha::Auth::PermissionManager.t

=head new

    my $permissionManager = Koha::Auth::PermissionManager->new();

Instantiates a new PemissionManager.

In the future this Manager can easily be improved with Koha::Cache.

=cut

sub new {
    my ($class, $self) = @_;
    $self = {} unless $self;
    bless($self, $class);
    return $self;
}

=head addPermission

    $permissionManager->addPermission({ code => "end_remaining_hostilities",
                                        description => "All your base are belong to us",
    });

INSERTs or UPDATEs a Koha::Auth::Permission to the Koha DB.
Very handy when introducing new features that need new permissions.

@PARAM1 Koha::Auth::Permission
        or
        HASHRef of all the koha.permissions-table columns set.
@THROWS Koha::Exception::BadParameter
=cut

sub addPermission {
    my ($self, $permission) = @_;
    if (blessed($permission) && not($permission->isa('Koha::Auth::Permission'))) {
        Koha::Exception::BadParameter->throw(error => __PACKAGE__."::addPermission():> Given permission is not a Koha::Auth::Permission-object.");
    }
    elsif (ref($permission) eq 'HASH') {
        $permission = Koha::Auth::Permission->new($permission);
    }
    unless (blessed($permission)) {
        Koha::Exception::BadParameter->throw(error => __PACKAGE__."::addPermission():> Given permission '$permission' is not of a recognized format.");
    }

    $permission->store();
}

=head getPermission

    my $permission = $permissionManager->getPermission('edit_items'); #koha.permissions.code
    my $permission = $permissionManager->getPermission(12);           #koha.permissions.permission_id
    my $permission = $permissionManager->getPermission($dbix_Permission); #Koha::Schema::Result::Permission

@RETURNS Koha::Auth::Permission-object
@THROWS Koha::Exception::BadParameter
=cut

sub getPermission {
    my ($self, $permissionId) = @_;

    try {
        return Koha::Auth::Permissions->cast($permissionId);
    } catch {
        if (blessed($_) && $_->isa('Koha::Exception::UnknownObject')) {
            #We catch this type of exception, and simply return nothing, since there was no such Permission
        }
        else {
            die $_;
        }
    };
}

=head delPermission

    $permissionManager->delPermission('edit_items'); #koha.permissions.code
    $permissionManager->delPermission(12);           #koha.permissions.permission_id
    $permissionManager->delPermission($dbix_Permission); #Koha::Schema::Result::Permission
    $permissionManager->delPermission($permission); #Koha::Auth::Permission

@THROWS Koha::Exception::UnknownObject if no given object in DB to delete.
=cut

sub delPermission {
    my ($self, $permissionId) = @_;

    my $permission = Koha::Auth::Permissions->cast($permissionId);
    $permission->delete();
}

=head addPermissionModule

    $permissionManager->addPermissionModule({   module => "scotland",
                                                description => "William Wallace is my hero!",
    });

INSERTs or UPDATEs a Koha::Auth::PermissionModule to the Koha DB.
Very handy when introducing new features that need new permissions.

@PARAM1 Koha::Auth::PermissionModule
        or
        HASHRef of all the koha.permission_modules-table columns set.
@THROWS Koha::Exception::BadParameter
=cut

sub addPermissionModule {
    my ($self, $permissionModule) = @_;
    if (blessed($permissionModule) && not($permissionModule->isa('Koha::Auth::PermissionModule'))) {
        Koha::Exception::BadParameter->throw(error => __PACKAGE__."::addPermission():> Given permissionModule is not a Koha::Auth::PermissionModule-object.");
    }
    elsif (ref($permissionModule) eq 'HASH') {
        $permissionModule = Koha::Auth::PermissionModule->new($permissionModule);
    }
    unless (blessed($permissionModule)) {
        Koha::Exception::BadParameter->throw(error => __PACKAGE__."::addPermission():> Given permissionModule '$permissionModule' is not of a recognized format.");
    }

    $permissionModule->store();
}

=head getPermissionModule

    my $permission = $permissionManager->getPermissionModule('cataloguing'); #koha.permission_modules.module
    my $permission = $permissionManager->getPermission(12);           #koha.permission_modules.permission_module_id
    my $permission = $permissionManager->getPermission($dbix_Permission); #Koha::Schema::Result::PermissionModule

@RETURNS Koha::Auth::PermissionModule-object
@THROWS Koha::Exception::BadParameter
=cut

sub getPermissionModule {
    my ($self, $permissionModuleId) = @_;

    try {
        return Koha::Auth::PermissionModules->cast($permissionModuleId);
    } catch {
        if (blessed($_) && $_->isa('Koha::Exception::UnknownObject')) {
            #We catch this type of exception, and simply return nothing, since there was no such PermissionModule
        }
        else {
            die $_;
        }
    };
}

=head delPermissionModule

    $permissionManager->delPermissionModule('cataloguing'); #koha.permission_modules.module
    $permissionManager->delPermissionModule(12);           #koha.permission_modules.permission_module_id
    $permissionManager->delPermissionModule($dbix_Permission); #Koha::Schema::Result::PermissionModule
    $permissionManager->delPermissionModule($permissionModule); #Koha::Auth::PermissionModule

@THROWS Koha::Exception::UnknownObject if no given object in DB to delete.
@THROWS Koha::Exception::BadParameter
=cut

sub delPermissionModule {
    my ($self, $permissionModuleId) = @_;

    my $permissionModule = Koha::Auth::PermissionModules->cast($permissionModuleId);
    $permissionModule->delete();
}

=head getKohaPermissions

    my $kohaPermissions = $permissionManager->getKohaPermissions();

Gets all the PermissionModules and their related Permissions in one huge DB query.
@RETURNS ARRAYRef of Koha::Auth::PermissionModule-objects with related objects prefetched.
=cut

sub getKohaPermissions {
    my ($self) = @_;

    my $schema = Koha::Database->new()->schema();
    my @permissionModules = $schema->resultset('PermissionModule')->search(
                                                            {},
                                                            {   join => ['permissions'],
                                                                prefetch => ['permissions'],
                                                                order_by => ['me.module', 'permissions.code'],
                                                            }
                                                        );
    #Cast DBIx to Koha::Object.
    for (my $i=0 ; $i<scalar(@permissionModules) ; $i++) {
        $permissionModules[$i] = Koha::Auth::PermissionModules->cast( $permissionModules[$i] );
    }
    return \@permissionModules;
}

=head listKohaPermissionsAsHASH

@RETURNS HASHRef, a HASH-representation of all the permissions and permission modules
in Koha. Eg:
                 {
                    acquisitions => {
                        description => "Yada yada",
                        module => 'acquisitions',
                        permission_module_id => 21,
                        permissions => {
                            budget_add_del => {
                                description => "More yada yada",
                                code => 'budget_add_del',
                                permission_id => 12,
                            }
                            budget_manage => {
                                description => "Yaawn yadayawn",
                                ...
                            }
                            ...
                        }
                    },
                    borrowers => {
                        ...
                    },
                    ...
                 }
=cut

sub listKohaPermissionsAsHASH {
    my ($self) = @_;
    my $permissionModules = $self->getKohaPermissions();
    my $hash = {};

    foreach my $permissionModule (sort {$a->module cmp $b->module} @$permissionModules) {
        my $module = $permissionModule->module;

        $hash->{$module} = $permissionModule->_result->{'_column_data'};
        $hash->{$module}->{permissions} = {};

        my $permissions = $permissionModule->getPermissions;
        foreach my $permission (sort {$a->code cmp $b->code} @$permissions) {
            my $code = $permission->code;

            $hash->{$module}->{permissions}->{$code} = $permission->_result->{'_column_data'};
        }
    }
    return $hash;
}

=head getBorrowerPermissions

    my $borrowerPermissions = $permissionManager->getBorrowerPermissions($borrower);     #Koha::Borrower
    my $borrowerPermissions = $permissionManager->getBorrowerPermissions($dbix_borrower);#Koha::Schema::Resultset::Borrower
    my $borrowerPermissions = $permissionManager->getBorrowerPermissions(1012);          #koha.borrowers.borrowernumber
    my $borrowerPermissions = $permissionManager->getBorrowerPermissions('167A0012311'); #koha.borrowers.cardnumber
    my $borrowerPermissions = $permissionManager->getBorrowerPermissions('bill69');      #koha.borrowers.userid

@RETURNS ARRAYRef of Koha::Auth::BorrowerPermission-objects
@THROWS Koha::Exception::UnknownObject, if the given $borrower cannot be casted to Koha::Borrower
@THROWS Koha::Exception::BadParameter
=cut

sub getBorrowerPermissions {
    my ($self, $borrower) = @_;
    $borrower = Koha::Patrons->cast($borrower);

    if ($borrower->isSuperuser()) {
        return [Koha::Auth::BorrowerPermission->new({borrower => $borrower, permission => 'superlibrarian', permissionModule => 'superlibrarian'})];
    }

    my $schema = Koha::Database->new()->schema();

    my @borrowerPermissions = $schema->resultset('BorrowerPermission')->search({borrowernumber => $borrower->borrowernumber},
                                                                               {join => ['permission','permission_module'],
                                                                                prefetch => ['permission','permission_module'],
                                                                                order_by => ['permission_module.module', 'permission.code']});
    for (my $i=0 ; $i<scalar(@borrowerPermissions) ; $i++) {
        $borrowerPermissions[$i] = Koha::Auth::BorrowerPermissions->cast($borrowerPermissions[$i]);
    }
    return \@borrowerPermissions;
}

=head grantAllSubpermissions

    $permissionManager->grantAllSubpermissions($borrower, [
        borrowers,
        reserveforothers,
        tools
    ]);

    $permissionManager->grantAllSubpermissions($borrower,
        \Koha::Auth::PermissionModules->as_list
    );

    $permissionManager->grantAllSubpermissions($borrower, [
        Koha::Auth::PermissionModule,
        Koha::Auth::PermissionModule,
        Koha::Auth::PermissionModule
    ]);

Grants all permissions from the given module(s).

@THROWS Koha::Exception::UnknownObject, if the given $borrower cannot be casted to Koha::Borrower
@THROWS Koha::Exception::BadParameter
=cut

sub grantAllSubpermissions {
    my ($self, $borrower, $modules) = @_;

    unless (ref($modules) eq 'ARRAY') {
        $modules = [$modules];
    }

    my $to_be_granted = {};
    foreach my $module (@$modules) {
        if (ref($module) eq 'Koha::Auth::PermissionModule') {
            $to_be_granted->{$module->module} = $module->getPermissions();
        } else {
            $to_be_granted->{$module} = Koha::Auth::PermissionModules->find({
                                        module => $module,
                                    })->getPermissions();
        }
    }

    $self->grantPermissions($borrower, $to_be_granted);
}

=head grantPermissions

    $permissionManager->grantPermissions($borrower, {borrowers => 'view_borrowers',
                                                     reserveforothers => ['place_holds'],
                                                     tools => ['edit_news', 'edit_notices'],
                                                     acquisition => {
                                                       budger_add_del => 1,
                                                       budget_modify => 1,
                                                     },
                                                    }
                                        );

Adds a group of permissions to one user.
@THROWS Koha::Exception::UnknownObject, if the given $borrower cannot be casted to Koha::Borrower
@THROWS Koha::Exception::BadParameter
=cut

sub grantPermissions {
    my ($self, $borrower, $permissionsGroup) = @_;

    while (my ($module, $permissions) = each(%$permissionsGroup)) {
        if (ref($permissions) eq 'ARRAY') {
            foreach my $permission (@$permissions) {
                $self->grantPermission($borrower, $module, $permission);
            }
        }
        elsif (ref($permissions) eq 'HASH') {
            foreach my $permission (keys(%$permissions)) {
                $self->grantPermission($borrower, $module, $permission);
            }
        }
        else {
            $self->grantPermission($borrower, $module, $permissions);
        }
    }
}

=head grantPermission

    my $borrowerPermission = $permissionManager->grantPermission($borrower, $permissionModule, $permission);

@PARAM1 Koha::Patron or
        Scalar koha.borrowers.borrowernumber or
        Scalar koha.borrowers.cardnumber or
        Scalar koha.borrowers.userid or
@PARAM2 Koha::Auth::PermissionModule-object
        Scalar koha.permission_modules.module or
        Scalar koha.permission_modules.permission_module_id
@PARAM3 Koha::Auth::Permission-object or
        Scalar koha.permissions.code or
        Scalar koha.permissions.permission_id
@RETURNS Koha::Auth::BorrowerPermissions
@THROWS Koha::Exception::UnknownObject, if the given parameters cannot be casted to Koha::Object-subclasses
@THROWS Koha::Exception::BadParameter
=cut

sub grantPermission {
    my ($self, $borrower, $permissionModule, $permission) = @_;

    my $borrowerPermission = Koha::Auth::BorrowerPermission->new({borrower => $borrower, permissionModule => $permissionModule, permission => $permission});
    $borrowerPermission->store();
    return $borrowerPermission;
}

=head

    $permissionManager->revokePermission($borrower, $permissionModule, $permission);

Revokes a Permission from a Borrower
same parameters as grantPermission()

@THROWS Koha::Exception::UnknownObject, if the given parameters cannot be casted to Koha::Object-subclasses
@THROWS Koha::Exception::BadParameter
=cut

sub revokePermission {
    my ($self, $borrower, $permissionModule, $permission) = @_;

    my $borrowerPermission = Koha::Auth::BorrowerPermission->new({borrower => $borrower, permissionModule => $permissionModule, permission => $permission});
    $borrowerPermission->delete();
    return $borrowerPermission;
}

=head revokeAllPermissions

    $permissionManager->revokeAllPermissions($borrower);

@THROWS Koha::Exception::UnknownObject, if the given $borrower cannot be casted to Koha::Borrower
@THROWS Koha::Exception::BadParameter
=cut

sub revokeAllPermissions {
    my ($self, $borrower) = @_;
    $borrower = Koha::Patrons->cast($borrower);

    my $schema = Koha::Database->new()->schema();
    $schema->resultset('BorrowerPermission')->search({borrowernumber => $borrower->borrowernumber})->delete_all();
}

=head hasPermissions

See if the given Borrower has all of the given permissions
@PARAM1 Koha::Borrower, or any of the koha.borrowers-table's unique identifiers.
@PARAM2 HASHRef of needed permissions,
    {
        borrowers => 'view_borrowers',
        reserveforothers => ['place_holds'],
        tools => ['edit_news', 'edit_notices'],
        acquisition => {
            budger_add_del => 1,
            budget_modify => 1,
        },
        coursereserves => '*', #Means any Permission under this PermissionModule
   }
@RETURNS see hasPermission()
@THROWS Koha::Exception::NoPermission, from hasPermission() if permission is missing.
=cut

sub hasPermissions {
    my ($self, $borrower, $requiredPermissions) = @_;

    foreach my $module (keys(%$requiredPermissions)) {
        my $permissions = $requiredPermissions->{$module};
        if (ref($permissions) eq 'ARRAY') {
            foreach my $permission (@$permissions) {
                $self->hasPermission($borrower, $module, $permission);
            }
        }
        elsif (ref($permissions) eq 'HASH') {
            foreach my $permission (keys(%$permissions)) {
                $self->hasPermission($borrower, $module, $permission);
            }
        }
        else {
            $self->hasPermission($borrower, $module, $permissions);
        }
    }
    return 1;
}

=head hasPermission

See if the given Borrower has the given permission
@PARAM1 Koha::Borrower, or any of the koha.borrowers-table's unique identifiers.
@PARAM2 Koha::Auth::PermissionModule or koha.permission_modules.module or koha.permission_modules.permission_module_id
@PARAM3 Koha::Auth::Permission or koha.permissions.code or koha.permissions.permission_id or
                               '*' if we just need any permission for the given PermissionModule.
@RETURNS Integer, 1 if permission check succeeded.
                  2 if user is a superlibrarian.
                  Catch Exceptions if permission check fails.
@THROWS Koha::Exception::NoPermission, if Borrower is missing the permission.
                                       Exception tells which permission is missing.
@THROWS Koha::Exception::UnknownObject, if the given parameters cannot be casted to Koha::Object-subclasses
@THROWS Koha::Exception::BadParameter
=cut

sub hasPermission {
    my ($self, $borrower, $permissionModule, $permission) = @_;

    $borrower = Koha::Patrons->cast($borrower);
    $permissionModule = Koha::Auth::PermissionModules->cast($permissionModule);
    $permission = Koha::Auth::Permissions->cast($permission) unless $permission eq '*';

    my $error;
    if ($permission eq '*') {
        my $borrowerPermission = Koha::Auth::BorrowerPermissions->search({borrowernumber => $borrower->borrowernumber,
                                                 permission_module_id => $permissionModule->permission_module_id,
                                                })->next();
        return 1 if ($borrowerPermission);
        $error = "Borrower '".$borrower->borrowernumber."' lacks any permission under permission module '".$permissionModule->module."'.";
    }
    else {
        my $borrowerPermission = Koha::Auth::BorrowerPermissions->search({borrowernumber => $borrower->borrowernumber,
                                                 permission_module_id => $permissionModule->permission_module_id,
                                                 permission_id => $permission->permission_id,
                                                })->next();
        return 1 if ($borrowerPermission);
        $error = "Borrower '".$borrower->borrowernumber."' lacks permission module '".$permissionModule->module."' and permission '".$permission->code."'.";
    }

    return 2 if not($permissionModule->module eq 'superlibrarian') && $self->_isSuperuser($borrower);
    return 2 if not($permissionModule->module eq 'superlibrarian') && $self->_isSuperlibrarian($borrower);
    Koha::Exception::NoPermission->throw(error => $error);
}

sub _isSuperuser {
    my ($self, $borrower) = @_;
    $borrower = Koha::Patrons->cast($borrower);

    if ( $borrower->userid && $borrower->userid eq C4::Context->config('user') ) {
        return 1;
    }
    elsif ( $borrower->userid && $borrower->userid eq 'demo' && C4::Context->config('demo') ) {
        return 1;
    }
    return 0;
}

sub _isSuperlibrarian {
    my ($self, $borrower) = @_;

    try {
        return $self->hasPermission($borrower, 'superlibrarian', 'superlibrarian');
    } catch {
        if (blessed($_) && $_->isa('Koha::Exception::NoPermission')) {
            return 0;
        }
        else {
            die $_;
        }
    };
}

1;
