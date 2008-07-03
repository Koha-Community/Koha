package KohaTest::Biblio::ModBiblio;
use base qw( KohaTest::Biblio );

use strict;
use warnings;

use Test::More;

use C4::Biblio;
use C4::Items;

=head2 STARTUP METHODS

These get run once, before the main test methods in this module

=head3 add_bib_to_modify

=cut

sub add_bib_to_modify : Test( startup => 3 ) {
    my $self = shift;

    my $bib = MARC::Record->new();
    $bib->leader('     ngm a22     7a 4500');   
    $bib->append_fields(
        MARC::Field->new('100', ' ', ' ', a => 'Moffat, Steven'),
        MARC::Field->new('245', ' ', ' ', a => 'Silence in the library'),
    );
    
    my ($bibnum, $bibitemnum) = AddBiblio($bib, '');
    $self->{'bib_to_modify'} = $bibnum;

    # add an item
    my ($item_bibnum, $item_bibitemnum, $itemnumber) = AddItem({ homebranch => 'CPL', holdingbranch => 'CPL' } , $bibnum);

    cmp_ok($item_bibnum, '==', $bibnum, "new item is linked to correct biblionumber"); 
    cmp_ok($item_bibitemnum, '==', $bibitemnum, "new item is linked to correct biblioitemnumber"); 

    $self->reindex_marc(); 

    my $marc = $self->fetch_bib($bibnum);
    $self->sort_item_and_bibnumber_fields($marc);
    $self->{'bib_to_modify_formatted'} = $marc->as_formatted(); # simple way to compare later
}

=head2 TEST METHODS

standard test methods

=head3 bug_2297

Regression test for bug 2297 (saving a subscription duplicates MARC  item fields)

=cut

sub bug_2297 : Test( 5 ) {
    my $self = shift;

    my $bibnum = $self->{'bib_to_modify'};
    my $marc = $self->fetch_bib($bibnum);
    $self->check_item_count($marc, 1);

    ModBiblio($marc, $bibnum, ''); # no change made to bib

    my $modified_marc = $self->fetch_bib($bibnum);
    diag "checking item field count after null modification";
    $self->check_item_count($modified_marc, 1);

    $self->sort_item_and_bibnumber_fields($modified_marc);
    is($modified_marc->as_formatted(), $self->{'bib_to_modify_formatted'}, "no change to bib after null modification");
}

=head2 HELPER METHODS

These methods are used by other test methods, but
are not meant to be called directly.

=cut

=head3 fetch_bib

=cut

sub fetch_bib { # +1 to test count per call
    my $self = shift;
    my $bibnum = shift;

    my $marc = GetMarcBiblio($bibnum);
    ok(defined($marc), "retrieved bib record $bibnum");

    return $marc;
}

=head3 check_item_count

=cut

sub check_item_count { # +1 to test count per call
    my $self = shift;
    my $marc = shift;
    my $expected_items = shift;

    my ($itemtag, $itemsubfield) = GetMarcFromKohaField("items.itemnumber", '');
    my @item_fields = $marc->field($itemtag);
    cmp_ok(scalar(@item_fields), "==", $expected_items, "exactly one item field");
}

=head3 sort_item_and_bibnumber_fields

This method sorts the field containing the embedded item data
and the bibnumber - ModBiblio(), AddBiblio(), and ModItem() do
not guarantee that these fields will be sorted in tag order.

=cut

sub sort_item_and_bibnumber_fields {
    my $self = shift;
    my $marc = shift;

    my ($itemtag, $itemsubfield)     = GetMarcFromKohaField("items.itemnumber", '');
    my ($bibnumtag, $bibnumsubfield) = GetMarcFromKohaField("biblio.biblionumber", '');

    my @item_fields = ();
    foreach my $field ($marc->field($itemtag)) {
        push @item_fields, $field;
        $marc->delete_field($field);
    }
    $marc->insert_fields_ordered(@item_fields) if scalar(@item_fields);;
   
    my @bibnum_fields = (); 
    foreach my $field ($marc->field($bibnumtag)) {
        push @bibnum_fields, $field;
        $marc->delete_field($field);
    }
    $marc->insert_fields_ordered(@bibnum_fields) if scalar(@bibnum_fields);

}

=head2 SHUTDOWN METHODS

These get run once, after the main test methods in this module

=head3 shutdown_clean_object

=cut

sub shutdown_clean_object : Test( shutdown => 0 ) {
    my $self = shift;

    delete $self->{'bib_to_modify'};
    delete $self->{'bib_to_modify_formatted'};
}

1;
