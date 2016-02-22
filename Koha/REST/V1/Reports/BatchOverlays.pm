package Koha::REST::V1::Reports::BatchOverlays;

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

use Mojo::Base 'Mojolicious::Controller';

use C4::BatchOverlay::ReportManager;

use Koha::Exception::UnknownObject;

use DateTime::Format::RFC3339;
use DateTime::Format::MySQL;
use Scalar::Util qw(blessed);
use Try::Tiny;

sub list_report_containers {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $containers = C4::BatchOverlay::ReportManager->listReports();

        if (scalar(@$containers)) {
            return $c->render( status => 200, openapi =>
                _swaggerizeReportContainers($containers)
            );
        }
        else {
            return $c->render( status => 404, openapi => {
                error => "No containers found"
            } );
        }
    } catch {
        Koha::Exceptions::rethrow_exception($_);
    };
}

sub list_reports {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $reportContainerId = $c->validation->param('reportContainerId');
        my $showAllExceptions = $c->validation->param('showAllExceptions') || 0;
        my $reports = C4::BatchOverlay::ReportManager->getReports(
            $reportContainerId,
            $showAllExceptions
        );

        if (scalar(@$reports)) {
            return $c->render( status => 200, openapi =>
                _swaggerizeReports($reports)
            );
        }
        else {
            return $c->render( status => 404, openapi => {
                error => "No reports found"
            } );
        }
    } catch {
        Koha::Exceptions::rethrow_exception($_);
    };
}

sub _swaggerizeReportContainer {
    my ($container) = @_;
    $container->{id}             = 0+$container->{id},
    $container->{borrowernumber} = 0+$container->{borrowernumber},
    $container->{reportsCount}   = 0+$container->{reportsCount},
    $container->{errorsCount}    = 0+$container->{errorsCount},
    $container->{timestamp}      = DateTime::Format::RFC3339->format_datetime( DateTime::Format::MySQL->parse_datetime($container->{timestamp}) ),
    return $container;
}
sub _swaggerizeReportContainers {
    my ($containers) = @_;
    for (my $i=0 ; $i<scalar(@$containers) ; $i++) {
        $containers->[$i] = _swaggerizeReportContainer($containers->[$i]);
    }
    return $containers;
}
sub _swaggerizeReport {
    my ($r) = @_;

    my $swag = {
        id =>                int($r->getId()),
        reportContainerId => int($r->getReportContainerId()),
        biblionumber =>      int($r->getBiblionumber() || 0) || undef,
        timestamp =>         DateTime::Format::RFC3339->new()->format_datetime( $r->getTimestamp() ),
        operation =>         $r->getOperation(),
        ruleName =>          $r->getRuleName(),
        diff =>              $r->serializeDiff(),
        headers =>           [],
    };
    my $headers = $r->getHeaders();
    foreach my $h (@$headers) {
        my $swgHd = {
            id =>                   int($h->getId()),
            batchOverlayReportId => int($h->getBatchOverlayReportId()),
            biblionumber =>         (defined($h->getBiblionumber())) ? int($h->getBiblionumber()) : undef,
            breedingid =>           (defined($h->getBreedingid())) ? int($h->getBreedingid()) : undef,
            title =>                $h->getTitle() || '',
            stdid =>                $h->getStdid() || '',
        };
        push(@{$swag->{headers}}, $swgHd);
    }
    return $swag;
}
sub _swaggerizeReports {
    my ($reports) = @_;
    for (my $i=0 ; $i<scalar(@$reports) ; $i++) {
        $reports->[$i] = _swaggerizeReport($reports->[$i]);
    }
    return $reports;
}

1;
