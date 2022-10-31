package Koha::Items;

# Copyright ByWater Solutions 2014
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
use Array::Utils qw( array_minus );
use List::MoreUtils qw( uniq );
use Try::Tiny;

use C4::Context;
use C4::Biblio qw( GetMarcStructure GetMarcFromKohaField );
use C4::Circulation;

use Koha::Database;
use Koha::SearchEngine::Indexer;

use Koha::Item::Attributes;
use Koha::Item;
use Koha::CirculationRules;

use base qw(Koha::Objects);

use Koha::SearchEngine::Indexer;

=head1 NAME

Koha::Items - Koha Item object set class

=head1 API

=head2 Class methods

=cut

=head3 filter_by_for_hold

    my $filtered_items = $items->filter_by_for_hold;

Return the items of the set that are *potentially* holdable.

Caller has the responsibility to call C4::Reserves::CanItemBeReserved before
placing a hold on one of those items.

=cut

sub filter_by_for_hold {
    my ($self) = @_;

    my @hold_not_allowed_itypes = Koha::CirculationRules->search(
        {
            rule_name    => 'holdallowed',
            branchcode   => undef,
            categorycode => undef,
            rule_value   => 'not_allowed',
        }
    )->get_column('itemtype');
    push @hold_not_allowed_itypes, Koha::ItemTypes->search({ notforloan => 1 })->get_column('itemtype');

    my $params = {
        itemlost   => 0,
        withdrawn  => 0,
        notforloan => { '<=' => 0 },    # items with negative or zero notforloan value are holdable
        ( C4::Context->preference('AllowHoldsOnDamagedItems')? (): ( damaged => 0 ) ),
        ( C4::Context->only_my_library() ? ( homebranch => C4::Context::mybranch() ) : () ),
    };

    if ( C4::Context->preference("item-level_itypes") ) {
        return $self->search(
            {
                %$params,
                itype        => { -not_in => \@hold_not_allowed_itypes },
            }
        );
    } else {
        return $self->search(
            {
                %$params,
                'biblioitem.itemtype' => { -not_in => \@hold_not_allowed_itypes },
            },
            {
                join => 'biblioitem',
            }
        );
    }
}

=head3 filter_by_visible_in_opac

    my $filered_items = $items->filter_by_visible_in_opac(
        {
            [ patron => $patron ]
        }
    );

Returns a new resultset, containing those items that are not expected to be hidden in OPAC
for the passed I<Koha::Patron> object that is passed.

The I<OpacHiddenItems>, I<hidelostitems> and I<OpacHiddenItemsExceptions> system preferences
are honoured.

=cut

sub filter_by_visible_in_opac {
    my ($self, $params) = @_;

    my $patron = $params->{patron};

    my $result = $self;

    # Filter out OpacHiddenItems unless disabled by OpacHiddenItemsExceptions
    unless ( $patron and $patron->category->override_hidden_items ) {
        my $rules = C4::Context->yaml_preference('OpacHiddenItems') // {};

        my $rules_params;
        foreach my $field ( keys %$rules ) {
            $rules_params->{'me.'.$field} =
              [ { '-not_in' => $rules->{$field} }, undef ];
        }

        $result = $result->search( $rules_params );
    }

    if (C4::Context->preference('hidelostitems')) {
        $result = $result->filter_out_lost;
    }

    return $result;
}

=head3 filter_out_lost

    my $filered_items = $items->filter_out_lost;

Returns a new resultset, containing those items that are not marked as lost.

=cut

sub filter_out_lost {
    my ($self) = @_;

    my $params = { itemlost => 0 };

    return $self->search( $params );
}


=head3 move_to_biblio

 $items->move_to_biblio($to_biblio);

Move items to a given biblio.

=cut

sub move_to_biblio {
    my ( $self, $to_biblio ) = @_;

    my $biblionumbers = { $to_biblio->biblionumber => 1 };
    while ( my $item = $self->next() ) {
        $biblionumbers->{ $item->biblionumber } = 1;
        $item->move_to_biblio( $to_biblio, { skip_record_index => 1 } );
    }
    my $indexer = Koha::SearchEngine::Indexer->new({ index => $Koha::SearchEngine::BIBLIOS_INDEX });
    for my $biblionumber ( keys %{$biblionumbers} ) {
        $indexer->index_records( $biblionumber, "specialUpdate", "biblioserver" );
    }
}

