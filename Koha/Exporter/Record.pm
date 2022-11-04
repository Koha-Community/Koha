package Koha::Exporter::Record;

use Modern::Perl;
use MARC::File::XML;
use MARC::File::USMARC;

use C4::AuthoritiesMarc;
use C4::Biblio qw( GetMarcFromKohaField );
use C4::Record;
use Koha::Biblios;
use Koha::CsvProfiles;
use Koha::Logger;
use List::Util qw( all any );

sub _get_record_for_export {
    my ($params)           = @_;
    my $record_type        = $params->{record_type};
    my $record_id          = $params->{record_id};
    my $conditions         = $params->{record_conditions};
    my $dont_export_fields = $params->{dont_export_fields};
    my $clean              = $params->{clean};

    my $record;
    if ( $record_type eq 'auths' ) {
        $record = _get_authority_for_export( { %$params, authid => $record_id } );
    } elsif ( $record_type eq 'bibs' ) {
        $record = _get_biblio_for_export( { %$params, biblionumber => $record_id } );
    } else {
        Koha::Logger->get->warn( "Record_type $record_type not supported." );
    }
    if ( !$record ) {
        Koha::Logger->get->warn( "Record $record_id could not be exported." );
        return;
    }

    # If multiple conditions all are required to match (and)
    # For matching against multiple marc targets all are also required to match
    my %operators = (
        '=' => sub {
            return $_[0] eq $_[1];
        },
        '!=' => sub {
            return $_[0] ne $_[1];
        },
        '>' => sub {
            return $_[0] gt $_[1];
        },
        '<' => sub {
            return $_[0] lt $_[1];
        },
    );
    if ($conditions) {
        foreach my $condition (@{$conditions}) {
            my ($field_tag, $subfield, $operator, $match_value) = @{$condition};
            my @fields = $record->field($field_tag);
            my $no_target = 0;

            if (!@fields) {
                $no_target = 1;
            }
            else {
                if ($operator eq '?') {
                    return unless any { $subfield ? $_->subfield($subfield) : $_->data() } @fields;
                } elsif ($operator eq '!?') {
                    return if any { $subfield ? $_->subfield($subfield) : $_->data() } @fields;
                } else {
                    my $op;
                    if (exists $operators{$operator}) {
                        $op = $operators{$operator};
                    } else {
                        die("Invalid operator: $op");
                    }
                    my @target_values = map { $subfield ? $_->subfield($subfield) : ($_->data()) } @fields;
                    if (!@target_values) {
                        $no_target = 1;
                    }
                    else {
                        return unless all { $op->($_, $match_value) } @target_values;
                    }
                }
            }
            return if $no_target && $operator ne '!=';
        }
    }

    if ($dont_export_fields) {
        for my $f ( split / /, $dont_export_fields ) {
            if ( $f =~ m/^(\d{3})(.)?$/ ) {
                my ( $field, $subfield ) = ( $1, $2 );

                # skip if this record doesn't have this field
                if ( defined $record->field($field) ) {
                    if ( defined $subfield ) {
                        my @tags = $record->field($field);
                        foreach my $t (@tags) {
                            $t->delete_subfields($subfield);
                        }
                    } else {
                        $record->delete_fields( $record->field($field) );
                    }
                }
            }
        }
    }
    C4::Biblio::RemoveAllNsb($record) if $clean;
    return $record;
}

sub _get_authority_for_export {
    my ($params) = @_;
    my $authid = $params->{authid} || return;
    my $authority = Koha::MetadataRecord::Authority->get_from_authid($authid);
    return unless $authority;
    return $authority->record;
}

