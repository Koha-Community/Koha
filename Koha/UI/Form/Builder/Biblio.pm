package Koha::UI::Form::Builder::Biblio;

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
use C4::ClassSource qw( GetClassSources );
use Koha::DateUtils qw( dt_from_string );
use Koha::ItemTypes;
use Koha::Libraries;

=head1 NAME

Koha::UI::Form::Builder::Biblio

Helper to build a form to add or edit a new biblio

=head1 API

=head2 Class methods

=cut

=head3 new

    my $form = Koha::UI::Form::Builder::Biblio->new(
        {
            biblionumber => $biblionumber,
        }
    );

=cut


sub new {
    my ( $class, $params ) = @_;

    my $self = {};
    $self->{biblionumber} = $params->{biblionumber};

    bless $self, $class;
    return $self;
}

=head3 generate_subfield_form

    Generate subfield's info for given tag, subfieldtag, etc.

=cut

sub generate_subfield_form {
    my ($self, $params) = @_;

    my $tag = $params->{tag};
    my $subfield = $params->{subfield};
    my $value = $params->{value} // '';
    my $index_tag = $params->{index_tag};
    my $rec = $params->{record};
    my $hostitemnumber = $params->{hostitemnumber};
    my $op = $params->{op} // '';
    my $changed_framework = $params->{changed_framework};
    my $breedingid = $params->{breedingid};
    my $tagslib = $params->{tagslib};
    my $mandatory_z3950 = $params->{mandatory_z3950} // {};

    my $index_subfield = $self->create_key(); # create a specific key for each subfield

    # Apply optional framework default value when it is a new record,
    # or when editing as new (duplicating a record),
    # or when changing a record's framework,
    # or when importing a record,
    # based on the ApplyFrameworkDefaults setting.
    # Substitute date parts, user name
    my $applydefaults = C4::Context->preference('ApplyFrameworkDefaults');
    if ( $value eq '' && (
        ( $applydefaults =~ /new/ && !$self->{biblionumber} ) ||
        ( $applydefaults =~ /duplicate/ && $op eq 'duplicate' ) ||
        ( $applydefaults =~ /changed/ && $changed_framework ) ||
        ( $applydefaults =~ /imported/ && $breedingid )
    ) ) {
        $value = $tagslib->{$tag}->{$subfield}->{defaultvalue} // q{};

        # get today date & replace <<YYYY>>, <<YY>>, <<MM>>, <<DD>> if provided in the default value
        my $today_dt = dt_from_string;
        my $year = $today_dt->strftime('%Y');
        my $shortyear = $today_dt->strftime('%y');
        my $month = $today_dt->strftime('%m');
        my $day = $today_dt->strftime('%d');
        $value =~ s/<<YYYY>>/$year/g;
        $value =~ s/<<YY>>/$shortyear/g;
        $value =~ s/<<MM>>/$month/g;
        $value =~ s/<<DD>>/$day/g;
        # And <<USER>> with surname (?)
        my $username=(C4::Context->userenv?C4::Context->userenv->{'surname'}:"superlibrarian");
        $value=~s/<<USER>>/$username/g;
    }

    my $dbh = C4::Context->dbh;

    # map '@' as "subfield" label for fixed fields
    # to something that's allowed in a div id.
    my $id_subfield = $subfield;
    $id_subfield = "00" if $id_subfield eq "@";

    my %subfield_data = (
        tag        => $tag,
        subfield   => $id_subfield,
        marc_lib       => $tagslib->{$tag}->{$subfield}->{lib},
        tag_mandatory  => $tagslib->{$tag}->{mandatory},
        mandatory      => $tagslib->{$tag}->{$subfield}->{mandatory},
        important      => $tagslib->{$tag}->{$subfield}->{important},
        repeatable     => $tagslib->{$tag}->{$subfield}->{repeatable},
        kohafield      => $tagslib->{$tag}->{$subfield}->{kohafield},
        index          => $index_tag,
        id             => "tag_".$tag."_subfield_".$id_subfield."_".$index_tag."_".$index_subfield,
        value          => $value,
        maxlength      => $tagslib->{$tag}->{$subfield}->{maxlength},
        random         => $self->create_key(),
    );

    if (exists $mandatory_z3950->{$tag.$subfield}){
        $subfield_data{z3950_mandatory} = $mandatory_z3950->{$tag.$subfield};
    }
    # Subfield is hidden depending of hidden and mandatory flag, and is always
    # shown if it contains anything or if its field is mandatory or important.
    my $tdef = $tagslib->{$tag};
    $subfield_data{visibility} = "display:none;"
        if $tdef->{$subfield}->{hidden} % 2 == 1 &&
           $value eq '' &&
           !$tdef->{$subfield}->{mandatory} &&
           !$tdef->{mandatory} &&
           !$tdef->{$subfield}->{important} &&
           !$tdef->{important};
    # expand all subfields of 773 if there is a host item provided in the input
    $subfield_data{visibility} = '' if ($tag eq '773' and $hostitemnumber);


    # it's an authorised field
    if ( $tagslib->{$tag}->{$subfield}->{authorised_value} ) {
        $subfield_data{marc_value} = $self->build_authorized_values_list(
            {
                tag => $tag,
                subfield => $subfield,
                value => $value,
                index_tag => $index_tag,
                index_subfield => $index_subfield,
                tagslib => $tagslib,
            }
        );
    }
    # it's a subfield $9 linking to an authority record - see bug 2206 and 28022
    elsif ($subfield eq "9" and
           exists($tagslib->{$tag}->{'a'}->{authtypecode}) and
           defined($tagslib->{$tag}->{'a'}->{authtypecode}) and
           $tagslib->{$tag}->{'a'}->{authtypecode} ne '' and
           $tagslib->{$tag}->{'a'}->{hidden} > -4 and
           $tagslib->{$tag}->{'a'}->{hidden} < 5) {
        $subfield_data{marc_value} = {
            type      => 'text',
            id        => $subfield_data{id},
            name      => $subfield_data{id},
            value     => $value,
            size      => 5,
            maxlength => $subfield_data{maxlength},
            readonly  => 1,
        };

    # it's a thesaurus / authority field
    }
    elsif ( $tagslib->{$tag}->{$subfield}->{authtypecode} ) {
        # when authorities auto-creation is allowed, do not set readonly
        my $is_readonly = C4::Context->preference('RequireChoosingExistingAuthority');

        $subfield_data{marc_value} = {
            type      => 'text',
            id        => $subfield_data{id},
            name      => $subfield_data{id},
            value     => $value,
            size      => 67,
            maxlength => $subfield_data{maxlength},
            readonly  => ($is_readonly) ? 1 : 0,
            authtype  => $tagslib->{$tag}->{$subfield}->{authtypecode},
        };

    # it's a plugin field
    } elsif ( $tagslib->{$tag}->{$subfield}->{'value_builder'} ) {
        require Koha::FrameworkPlugin;
        my $plugin = Koha::FrameworkPlugin->new( {
            name => $tagslib->{$tag}->{$subfield}->{'value_builder'},
        });
        my $pars= { dbh => $dbh, record => $rec, tagslib => $tagslib,
            id => $subfield_data{id} };
        $plugin->build( $pars );
        if( !$plugin->errstr ) {
            $subfield_data{marc_value} = {
                type           => 'text_complex',
                id             => $subfield_data{id},
                name           => $subfield_data{id},
                value          => $value,
                size           => 67,
                maxlength      => $subfield_data{maxlength},
                javascript     => $plugin->javascript,
                plugin         => $plugin->name,
                noclick        => $plugin->noclick,
            };
        } else {
            warn $plugin->errstr;
            # supply default input form
            $subfield_data{marc_value} = {
                type      => 'text',
                id        => $subfield_data{id},
                name      => $subfield_data{id},
                value     => $value,
                size      => 67,
                maxlength => $subfield_data{maxlength},
                readonly  => 0,
            };
        }

    # it's an hidden field
    } elsif ( $tag eq '' ) {
        $subfield_data{marc_value} = {
            type      => 'hidden',
            id        => $subfield_data{id},
            name      => $subfield_data{id},
            value     => $value,
            size      => 67,
            maxlength => $subfield_data{maxlength},
        };

    }
    else {
        # it's a standard field
        if (
            length($value) > 100
            or
            ( C4::Context->preference("marcflavour") eq "UNIMARC" && $tag >= 300
                and $tag < 400 && $subfield eq 'a' )
            or (    $tag >= 500
                and $tag < 600
                && C4::Context->preference("marcflavour") eq "MARC21" )
          )
        {
            $subfield_data{marc_value} = {
                type      => 'textarea',
                id        => $subfield_data{id},
                name      => $subfield_data{id},
                value     => $value,
            };

        }
        else {
            $subfield_data{marc_value} = {
                type      => 'text',
                id        => $subfield_data{id},
                name      => $subfield_data{id},
                value     => $value,
                size      => 67,
                maxlength => $subfield_data{maxlength},
                readonly  => 0,
            };

        }
    }
    $subfield_data{'index_subfield'} = $index_subfield;

    return \%subfield_data;
}

