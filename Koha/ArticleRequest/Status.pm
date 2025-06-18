package Koha::ArticleRequest::Status;

# Copyright ByWater Solutions 2015
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

use Modern::Perl;

use constant Requested  => 'REQUESTED';
use constant Pending    => 'PENDING';
use constant Processing => 'PROCESSING';
use constant Completed  => 'COMPLETED';
use constant Canceled   => 'CANCELED';

=head1 AUTHOR

Kyle M Hall <kyle@bywatersolutions.com>

=cut

1;
