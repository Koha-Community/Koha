package Koha::Auth::PermissionModule;

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

use Koha::Auth::PermissionModules;

use Koha::Exception::BadParameter;

use base qw(Koha::Object);

sub _type {
    return 'PermissionModule';
}

sub new {
    my ($class, $params) = @_;

    _validateParams($params);

    my $self = Koha::Auth::PermissionModules->find({module => $params->{module}});
    $self = $class->SUPER::new() unless $self;
    $self->set($params);
    return $self;
}

sub _validateParams {
    my ($params) = @_;

    unless ($params->{description} && length $params->{description} > 0) {
        Koha::Exception::BadParameter->throw(error => "Koha::Auth::Permission->new():> Parameter 'description' isn't defined or is empty.");
    }
    unless ($params->{module} && length $params->{module} > 0) {
        Koha::Exception::BadParameter->throw(error => "Koha::Auth::Permission->new():> Parameter 'module' isn't defined or is empty.");
    }
}

=head getPermissions

    my $permissions = $permissionModule->getPermissions();

@RETURNS List of Koha::Auth::Permission-objects
=cut

sub getPermissions {
    my ($self) = @_;

    unless ($self->{params}->{permissions}) {
        $self->{params}->{permissions} = [];
        my @dbix_objects = $self->_result()->permissions;
        foreach my $dbix_object (@dbix_objects) {
            my $object = Koha::Auth::Permission->_new_from_dbic($dbix_object);
            push @{$self->{params}->{permissions}}, $object;
        }
    }
    return $self->{params}->{permissions};
}

1;
