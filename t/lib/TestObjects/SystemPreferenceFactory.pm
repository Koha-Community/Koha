package t::lib::TestObjects::SystemPreferenceFactory;

# Copyright Vaara-kirjastot 2015
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
#

use Modern::Perl;
use Carp;
use Scalar::Util qw(blessed);

use base qw(t::lib::TestObjects::ObjectFactory);

use Koha::Exception::ObjectExists;

sub new {
    my ($class) = @_;

    my $self = {};
    bless($self, $class);
    return $self;
}

sub getDefaultHashKey {
    return 'preference';
}
sub getObjectType {
    return 'HASH';
}

=head createTestGroup( $data [, $hashKey, $testContexts...] )
@OVERLOADED

    my $preferences = t::lib::TestObjects::SystemPreferenceFactory->createTestGroup([
                        {preference => 'ValidateEmailAddress',
                         value      => 1,
                        },
                        {preference => 'ValidatePhoneNumber',
                         value      => 'OFF',
                        },
                    ], undef, $testContext1, $testContext2, $testContext3);

    #Do test stuff...

    t::lib::TestObjects::ObjectFactory->tearDownTestContext($testContext1);
    t::lib::TestObjects::ObjectFactory->tearDownTestContext($testContext2);
    t::lib::TestObjects::ObjectFactory->tearDownTestContext($testContext3);

See t::lib::TestObjects::ObjectFactory for more documentation
=cut

sub handleTestObject {
    my ($class, $pref, $stashes) = @_;

    my $preference = $pref->{preference};

    # Check if preference is already stored, so we wont lose the original preference
    my $alreadyStored;
    my $stashablePref = $pref;
    foreach my $stash (@$stashes) {
        if (exists $stash->{systempreference}->{$preference}) {
            $alreadyStored = 1;
            $stashablePref = $stash->{systempreference}->{$preference};
            last();
        }
    }
    $stashablePref->{old_value} = C4::Context->preference($pref->{preference}) unless ($alreadyStored);

    C4::Context->set_preference($pref->{preference}, $pref->{value});

    $stashablePref->{value} = $pref->{value};

    return $stashablePref;
}

=head validateAndPopulateDefaultValues
@OVERLOAD

Validates given Object parameters and makes sure that critical fields are given
and populates defaults for missing values.
=cut

sub validateAndPopulateDefaultValues {
    my ($class, $preference, $hashKey) = @_;
    $class->SUPER::validateAndPopulateDefaultValues($preference, $hashKey);

    if (not(defined(C4::Context->preference($preference->{preference})))) {
        croak __PACKAGE__.":> Preference '".$preference->{preference}."' not found.";
        next;
    }
    unless (exists($preference->{value})) {
        croak __PACKAGE__.":> Mandatory parameter 'value' not found.";
    }
}

=head deleteTestGroup
@OVERLOADED

    my $records = createTestGroup();
    ##Do funky stuff
    deleteTestGroup($prefs);

Removes the given test group from the DB.

=cut

sub deleteTestGroup {
    my ($class, $preferences) = @_;

    while( my ($key, $pref) = each %$preferences) {
        C4::Context->set_preference($pref->{preference}, $pref->{old_value});
    }
}

1;