=head3 batch_update

    Koha::Items->search->batch_update
        {
            new_values => {
                itemnotes => $new_item_notes,
                k         => $k,
            },
            regex_mod => {
                itemnotes_nonpublic => {
                    search => 'foo',
                    replace => 'bar',
                    modifiers => 'gi',
                },
            },
            exclude_from_local_holds_priority => 1|0,
            callback => sub {
                # increment something here
            },
        }
    );

Batch update the items.

Returns ( $report, $self )
Report has 2 keys:
  * modified_itemnumbers - list of the modified itemnumbers
  * modified_fields - number of fields modified

Parameters:

=over

=item new_values

Allows to set a new value for given fields.
The key can be one of the item's column name, or one subfieldcode of a MARC subfields not linked with a Koha field

=item regex_mod

Allows to modify existing subfield's values using a regular expression

=item exclude_from_local_holds_priority

Set the passed boolean value to items.exclude_from_local_holds_priority

=item mark_items_returned

Move issues on these items to the old issues table, do not mark items found, or
adjust damaged/withdrawn statuses, or fines, or locations.

=item callback

Callback function to call after an item has been modified

=back

=cut

sub batch_update {
    my ( $self, $params ) = @_;

    my $regex_mod = $params->{regex_mod} || {};
    my $new_values = $params->{new_values} || {};
    my $exclude_from_local_holds_priority = $params->{exclude_from_local_holds_priority};
    my $mark_items_returned = $params->{mark_items_returned};
    my $callback = $params->{callback};

    my (@modified_itemnumbers, $modified_fields);
    my $i;
    my $schema = Koha::Database->new->schema;
    while ( my $item = $self->next ) {

        try {$schema->txn_do(sub {
            my $modified_holds_priority = 0;
            my $item_returned = 0;
            if ( defined $exclude_from_local_holds_priority ) {
                if(!defined $item->exclude_from_local_holds_priority || $item->exclude_from_local_holds_priority != $exclude_from_local_holds_priority) {
                    $item->exclude_from_local_holds_priority($exclude_from_local_holds_priority)->store;
                    $modified_holds_priority = 1;
                }
            }

            my $modified = 0;
            my $new_values = {%$new_values};    # Don't modify the original

            my $old_values = $item->unblessed;
            if ( $item->more_subfields_xml ) {
                $old_values = {
                    %$old_values,
                    %{$item->additional_attributes->to_hashref},
                };
            }

            for my $attr ( keys %$regex_mod ) {
                my $old_value = $old_values->{$attr};

                next unless $old_value;

                my $value = apply_regex(
                    {
                        %{ $regex_mod->{$attr} },
                        value => $old_value,
                    }
                );

                $new_values->{$attr} = $value;
            }

            for my $attribute ( keys %$new_values ) {
                next if $attribute eq 'more_subfields_xml'; # Already counted before

                my $old = $old_values->{$attribute};
                my $new = $new_values->{$attribute};
                $modified++
                  if ( defined $old xor defined $new )
                  || ( defined $old && defined $new && $new ne $old );
            }

            { # Dealing with more_subfields_xml

                my $frameworkcode = $item->biblio->frameworkcode;
                my $tagslib = C4::Biblio::GetMarcStructure( 1, $frameworkcode, { unsafe => 1 });
                my ( $itemtag, $itemsubfield ) = C4::Biblio::GetMarcFromKohaField( "items.itemnumber" );

                my @more_subfield_tags = map {
                    (
                             ref($_)
                          && %$_
                          && !$_->{kohafield}    # Get subfields that are not mapped
                      )
                      ? $_->{tagsubfield}
                      : ()
                } values %{ $tagslib->{$itemtag} };

                my $more_subfields_xml = Koha::Item::Attributes->new(
                    {
                        map {
                            exists $new_values->{$_} ? ( $_ => $new_values->{$_} )
                              : exists $old_values->{$_}
                              ? ( $_ => $old_values->{$_} )
                              : ()
                        } @more_subfield_tags
                    }
                )->to_marcxml($frameworkcode);

                $new_values->{more_subfields_xml} = $more_subfields_xml;

                delete $new_values->{$_} for @more_subfield_tags; # Clean the hash

            }

            if ( $modified ) {
                my $itemlost_pre = $item->itemlost;
                $item->set($new_values)->store({skip_record_index => 1});

                C4::Circulation::LostItem(
                    $item->itemnumber, 'batchmod', undef,
                    { skip_record_index => 1 }
                ) if $item->itemlost
                      and not $itemlost_pre;
            }
            if ( $mark_items_returned ){
                my $issue = $item->checkout;
                if( $issue ){
                        $item_returned = 1;
                        C4::Circulation::MarkIssueReturned(
                        $issue->borrowernumber,
                        $item->itemnumber,
                        undef,
                        $issue->patron->privacy,
                        {
                            skip_record_index => 1,
                            skip_holds_queue  => 1,
                        }
                    );
                }
            }

            push @modified_itemnumbers, $item->itemnumber if $modified || $modified_holds_priority || $item_returned;
            $modified_fields += $modified + $modified_holds_priority + $item_returned;
        })}
        catch {
            warn $_
        };

        if ( $callback ) {
            $callback->(++$i);
        }
    }

    if (@modified_itemnumbers) {
        my @biblionumbers = uniq(
            Koha::Items->search( { itemnumber => \@modified_itemnumbers } )
                       ->get_column('biblionumber'));

        if ( @biblionumbers ) {
            my $indexer = Koha::SearchEngine::Indexer->new(
                { index => $Koha::SearchEngine::BIBLIOS_INDEX } );

            $indexer->index_records( \@biblionumbers, 'specialUpdate',
                "biblioserver", undef );
        }
    }

    return ( { modified_itemnumbers => \@modified_itemnumbers, modified_fields => $modified_fields }, $self );
}

