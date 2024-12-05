package Koha::UI::Form::Builder::Item;

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
use List::Util qw( any );
use MARC::Record;
use C4::Context;
use C4::Biblio qw( GetFrameworkCode GetMarcStructure IsMarcStructureInternal );
use C4::Koha qw( GetAuthorisedValues );
use C4::ClassSource qw( GetClassSources );

use Koha::Biblios;
use Koha::DateUtils qw( dt_from_string );
use Koha::Libraries;

=head1 NAME

Koha::UI::Form::Builder::Item

Helper to build a form to add or edit a new item.

=head1 API

=head2 Class methods

=cut

=head3 new

    my $form = Koha::UI::Form::Builder::Item->new(
        {
            biblionumber => $biblionumber,
            item => $current_item,
        }
    );

Constructor.
biblionumber should be passed if we are creating a new item.
For edition, an hashref representing the item to edit item must be passed.

=cut


sub new {
    my ( $class, $params ) = @_;

    my $self;
    $self->{biblionumber} = $params->{biblionumber};
    $self->{item} = $params->{item};

    bless $self, $class;
    return $self;
}

=head3 generate_subfield_form

Generate subfield's info for given tag, subfieldtag, etc.

=cut

sub generate_subfield_form {

    my ($self, $params)    = @_;
    my $tag         = $params->{tag};
    my $subfieldtag = $params->{subfieldtag};
    my $value       = $params->{value};
    my $tagslib     = $params->{tagslib};
    my $libraries   = $params->{libraries};
    my $marc_record = $params->{marc_record};
    my $restricted_edition = $params->{restricted_editition};
    my $prefill_with_default_values = $params->{prefill_with_default_values};
    my $branch_limit = $params->{branch_limit};
    my $default_branches_empty = $params->{default_branches_empty};
    my $readonly = $params->{readonly};

    my $item         = $self->{item};
    my $subfield     = $tagslib->{$tag}{$subfieldtag};
    my $biblionumber = $self->{biblionumber};

    my $frameworkcode = $biblionumber ? GetFrameworkCode($biblionumber) : q{};

    my %subfield_data;
    my $dbh = C4::Context->dbh;

    my $index_subfield = int( rand(1000000) );
    if ( $subfieldtag eq '@' ) {
        $subfield_data{id} = "tag_" . $tag . "_subfield_00_" . $index_subfield;
    }
    else {
        $subfield_data{id} =
          "tag_" . $tag . "_subfield_" . $subfieldtag . "_" . $index_subfield;
    }

    $subfield_data{tag}      = $tag;
    $subfield_data{subfield} = $subfieldtag;
    $subfield_data{marc_lib} =
        "<span title=\""
      . $subfield->{lib} . "\">"
      . $subfield->{lib}
      . "</span>";
    $subfield_data{mandatory}     = $subfield->{mandatory};
    $subfield_data{important}     = $subfield->{important};
    $subfield_data{repeatable}    = $subfield->{repeatable};
    $subfield_data{maxlength}     = $subfield->{maxlength};
    $subfield_data{display_order} = $subfield->{display_order};
    $subfield_data{kohafield} =
      $subfield->{kohafield} || 'items.more_subfields_xml';

    if ( $prefill_with_default_values && ( !defined($value) || $value eq '' ) ) {
        $value = $subfield->{defaultvalue} if !$item->{itemnumber}; # apply defaultvalue only to new items
        if ($value) {

# get today date & replace <<YYYY>>, <<YY>>, <<MM>>, <<DD>> if provided in the default value
            my $today_dt  = dt_from_string;
            my $year      = $today_dt->strftime('%Y');
            my $shortyear = $today_dt->strftime('%y');
            my $month     = $today_dt->strftime('%m');
            my $day       = $today_dt->strftime('%d');
            $value =~ s/<<YYYY>>/$year/g;
            $value =~ s/<<YY>>/$shortyear/g;
            $value =~ s/<<MM>>/$month/g;
            $value =~ s/<<DD>>/$day/g;

            # And <<USER>> with surname (?)
            my $username = (
                  C4::Context->userenv
                ? C4::Context->userenv->{'surname'}
                : "superlibrarian"
            );
            $value =~ s/<<USER>>/$username/g;
        }
    }

    $subfield_data{visibility} = "display:none;"
      if ( ( $subfield->{hidden} > 4 ) || ( $subfield->{hidden} <= -4 ) );

    my $pref_itemcallnumber = C4::Context->preference('itemcallnumber');
    if (  $prefill_with_default_values
        && !$value
        && $subfield->{kohafield}
        && $subfield->{kohafield} eq 'items.itemcallnumber'
        && $pref_itemcallnumber
        && $marc_record )
    {
        foreach
          my $pref_itemcallnumber_part ( split( /,/, $pref_itemcallnumber ) )
        {
            my $CNtag =
              substr( $pref_itemcallnumber_part, 0, 3 );    # 3-digit tag number
            my $CNsubfields =
              substr( $pref_itemcallnumber_part, 3 );    # Any and all subfields
            $CNsubfields = undef if $CNsubfields eq '';
            my $temp2 = $marc_record->field($CNtag);

            next unless $temp2;
            $value = $temp2->as_string( $CNsubfields, ' ' );
            last if $value;
        }
    }

    if ( $subfield->{authorised_value} ) {
        my @authorised_values;
        my %authorised_lib;

        # builds list, depending on authorised value...
        if ( $subfield->{authorised_value} eq "LOST" ) {
            my $ClaimReturnedLostValue =
              C4::Context->preference('ClaimReturnedLostValue');
            my $item_is_return_claim =
                 $ClaimReturnedLostValue
              && exists $item->{itemlost}
              && $ClaimReturnedLostValue eq $item->{itemlost};
            $subfield_data{IS_RETURN_CLAIM} = $item_is_return_claim;

            $subfield_data{IS_LOST_AV} = 1;

            push @authorised_values, qq{};
            my $av = GetAuthorisedValues( $subfield->{authorised_value} );
            for my $r (@$av) {
                push @authorised_values, $r->{authorised_value};
                $authorised_lib{ $r->{authorised_value} } = $r->{lib};
            }
        }
        elsif ( $subfield->{authorised_value} eq "branches" ) {
            push @authorised_values, "" if $default_branches_empty;
            foreach my $thisbranch (@$libraries) {
                push @authorised_values, $thisbranch->{branchcode};
                $authorised_lib{ $thisbranch->{branchcode} } =
                  $thisbranch->{branchname};
                $value = $thisbranch->{branchcode}
                  if $thisbranch->{selected} && !$value;
            }
        }
        elsif ( $subfield->{authorised_value} eq "itemtypes" ) {
            push @authorised_values, "";
            my $itemtypes;
            if ($branch_limit) {
                $itemtypes = Koha::ItemTypes->search_with_localization(
                    { branchcode => $branch_limit } );
            }
            else {
                $itemtypes = Koha::ItemTypes->search_with_localization;
            }
            while ( my $itemtype = $itemtypes->next ) {
                push @authorised_values, $itemtype->itemtype;
                $authorised_lib{ $itemtype->itemtype } =
                  $itemtype->translated_description;
            }

            if (!$value && $biblionumber) {
                my $itype_sth = $dbh->prepare(
                    "SELECT itemtype FROM biblioitems WHERE biblionumber = ?");
                $itype_sth->execute($biblionumber);
                my ($biblio_itemtype) = $itype_sth->fetchrow_array;

                # Use biblioitems.itemtype as a default value only if it's a valid itemtype
                if ( any { $_ eq $biblio_itemtype } @authorised_values ) {
                    $value = $biblio_itemtype;
                }
            }

            #---- class_sources
        }
        elsif ( $subfield->{authorised_value} eq "cn_source" ) {
            push @authorised_values, "";

            my $class_sources = GetClassSources();
            my $default_source =
              C4::Context->preference("DefaultClassificationSource");

            foreach my $class_source ( sort keys %$class_sources ) {
                next
                  unless $class_sources->{$class_source}->{'used'}
                  or ( $value and $class_source eq $value )
                  or ( $class_source eq $default_source );
                push @authorised_values, $class_source;
                $authorised_lib{$class_source} =
                  $class_sources->{$class_source}->{'description'};
            }
            $value = $default_source if !$value && $prefill_with_default_values;

            #---- "true" authorised value
        }
        else {
            push @authorised_values, qq{};
            my $av = GetAuthorisedValues( $subfield->{authorised_value} );
            for my $r (@$av) {
                push @authorised_values, $r->{authorised_value};
                $authorised_lib{ $r->{authorised_value} } = $r->{lib};
            }
        }

        if ( $subfield->{hidden} > 4 or $subfield->{hidden} <= -4 ) {
            $subfield_data{marc_value} = {
                type      => 'hidden',
                id        => $subfield_data{id},
                maxlength => $subfield_data{maxlength},
                value     => $value,
                (
                    (
                        grep { $_ eq $subfield->{authorised_value} }
                          (qw(branches itemtypes cn_source))
                    ) ? () : ( category => $subfield->{authorised_value} )
                ),
            };
        }
        else {
            $subfield_data{marc_value} = {
                type => 'select',
                id   => "tag_"
                  . $tag
                  . "_subfield_"
                  . $subfieldtag . "_"
                  . $index_subfield,
                values  => \@authorised_values,
                labels  => \%authorised_lib,
                default => $value,
                (
                    (
                        grep { $_ eq $subfield->{authorised_value} }
                          (qw(branches itemtypes cn_source))
                    ) ? () : ( category => $subfield->{authorised_value} )
                ),
            };
        }
    }

    # it's a thesaurus / authority field
    elsif ( $subfield->{authtypecode} ) {
        $subfield_data{marc_value} = {
            type         => 'text_auth',
            id           => $subfield_data{id},
            maxlength    => $subfield_data{maxlength},
            value        => $value,
            authtypecode => $subfield->{authtypecode},
        };
    }

    # it's a plugin field
    elsif ( $subfield->{value_builder} ) {    # plugin
        require Koha::FrameworkPlugin;
        my $plugin = Koha::FrameworkPlugin->new(
            {
                name       => $subfield->{'value_builder'},
                item_style => 1,
            }
        );
        my $pars = {
            dbh     => $dbh,
            record  => $marc_record, #Note: could be undefined
            tagslib => $tagslib,
            id      => $subfield_data{id},
        };
        $plugin->build($pars);
        if ( !$plugin->errstr ) {
            my $class = 'buttonDot' . ( $plugin->noclick ? ' disabled' : '' );
            $subfield_data{marc_value} = {
                type       => 'text_plugin',
                id         => $subfield_data{id},
                maxlength  => $subfield_data{maxlength},
                value      => $value,
                class      => $class,
                nopopup    => $plugin->noclick,
                javascript => $plugin->javascript,
            };
        }
        else {
            warn $plugin->errstr;
            $subfield_data{marc_value} = {
                type      => 'text',
                id        => $subfield_data{id},
                maxlength => $subfield_data{maxlength},
                value     => $value,
            };    # supply default input form
        }
    }
    elsif ( $tag eq '' ) {    # it's an hidden field
        $subfield_data{marc_value} = {
            type      => 'hidden',
            id        => $subfield_data{id},
            maxlength => $subfield_data{maxlength},
            value     => $value,
        };
    }
    elsif ( $subfield->{'hidden'} )
    {                         # FIXME: shouldn't input type be "hidden" ?
        $subfield_data{marc_value} = {
            type      => 'text',
            id        => $subfield_data{id},
            maxlength => $subfield_data{maxlength},
            value     => $value,
        };
    }
    elsif (
        ( $value and length($value) > 100 )
        or ( C4::Context->preference("marcflavour") eq "UNIMARC"
            and 300 <= $tag && $tag < 400 && $subfieldtag eq 'a' )
        or ( C4::Context->preference("marcflavour") eq "MARC21"
            and 500 <= $tag && $tag < 600 )
      )
    {
        # oversize field (textarea)
        $subfield_data{marc_value} = {
            type  => 'textarea',
            id    => $subfield_data{id},
            value => $value,
        };
    }
    else {
        # it's a standard field
        $subfield_data{marc_value} = {
            type      => 'text',
            id        => $subfield_data{id},
            maxlength => $subfield_data{maxlength},
            value     => $value,
        };
    }

    # If we're on restricted editing, and our field is not in the list of subfields to allow,
    # then it is read-only
    $subfield_data{marc_value}->{readonly} = $readonly;

    return \%subfield_data;
}

