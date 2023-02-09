package Koha::Illrequest::Logger;

# Copyright 2018 PTFS Europe Ltd
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
use JSON qw( from_json to_json );

use C4::Koha qw( GetAuthorisedValues );
use C4::Context;
use C4::Templates;
use C4::Log qw( logaction );
use Koha::ActionLogs;
use Koha::Notice::Template;

=head1 NAME

Koha::Illrequest::Logger - Koha ILL Action / Event logger

=head1 SYNOPSIS

Object-oriented class that provides event logging functionality for
ILL requests

=head1 DESCRIPTION

This class provides the ability to log arbitrary actions or events
relating to Illrequest to the action log.

=head1 API

=head2 Class Methods

=head3 new

    my $config = Koha::Illrequest::Logger->new();

Create a new Koha::Illrequest::Logger object.
We also set up what can be logged, how to do it and how to display
log entries we get back out

=cut

sub new {
    my ( $class ) = @_;
    my $self  = {};

    $self->{loggers} = {
        status => sub {
            $self->log_status_change(@_);
        },
        patron_notice => sub {
            $self->log_patron_notice(@_);
        }
    };

    my $query = CGI->new; # To keep C4::Templates::_get_template_file() from complaining
    my ( $htdocs, $theme, $lang, $base ) =
        C4::Templates::_get_template_file('ill/log/', 'intranet', $query);

    $self->{templates} = {
        STATUS_CHANGE => $base . 'status_change.tt',
        PATRON_NOTICE => $base . 'patron_notice.tt'
    };

    bless $self, $class;

    return $self;
}

=head3 log_maybe

    Koha::IllRequest::Logger->log_maybe($params);

Receive params hashref, containing a request object and an attrs
hashref (which may or may not be defined) If the attrs hashref contains
a key matching our "loggers" hashref then we want to log it

=cut

sub log_maybe {
    my ($self, $params) = @_;

    if (defined $params->{request} && defined $params->{attrs}) {
        foreach my $key (keys %{ $params->{attrs} }) {
            if (defined($self->{loggers}->{$key})) {
                $self->{loggers}->{$key}(
                    $params->{request},
                    $params->{attrs}->{$key}
                );
            }
        }
    }
}

=head3 log_patron_notice

    Koha::IllRequest::Logger->log_patron_notice($params);

Receive a hashref containing a request object and params to log,
and log it

=cut

sub log_patron_notice {
    my ( $self, $params ) = @_;

    if (defined $params->{request} && defined $params->{notice_code}) {
        $self->log_something({
            modulename   => 'ILL',
            actionname   => 'PATRON_NOTICE',
            objectnumber => $params->{request}->id,
            infos        => to_json({
                log_origin    => 'core',
                notice_code => $params->{notice_code}
            })
        });
    }
}

=head3 log_status_change

    Koha::IllRequest::Logger->log_status_change($params);

Receive a hashref containing a request object and a status to log,
and log it

=cut

sub log_status_change {
    my ( $self, $params ) = @_;

    if (defined $params->{request} && defined $params->{value}) {
        $self->log_something({
            modulename   => 'ILL',
            actionname   => 'STATUS_CHANGE',
            objectnumber => $params->{request}->id,
            infos        => to_json({
                log_origin    => 'core',
                status_before => $params->{request}->{previous_status},
                status_after  => $params->{value}
            })
        });
    }
}

=head3 log_something

    Koha::IllRequest::Logger->log_something({
        modulename   => 'ILL',
        actionname   => 'STATUS_CHANGE',
        objectnumber => $req->id,
        infos        => to_json({
            log_origin    => 'core',
            status_before => $req->{previous_status},
            status_after  => $new_status
        })
    });

If we have the required data passed, log an action

=cut

sub log_something {
    my ( $self, $to_log ) = @_;

    if (
        defined $to_log->{modulename} &&
        defined $to_log->{actionname} &&
        defined $to_log->{objectnumber} &&
        defined $to_log->{infos} &&
        C4::Context->preference("IllLog")
    ) {
        logaction(
            $to_log->{modulename},
            $to_log->{actionname},
            $to_log->{objectnumber},
            $to_log->{infos}
        );
    }
}

=head3 get_log_template

    $template_path = get_log_template($params);

Given a log's origin and action, get the appropriate display template

=cut

sub get_log_template {
    my ($self, $params) = @_;

    my $origin = $params->{origin};
    my $action = $params->{action};

    if ($origin eq 'core') {
        # It's a core log, so we can just get the template path from
        # the hashref above
        return $self->{templates}->{$action};
    } else {
        # It's probably a backend log, so we need to get the path to the
        # template from the backend
        #
        # We need to load the backend that this log was made from, so we
        # can get the template
        $params->{request}->load_backend($origin);
        my $backend =$params->{request}->{_my_backend};
        return $backend->get_log_template_path($action);
    }
}

=head3 get_request_logs

    $requestlogs = Koha::IllRequest::Logger->get_request_logs($request_id);

Get all logged actions for a given request

=cut

sub get_request_logs {
    my ( $self, $request ) = @_;

    my $logs = Koha::ActionLogs->search(
        {
            module => 'ILL',
            object => $request->id
        },
        { order_by => { -desc => "timestamp" } }
    )->unblessed;

    # Populate a lookup table for all ILL notice types
    my $notice_types = Koha::Notice::Templates->search({
        module => 'ill'
    })->unblessed;
    my $notice_hash;
    foreach my $notice(@{$notice_types}) {
        $notice_hash->{$notice->{code}} = $notice;
    }
    # Populate a lookup table for status aliases
    my $aliases = C4::Koha::GetAuthorisedValues('ILL_STATUS_ALIAS');
    my $alias_hash;
    foreach my $alias(@{$aliases}) {
        $alias_hash->{$alias->{authorised_value}} = $alias;
    }
    foreach my $log(@{$logs}) {
        $log->{notice_types} = $notice_hash;
        $log->{aliases} = $alias_hash;
        $log->{info} = from_json($log->{info});
        $log->{template} = $self->get_log_template({
            request => $request,
            origin => $log->{info}->{log_origin},
            action => $log->{action}
        });
    }

    return $logs;
}

=head1 AUTHOR

Andrew Isherwood <andrew.isherwood@ptfs-europe.com>

=cut

1;
