package Koha::Filter::MARC::ViewPolicy;

# Copyright 2015 Mark Tompsett
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

=head1 NAME

Koha::Filter::MARC::ViewPolicy - this filters a MARC record.

=head1 VERSION

version 1.0

=head1 SYNOPSIS

my $processor = Koha::RecordProcessor->new( { filters => ('ViewPolicy') } );

=head1 DESCRIPTION

Filter to remove fields based on the 'Advance constraints'
settings found when editing a particular subfield definition of
a MARC bibliographic framework found under the Koha administration
menu.

=cut

use Modern::Perl;
use Carp;
use C4::Biblio;

use base qw(Koha::RecordProcessor::Base);
our $NAME    = 'MARC_ViewPolicy';
our $VERSION = '3.23';              # Master version I hope it gets in.

use constant FIRST_NONCONTROL_TAG => 10;    # tags < 10 are control tags.

=head1 SUBROUTINES/METHODS

=head2 filter

    my $processor = Koha::RecordProcessor->new( { filters => ('ViewPolicy') } );
...
    my $newrecord = $processor->filter($record);
    my $newrecords = $processor->filter(\@records);

This returns a filtered copy of the record based on the Advanced constraints
visibility settings.

=cut

sub filter {
    my $self    = shift;
    my $precord = shift;
    my @records;

    if ( !$precord ) {
        return $precord;
    }

    if ( ref($precord) eq 'ARRAY' ) {
        @records = @{$precord};
    }
    else {
        push @records, $precord;
    }

    foreach my $current_record (@records) {
        my $result        = $current_record;
        my $interface     = $self->{options}->{interface} // 'opac';
        my $frameworkcode = $self->{options}->{frameworkcode} // q{};
        my $hide          = _should_hide_on_interface();

        my $marcsubfieldstructure = GetMarcStructure( 0, $frameworkcode );

        #if ($marcsubfieldstructure->{'000'}->{'@'}->{hidden}>0) {
        # LDR field is excluded from $current_record->fields().
        # if we hide it here, the MARCXML->MARC::Record->MARCXML
        # transformation blows up.
        #}
        foreach my $field ( $result->fields() ) {
            _filter_field(
                {
                    field                 => $field,
                    marcsubfieldstructure => $marcsubfieldstructure,
                    hide                  => $hide,
                    interface             => $interface,
                    result                => $result
                }
            );
        }
    }
    return;
}

sub _filter_field {
    my ($parameter) = @_;

    my $field                 = $parameter->{field};
    my $marcsubfieldstructure = $parameter->{marcsubfieldstructure};
    my $hide                  = $parameter->{hide};
    my $interface             = $parameter->{interface};
    my $result                = $parameter->{result};

    my $tag = $field->tag();
    if ( $tag >= FIRST_NONCONTROL_TAG ) {
        foreach my $subpairs ( $field->subfields() ) {
            my ( $subtag, $value ) = @{$subpairs};

            # visibility is a "level" (-9 to +9), default to 0
            # -8 is flagged, and 9/-9 are not implemented.
            my $visibility =
              $marcsubfieldstructure->{$tag}->{$subtag}->{hidden};
            $visibility //= 0;
            if ( $hide->{$interface}->{$visibility} ) {

                # deleting last subfield doesn't delete field, so
                # this detects that case to delete the field.
                if ( scalar $field->subfields() <= 1 ) {
                    $result->delete_fields($field);
                }
                else {
                    $field->delete_subfield( code => $subtag );
                }
            }
        }
    }

    # control tags don't have subfields, use @ trick.
    else {
        # visibility is a "level" (-9 to +9), default to 0
        # -8 is flagged, and 9/-9 are not implemented.
        my $visibility = $marcsubfieldstructure->{$tag}->{q{@}}->{hidden};
        $visibility //= 0;
        if ( $hide->{$interface}->{$visibility} ) {
            $result->delete_fields($field);
        }

    }
    return;
}

sub initialize {
    my $self  = shift;
    my $param = shift;

    my $options = $param->{options};
    $self->{options} = $options;
    $self->Koha::RecordProcessor::Base::initialize($param);
    return;
}

