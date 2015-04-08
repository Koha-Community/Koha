package C4::BackgroundJob;

# Copyright (C) 2007 LibLime
# Galen Charlton <galen.charlton@liblime.com>
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

use strict;
#use warnings; FIXME - Bug 2505
use C4::Context;
use C4::Auth qw/get_session/;
use Digest::MD5;

use vars qw($VERSION);

BEGIN {
	# set the version for version checking
    $VERSION = 3.07.00.049;
}

=head1 NAME

C4::BackgroundJob - manage long-running jobs
initiated from the web staff interface

=head1 SYNOPSIS

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

This module manages tracking the progress and results
of (potentially) long-running jobs initiated from 
the staff user interface.  Such jobs can include
batch MARC and patron record imports.

=head1 METHODS

=head2 new

 my $job = C4::BackgroundJob->new($sessionID, $job_name, $job_invoker, $num_work_units);

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
    $self->{'extra_values'} = {};

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

 my $jobID = $job->id();

Read-only accessor for job ID.

=cut

sub id {
    my $self = shift;
    return $self->{'jobID'};
}

=head2 name

 my $name = $job->name();
 $job->name($name);

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

 my $invoker = $job->invoker();
i $job->invoker($invoker);

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

 my $progress = $job->progress();
 $job->progress($progress);

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

 my $status = $job->status();

Read-only accessor for job status.

=cut

sub status {
    my $self = shift;
    return $self->{'status'};
}

=head2 size

 my $size = $job->size();
 $job->size($size);

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

 $job->finish($results_hashref);

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

 my $results_hashref = $job->results();

Retrieve the results of the current job.  Returns undef 
if the job status is not 'completed'.

=cut

sub results {
    my $self = shift;
    return unless $self->{'status'} eq 'completed';
    return $self->{'results'};
}

=head2 fetch

 my $job = C4::BackgroundJob->fetch($sessionID, $jobID);

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
        return;
    }
    my $self = $session->param($prefix);
    bless $self, $class;
    return $self;
}

=head2 set

=over 4

=item $job->set($hashref);

=back

Set some variables into the hashref.
These variables can be retrieved using the get method.

=cut

sub set {
    my ($self, $hashref) = @_;
    while ( my ($k, $v) = each %$hashref ) {
        $self->{extra_values}->{$k} = $v;
    }
    $self->_serialize();
    return;
}

=head2 get

=over 4

=item $value = $job->get($key);

=back

Get a variable which has been previously stored with the set method.

=cut

sub get {
    my ($self, $key) = @_;
    return $self->{extra_values}->{$key};
}

1;
__END__

=head1 AUTHOR

Koha Development Team <http://koha-community.org/>

Galen Charlton <galen.charlton@liblime.com>

=cut
