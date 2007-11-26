package C4::BackgroundJob;

# Copyright (C) 2007 LibLime
# Galen Charlton <galen.charlton@liblime.com>
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

use strict;
use C4::Context;
use C4::Auth qw/get_session/;
use Digest::MD5;

use vars qw($VERSION);

# set the version for version checking
$VERSION = 3.00;

=head1 NAME

C4::BackgroundJob - manage long-running jobs
initiated from the web staff interface

=head1 SYNOPSIS

=over 4

# start tracking a job
my $job = C4::BackgroundJob->new($sessionID, $job_name, $job_invoker, $num_work_units);
my $jobID = $job->id();
$job->progress($work_units_processed);
$job->finish($job_result_hashref);

# get status and results of a job
my $job = C4::BackgroundJob->fetch($sessionID, $jobID);
my $max_work_units = $job->size();
my $work_units_processed = $job->progress();
my $job_status = $job->status();
my $job_name = $job->name();
my $job_invoker = $job->invoker();
my $results_hashref = $job->results();

=back

This module manages tracking the progress and results
of (potentially) long-running jobs initiated from 
the staff user interface.  Such jobs can include
batch MARC and patron record imports.

=cut

=head1 METHODS

=cut

=head2 new

=over 4

my $job = C4::BackgroundJob->new($sessionID, $job_name, $job_invoker, $num_work_units);

=back

Create a new job object and set its status to 'running'.  C<$num_work_units>
should be a number representing the size of the job; the units of the
job size are up to the caller and could be number of records, 
number of bytes, etc.

=cut

sub new {
    my $class = shift;
    my ($sessionID, $job_name, $job_invoker, $num_work_units) = @_;

    my $self = {};
    $self->{'sessionID'} = $sessionID;
    $self->{'name'} = $job_name;
    $self->{'invoker'} = $job_invoker;
    $self->{'size'} = $num_work_units;
    $self->{'progress'} = 0;
    $self->{'status'} = "running";
    $self->{'jobID'} = Digest::MD5::md5_hex(Digest::MD5::md5_hex(time().{}.rand().{}.$$));

    bless $self, $class;
    $self->_serialize();

    return $self;
}

# store object in CGI session
sub _serialize {
    my $self = shift;

    my $prefix = "job_" . $self->{'jobID'};
    my $session = get_session($self->{'sessionID'});
    $session->param($prefix, $self);
    $session->flush();
}

=head2 id

=over 4

my $jobID = $job->id();

=back

Read-only accessor for job ID.

=cut

sub id {
    my $self = shift;
    return $self->{'jobID'};
}

=head2 name

=over 4

my $name = $job->name();
$job->name($name);

=back

Read/write accessor for job name.

=cut

sub name {
    my $self = shift;
    if (@_) {
        $self->{'name'} = shift;
        $self->_serialize();
    } else {
        return $self->{'name'};
    }
}

=head2 invoker

=over 4

my $invoker = $job->invoker();
$job->invoker($invoker);

=back

Read/write accessor for job invoker.

=cut

sub invoker {
    my $self = shift;
    if (@_) {
        $self->{'invoker'} = shift;
        $self->_serialize();
    } else {
        return $self->{'invoker'};
    }
}

=head2 progress

=over 4

my $progress = $job->progress();
$job->progress($progress);

=back

Read/write accessor for job progress.

=cut

sub progress {
    my $self = shift;
    if (@_) {
        $self->{'progress'} = shift;
        $self->_serialize();
    } else {
        return $self->{'progress'};
    }
}

=head2 status

=over 4

my $status = $job->status();

=back

Read-only accessor for job status.

=cut

sub status {
    my $self = shift;
    return $self->{'status'};
}

=head2 size

=over 4

my $size = $job->size();
$job->size($size);

=back

Read/write accessor for job size.

=cut

sub size {
    my $self = shift;
    if (@_) {
        $self->{'size'} = shift;
        $self->_serialize();
    } else {
        return $self->{'size'};
    }
}

=head2 finish

=over 4

$job->finish($results_hashref);

=back

Mark the job as finished, setting its status to 'completed'.
C<$results_hashref> should be a reference to a hash containing
the results of the job.

=cut

sub finish {
    my $self = shift;
    my $results_hashref = shift;
    $self->{'status'} = 'completed';
    $self->{'results'} = $results_hashref;
    $self->_serialize();
}

=head2 results

=over 4

my $results_hashref = $job->results();

=back

Retrieve the results of the current job.  Returns undef 
if the job status is not 'completed'.

=cut

sub results {
    my $self = shift;
    return undef unless $self->{'status'} eq 'completed';
    return $self->{'results'};
}

=head2 fetch

=over 4

my $job = C4::BackgroundJob->fetch($sessionID, $jobID);

=back

Retrieve a job that has been serialized to the database. 
Returns C<undef> if the job does not exist in the current 
session.

=cut

sub fetch {
    my $class = shift;
    my $sessionID = shift;
    my $jobID = shift;

    my $session = get_session($sessionID);
    my $prefix = "job_$jobID";
    unless (defined $session->param($prefix)) {
        return undef;
    }
    my $self = $session->param($prefix);
    bless $self, $class;
    return $self;
}

=head1 AUTHOR

Koha Development Team <info@koha.org>

Galen Charlton <galen.charlton@liblime.com>

=cut
