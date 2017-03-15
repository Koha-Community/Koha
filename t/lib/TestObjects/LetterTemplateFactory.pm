package t::lib::TestObjects::LetterTemplateFactory;

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

use C4::Letters;
use Koha::LetterTemplates;

use base qw(t::lib::TestObjects::ObjectFactory);

sub new {
    my ($class) = @_;

    my $self = {};
    bless($self, $class);
    return $self;
}

sub getDefaultHashKey {
    return ['module', 'code', 'branchcode', 'message_transport_type'];
}
sub getObjectType {
    return 'Koha::LetterTemplate';
}

=head t::lib::TestObjects::LetterTemplateFactory->createTestGroup
Returns a HASH of Koha::LetterTemplate-objects
The HASH is keyed with the PRIMARY KEYS eg. 'circulation-ODUE2-CPL-print', or the given $hashKey.
=cut

#Incredibly the Letters-module has absolutely no Create or Update-component to operate on Letter templates?
#Tests like these are brittttle. :(
sub handleTestObject {
    my ($class, $object, $stashes) = @_;

    my $schema = Koha::Database->new->schema();
    my $rs = $schema->resultset('Letter');
    my $result = $rs->update_or_create({
            module     => $object->{module},
            code       => $object->{code},
            branchcode => ($object->{branchcode}) ? $object->{branchcode} : '',
            name       => $object->{name},
            is_html    => $object->{is_html},
            title      => $object->{title},
            message_transport_type => $object->{message_transport_type},
            content    => $object->{content},
    });

    return Koha::LetterTemplates->cast($result);
}

=head

Removes the given test group from the DB.

=cut

sub deleteTestGroup {
    my ($self, $letterTemplates) = @_;

    my $schema = Koha::Database->new_schema();
    while( my ($key, $letterTemplate) = each %$letterTemplates ) {
        $letterTemplate->delete();
    }
}

sub _deleteTestGroupFromIdentifiers {
    my $testGroupIdentifiers = shift;

    my $schema = Koha::Database->new_schema();
    foreach my $key (@$testGroupIdentifiers) {
        my ($module, $code, $branchcode, $mtt) = split('-',$key);
        $schema->resultset('Letter')->find({module => $module,
                                                    code => $code,
                                                    branchcode => $branchcode,
                                                    message_transport_type => $mtt,
                                                })->delete();
    }
}

1;
