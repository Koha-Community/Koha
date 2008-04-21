package C4::Scheduler;

# Copyright 2007 Liblime Ltd
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

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
use C4::Context;
use Schedule::At;

BEGIN {
	# set the version for version checking
	$VERSION = 0.02;
	require Exporter;
	@ISA = qw(Exporter);
	@EXPORT =
		qw(get_jobs get_at_jobs get_at_job add_at_job remove_at_job);
}

=head1 NAME

C4::Scheduler - Module for running jobs with the unix at command

=head1 SYNOPSIS

  use C4::Scheduler;

=head1 DESCRIPTION


=head1 METHODS

=over 2

=cut

=item get_jobs();

This will return all scheduled jobs

=cut

sub get_jobs {
    my $jobs = get_at_jobs();
# add call to get cron jobs here too
    return ($jobs);
}

=item get_at_jobs();

This will return all At scheduled jobs

=cut

sub get_at_jobs {
	my %jobs = Schedule::At::getJobs();
	return (\%jobs);
}

=item get_at_job($id)

This will return the At job with the given id

=cut

sub get_at_job {
	my ($id)=@_;
	my %jobs = Schedule::At::getJobs(JOBID => $id);
}

=item add_at_job ($time,$command)

Given a timestamp and a command this will schedule the job to run at that time

=cut

sub add_at_job {
	my ($time,$command) = @_;
	Schedule::At::add(TIME => $time, COMMAND => $command, TAG => $command);
}

sub remove_at_job {
	my ($jobid)=@_;
	Schedule::At::remove(JOBID => $jobid);
}

1;
__END__

=head1 AUTHOR

Chris Cormack <crc@liblime.com>

=cut
