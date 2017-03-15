package t::lib::TestObjects::MatcherFactory;

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

use C4::Matcher;

use base qw(t::lib::TestObjects::ObjectFactory);

sub getDefaultHashKey {
    return 'code';
}
sub getObjectType {
    return 'C4::Matcher';
}

=head t::lib::TestObjects::createTestGroup

    my $matchers = t::lib::TestObjects::MatcherFactory->createTestGroup([
                            {code => 'MATCHER',
                             description => 'I dunno',
                             threshold => 1000,
                             matchpoints => [
                                {
                                   index       => 'title',
                                   score       => 500,
                                   components => [{
                                        tag         => '245',
                                        subfields   => 'a',
                                        offset      => 0,
                                        length      => 0,
                                        norms       => [''],
                                   }]
                                },
                                {
                                   index       => 'author',
                                   score       => 500,
                                   components => [{
                                        tag         => '100',
                                        subfields   => 'a',
                                        offset      => 0,
                                        length      => 0,
                                        norms       => [''],
                                   }]
                                }
                             ],
                            required_checks => [
                                {
                                    source => [{
                                        tag         => '020',
                                        subfields   => 'a',
                                        offset      => 0,
                                        length      => 0,
                                        norms       => ['copy'],
                                    }],
                                    target => [{
                                        tag         => '024',
                                        subfields   => 'a',
                                        offset      => 0,
                                        length      => 0,
                                        norms       => ['paste'],
                                    }],
                                },
                                {
                                    source => [{
                                        tag         => '044',
                                        subfields   => 'a',
                                        offset      => 0,
                                        length      => 0,
                                        norms       => ['copy'],
                                    }],
                                    target => [{
                                        tag         => '048',
                                        subfields   => 'a',
                                        offset      => 0,
                                        length      => 0,
                                        norms       => ['paste'],
                                    }],
                                }
                            ],
                            },
                        ], undef, $testContext1, $testContext2, $testContext3);

Calls C4::Matcher to add a C4::Matcher object or objects to DB.

The HASH is keyed with the 'koha.marc_matchers.code', or the given $hashKey.

There is a duplication check to first look for C4::Matcher-rows with the same 'code'.
If a matching C4::Matcher is found, then we use the existing object.

@RETURNS HASHRef of C4::Matcher-objects
         or a C4::Matcher-object

See t::lib::TestObjects::ObjectFactory for more documentation
=cut

sub handleTestObject {
    my ($class, $object, $stashes) = @_;

    ##First see if the given Record already exists in the DB. For testing purposes we use the isbn as the UNIQUE identifier.
    my $matcher;
    my $id = C4::Matcher::GetMatcherId($object->{code});
    if ($id) {
        $matcher = C4::Matcher->fetch($id);
    }
    else {
        $matcher = C4::Matcher->new('biblio', $object->{threshold} || 1000);

        $matcher->code( $object->{code} );
        $matcher->description( $object->{description} ) if $object->{description};

        ##Add matchpoints
        if ($object->{matchpoints}) {
            foreach my $mc (@{$object->{matchpoints}}) {
                $matcher->add_matchpoint($mc->{index}, $mc->{score}, $mc->{components});
            }
        }
        else {
            $matcher->add_matchpoint('title', 500, [{
            tag         => '245',
                    subfields   => 'a',
                    offset      => 0,
                    length      => 0,
                    norms       => [''],
            }]);
            $matcher->add_matchpoint('author', 500, [{
            tag         => '100',
                    subfields   => 'a',
                    offset      => 0,
                    length      => 0,
                    norms       => [''],
            }]);
        }

        ##Add match checks
        if ($object->{required_checks}) {
            foreach my $rc (@{$object->{required_checks}}) {
                $matcher->add_required_check($rc->{source}, $rc->{target});
            }
        }
        else {
            $matcher->add_required_check(
                [{
            tag         => '020',
                    subfields   => 'a',
                    offset      => 0,
                    length      => 0,
                    norms       => ['copy'],
                }],
                [{
            tag         => '024',
                    subfields   => 'a',
                    offset      => 0,
                    length      => 0,
                    norms       => ['paste'],
                }]
            );
        }

        $matcher->store();
    }

    return $matcher;
}

=head validateAndPopulateDefaultValues
@OVERLOAD

Validates given Object parameters and makes sure that critical fields are given
and populates defaults for missing values.
=cut

sub validateAndPopulateDefaultValues {
    my ($self, $object, $hashKey) = @_;

    $object->{code} = 'MATCHER' unless $object->{code};

    $self->SUPER::validateAndPopulateDefaultValues($object, $hashKey);
}

sub deleteTestGroup {
    my ($class, $objects) = @_;

    while( my ($key, $object) = each %$objects) {
        my $matcher = $objects->{$key};
        eval {
            C4::Matcher->delete( $matcher->{id} );
        };
        if ($@) {
            warn "$class->deleteTestGroup():> Error hapened: $@\n";
        }
    }
}

1;
