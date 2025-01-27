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

=head1 NAME

Koha::Template::Plugin::CirculationRules - A template plugin for dealing with things related to circulation


=head2 Methods

=head3 Get

[% SET rule = CirculationRules.Get( branchcode, categorycode, itemtype, rule_name ) %]

Returns the effective rule value for the given tuple.

=cut

sub Get {
    my ( $self, $branchcode, $categorycode, $itemtype, $rule_name ) = @_;

    $branchcode   = undef if $branchcode eq q{}   or $branchcode eq q{*};
    $categorycode = undef if $categorycode eq q{} or $categorycode eq q{*};
    $itemtype     = undef if $itemtype eq q{}     or $itemtype eq q{*};

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

=head3 Search

[% SET rule = CirculationRules.Search( branchcode, categorycode, itemtype, rule_name, { want_rule = 1 } ) %]

Returns the first rule that matches the given critea.
It does not perform precedence sorting as CirculationRules.Get would.

By default, it returns only the rule value. Set want_rule to true to return
the rule object.

=cut

sub Search {
    my ( $self, $branchcode, $categorycode, $itemtype, $rule_name, $params ) = @_;

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

    return $rule             if $params->{want_rule};
    return $rule->rule_value if $rule;
}

=head3 Renewals

[% SET renewals = CirculationRules.Renewals( borrowernumber, itemnumber ) %]
[% renewals.remaining | html %]

Returns a hash of data about renewals for a checkout, by the given borrowernumber and itemnumber.

Hash keys include:
count - The number of renewals already used
allowed - The total number of renewals this checkout may have
remaining - The total number of renewals that can still be made
unseen_count - The number of unseen renewals already used
unseen_allowed - The total number of unseen renewals this checkout may have
unseen_remaining - The total number of unseen renewals that can still be made

=cut

sub Renewals {
    my ( $self, $borrowernumber, $itemnumber ) = @_;

    my ( $count, $allowed, $remaining, $unseen_count, $unseen_allowed, $unseen_remaining ) =
        GetRenewCount( $borrowernumber, $itemnumber );

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
