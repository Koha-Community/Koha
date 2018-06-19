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

package Koha::RemoteAPIs;

use Modern::Perl;

use Encode;
use YAML::XS;
use JSON;
use Scalar::Util qw(blessed);

use C4::Context;
use Koha::RemoteAPIs::Remote;

use Koha::Exception::FeatureUnavailable;
use Koha::Exception::BadParameter;
use Koha::Exception::UnknownProtocol;

sub new {
    my ($class) = @_;

    my $self = {};
    bless($self, $class);

    $self->_loadConfig();
    return $self;
}

sub _loadConfig {
    my ($self) = @_;

    my $config = Encode::encode_utf8(C4::Context->preference('RemoteAPIs'));
    Koha::Exception::FeatureUnavailable->throw(error => "'RemoteAPIs'-syspref is not defined.") unless $config;
    eval {
        $config = YAML::XS::Load($config);
    };
    if ($@) {
        Koha::Exception::BadParameter->throw(error => "'RemoteAPIs'-syspref is not proper YAML. YAML::XS error: '$@'");
    }
    Koha::Exception::BadParameter->throw(error => "'RemoteAPIs'-syspref is not properly defined.") unless(ref($config) eq 'HASH');

    my %config;
    foreach my $name (keys %{$config}) {
        my $remote = Koha::RemoteAPIs::Remote->new($name, $config->{$name});
        $config{$remote->id} = $remote;
    }
    $self->{config} = \%config;
}

=head2 remotes

  my $remotes = $self->remotes

@returns {ArrayRef of Koha::RemoteAPIs::Remote}

=cut

sub remotes {
    my @remotes = map {$_[0]->{config}->{$_}} keys(%{$_[0]->{config}});
    return \@remotes;
}

=head2 remote

  my $remote = $self->remote('remote_id');

@param {String} remote_id
@returns {Koha::RemoteAPIs::Remote}

=cut

sub remote {
    return $_[0]->{config}->{$_[1]};
}

=head2 isSupportedAPI

@returns {Boolean}, true if the given api name is supported
@throws {Koha::Exception::UnknownProtocol} if the api is not supported

=cut

sub isSupportedAPI {
    my ($api) = @_;
    return 1 if $api =~ m!Koha-Suomi|Koha-Suomi|Webkake!;
    Koha::Exception::UnknownProtocol->throw(error => "Parameter \$api '".$api."' is not supported. Supported API protocols are 'Koha-Suomi, Webkake'");
}

=head2 isSupportedAuthentication

@returns {Boolean}, true if the given authentication is supported
@throws {Koha::Exception::UnknownProtocol} if authentication protocol is not supported

=cut

sub isSupportedAuthentication {
    my ($authentication) = @_;
    return 1 if $authentication =~ m!cookies|none!;
    Koha::Exception::UnknownProtocol->throw(error => "Parameter \$authentication '".$authentication."' is not supported. Supported authentication protocols are 'cookies|none'");
}

sub toJSON {
    my ($self) = @_;

    return JSON->new->encode($self->toHash);
}

sub toHash {
    my ($self) = @_;

    my %self;
    while (my ($key, $value) = each(%{$self->{config}})) {
        $self{$key} = (blessed($value)) ? $value->toHash : $value;
    }
    return \%self;
}

1;