# Copied and modified from 3.10.x help file
# marc_subfields_structure.hidden
# allows you to select from 19 possible visibility conditions, 17 of which are implemented. They are the following:
# -9 => Future use
# -8 => Flag
# -7 => OPAC !Intranet !Editor Collapsed
# -6 => OPAC Intranet !Editor !Collapsed
# -5 => OPAC Intranet !Editor Collapsed
# -4 => OPAC !Intranet !Editor !Collapsed
# -3 => OPAC !Intranet Editor Collapsed
# -2 => OPAC !Intranet Editor !Collapsed
# -1 => OPAC Intranet Editor Collapsed
# 0 => OPAC Intranet Editor !Collapsed
# 1 => !OPAC Intranet Editor Collapsed
# 2 => !OPAC !Intranet Editor !Collapsed
# 3 => !OPAC !Intranet Editor Collapsed
# 4 => !OPAC Intranet Editor !Collapsed
# 5 => !OPAC !Intranet !Editor Collapsed
# 6 => !OPAC Intranet !Editor !Collapsed
# 7 => !OPAC Intranet !Editor Collapsed
# 8 => !OPAC !Intranet !Editor !Collapsed
# 9 => Future use
# ( ! means 'not visible' or in the case of Collapsed 'not Collapsed')

sub _should_hide_on_interface {
    my $hide = {
        opac => {
            '-8' => 1,
            '1'  => 1,
            '2'  => 1,
            '3'  => 1,
            '4'  => 1,
            '5'  => 1,
            '6'  => 1,
            '7'  => 1,
            '8'  => 1,
        },
        intranet => {
            '-8' => 1,
            '-7' => 1,
            '-4' => 1,
            '-3' => 1,
            '-2' => 1,
            '2'  => 1,
            '3'  => 1,
            '5'  => 1,
            '8'  => 1,
        },
    };
    return $hide;
}

=head2 should_hide_marc

Return a hash reference of whether a field, built from
kohafield and tag, is hidden (1) or not (0) for a given
interface

  my $OpacHideMARC =
    should_hide_marc( {
                        frameworkcode => $frameworkcode,
                        interface     => 'opac',
                      } );

  if ($OpacHideMARC->{'stocknumber'}==1) {
       print "Hidden!\n";
  }

C<$OpacHideMARC> is a ref to a hash which contains a series
of key value pairs indicating if that field (key) is
hidden (value == 1) or not (value == 0).

C<$frameworkcode> is the framework code.

C<$interface> is the interface. It defaults to 'opac' if
nothing is passed. Valid values include 'opac' or 'intranet'.

=cut

sub should_hide_marc {
    my ( $self, $parms ) = @_;
    my $frameworkcode = $parms->{frameworkcode} // q{};
    my $interface     = $parms->{interface}     // 'opac';
    my $hide          = _should_hide_on_interface();

    my %shouldhidemarc;
    my $marc_subfield_structure = GetMarcStructure( 0, $frameworkcode );
    foreach my $tag ( keys %{$marc_subfield_structure} ) {
        foreach my $subtag ( keys %{ $marc_subfield_structure->{$tag} } ) {
            my $subfield_record = $marc_subfield_structure->{$tag}->{$subtag};
            if ( ref $subfield_record eq 'HASH' ) {
                my $kohafield = $subfield_record->{'kohafield'};
                if ($kohafield) {
                    my @tmpsplit   = split /[.]/xsm, $kohafield;
                    my $field      = $tmpsplit[-1];
                    my $hidden     = $subfield_record->{'hidden'};
                    my $shouldhide = $hide->{$interface}->{$hidden};
                    if ($shouldhide) {
                        $shouldhidemarc{$field} = 1;
                    }
                    elsif ( !exists $shouldhidemarc{$field} ) {
                        $shouldhidemarc{$field} = 0;
                    }
                }
            }
        }
    }

    return \%shouldhidemarc;
}

=head1 DIAGNOSTICS

 $ prove -v t/RecordProcessor.t
 $ prove -v t/db_dependent/Filter_MARC_ViewPolicy.t

=head1 CONFIGURATION AND ENVIRONMENT

Install Koha. This filter will be used appropriately by the OPAC or Staff client.

=head1 INCOMPATIBILITIES

This is designed for MARC::Record filtering currently. It will not handle MARC::MARCXML.

=head1 DEPENDENCIES

The following Perl libraries are required: Modern::Perl and Carp.
The following Koha libraries are required: C4::Biblio, Koha::RecordProcessor, and Koha::RecordProcessor::Base.
These should all be installed if the koha-common package is installed or Koha is otherwise installed.

=head1 BUGS AND LIMITATIONS

This is the initial version. Please feel free to report bugs
at http://bugs.koha-community.org/.

=head1 AUTHOR

Mark Tompsett

=head1 LICENSE AND COPYRIGHT

Copyright 2015 Mark Tompsett

This file is part of Koha.

Koha is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3 of the License, or
(at your option) any later version.

Koha is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Koha; if not, see <http://www.gnu.org/licenses>.

=cut

1;
