package Koha::Patron::AllData;

# Copyright 2018 Koha-Suomi Oy
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

use Carp;

use C4::Context;
use Try::Tiny;
use Koha::Database;
use Koha::Patrons;
use Koha::Checkouts;
use Koha::Old::Checkouts;
use Koha::Holds;
use Koha::Old::Holds;
use Koha::Account::Lines;
use Koha::Patron::Messages;
use Koha::Suggestions;
use Koha::MessageQueues;
use Koha::RemoteAPIs;
use JSON;
use REST::Client;
use Encode qw(decode encode);


=head1 NAME

Koha::Patron::AllData - Module for managing patron AllData

=head1 METHODS

=over

=cut

sub getall {
    my ($class, $params) = @_;
    my $self = bless( {}, $class );

    return unless $params->{'borrowernumber'};

    my $borrowernumber = $params->{'borrowernumber'};
    my $jsonObject;
    my $error;
    try {
        $jsonObject->{personal} = Koha::Patrons->find($borrowernumber)->unblessed;
        $jsonObject->{checkouts} = Koha::Checkouts->search({borrowernumber => $borrowernumber})->unblessed;
        $jsonObject->{oldcheckouts} = Koha::Old::Checkouts->search({borrowernumber => $borrowernumber})->unblessed;
        $jsonObject->{holds} = Koha::Holds->search({borrowernumber => $borrowernumber})->unblessed;
        $jsonObject->{oldholds} = Koha::Old::Holds->search({borrowernumber => $borrowernumber})->unblessed;
        $jsonObject->{accountlines} = Koha::Account::Lines->search({borrowernumber => $borrowernumber})->unblessed;
        $jsonObject->{notices} = Koha::MessageQueues->search({borrowernumber => $borrowernumber})->unblessed;
        $jsonObject->{messages} = Koha::Patron::Messages->search({borrowernumber => $borrowernumber})->unblessed;
        $jsonObject->{debarments} = Koha::Patron::Debarments::GetDebarments({ borrowernumber => $borrowernumber});
        $jsonObject->{suggestions} = Koha::Suggestions->search({suggestedby => $borrowernumber})->unblessed;
        my ($ills, $illserror) = Koha::Patron::AllData->getill({borrowernumber => $borrowernumber});
        if ($ills) {
            foreach my $key (keys %{$ills}) {
                $jsonObject->{$key} = $ills->{$key};
            }
        }
    } catch {
        $error = $_->error;
    };
    return ($jsonObject, $error);
}

sub getpersonal {
    my ($class, $params) = @_;
    my $self = bless( {}, $class );

    return unless $params->{'borrowernumber'};

    my $borrowernumber = $params->{'borrowernumber'};
    my $jsonObject;
    my $error;

    try {
        $jsonObject->{personal} = Koha::Patrons->find($borrowernumber)->unblessed;
    } catch {
        $error = $_->error;
    };

    return ($jsonObject, $error);
}

sub getcheckouts {
    my ($class, $params) = @_;
    my $self = bless( {}, $class );

    return unless $params->{'borrowernumber'};

    my $borrowernumber = $params->{'borrowernumber'};
    my $jsonObject;
    my $error;

    try {
        $jsonObject->{checkouts} = Koha::Checkouts->search({borrowernumber => $borrowernumber})->unblessed;
        $jsonObject->{oldcheckouts} = Koha::Old::Checkouts->search({borrowernumber => $borrowernumber})->unblessed;
    } catch {
        $error = $_->error;
    };

    return ($jsonObject, $error);
}

sub getholds {
    my ($class, $params) = @_;
    my $self = bless( {}, $class );

    return unless $params->{'borrowernumber'};

    my $borrowernumber = $params->{'borrowernumber'};
    my $jsonObject;
    my $error;

    try {
        $jsonObject->{holds} = Koha::Holds->search({borrowernumber => $borrowernumber})->unblessed;
        $jsonObject->{oldholds} = Koha::Old::Holds->search({borrowernumber => $borrowernumber})->unblessed;
    } catch {
        $error = $_->error;
    };

    return ($jsonObject, $error);
}

