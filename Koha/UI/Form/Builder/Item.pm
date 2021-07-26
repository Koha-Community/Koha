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
use C4::Context;
use C4::Biblio qw( GetFrameworkCode GetMarcBiblio GetMarcStructure IsMarcStructureInternal );
use C4::Koha qw( GetAuthorisedValues );
use C4::ClassSource qw( GetClassSources );

use Koha::DateUtils qw( dt_from_string );
use Koha::Libraries;

sub new {
    my ( $class, $params ) = @_;

    my $self;
    $self->{biblionumber} = $params->{biblionumber};
    $self->{item} = $params->{item};

    bless $self, $class;
    return $self;
}

sub generate_subfield_form {

    my ($self, $params)    = @_;
    my $tag         = $params->{tag};
    my $subfieldtag = $params->{subfieldtag};
    my $value       = $params->{value};
    my $tagslib     = $params->{tagslib};
    my $libraries   = $params->{libraries};
    my $marc_record = $params->{marc_record};
    my $restricted_edition = $params->{restricted_editition};

    my $item = $self->{item};
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

    if ( !defined($value) || $value eq '' ) {
        $value = $subfield->{defaultvalue};
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
    if (  !$value
        && $subfield->{kohafield} eq 'items.itemcallnumber'
        && $pref_itemcallnumber )
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

    my $default_location = C4::Context->preference('NewItemsDefaultLocation');
    if (  !$value
        && $subfield->{kohafield} eq 'items.location'
        && $default_location )
    {
        $value = $default_location;
    }

    if (   $frameworkcode eq 'FA'
        && $subfield->{kohafield} eq 'items.barcode'
        && !$value )
    {
        my $input = CGI->new;
        $value = $input->param('barcode');
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
            my $branch_limit =
              C4::Context->userenv && C4::Context->userenv->{"branch"};
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

            unless ($value) {
                my $itype_sth = $dbh->prepare(
                    "SELECT itemtype FROM biblioitems WHERE biblionumber = ?");
                $itype_sth->execute($biblionumber);
                ($value) = $itype_sth->fetchrow_array;
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
            $value = $default_source unless ($value);

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
            record  => $marc_record,
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

    # Getting list of subfields to keep when restricted editing is enabled
    # FIXME Improve the following block, no need to do it for every subfields
    my $subfieldsToAllowForRestrictedEditing =
      C4::Context->preference('SubfieldsToAllowForRestrictedEditing');
    my $allowAllSubfields = (
        not defined $subfieldsToAllowForRestrictedEditing
          or $subfieldsToAllowForRestrictedEditing eq q||
    ) ? 1 : 0;
    my @subfieldsToAllow = split( / /, $subfieldsToAllowForRestrictedEditing );

# If we're on restricted editing, and our field is not in the list of subfields to allow,
# then it is read-only
    $subfield_data{marc_value}->{readonly} =
      (       not $allowAllSubfields
          and $restricted_edition
          and !grep { $tag . '$' . $subfieldtag eq $_ } @subfieldsToAllow )
      ? 1
      : 0;

    return \%subfield_data;
}

sub edit_form {
    my ( $self, $params ) = @_;

    my $branchcode         = $params->{branchcode};
    my $restricted_edition = $params->{restricted_editition};
    my $subfields_to_prefill = $params->{subfields_to_prefill} || [];
    my $libraries =
      Koha::Libraries->search( {}, { order_by => ['branchname'] } )->unblessed;
    for my $library (@$libraries) {
        $library->{selected} = 1 if $library->{branchcode} eq $branchcode;
    }

    my $item           = $self->{item};
    my $biblionumber   = $self->{biblionumber};
    my $frameworkcode  = $biblionumber ? GetFrameworkCode($biblionumber) : q{};
    my $marc_record    = $biblionumber ? GetMarcBiblio( { biblionumber => $biblionumber } ) : undef;
    my @subfields;
    my $tagslib = GetMarcStructure( 1, $frameworkcode );
    foreach my $tag ( keys %{$tagslib} ) {

        foreach my $subfieldtag ( keys %{ $tagslib->{$tag} } ) {

            my $subfield = $tagslib->{$tag}{$subfieldtag};

            next if IsMarcStructureInternal($subfield);
            next if ( $subfield->{tab} ne "10" );

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
                    my $marc_more = $item->{marc_more_subfields_xml};
                    if ($marc_more) {
                        for my $f ( $marc_more->fields($tag) ) {
                            push @values, $f->subfield($subfieldtag);
                        }
                    }
                }
            }

            @values = ('') unless @values;

            for my $value (@values) {
                my $subfield_data = $self->generate_subfield_form(
                    {tag => $tag,          subfieldtag => $subfieldtag,      value => $value,
                    tagslib => $tagslib,      libraries => $libraries,
                    marc_record => $marc_record, restricted_edition => $restricted_edition,
                });
                push @subfields, $subfield_data;
                $i++;
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