=head3 build_authorized_values_list

    Return list of authorized values for given tag, subfield

=cut

sub build_authorized_values_list {
    my ($self, $params) = @_;

    my $tag = $params->{tag};
    my $subfield = $params->{subfield};
    my $value = $params->{value};
    my $index_tag = $params->{index_tag};
    my $index_subfield = $params->{index_subfield};
    my $tagslib = $params->{tagslib};

    my @authorised_values;
    my %authorised_lib;

    # builds list, depending on authorised value...

    #---- branch
    my $category = $tagslib->{$tag}->{$subfield}->{authorised_value};
    if ( $category eq "branches" ) {
        my $libraries = Koha::Libraries->search_filtered({}, {order_by => ['branchname']});
        while ( my $l = $libraries->next ) {
            push @authorised_values, $l->branchcode;
            $authorised_lib{$l->branchcode} = $l->branchname;
        }
    }
    elsif ( $category eq "itemtypes" ) {
        push @authorised_values, "";

        my $itemtype;
        my $itemtypes = Koha::ItemTypes->search_with_localization;
        while ( $itemtype = $itemtypes->next ) {
            push @authorised_values, $itemtype->itemtype;
            $authorised_lib{$itemtype->itemtype} = $itemtype->translated_description;
        }
        $value = $itemtype unless ($value);
    }
    elsif ( $category eq "cn_source" ) {
        push @authorised_values, "";

        my $class_sources = GetClassSources();

        my $default_source = C4::Context->preference("DefaultClassificationSource");

        foreach my $class_source (sort keys %$class_sources) {
            next unless $class_sources->{$class_source}->{'used'} or
                        ($value and $class_source eq $value) or
                        ($class_source eq $default_source);
            push @authorised_values, $class_source;
            $authorised_lib{$class_source} = $class_sources->{$class_source}->{'description'};
        }
        $value = $default_source unless $value;
    }
    else {
        my $branch_limit = C4::Context->userenv ? C4::Context->userenv->{branch} : '';
        my $query = 'SELECT authorised_value, lib FROM authorised_values';
        $query .= ' LEFT JOIN authorised_values_branches ON ( id = av_id )' if $branch_limit;
        $query .= ' WHERE category = ?';
        $query .= ' AND ( branchcode = ? OR branchcode IS NULL )' if $branch_limit;
        $query .= ' GROUP BY authorised_value,lib ORDER BY lib, lib_opac';
        my $authorised_values_sth = C4::Context->dbh->prepare($query);

        $authorised_values_sth->execute(
            $tagslib->{$tag}->{$subfield}->{authorised_value},
            $branch_limit ? $branch_limit : (),
        );

        push @authorised_values, "";

        while ( my ( $value, $lib ) = $authorised_values_sth->fetchrow_array ) {
            push @authorised_values, $value;
            $authorised_lib{$value} = $lib;
        }
    }

    return {
        type     => 'select',
        id       => "tag_".$tag."_subfield_".$subfield."_".$index_tag."_".$index_subfield,
        name     => "tag_".$tag."_subfield_".$subfield."_".$index_tag."_".$index_subfield,
        default  => $value,
        values   => \@authorised_values,
        labels   => \%authorised_lib,
        ( ( grep { $_ eq $category } ( qw(branches itemtypes cn_source) ) ) ? () : ( category => $category ) ),
    };

}

=head3 create_key

    Create unique key for subfields

=cut

sub create_key {
    return int(rand(1000000));
}

1;