=head3 edit_form

    my $subfields =
      Koha::UI::Form::Builder::Item->new(
        { biblionumber => $biblionumber, item => $current_item } )->edit_form(
        {
            branchcode           => $branchcode,
            restricted_editition => $restrictededition,
            (
                @subfields_to_prefill
                ? ( subfields_to_prefill => \@subfields_to_prefill )
                : ()
            ),
            prefill_with_default_values => 1,
            branch_limit => C4::Context->userenv->{"branch"},
        }
    );

Returns the list of subfields to display on the add/edit item form.

Use it in the view with:
  [% PROCESS subfields_for_item subfields => subfields %]

Parameters:

=over

=item branchcode

Pre-select a library (for logged in user)

=item restricted_editition

Flag to restrict the edition if the user does not have necessary permissions.

=item subfields_to_prefill

List of subfields to prefill (value of syspref SubfieldsToUseWhenPrefill)

If empty all subfields will be prefilled. For none, you can pass an array with a single false value.

=item subfields_to_allow

List of subfields to allow (value of syspref SubfieldsToAllowForRestrictedBatchmod or SubfieldsToAllowForRestrictedEditing)

=item ignore_not_allowed_subfields

If set, the subfields in subfields_to_allow will be ignored (ie. they will not be part of the subfield list.
If not set, the subfields in subfields_to_allow will be marked as readonly.

=item kohafields_to_ignore

List of subfields to ignore/skip

=item prefill_with_default_values

Flag to prefill with the default values defined in the framework.

=item branch_limit

Limit info depending on the library (so far only item types).

=item default_branches_empty

Flag to add an empty option to the library list.

=item ignore_invisible_subfields

Skip the subfields that are not visible on the editor.

When duplicating an item we do not want to retrieve the subfields that are hidden.

=back

=cut

sub edit_form {
    my ( $self, $params ) = @_;

    my $branchcode         = $params->{branchcode};
    my $restricted_edition = $params->{restricted_editition};
    my $subfields_to_prefill = $params->{subfields_to_prefill} || [];
    my $subfields_to_allow = $params->{subfields_to_allow} || [];
    my $ignore_not_allowed_subfields = $params->{ignore_not_allowed_subfields};
    my $kohafields_to_ignore = $params->{kohafields_to_ignore} || [];
    my $prefill_with_default_values = $params->{prefill_with_default_values};
    my $branch_limit = $params->{branch_limit};
    my $default_branches_empty = $params->{default_branches_empty};
    my $ignore_invisible_subfields = $params->{ignore_invisible_subfields} || 0;

    my $libraries =
      Koha::Libraries->search( {}, { order_by => ['branchname'] } )->unblessed;
    for my $library (@$libraries) {
        $library->{selected} = 1 if $branchcode && $library->{branchcode} eq $branchcode;
    }

    my $item                = $self->{item};
    my $marc_more_subfields = $item->{more_subfields_xml}
      ?
        # FIXME Use Maybe MARC::Record::new_from_xml if encoding issues on subfield (??)
        MARC::Record->new_from_xml( $item->{more_subfields_xml}, 'UTF-8' )
      : undef;

    my $biblionumber   = $self->{biblionumber};
    my $biblio         = Koha::Biblios->find($biblionumber);
    my $frameworkcode  = $biblio ? GetFrameworkCode($biblionumber) : q{};
    my $marc_record    = $biblio ? $biblio->metadata->record : undef;
    my @subfields;
    my $tagslib = GetMarcStructure( 1, $frameworkcode );
    foreach my $tag ( keys %{$tagslib} ) {

        foreach my $subfieldtag ( keys %{ $tagslib->{$tag} } ) {

            my $subfield = $tagslib->{$tag}{$subfieldtag};

            next if IsMarcStructureInternal($subfield);
            next if $subfield->{tab} ne "10";
            next
              if grep { $subfield->{kohafield} && $subfield->{kohafield} eq $_ }
              @$kohafields_to_ignore;

            next
              if $ignore_invisible_subfields
              && ( $subfield->{hidden} > 4 || $subfield->{hidden} <= -4 );

            my $readonly;
            if (
                @$subfields_to_allow && !grep {
                    sprintf( "%s\$%s", $subfield->{tagfield}, $subfield->{tagsubfield} ) eq $_
                } @$subfields_to_allow
              )
            {
                next if $ignore_not_allowed_subfields;
                $readonly = 1 if $restricted_edition;
            }

            my @values = ();

            my $subfield_data;

            if (
                !@$subfields_to_prefill
                || ( @$subfields_to_prefill && grep { $_ eq $subfieldtag }
                    @$subfields_to_prefill )
              )
            {
                my $kohafield = $subfield->{kohafield};
                if ($kohafield) {

                    # This is a mapped field
                    ( my $attribute = $kohafield ) =~ s|^items\.||;
                    push @values, $subfield->{repeatable}
                      ? split '\s\|\s', $item->{$attribute}
                      : $item->{$attribute}
                      if defined $item->{$attribute};
                }
                else {
                  # Not mapped, picked the values from more_subfields_xml's MARC
                    if ($marc_more_subfields) {
                        for my $f ( $marc_more_subfields->fields($tag) ) {
                            push @values, $f->subfield($subfieldtag);
                        }
                    }
                }
            }

            @values = ('') unless @values;

            for my $value (@values) {
                my $subfield_data = $self->generate_subfield_form(
                    {
                        tag                => $tag,
                        subfieldtag        => $subfieldtag,
                        value              => $value,
                        tagslib            => $tagslib,
                        libraries          => $libraries,
                        marc_record        => $marc_record, #Note: could be undefined
                        restricted_edition => $restricted_edition,
                        prefill_with_default_values => $prefill_with_default_values,
                        branch_limit       => $branch_limit,
                        default_branches_empty => $default_branches_empty,
                        readonly           => $readonly
                    }
                );
                push @subfields, $subfield_data;
            }
        }
    }

    @subfields = sort {
             $a->{display_order} <=> $b->{display_order}
          || $a->{subfield} cmp $b->{subfield}
    } @subfields;

    return \@subfields;

}

1;
