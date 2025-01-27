package Koha::Subscription;

# Copyright ByWater Solutions 2015
#
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

use Koha::Database;
use Koha::Biblios;
use Koha::Acquisition::Booksellers;
use Koha::Biblioitems;
use Koha::Subscriptions;
use Koha::Subscription::Frequencies;
use Koha::Subscription::Numberpatterns;

use base qw(Koha::Object Koha::Object::Mixin::AdditionalFields);

=head1 NAME

Koha::Subscription - Koha Subscription Object class

=head1 API

=head2 Class Methods

=cut

=head3 biblio

Returns the biblio linked to this subscription as a Koha::Biblio object

=cut

sub biblio {
    my ($self) = @_;

    return Koha::Biblios->find( $self->biblionumber );
}

=head3 vendor

Returns the vendor/supplier linked to this subscription as a Koha::Acquisition::Bookseller object

=cut

sub vendor {
    my ($self) = @_;
    return Koha::Acquisition::Booksellers->find( $self->aqbooksellerid );
}

=head3 subscribers

my $subscribers = $subscription->subscribers;

return a Koha::Patrons object

=cut

sub subscribers {
    my ($self) = @_;
    my $schema = Koha::Database->new->schema;
    my @borrowernumbers =
        $schema->resultset('Alert')->search( { externalid => $self->subscriptionid } )->get_column('borrowernumber')
        ->all;
    return Koha::Patrons->search( { borrowernumber => { -in => \@borrowernumbers } } );
}

=head3 add_subscriber

$subscription->add_subscriber( $patron );

Add a new subscriber (Koha::Patron) to this subscription

=cut

sub add_subscriber {
    my ( $self, $patron ) = @_;
    my $schema = Koha::Database->new->schema;
    my $rs     = $schema->resultset('Alert');
    $rs->create( { externalid => $self->subscriptionid, borrowernumber => $patron->borrowernumber } );
}

=head3 remove_subscriber

$subscription->remove_subscriber( $subscriber );

Remove a subscriber (Koha::Patron) from this subscription

=cut

sub remove_subscriber {
    my ( $self, $patron ) = @_;
    my $schema     = Koha::Database->new->schema;
    my $rs         = $schema->resultset('Alert');
    my $subscriber = $rs->find( { externalid => $self->subscriptionid, borrowernumber => $patron->borrowernumber } );
    $subscriber->delete if $subscriber;
}

=head3 frequency

my $frequency = $subscription->frequency

Return the subscription frequency

=cut

sub frequency {
    my ($self) = @_;
    my $frequency_rs = $self->_result->periodicity;
    return Koha::Subscription::Frequency->_new_from_dbic($frequency_rs);
}

=head3 get_search_info

=cut

sub get_search_info {
    my $self            = shift;
    my $searched_sub_id = shift;
    my $biblio          = Koha::Biblios->find( { 'biblionumber' => $searched_sub_id } );
    return unless $biblio;
    my $biblioitem = Koha::Biblioitems->find( { 'biblionumber' => $searched_sub_id } );

    my $sub_mana_info = {
        'title'         => $biblio->title,
        'issn'          => $biblioitem->issn,
        'ean'           => $biblioitem->ean,
        'publishercode' => $biblioitem->publishercode
    };
    return $sub_mana_info;
}

=head3 get_sharable_info

=cut

sub get_sharable_info {
    my $self               = shift;
    my $shared_sub_id      = shift;
    my $subscription       = Koha::Subscriptions->find($shared_sub_id);
    my $biblio             = Koha::Biblios->find( $subscription->biblionumber );
    my $biblioitem         = Koha::Biblioitems->find( { 'biblionumber' => $subscription->biblionumber } );
    my $sub_frequency      = Koha::Subscription::Frequencies->find( $subscription->periodicity );
    my $sub_numberpatteern = Koha::Subscription::Numberpatterns->find( $subscription->numberpattern );

    my $sub_mana_info = {
        'title'           => $biblio->title,
        'sfdescription'   => $sub_frequency->description,
        'unit'            => $sub_frequency->unit,
        'unitsperissue'   => $sub_frequency->unitsperissue,
        'issuesperunit'   => $sub_frequency->issuesperunit,
        'label'           => $sub_numberpatteern->label,
        'sndescription'   => $sub_numberpatteern->description,
        'numberingmethod' => $sub_numberpatteern->numberingmethod,
        'label1'          => $sub_numberpatteern->label1,
        'add1'            => $sub_numberpatteern->add1,
        'every1'          => $sub_numberpatteern->every1,
        'whenmorethan1'   => $sub_numberpatteern->whenmorethan1,
        'setto1'          => $sub_numberpatteern->setto1,
        'numbering1'      => $sub_numberpatteern->numbering1,
        'label2'          => $sub_numberpatteern->label2,
        'add2'            => $sub_numberpatteern->add2,
        'every2'          => $sub_numberpatteern->every2,
        'whenmorethan2'   => $sub_numberpatteern->whenmorethan2,
        'setto2'          => $sub_numberpatteern->setto2,
        'numbering2'      => $sub_numberpatteern->numbering2,
        'label3'          => $sub_numberpatteern->label3,
        'add3'            => $sub_numberpatteern->add3,
        'every3'          => $sub_numberpatteern->every3,
        'whenmorethan3'   => $sub_numberpatteern->whenmorethan3,
        'setto3'          => $sub_numberpatteern->setto3,
        'numbering3'      => $sub_numberpatteern->numbering3,
        'issn'            => $biblioitem->issn,
        'ean'             => $biblioitem->ean,
        'publishercode'   => $biblioitem->publishercode
    };
    return $sub_mana_info;
}

=head3 _type

=cut

sub _type {
    return 'Subscription';
}

=head1 AUTHOR

Kyle M Hall <kyle@bywatersolutions.com>

=cut

1;
