package Koha::Auth::Challenge::IndependentBranchesAutolocation;

# Copyright 2015 Vaara-kirjastot
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

use C4::Context;

use Koha::Libraries;

use Koha::Exception::LoginFailed;

use base qw(Koha::Auth::Challenge);

=head challenge

If sysprefs 'IndependentBranches' and 'Autolocation' are active, checks if the user
is in the correct network region to login.
@PARAM1 String, branchcode of the branch the current user is authenticating in to.
@THROWS Koha::Exception::LoginFailed, if the user is in the wrong network segment.
=cut

sub challenge {
    my ($currentBranchcode) = @_;

    if ( $currentBranchcode && C4::Context->boolean_preference('IndependentBranches') && C4::Context->boolean_preference('Autolocation') ) {
        my $ip = $ENV{'REMOTE_ADDR'};

        my $branches = Koha::Libraries->search->unblessed;
        # we have to check they are coming from the right ip range
        my $domain = $branches->{$currentBranchcode}->{'branchip'};
        if ( $ip !~ /^$domain/ ) {
            Koha::Exception::LoginFailed->throw(error => "Branch '$currentBranchcode' is inaccessible from this network.");
        }
    }
}

1;
