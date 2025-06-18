package C4::SMS;

# Copyright 2007 Liblime
# Copyright 2015 Biblibre
# Copyright 2016 Catalyst
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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

=head1 NAME

C4::SMS - send SMS messages

=head1 SYNOPSIS

my ( $success, $error ) = C4::SMS->send_sms(
    {
        message     => 'This is my text message',
        destination => '212-555-1212'
    }
);

=head1 DESCRIPTION

A wrapper for SMS::Send.

Can use a yaml file for config, the path to which is in the koha-conf.xml
<sms_send_config>__KOHA_CONF_DIR__/sms_send/</sms_send_config>

Each file needs to be in the format of
__KOHA_CONF_DIR__/sms_send/<driver>.yaml

For example for SMS::Send::UK::Kapow the config would be

/etc/koha/sites/instancename/sms_send/UK/Kapow.yaml for package install
or
/etc/koha/sms_send/UK/Kapow.yaml for tarball

A underscore character is prepended to all parameter names so they are
treated as driver-specific options (leading underscore must not appear
in config file).

=cut

use strict;
use warnings;

use C4::Context;
use File::Spec;

=head1 METHODS

=cut

# The previous implementation used username and password.
# our $user = C4::Context->config('smsuser');
# our $pwd  = C4::Context->config('smspass');

=head2 send_sms

=cut

sub send_sms {
    my $self   = shift;
    my $params = shift;

    foreach my $required_parameter (qw( message destination )) {

        # Should I warn in some way?
        return unless defined $params->{$required_parameter};
    }

    eval { require SMS::Send; };
    if ($@) {

        # we apparently don't have SMS::Send. Return a failure.
        return;
    }

    # This allows the user to override the driver. See SMS::Send::Test
    my $driver = exists $params->{'driver'} ? $params->{'driver'} : $self->driver();
    return ( undef, 'SMS_SEND_DRIVER_MISSING' ) unless $driver;

    my ( $sent, $sender );

    my $subpath = $driver;
    $subpath =~ s|::|/|g;

    # Extract additional SMS::Send arguments from file
    my $sms_send_config = C4::Context->config('sms_send_config');
    my $conf_file =
        defined $sms_send_config
        ? File::Spec->catfile( $sms_send_config, $subpath )
        : $subpath;
    $conf_file .= q{.yaml};

    my %args = ();
    if ( -f $conf_file ) {
        require YAML::XS;
        my $conf = YAML::XS::LoadFile($conf_file);
        %args = map { q{_} . $_ => $conf->{$_} } keys %$conf;
    }

    # Extract additional SMS::Send arguments from the syspref
    # Merge with any arguments from file with syspref taking precedence
    if ( C4::Context->preference('SMSSendAdditionalOptions') ) {
        my $sms_send_config_syspref = C4::Context->yaml_preference('SMSSendAdditionalOptions');
        %args = ( %args, %$sms_send_config_syspref ) if $sms_send_config_syspref;
    }

    eval {
        # Create a sender
        $sender = SMS::Send->new(
            $driver,
            _login    => C4::Context->preference('SMSSendUsername'),
            _password => C4::Context->preference('SMSSendPassword'),
            %args,
        );

        # Send a message
        $sent = $sender->send_sms(
            to   => $params->{destination},
            text => $params->{message},
        );
    };

    #We might die because SMS::Send $driver is not defined or the sms-number has a bad format
    #Catch those errors and fail the sms-sending gracefully.
    if ($@) {
        warn $@;
        return ( undef, $@ );
    }

    # warn 'failure' unless $sent;
    return $sent;
}

=head2 driver

=cut

sub driver {
    my $self = shift;

    # return 'US::SprintPCS';
    return C4::Context->preference('SMSSendDriver');

}

1;

__END__

