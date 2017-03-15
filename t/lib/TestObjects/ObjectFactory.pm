package t::lib::TestObjects::ObjectFactory;

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
use Koha::Exception::BadParameter;
use Koha::Exception::UnknownObject;

=head createTestGroup( $data [, $hashKey, $testContexts...] )

    my $factory = t::lib::TestObjects::ObjectFactory->new();
    my $objects = $factory->createTestGroup([
                        #Imagine if using the PatronFactory
                        {firstname => 'Olli-Antti',
                         surname   => 'Kivi',
                         cardnumber => '11A001',
                         branchcode     => 'CPL',
                         ...
                        },
                        #Or if using the ItemFactory
                        {biblionumber => 123413,
                         barcode   => '11N002',
                         homebranch => 'FPL',
                         ...
                        },
                    ], $hashKey, $testContext1, $testContext2, $testContext3);

    #Do test stuff...

    t::lib::TestObjects::ObjectFactory->tearDownTestContext($testContext1);
    t::lib::TestObjects::ObjectFactory->tearDownTestContext($testContext2);
    t::lib::TestObjects::ObjectFactory->tearDownTestContext($testContext3);

The HASH is keyed with the given $hashKey or the default hash key accessed with
getDefaultHashKey()
See the createTestGroup() documentation in the implementing Factory-class for how
the table columns need to be given.

@PARAM1 ARRAYRef of HASHRefs of desired Object constructor parameters
        or
        HASHRef of desired Object constructor parameters
@PARAM2 koha.<object>-column which is used as the test context HASH key to find individual Objects,
                usually defaults to to one of the UNIQUE database keys.
@PARAM3-5 HASHRef of test contexts. You can save the given Objects to multiple
                test contexts. Usually one is enough. These test contexts are
                used to help tear down DB changes.
