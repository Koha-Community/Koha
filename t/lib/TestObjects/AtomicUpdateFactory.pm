package t::lib::TestObjects::AtomicUpdateFactory;

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

use Koha::AtomicUpdater;
use Koha::Database;

use Koha::Exception::UnknownProgramState;

use base qw(t::lib::TestObjects::ObjectFactory);

sub getDefaultHashKey {
    return 'issue_id';
}
sub getObjectType {
    return 'Koha::AtomicUpdate';
}

=head t::lib::TestObjects::createTestGroup

    my $atomicupdates = t::lib::TestObjects::AtomicUpdateFactory->createTestGroup([
                            {'issue_id' => 'Bug3432',
                             'filename' => 'Bug3432-RavingRabbitsMayhem',
                             'modification_time' => '2015-01-02 15:59:32',
                            },
                        ], undef, $testContext1, $testContext2, $testContext3);

Calls Koha::AtomicUpdater to add a Koha::AtomicUpdate object to DB.

The HASH is keyed with the 'koha.atomicupdates.issue_id', or the given $hashKey.

There is a duplication check to first look for atomicupdate-rows with the same 'issue_id'.
If a matching atomicupdate is found, then we use the existing Record instead of adding a new one.

@RETURNS HASHRef of Koha::AtomicUpdate-objects

See t::lib::TestObjects::ObjectFactory for more documentation
=cut

sub handleTestObject {
    my ($class, $object, $stashes) = @_;

    ##First see if the given Record already exists in the DB. For testing purposes we use the isbn as the UNIQUE identifier.
    my $atomicupdate = Koha::AtomicUpdater->find($object->{issue_id});
    unless ($atomicupdate) {
        my $atomicupdater = Koha::AtomicUpdater->new();
        $atomicupdate = $atomicupdater->addAtomicUpdate($object);
    }

    Koha::Exception::UnknownProgramState->throw(error => "$class->handleTestObject():> Cannot create a new object\n$@\n")
                unless $atomicupdate;

    return $atomicupdate;
}

=head validateAndPopulateDefaultValues
@OVERLOAD

Validates given Object parameters and makes sure that critical fields are given
and populates defaults for missing values.
=cut

sub validateAndPopulateDefaultValues {
    my ($self, $object, $hashKey) = @_;

    $object->{issue_id} = 'BugRancidacid' unless $object->{issue_id};
    $object->{filename} = 'BugRancidacid-LaboratoryExperimentsGoneSour' unless $object->{filename};

    $self->SUPER::validateAndPopulateDefaultValues($object, $hashKey);
}

sub deleteTestGroup {
    my ($class, $objects) = @_;

    while( my ($key, $object) = each %$objects) {
        my $atomicupdate = Koha::AtomicUpdater->cast($object);
        eval {
            $atomicupdate->delete();
        };
        if ($@) {
            warn "$class->deleteTestGroup():> Error hapened: $@\n";
        }
    }
}

1;