sub _get_biblio_for_export {
    my ($params)     = @_;
    my $biblionumber = $params->{biblionumber};
    my $itemnumbers  = $params->{itemnumbers};
    my $export_items = $params->{export_items} // 1;
    my $only_export_items_for_branches = $params->{only_export_items_for_branches};

    my $biblio = Koha::Biblios->find($biblionumber);
    my $record = eval { $biblio->metadata->record };

    return if $@ or not defined $record;

    if ($export_items) {
        Koha::Biblio::Metadata->record(
            {
                record       => $record,
                embed_items  => 1,
                biblionumber => $biblionumber,
                itemnumbers => $itemnumbers,
            }
        );
        if ($only_export_items_for_branches && @$only_export_items_for_branches) {
            my %export_items_for_branches = map { $_ => 1 } @$only_export_items_for_branches;
            my ( $homebranchfield, $homebranchsubfield ) = GetMarcFromKohaField( 'items.homebranch' );

            for my $itemfield ( $record->field($homebranchfield) ) {
                my $homebranch = $itemfield->subfield($homebranchsubfield);
                unless ( $export_items_for_branches{$homebranch} ) {
                    $record->delete_field($itemfield);
                }
            }
        }
    }
    return $record;
}

sub export {
    my ($params) = @_;

    my $record_type        = $params->{record_type};
    my $record_ids         = $params->{record_ids} || [];
    my $format             = $params->{format};
    my $itemnumbers        = $params->{itemnumbers} || [];    # Does not make sense with record_type eq auths
    my $export_items       = $params->{export_items};
    my $dont_export_fields = $params->{dont_export_fields};
    my $csv_profile_id     = $params->{csv_profile_id};
    my $output_filepath    = $params->{output_filepath};

    if( !$record_type ) {
        Koha::Logger->get->warn( "No record_type given." );
        return;
    }
    return unless @$record_ids;

    my $fh;
    if ( $output_filepath ) {
        open $fh, '>', $output_filepath or die "Cannot open file $output_filepath ($!)";
        select $fh;
        binmode $fh, ':encoding(UTF-8)' unless $format eq 'csv';
    } else {
        binmode STDOUT, ':encoding(UTF-8)' unless $format eq 'csv';
    }

    if ( $format eq 'iso2709' ) {
        for my $record_id (@$record_ids) {
            my $record = _get_record_for_export( { %$params, record_id => $record_id } );
            next unless $record;
            my $errorcount_on_decode = eval { scalar( MARC::File::USMARC->decode( $record->as_usmarc )->warnings() ) };
            if ( $errorcount_on_decode or $@ ) {
                my $msg = "Record $record_id could not be exported. " .
                    ( $@ // '' );
                chomp $msg;
                Koha::Logger->get->info( $msg );
                next;
            }
            print $record->as_usmarc();
        }
    } elsif ( $format eq 'xml' ) {
        my $marcflavour = C4::Context->preference("marcflavour");
        MARC::File::XML->default_record_format( ( $marcflavour eq 'UNIMARC' && $record_type eq 'auths' ) ? 'UNIMARCAUTH' : $marcflavour );

        print MARC::File::XML::header();
        print "\n";
        for my $record_id (@$record_ids) {
            my $record = _get_record_for_export( { %$params, record_id => $record_id } );
            next unless $record;
            print MARC::File::XML::record($record);
            print "\n";
        }
        print MARC::File::XML::footer();
        print "\n";
    } elsif ( $format eq 'csv' ) {
        die 'There is no valid csv profile defined for this export'
            unless Koha::CsvProfiles->find( $csv_profile_id );
        print marc2csv( $record_ids, $csv_profile_id, $itemnumbers );
    }

    close $fh if $output_filepath;
}

1;

__END__

=head1 NAME

Koha::Exporter::Records - module to export records (biblios and authorities)

=head1 SYNOPSIS

This module provides a public subroutine to export records as xml, csv or iso2709.

=head2 FUNCTIONS

=head3 export

    Koha::Exporter::Record::export($params);

$params is a hashref with some keys:

It will displays on STDOUT the generated file.

=over 4

=item record_type

  Must be set to 'bibs' or 'auths'

=item record_ids

  The list of the records to export (a list of biblionumber or authid)

=item format

  The format must be 'csv', 'xml' or 'iso2709'.

=item itemnumbers

  Generate the item infos only for these itemnumbers.

  Must only be used with biblios.

=item export_items

  If this flag is set, the items will be exported.
  Default is ON.

=item dont_export_fields

  List of fields not to export.

=item csv_profile_id

  If the format is csv, you have to define a csv_profile_id.

=cut

=back

=head1 LICENSE

This file is part of Koha.

Copyright Koha Development Team

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
