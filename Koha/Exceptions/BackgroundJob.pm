package Koha::Exceptions::BackgroundJob;

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

use Modern::Perl;

use Koha::Exception;

use Exception::Class (

    'Koha::Exceptions::BackgroundJob' => {
        isa => 'Koha::Exception',
    },
    'Koha::Exceptions::BackgroundJob::InconsistentStatus' => {
        isa         => 'Koha::Exceptions::BackgroundJob',
        description => 'Status change requested but an invalid status found',
        fields      => [ 'current_status', 'expected_status' ]
    },
    'Koha::Exceptions::BackgroundJob::StepOutOfBounds' => {
        isa         => 'Koha::Exceptions::BackgroundJob',
        description => 'Cannot move progress forward'
    },
);

=head1 NAME

Koha::Exceptions::BackgroundJob - Base class for BackgroundJob exceptions

=head1 Exceptions

=head2 Koha::Exceptions::BackgroundJob

Generic BackgroundJob exception

=head2 Koha::Exceptions::BackgroundJob::InconsistentStatus

Exception to be used when an action on an BackgroundJob requires the job to
be in an specific I<status>, but it is not the case.

=head2 Koha::Exceptions::BackgroundJob::StepOutOfBounds

Exception to be used when the it is tried to advance one step in progress, but
the job size limit as been reached already.

=cut

1;