@RETURNS HASHRef of $hashKey => Objects, eg.
                { $hashKey => {#borrower1 HASH},
                  $hashKey => {#borrower2 HASH},
                }
         or
         Object, single object reference if the constructors parameters were given as a HASHRef instead
=cut

sub createTestGroup {
    my ($class, $objects, $hashKey, $featureStash, $scenarioStash, $stepStash) = @_;
    my $stashes = [$featureStash, $scenarioStash, $stepStash];
    $class->_validateStashes(@$stashes);
    $hashKey = $class->getDefaultHashKey() unless $hashKey;

    my $retType = 'HASHRef';
    unless (ref($objects) eq 'ARRAY') {
        $objects = [$objects];
        $retType = 'SCALAR';
    }

    my %objects;
    foreach my $o (@$objects) {
        $class->validateAndPopulateDefaultValues($o, $hashKey, $stashes);

        my $addedObject = $class->handleTestObject($o, $stashes);
        if (not($addedObject) ||
            (blessed($addedObject) && not($addedObject->isa($class->getObjectType()))) ||
            not(ref($addedObject) eq $class->getObjectType() )
           ) {
            Koha::Exception::UnknownObject->throw(error => __PACKAGE__."->createTestGroup():> Subroutine '$class->handleTestObject()' must return a HASH or a Koha::Object");
        }

        my $key = $class->getHashKey($addedObject, undef, $hashKey);
        $objects{$key} = $addedObject;
    }

    $class->_persistToStashes(\%objects, $class->getHashGroupName(), @$stashes);

    if ($retType eq 'HASHRef') {
        return \%objects;
    }
    else {
        foreach my $key (keys %objects) {
            return $objects{$key};
        }
    }
}

=head getHashGroupName
@OVERRIDABLE

@RETURNS String, the test context/stash key under which all of these test objects are put.
                 The key is calculated by default from the last components of the Object package,
                 but it is possible to override this method from the subclass to force another key.
                 Eg. 't::lib::PageObject::Acquisition::Bookseller::ContactFactory' becomes
                     acquisition-bookseller-contact
=cut

sub getHashGroupName {
    my ($class) = @_;

    my $excludedPackageStart = 't::lib::TestObjects';
    unless ($class =~ m/^${excludedPackageStart}::(.+?)Factory/i) {
        Koha::Exception::BadParameter->throw(error =>
            "$class->getHashGroupName():> Couldn't parse the class name to the default test stash group name. Your class is badly named. Expected format '${excludedPackageStart}::<Module>[::Submodule]::<Class>Factory'");
    }
    my @e = split('::', lc($1));
    return join('-', @e);
}

sub handleTestObject {} #OVERLOAD THIS FROM SUBCLASS
sub deleteTestGroup {} #OVERLOAD THIS FROM SUBCLASS

=head tearDownTestContext

Given a testContext stash populated using one of the TestObjectFactory implementations createTestGroup()-subroutines,
Removes all the persisted objects in the stash.

TestObjectFactories must be lazy loaded here to make it possible for them to subclass this.
=cut

sub tearDownTestContext {
    my ($self, $stash) = @_;
    unless (ref($stash) eq 'HASH') {
        Koha::Exception::BadParameter->throw(error => "Parameter '\$stash' is not a HASHref. You must call this subroutine with -> instead of ::");
    }

    ##You should introduce tearDowns in such an order that to not provoke FOREIGN KEY issues.
    if ($stash->{'file'}) {
        require t::lib::TestObjects::FileFactory;
        t::lib::TestObjects::FileFactory->deleteTestGroup($stash->{'file'});
        delete $stash->{'file'};
    }
    if ($stash->{'serial-subscription'}) {
        require t::lib::TestObjects::Serial::SubscriptionFactory;
        t::lib::TestObjects::Serial::SubscriptionFactory->deleteTestGroup($stash->{'serial-subscription'});
        delete $stash->{'serial-subscription'};
    }
    if ($stash->{'acquisition-bookseller-contact'}) {
        require t::lib::TestObjects::Acquisition::Bookseller::ContactFactory;
        t::lib::TestObjects::Acquisition::Bookseller::ContactFactory->deleteTestGroup($stash->{'acquisition-bookseller-contact'});
        delete $stash->{'acquisition-bookseller-contact'};
    }
    if ($stash->{'acquisition-bookseller'}) {
        require t::lib::TestObjects::Acquisition::BooksellerFactory;
        t::lib::TestObjects::Acquisition::BooksellerFactory->deleteTestGroup($stash->{'acquisition-bookseller'});
        delete $stash->{'acquisition-bookseller'};
    }
    if ($stash->{'labels-sheet'}) {
        require t::lib::TestObjects::Labels::SheetFactory;
        t::lib::TestObjects::Labels::SheetFactory->deleteTestGroup($stash->{'labels-sheet'});
        delete $stash->{'labels-sheet'};
    }
    if ($stash->{checkout}) {
        require t::lib::TestObjects::CheckoutFactory;
        t::lib::TestObjects::CheckoutFactory->deleteTestGroup($stash->{checkout});
        delete $stash->{checkout};
    }
    if ($stash->{item}) {
        require t::lib::TestObjects::ItemFactory;
        t::lib::TestObjects::ItemFactory->deleteTestGroup($stash->{item});
        delete $stash->{item};
    }
    if ($stash->{biblio}) {
        require t::lib::TestObjects::BiblioFactory;
        t::lib::TestObjects::BiblioFactory->deleteTestGroup($stash->{biblio});
        delete $stash->{biblio};
    }
    if ($stash->{atomicupdate}) {
        require t::lib::TestObjects::AtomicUpdateFactory;
        t::lib::TestObjects::AtomicUpdateFactory->deleteTestGroup($stash->{atomicupdate});
        delete $stash->{atomicupdate};
    }
    if ($stash->{patron}) {
        require t::lib::TestObjects::PatronFactory;
        t::lib::TestObjects::PatronFactory->deleteTestGroup($stash->{patron});
        delete $stash->{patron};
    }
    if ($stash->{hold}) {
        require t::lib::TestObjects::HoldFactory;
        t::lib::TestObjects::HoldFactory->deleteTestGroup($stash->{hold});
        delete $stash->{hold};
    }
    if ($stash->{lettertemplate}) {
        require t::lib::TestObjects::LetterTemplateFactory;
        t::lib::TestObjects::LetterTemplateFactory->deleteTestGroup($stash->{lettertemplate});
        delete $stash->{letterTemplate};
    }
    if ($stash->{systempreference}) {
        require t::lib::TestObjects::SystemPreferenceFactory;
        t::lib::TestObjects::SystemPreferenceFactory->deleteTestGroup($stash->{systempreference});
        delete $stash->{systempreference};
    }
    if ($stash->{matcher}) {
        require t::lib::TestObjects::MatcherFactory;
        t::lib::TestObjects::MatcherFactory->deleteTestGroup($stash->{matcher});
        delete $stash->{matcher};
    }
    if ($stash->{messagequeue}) {
        require t::lib::TestObjects::MessageQueueFactory;
        t::lib::TestObjects::MessageQueueFactory->deleteTestGroup($stash->{messagequeue});
        delete $stash->{messagequeue};
    }
    if ($stash->{fines}) {
        require t::lib::TestObjects::FinesFactory;
        t::lib::TestObjects::FinesFactory->deleteTestGroup($stash->{fines});
        delete $stash->{fines};
    }
}

=head getHashKey
@OVERLOADABLE

@RETURNS String, The test context/stash HASH key to differentiate this object
                 from all other such test objects.
=cut

sub getHashKey {
    my ($class, $object, $primaryKey, $hashKeys) = @_;

    my @collectedHashKeys;
    $hashKeys = $class->getDefaultHashKey unless $hashKeys;
    $hashKeys = [$hashKeys] unless ref($hashKeys) eq 'ARRAY';
    foreach my $hashKey (@$hashKeys) {
        if (ref($object) eq 'HASH') {
            if ($hashKey && not($object->{$hashKey})) {
                croak $class."->getHashKey($object, $primaryKey, $hashKey):> Given ".ref($object)." has no \$hashKey '$hashKey'.";
            }
            push @collectedHashKeys, $object->{$hashKey};
        }
        else {
            my $key = $object->{$hashKey};
            eval {
                $key = $object->$hashKey();
            } unless $key;
            if ($hashKey && not($key)) {
                croak $class."->getHashKey($object, $primaryKey, $hashKey):> Given ".ref($object)." has no \$hashKey '$hashKey'. ".($@) ? $@ : '';
            }
            push @collectedHashKeys, $key;
        }
    }
    return join('-', @collectedHashKeys);
}

=head

=cut

sub addToContext {
    my ($class, $objects, $hashKeys, $featureStash, $scenarioStash, $stepStash) = @_;
    my @stashes = ($featureStash, $scenarioStash, $stepStash);

    if (ref($objects) eq 'ARRAY') {
        foreach my $object (@$objects) {
            $class->addToContext($object, $hashKeys, @stashes);
        }
        return undef; #End recursion
    }
    elsif (ref($objects) eq 'HASH') {
        #Apparently we get a HASH of keyed objects.
        $class->_persistToStashes($objects, $class->getHashGroupName(), @stashes);
        return undef; #End recursion
    }
    else {
        #Here $objects is verified to be a single object, instead of a group of objects.
        #We create a hash key for it and append it to the stashes.
        my $hash = { $class->getHashKey($objects, undef, $class->getDefaultHashKey) => $objects};
        $class->_persistToStashes($hash, $class->getHashGroupName(), @stashes);
    }
}

=head validateAndPopulateDefaultValues
@INTERFACE

Validates given Object parameters and makes sure that critical fields are given
and populates defaults for missing values.
You must overload this in the subclassing factory if you want to validate and check the given parameters
=cut

sub validateAndPopulateDefaultValues {
    my ($self, $object, $hashKeys) = @_;

    $hashKeys = [$hashKeys] unless ref($hashKeys) eq 'ARRAY';
    foreach my $hashKey (@$hashKeys) {
        unless ($object->{$hashKey}) {
            Koha::Exception::BadParameter->throw(error => ref($self)."():> You want to access test Objects using hashKey '$hashKey', but you haven't supplied it as a Object parameter. ObjectFactories need a unique identifier to function properly.");
        }
    }
}

=head validateObjectType

    try {
        $object = $class->validateObjectType($object);
    } catch {
        ...
    }

Validates if the given Object matches the expected type of the subclassing TestObjectFactory.
@PARAM1 Object that needs to be validated.
@THROWS Koha::Exception::UnknownObject, if the given object is not of the same type that the object factory creates.

=cut

sub validateObjectType {
    my ($class, $object) = @_;

    my $invalid = 0;
    if (blessed($object)) {
        unless ($object->isa( $class->getObjectType() )) {
            $invalid = 1;
        }
    }
    else {
        unless (ref($object) eq $class->getObjectType()) {
            $invalid = 1;
        }
    }

    Koha::Exception::UnknownObject->throw(
        error => "$class->validateObjectType():> Given object '$object' isn't a '".$class->getObjectType()."'-object."
    ) if $invalid;

    return $object;
}

=head getObjectType
@OVERLOAD
Get the type of objects this factory creates.
@RETURN String, the object package this factory creates. eg. Koha::Borrower
=cut

sub getObjectType {
    my ($class) = @_;
    die "You must overload 'validateObjectType()' in the implementing ObjectFactory subclass '$class'.";
    return 'Koha::Object derivative or other Object';
}

=head _validateStashes

    _validateStashes($featureStash, $scenarioStash, $stepStash);

Validates that the given stahses are what they are supposed to be... ,  HASHrefs.
@THROWS Koha::Exception::BadParameter, if validation failed.
=cut

sub _validateStashes {
    my ($self, $featureStash, $scenarioStash, $stepStash) = @_;

    if ($featureStash && not(ref($featureStash) eq 'HASH')) {
        Koha::Exception::BadParameter->throw(error => __PACKAGE__."->_validateStashes():> Stash '\$featureStash' is not a HASHRef! Leave it 'undef' if you don't want to use it.");
    }
    if ($scenarioStash && not(ref($scenarioStash) eq 'HASH')) {
        Koha::Exception::BadParameter->throw(error => __PACKAGE__."->_validateStashes():> Stash '\$scenarioStash' is not a HASHRef! Leave it 'undef' if you don't want to use it.");
    }
    if ($stepStash && not(ref($stepStash) eq 'HASH')) {
        Koha::Exception::BadParameter->throw(error => __PACKAGE__."->_validateStashes():> Stash '\$stepStash' is not a HASHRef! Leave it 'undef' if you don't want to use it.");
    }
}

=head _persistToStashes

    _persistToStashes($objects, $stashKey, $featureStash, $scenarioStash, $stepStash);

Saves the given HASH to the given stashes using the given stash key.
=cut

sub _persistToStashes {
    my ($class, $objects, $stashKey, $featureStash, $scenarioStash, $stepStash) = @_;

    if ($featureStash || $scenarioStash || $stepStash) {
        while( my ($key, $object) = each %$objects) {
            $class->validateObjectType($object); #Make sure we put in what we are expected to
            $featureStash->{$stashKey}->{ $key }  = $object if $featureStash;
            $scenarioStash->{$stashKey}->{ $key } = $object if $scenarioStash;
            $stepStash->{$stashKey}->{ $key }     = $object if $stepStash;
        }
    }
}

1;