sub apply_regex {
    # FIXME Should be moved outside of Koha::Items
    # FIXME This is nearly identical to Koha::SimpleMARC::_modify_values
    my ($params) = @_;
    my $search   = $params->{search};
    my $replace  = $params->{replace};
    my $modifiers = $params->{modifiers} || q{};
    my $value = $params->{value};

    $replace =~ s/"/\\"/g;                    # Protection from embedded code
    $replace = '"' . $replace . '"'; # Put in a string for /ee
    my @available_modifiers = qw( i g );
    my $retained_modifiers  = q||;
    for my $modifier ( split //, $modifiers ) {
        $retained_modifiers .= $modifier
          if grep { /$modifier/ } @available_modifiers;
    }
    if ( $retained_modifiers =~ m/^(ig|gi)$/ ) {
        $value =~ s/$search/$replace/igee;
    }
    elsif ( $retained_modifiers eq 'i' ) {
        $value =~ s/$search/$replace/iee;
    }
    elsif ( $retained_modifiers eq 'g' ) {
        $value =~ s/$search/$replace/gee;
    }
    else {
        $value =~ s/$search/$replace/ee;
    }

    return $value;
}

=head3 search_ordered

 $items->search_ordered;

Search and sort items in a specific order, depending if serials are present or not

=cut

sub search_ordered {
    my ($self, $params, $attributes) = @_;

    $self = $self->search($params, $attributes);

    my @biblionumbers = uniq $self->get_column('biblionumber');

    if ( scalar ( @biblionumbers ) == 1
        && Koha::Biblios->find( $biblionumbers[0] )->serial )
    {
        return $self->search(
            {},
            {
                order_by => [ 'serialid.publisheddate', 'me.enumchron' ],
                join     => { serialitem => 'serialid' }
            }
        );
    } else {
        return $self->search(
            {},
            {
                order_by => [
                    'homebranch.branchname',
                    'me.enumchron',
                    \"LPAD( me.copynumber, 8, '0' )",
                    {-desc => 'me.dateaccessioned'}
                ],
                join => ['homebranch']
            }
        );
    }
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'Item';
}

=head3 object_class

=cut

sub object_class {
    return 'Koha::Item';
}

=head1 AUTHOR

Kyle M Hall <kyle@bywatersolutions.com>
Tomas Cohen Arazi <tomascohen@theke.io>
Martin Renvoize <martin.renvoize@ptfs-europe.com>

=cut

1;
