package Koha::Template::Plugin::CirculationRules;

# Copyright ByWater Solutions 2017

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

use base qw( Template::Plugin );

use Koha::CirculationRules;
use C4::Circulation qw( GetRenewCount );

sub Get {
    my ( $self, $branchcode, $categorycode, $itemtype, $rule_name ) = @_;

    $branchcode   = undef if $branchcode eq q{}   or $branchcode eq q{*};
    $categorycode = undef if $categorycode eq q{} or $categorycode eq q{*};
    $itemtype     = undef if $itemtype eq q{}     or $itemtype  eq q{*};

    my $rule = Koha::CirculationRules->get_effective_rule(
        {
            branchcode   => $branchcode,
            categorycode => $categorycode,
            itemtype     => $itemtype,
            rule_name    => $rule_name,
        }
    );

    return $rule->rule_value if $rule;
}

sub Search {
    my ( $self, $branchcode, $categorycode, $itemtype, $rule_name, $params) = @_;

    $branchcode   = undef if $branchcode eq q{}   or $branchcode eq q{*};
    $categorycode = undef if $categorycode eq q{} or $categorycode eq q{*};
    $itemtype     = undef if $itemtype eq q{}     or $itemtype eq q{*};

    my $rule = Koha::CirculationRules->search(
        {
            branchcode   => $branchcode,
            categorycode => $categorycode,
            itemtype     => $itemtype,
            rule_name    => $rule_name,
        }
    )->next;

    return $rule if $params->{want_rule};
    return $rule->rule_value if $rule;
}

sub Renewals {
    my ( $self, $borrowernumber, $itemnumber ) = @_;

    my ( $count, $allowed, $remaining, $unseen_count, $unseen_allowed, $unseen_remaining ) = GetRenewCount( $borrowernumber, $itemnumber );

    return {
        count            => $count,
        allowed          => $allowed,
        remaining        => $remaining,
        unseen_count     => $unseen_count,
        unseen_allowed   => $unseen_allowed,
        unseen_remaining => $unseen_remaining,
    };
}

1;
