package t::lib::TestObjects::FileFactory;

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
use File::Spec;
use File::Path;

use Koha::AtomicUpdater;
use Koha::Database;
use File::Fu::File;

use Koha::Exception::BadParameter;

use base qw(t::lib::TestObjects::ObjectFactory);

my $tmpdir = File::Spec->tmpdir();

sub getDefaultHashKey {
    return 'OVERLOADED';
}
sub getObjectType {
    return 'File::Fu::File';
}

=head t::lib::TestObjects::createTestGroup

    my $files = t::lib::TestObjects::FileFactory->createTestGroup([
                    {'filepath' => 'atomicupdate/', #this is prepended with the system's default tmp directory, usually /tmp/
                     'filename' => '#30-RabiesIsMyDog.pl',
                     'content' => 'print "Mermaids are my only love\nI never let them down";',
                    },
                ], ['filepath', 'filename'], $testContext1, $testContext2, $testContext3);

Calls Koha::FileFactory to add files with content to your system, and clean up automatically.

The HASH is keyed with the 'filename', or the given $hashKeys.

@RETURNS HASHRef of File::Fu::File-objects

See t::lib::TestObjects::ObjectFactory for more documentation
=cut

sub handleTestObject {
    my ($class, $object, $stashes) = @_;

    my $absolutePath = $tmpdir.'/'.$object->{filepath};
    File::Path::make_path($absolutePath);
    my $file = File::Fu::File->new($absolutePath.'/'.$object->{filename});

    $file->write($object->{content}) if $object->{content};

    return $file;
}

=head validateAndPopulateDefaultValues
@OVERLOAD

Validates given Object parameters and makes sure that critical fields are given
and populates defaults for missing values.
=cut

sub validateAndPopulateDefaultValues {
    my ($self, $object, $hashKey) = @_;

    foreach my $param (('filename', 'filepath')) {
        unless ($object->{$param}) {
            Koha::Exception::BadParameter->throw(
                error => __PACKAGE__."->validateAndPopulateDefaultValues():> parameter '$param' is mandatory.");
        }
        if ($object->{$param} =~ m/(\$|\.\.|~|\s)/) {
            Koha::Exception::BadParameter->throw(
                error => __PACKAGE__."->validateAndPopulateDefaultValues():> parameter '$param' as '".$object->{$param}."'.".
                         'Disallowed characters present  ..  ~  $ + whitespace');
        }
    }
}

sub deleteTestGroup {
    my ($class, $objects) = @_;

    while( my ($key, $object) = each %$objects) {
        $object->remove if $object->e;
        #We could as well remove the complete subfolder but I am too afraid to automate "rm -r" here
    }
}

=head getHashKey
@OVERLOADED

@RETURNS String, The test context/stash HASH key to differentiate this object
                 from all other such test objects.
=cut

sub getHashKey {
    my ($class, $fileObject, $primaryKey, $hashKeys) = @_;

    return $fileObject->get_file();
}

1;
