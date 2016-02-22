package C4::BatchOverlay::Report::Error;

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

use Modern::Perl;
use Scalar::Util qw(blessed);
use Try::Tiny;
use Data::Dumper;
use JSON::XS;

use C4::Context;
use C4::Biblio;
use C4::BatchOverlay::Report::Header;
use C4::BatchOverlay::ReportManager;

use Koha::Exception::BadParameter;
use Koha::Exception::DB;
use Koha::Exception::Parse;
use Koha::Exception::UnknownProgramState;

use base qw(C4::BatchOverlay::Report);

sub new {
    my ($class, $params) = @_;
    my $self = (ref($params) eq 'HASH') ? $params : {};
    bless $self, $class;
    $self->_validate();

    $self->createErrorPayload($self->{diff});

    return $self->SUPER::new();
}

=head newFromDB

    my $report = C4::BatchOverlay::Report->newFromDB($dbRow);

Takes a DB row of batch_overlay_diff and turns that into a Reports-object.
Also fetches all dependencies, like report headers.

@RETURNS C4::BatchOverlay::Report
@THROWS a lot of stuff

=cut

sub newFromDB {
    my ($class, $row) = @_;
    #Superclass already validated $row for us
    bless $row, $class;
    return $row;
}

=head createErrorPayload

turns a Exception::Class-object into a serializable and clear error report payload
@PARAM1 Exception::Class-subclass

=cut

sub createErrorPayload {
    my ($self, $exception) = @_;
    my $error;

    if (ref($exception)) {
        $error = {
            class => ref($exception),
            error => (blessed($exception) && $exception->can('error')) ? $exception->error : "$exception",
            searchTerm => $exception->{searchTerm},
            searchAlgorithm => $exception->{searchAlgorithm},
        };
    }
    else {
        $error = {
            error => "$exception",
        };
    }

    $self->{diff} = $error;
}

sub _validate {
    my ($self) = @_;
    $self->SUPER::_validate();
}

sub getError {
    return shift->{diff};
}

1; #Satisfying the compiler, we aim to please!
