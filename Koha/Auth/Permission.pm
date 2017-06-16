package Koha::Auth::Permission;

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

use Koha::Auth::Permissions;

use Koha::Exception::BadParameter;

use base qw(Koha::Object);

sub _type {
    return 'Permission';
}

sub new {
    my ($class, $params) = @_;

    _validateParams($params);

    my $self = Koha::Auth::Permissions->find({code => $params->{code}, module => $params->{module}});
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
    unless ($params->{code} && length $params->{code} > 0) {
        Koha::Exception::BadParameter->throw(error => "Koha::Auth::Permission->new():> Parameter 'code' isn't defined or is empty.");
    }
}

1;
