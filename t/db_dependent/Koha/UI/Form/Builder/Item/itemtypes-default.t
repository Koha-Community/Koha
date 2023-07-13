#!/usr/bin/perl

# This file is part of Koha
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
use Test::More tests => 2;

use Koha::Database;
use Koha::UI::Form::Builder::Item;
use t::lib::TestBuilder;

my $schema = Koha::Database->schema;
$schema->storage->txn_begin;

my $marc_subfield_structure_rs = $schema->resultset('MarcSubfieldStructure');
my $itemtag                    = C4::Context->preference('marcflavour') eq 'UNIMARC' ? '995' : '952';
my ($itype_subfield)           = $marc_subfield_structure_rs->search(
    {
        frameworkcode    => '',
        authorised_value => 'itemtypes',
        tagfield         => $itemtag,
    }
);
unless ($itype_subfield) {
    $itype_subfield = $marc_subfield_structure_rs->create(
        {
            frameworkcode    => '',
            tagfield         => $itemtag,
            tagsubfield      => 'Z',
            authorised_value => 'itemtypes',
        }
    );
}

my $builder = t::lib::TestBuilder->new;

my $biblio       = $builder->build_sample_biblio();
my $form_builder = Koha::UI::Form::Builder::Item->new( { biblionumber => $biblio->biblionumber } );
my $tagslib      = {
    $itemtag => {
        $itype_subfield->tagsubfield => { $itype_subfield->get_columns, lib => $itype_subfield->liblibrarian },
    },
};
my $subfield_data = $form_builder->generate_subfield_form(
    {
        tag         => $itemtag,
        subfieldtag => $itype_subfield->tagsubfield,
        tagslib     => $tagslib,
    }
);

is( $subfield_data->{marc_value}->{default}, $biblio->itemtype, 'defaults to biblio itemtype if valid' );

my $biblioitem = $biblio->biblioitem();
$biblioitem->itemtype('ZZZZZZ');
$biblioitem->store();
$subfield_data = $form_builder->generate_subfield_form(
    {
        tag         => $itemtag,
        subfieldtag => $itype_subfield->tagsubfield,
        tagslib     => $tagslib,
    }
);
is( $subfield_data->{marc_value}->{default}, undef, 'defaults to nothing if biblio itemtype is not valid' );

$schema->storage->txn_rollback;
