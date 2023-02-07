package Koha::Illrequest::Config;

# Copyright 2013,2014 PTFS Europe Ltd
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

use File::Basename qw( basename );

use C4::Context;

=head1 NAME

Koha::Illrequest::Config - Koha ILL Configuration Object

=head1 SYNOPSIS

Object-oriented class that giving access to the illconfig data derived
from ill/config.yaml.

=head1 DESCRIPTION

Config object providing abstract representation of the expected XML
returned by ILL API.

In particular the config object uses a YAML file, whose path is
defined by <illconfig> in koha-conf.xml. That YAML file provides the
data structure exposed in this object.

By default the configured data structure complies with fields used by
the British Library Interlibrary Loan DSS API.

The config file also provides mappings for Record Object accessors.

=head1 API

=head2 Class Methods

=head3 new

    my $config = Koha::Illrequest::Config->new();

Create a new Koha::Illrequest::Config object, with mapping data loaded from the
ILL configuration file.

=cut

sub new {
    my ( $class ) = @_;
    my $self  = {};

    $self->{configuration} = _load_configuration(
        C4::Context->config("interlibrary_loans")
      );

    bless $self, $class;

    return $self;
}

=head3 backend

    $backend = $config->backend($name);
    $backend = $config->backend;

Standard setter/accessor for our backend.

=cut

sub backend {
    my ( $self, $new ) = @_;
    $self->{configuration}->{backend} = $new if $new;
    return $self->{configuration}->{backend};
}

=head3 backend_dir

    $backend_dir = $config->backend_dir($new_path);
    $backend_dir = $config->backend_dir;

Standard setter/accessor for our backend_directory.

=cut

sub backend_dir {
    my ( $self, $new ) = @_;
    $self->{configuration}->{backend_directory} = $new if $new;
    return $self->{configuration}->{backend_directory};
}

=head3 available_backends

  $backends = $config->available_backends;
  $backends = $config->abailable_backends($reduced);

Return a list of available backends, if passed a | delimited list it
will filter those backends down to only those present in the list.

=cut

sub available_backends {
    my ( $self, $reduce ) = @_;
    my $backend_dir = $self->backend_dir;
    my @backends = ();
    @backends = glob "$backend_dir/*" if ( $backend_dir );
    @backends = map { basename($_) } @backends;
    @backends = grep { $_ =~ /$reduce/ } @backends if $reduce;
    return \@backends;
}

=head3 has_branch

Return whether a 'branch' block is defined

=cut

sub has_branch {
    my ( $self ) = @_;
    return $self->{configuration}->{raw_config}->{branch};
}

=head3 partner_code

    $partner_code = $config->partner_code($new_code);
    $partner_code = $config->partner_code;

Standard setter/accessor for our partner_code.

=cut

sub partner_code {
    my ( $self, $new ) = @_;
    $self->{configuration}->{partner_code} = $new if $new;
    return $self->{configuration}->{partner_code};
}

=head3 limits

    $limits = $config->limits($limitshash);
    $limits = $config->limits;

Standard setter/accessor for our limits.  No parsing is performed on
$LIMITSHASH, so caution should be exercised when using this setter.

=cut

sub limits {
    my ( $self, $new ) = @_;
    $self->{configuration}->{limits} = $new if $new;
    return $self->{configuration}->{limits};
}

=head3 getPrefixes

    my $prefixes = $config->getPrefixes();

Return the branch prefix for ILLs defined by our config.

=cut

sub getPrefixes {
    my ( $self ) = @_;
    return $self->{configuration}->{prefixes}->{branch};
}

=head3 getLimitRules

    my $rules = $config->getLimitRules('brw_cat' | 'branch')

Return the hash of ILL limit rules defined by our config.

=cut

sub getLimitRules {
    my ( $self, $type ) = @_;
    die "Unexpected type." unless ( $type eq 'brw_cat' || $type eq 'branch' );
    my $values = $self->{configuration}->{limits}->{$type};
    $values->{default} = $self->{configuration}->{limits}->{default};
    return $values;
}

=head3 getDigitalRecipients

    my $recipient_rules= $config->getDigitalRecipients('brw_cat' | 'branch');

Return the hash of digital_recipient settings defined by our config.

=cut

sub getDigitalRecipients {
    my ( $self, $type ) = @_;
    die "Unexpected type." unless ( $type eq 'brw_cat' || $type eq 'branch' );
    my $values = $self->{configuration}->{digital_recipients}->{$type};
    $values->{default} =
        $self->{configuration}->{digital_recipients}->{default};
    return $values;
}

=head3 censorship

    my $censoredValues = $config->censorship($hash);
    my $censoredValues = $config->censorship;

Standard setter/accessor for our limits.  No parsing is performed on $HASH, so
caution should be exercised when using this setter.

Return our censorship values for the OPAC as loaded from the koha-conf.xml, or
the fallback value (no censorship).

=cut

sub censorship {
    my ( $self, $new ) = @_;
    $self->{configuration}->{censorship} = $new if $new;
    return $self->{configuration}->{censorship};
}

=head3 _load_configuration

    my $configuration = $config->_load_configuration($config_from_xml);

Read the configuration values passed as the parameter, and populate a hashref
suitable for use with these.