sub getaccountlines {
    my ($class, $params) = @_;
    my $self = bless( {}, $class );

    return unless $params->{'borrowernumber'};

    my $borrowernumber = $params->{'borrowernumber'};
    my $jsonObject;
    my $error;

    try {
        $jsonObject->{accountlines} = Koha::Account::Lines->search({borrowernumber => $borrowernumber})->unblessed;
    } catch {
        $error = $_->error;
    };

    return ($jsonObject, $error);
}

sub getnotices {
    my ($class, $params) = @_;
    my $self = bless( {}, $class );

    return unless $params->{'borrowernumber'};

    my $borrowernumber = $params->{'borrowernumber'};
    my $jsonObject;
    my $error;

    try {
        $jsonObject->{notices} = Koha::MessageQueues->search({borrowernumber => $borrowernumber})->unblessed;
    } catch {
        $error = $_->error;
    };

    return ($jsonObject, $error);
}

sub getmessages {
    my ($class, $params) = @_;
    my $self = bless( {}, $class );

    return unless $params->{'borrowernumber'};

    my $borrowernumber = $params->{'borrowernumber'};
    my $jsonObject;
    my $error;

    try {
        $jsonObject->{messages} = Koha::Patron::Messages->search({borrowernumber => $borrowernumber})->unblessed;
    } catch {
        $error = $_->error;
    };

    return ($jsonObject, $error);
}

sub getdebarments {
    my ($class, $params) = @_;
    my $self = bless( {}, $class );

    return unless $params->{'borrowernumber'};

    my $borrowernumber = $params->{'borrowernumber'};
    my $jsonObject;
    my $error;

    try {
        $jsonObject->{debarments} = Koha::Patron::Debarments::GetDebarments({ borrowernumber => $borrowernumber});
    } catch {
        $error = $_->error;
    };

    return ($jsonObject, $error);
}

sub getsuggestions {
    my ($class, $params) = @_;
    my $self = bless( {}, $class );

    return unless $params->{'borrowernumber'};

    my $borrowernumber = $params->{'borrowernumber'};
    my $jsonObject;
    my $error;

    try {
        $jsonObject->{suggestions} = Koha::Suggestions->search({suggestedby => $borrowernumber})->unblessed;
    } catch {
        $error = $_->error;
    };

    return ($jsonObject, $error);
}

#############################
# Configurate RemoteApis system preference
#
# Ill:
#   host: https://myhost.com
#   basePath: /api/
#   authentication: none
#   subPaths: [ill_loans, old_ill_loans]
#   params:
#            param1: randomvalue
#            param2: cardnumber
#   api: MyILL
#
##############################

sub getill {
    my ($class, $params) = @_;
    my $self = bless( {}, $class );

    return unless $params->{'borrowernumber'};

    my $borrowernumber = $params->{'borrowernumber'};
    my $jsonObject;
    my $error;

    try {
        my $patron = Koha::Patrons->find($borrowernumber)->unblessed;
        my $client=REST::Client->new();
        my $remoteApis = Koha::RemoteAPIs->new->toJSON;
        my $config = from_json($remoteApis);
        if ($config->{ill}) {
            my $apiparams = "?";
            foreach my $key (keys %{$config->{ill}->{params}}) {
                if (exists $patron->{$config->{ill}->{params}->{$key}}) {
                    $apiparams .= $key."=".$patron->{$config->{ill}->{params}->{$key}};
                } else {
                    $apiparams .= $key."=".$config->{ill}->{params}->{$key};
                }
                $apiparams .= '&';
            }
            $apiparams =~ s/&$//;

            foreach my $subPath (@{$config->{ill}->{subPaths}}){
                my $url = $config->{ill}->{host}."/".$config->{ill}->{basePath}."/".$subPath.$apiparams;
                $client->GET($url);
                my $response = decode('UTF-8', $client->responseContent(), Encode::FB_CROAK);
                $jsonObject->{$subPath} = from_json($response);
            }
        }

    } catch {
        $error = $_->error;
    };

    return ($jsonObject, $error);
}

1;
