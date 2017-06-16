package Koha::Auth::BorrowerPermission;

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

use Koha::Auth::BorrowerPermissions;
use Koha::Auth::PermissionModules;
use Koha::Auth::Permissions;
use Koha::Patrons;

use Koha::Exception::BadParameter;

use base qw(Koha::Object);

sub _type {
    return 'BorrowerPermission';
}

=head NAME

Koha::Auth::BorrowerPermission

=head SYNOPSIS

Object representation of a Permission given to a Borrower.

=head new

    my $borrowerPermission = Koha::Auth::BorrowerPermission->new({
                                borrowernumber => 12,
                                permission_module_id => 2,
                                permission => $Koha::Auth::Permission,
    });
    my $borrowerPermission = Koha::Auth::BorrowerPermission->new({
                                borrower => $Koha::Patron,
                                permissionModule => $Koha::Auth::PermissionModule,
                                permission_id => 22,
    });

Remember to ->store() the returned object to persist it in the DB.
@PARAM1 HASHRef of constructor parameters:
            MANDATORY keys:
                borrower or borrowernumber
                permissionModule or permission_module_id
                permission or permission_id
            Values can be either Koha::Object derivatives or their respective DB primary keys
@RETURNS Koha::Auth::BorrowerPermission
=cut

sub new {
    my ($class, $params) = @_;

    _validateParams($params);

    #Check for duplicates, and update existing permission if available.
    my $self = Koha::Auth::BorrowerPermissions->find({borrowernumber => $params->{borrower}->borrowernumber,
                                                      permission_module_id => $params->{permissionModule}->permission_module_id,
                                                      permission_id => $params->{permission}->permission_id,
                                                    });
    $self = $class->SUPER::new() unless $self;
    $self->{params} = $params;
    $self->set({borrowernumber => $self->getBorrower()->borrowernumber,
                permission_id => $self->getPermission()->permission_id,
                permission_module_id => $self->getPermissionModule()->permission_module_id
                });
    return $self;
}

=head getBorrower

    my $borrower = $borrowerPermission->getBorrower();

@RETURNS Koha::Patron
=cut

sub getBorrower {
    my ($self) = @_;

    unless ($self->{params}->{borrower}) {
        my $dbix_borrower = $self->_result()->borrower;
        my $borrower = Koha::Patron->_new_from_dbic($dbix_borrower);
        $self->{params}->{borrower} = $borrower;
    }
    return $self->{params}->{borrower};
}

=head setBorrower

    my $borrowerPermission = $borrowerPermission->setBorrower( $borrower );

Set the Borrower.
When setting the DB is automatically updated as well.
@PARAM1 Koha::Patron, set the given Borrower to this BorrowerPermission.
@RETURNS Koha::Auth::BorrowerPermission,
=cut

sub setBorrower {
    my ($self, $borrower) = @_;

    unless (blessed($borrower) && $borrower->isa('Koha::Patron')) {
        Koha::Exception::BadParameter->throw(error => __PACKAGE__."->setPermissionModule():> Given parameter '\\$borrower' is not a Koha::Patron-object!");
    }
    $self->{params}->{borrower} = $borrower;
    $self->set({borrowernumber => $borrower->borrowernumber()});
    $self->store();
}

=head getPermissionModule

    my $permissionModule = $borrowerPermission->getPermissionModule();

@RETURNS Koha::Auth::PermissionModule
=cut

sub getPermissionModule {
    my ($self) = @_;

    unless ($self->{params}->{permissionModule}) {
        my $dbix_object = $self->_result()->permission_module;
        my $object = Koha::Auth::PermissionModule->_new_from_dbic($dbix_object);
        $self->{params}->{permissionModule} = $object;
    }
    return $self->{params}->{permissionModule};
}

=head setPermissionModule

    my $borrowerPermission = $borrowerPermission->setPermissionModule( $permissionModule );

Set the PermissionModule.
When setting the DB is automatically updated as well.
@PARAM1 Koha::Auth::PermissionModule, set the given PermissionModule as
                                      the PermissionModule of this BorrowePermission.
@RETURNS Koha::Auth::BorrowerPermission,
=cut

sub setPermissionModule {
    my ($self, $permissionModule) = @_;

    unless (blessed($permissionModule) && $permissionModule->isa('Koha::Auth::PermissionModule')) {
        Koha::Exception::BadParameter->throw(error => __PACKAGE__."->setPermissionModule():> Given parameter '\$permissionModule' is not a Koha::Auth::PermissionModule-object!");
    }
    $self->{params}->{permissionModule} = $permissionModule;
    $self->set({permission_module_id => $permissionModule->permission_module_id()});
    $self->store();
}

=head getPermission

    my $permission = $borrowerPermission->getPermission();

@RETURNS Koha::Auth::Permission
=cut

sub getPermission {
    my ($self) = @_;

    unless ($self->{params}->{permission}) {
        my $dbix_object = $self->_result()->permission;
        my $object = Koha::Auth::Permission->_new_from_dbic($dbix_object);
        $self->{params}->{permission} = $object;
    }
    return $self->{params}->{permission};
}

=head setPermission

    my $borrowerPermission = $borrowerPermission->setPermission( $permission );

Set the Permission.
When setting the DB is automatically updated as well.
@PARAM1 Koha::Auth::Permission, set the given Permission to this BorrowerPermission.
@RETURNS Koha::Auth::BorrowerPermission,
=cut

sub setPermission {
    my ($self, $permission) = @_;

    unless (blessed($permission) && $permission->isa('Koha::Auth::Permission')) {
        Koha::Exception::BadParameter->throw(error => __PACKAGE__."->setPermission():> Given parameter '\$permission' is not a Koha::Auth::Permission-object!");
    }
    $self->{params}->{permission} = $permission;
    $self->set({permission_id => $permission->permission_id()});
    $self->store();
}

=head _validateParams

Validates the given constructor parameters and fetches the Koha::Objects when needed.

=cut

sub _validateParams {
    my ($params) = @_;

    $params->{permissionModule} = Koha::Auth::PermissionModules->cast( $params->{permission_module_id} || $params->{permissionModule} );
    $params->{permission} = Koha::Auth::Permissions->cast( $params->{permission_id} || $params->{permission} );
    $params->{borrower} = Koha::Patrons->cast(  $params->{borrowernumber} || $params->{borrower}  );
}

1;
