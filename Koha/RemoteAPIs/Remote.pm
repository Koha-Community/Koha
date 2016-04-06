# Copyright (C) 2016 KohaSuomi
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

package Koha::RemoteAPIs::Remote;

use Modern::Perl;

use Mojo::URL;
use Scalar::Util qw(blessed);

use Koha::RemoteAPIs;

use Koha::Exception::BadParameter;

sub new {
    my ($class, $name, $params) = _validate(@_);
    bless($params, $class);
    $params->{id} = lc($name);
    $params->{id} =~ s!\s!_!g;
    return $params;
}

sub _validate {
    my ($class, $name, $params) = @_;

    unless ($name) {
        Koha::Exception::BadParameter->throw(error => "Parameter \$name '$name' is undefined or empty.");
    }
    $params->{name} = $name;

    unless ($params->{host} && $params->{host} =~ m!^(?:([^:/?#]+):)?(?://([^/?#]*))?$!) { #http://stackoverflow.com/questions/11927730/regular-expression-validate-url-in-perl
        Koha::Exception::BadParameter->throw(error => "Parameter \$host '".$params->{host}."' is not a proper fully qualified hostname, eg. 'http://me.naiset.fi:8080'");
    }
    $params->{host} = Mojo::URL->new($params->{host});

    #Strip leading and following slashes.
    if ($params->{basePath}) {
        $params->{basePath} =~ s!^/!!;
        $params->{basePath} =~ s!/$!!;
        $params->{basePath} = Mojo::URL->new($params->{basePath});
    }

    Koha::RemoteAPIs::isSupportedAPI($params->{api}); #Validate against supported api names
    Koha::RemoteAPIs::isSupportedAuthentication($params->{authentication}); #Validate against supported authentications

    return @_;
}

sub id {                return shift->{id};      }
sub host {              return shift->{host};    }
sub basePath {          return shift->{basePath};}
sub api {               return shift->{api};     }
sub authentication {    return shift->{authentication};}
sub name {              return shift->{name};    }

sub toHash {
    my ($self) = @_;

    my %self;
    while (my ($key, $value) = each(%$self)) {
        if (blessed($value)) {
            if ($value->can('toHash')) {
                $self{$key} = $value->toHash;
            }
            else {
                $self{$key} = "$value";
            }
        }
        else {
            $self{$key} = $value;
        }
    }
    return \%self;
}

1;