A key task performed here is the parsing of the input in the configuration
file to ensure we have only valid input there.

=cut

sub _load_configuration {
    my ( $xml_config ) = @_;
    my $xml_backend_dir = $xml_config->{backend_directory};

    # Default data structure to be returned
    my $configuration = {
        backend_directory  => $xml_backend_dir,
        censorship         => {
            censor_notes_staff => 0,
            censor_reply_date => 0,
        },
        limits             => {},
        digital_recipients => {},
        prefixes           => {},
        partner_code       => 'IL',
        raw_config         => $xml_config,
    };

    # Per Branch Configuration
    my $branches = $xml_config->{branch};
    if ( ref($branches) eq "ARRAY" ) {
        # Multiple branch overrides defined
        map {
            _load_unit_config({
                unit   => $_,
                id     => $_->{code},
                config => $configuration,
                type   => 'branch'
            })
        } @{$branches};
    } elsif ( ref($branches) eq "HASH" ) {
        # Single branch override defined
        _load_unit_config({
            unit   => $branches,
            id     => $branches->{code},
            config => $configuration,
            type   => 'branch'
        });
    }

    # Per Borrower Category Configuration
    my $brw_cats = $xml_config->{borrower_category};
    if ( ref($brw_cats) eq "ARRAY" ) {
        # Multiple borrower category overrides defined
        map {
            _load_unit_config({
                unit   => $_,
                id     => $_->{code},
                config => $configuration,
                type   => 'brw_cat'
            })
        } @{$brw_cats};
    } elsif ( ref($brw_cats) eq "HASH" ) {
        # Single branch override defined
        _load_unit_config({
            unit   => $brw_cats,
            id     => $brw_cats->{code},
            config => $configuration,
            type   => 'brw_cat'
        });
    }

    # Default Configuration
    _load_unit_config({
        unit   => $xml_config,
        id     => 'default',
        config => $configuration
    });

    # Censorship
    my $staff_comments = $xml_config->{staff_request_comments} || 0;
    $configuration->{censorship}->{censor_notes_staff} = 1
        if ( $staff_comments && 'hide' eq $staff_comments );
    my $reply_date = $xml_config->{reply_date} || 0;
    $configuration->{censorship}->{censor_reply_date} = 1
        if ( $reply_date && 'hide' eq $reply_date );

    # ILL Partners
    $configuration->{partner_code} = $xml_config->{partner_code} || 'IL';

    return $configuration;
}

=head3 _load_unit_config

    my $configuration->{part} = _load_unit_config($params);

$PARAMS is a hashref with the following elements:
- unit: the part of the configuration we are parsing.
- id: the name within which we will store the parsed unit in config.
- config: the configuration we are augmenting.
- type: the type of config unit we are parsing.  Assumed to be 'default'.

Read `unit', and augment `config' with these under `id'.

This is a helper for _load_configuration.

A key task performed here is the parsing of the input in the configuration
file to ensure we have only valid input there.

=cut

sub _load_unit_config {
    my ( $params ) = @_;
    my $unit = $params->{unit};
    my $id = $params->{id};
    my $config = $params->{config};
    my $type = $params->{type};
    die "TYPE should be either 'branch' or 'brw_cat' if ID is not 'default'."
        if ( $id ne 'default' && ( $type ne 'branch' && $type ne 'brw_cat') );
    return $config unless $id;

    if ( $unit->{api_key} && $unit->{api_auth} ) {
        $config->{credentials}->{api_keys}->{$id} = {
            api_key  => $unit->{api_key},
            api_auth => $unit->{api_auth},
        };
    }
    # Add request_limit rules.
    # METHOD := 'annual' || 'active'
    # COUNT  := x >= -1
    if ( ref $unit->{request_limit} eq 'HASH' ) {
        my $method  = $unit->{request_limit}->{method};
        my $count = $unit->{request_limit}->{count};
        if ( 'default' eq $id ) {
            $config->{limits}->{$id}->{method}  = $method
                if ( $method && ( 'annual' eq $method || 'active' eq $method ) );
            $config->{limits}->{$id}->{count} = $count
                if ( $count && ( -1 <= $count ) );
        } else {
            $config->{limits}->{$type}->{$id}->{method}  = $method
                if ( $method && ( 'annual' eq $method || 'active' eq $method ) );
            $config->{limits}->{$type}->{$id}->{count} = $count
                if ( $count && ( -1 <= $count ) );
        }
    }

    # Add prefix rules.
    # PREFIX := string
    if ( $unit->{prefix} ) {
        if ( 'default' eq $id ) {
            $config->{prefixes}->{$id} = $unit->{prefix};
        } else {
            $config->{prefixes}->{$type}->{$id} = $unit->{prefix};
        }
    }

    # Add digital_recipient rules.
    # DIGITAL_RECIPIENT := borrower || branch (defaults to borrower)
    if ( $unit->{digital_recipient} ) {
        if ( 'default' eq $id ) {
            $config->{digital_recipients}->{$id} = $unit->{digital_recipient};
        } else {
            $config->{digital_recipients}->{$type}->{$id} =
                $unit->{digital_recipient};
        }
    }

    return $config;
}

=head1 AUTHOR

Alex Sassmannshausen <alex.sassmannshausen@ptfs-europe.com>

=cut

1;
