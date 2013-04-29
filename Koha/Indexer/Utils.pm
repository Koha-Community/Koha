package Koha::Indexer::Utils;

# Copyright (c) 2012 Equinox Software, Inc.
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use strict;
use warnings;
use 5.010;

use XML::LibXML;

=head1 Koha::Indexer::Utils

Koha::Indexer::Utils - utility functions for managing search indexes

=head1 DESCRIPTION

This modules contains utility functions for managing various aspects
of Koha's bibliographic and authority search indexes.

=head1 FUNCTIONS

=cut

=head2 zebra_record_abs_to_dom

$dom_config = Koha::Indexer::Utils::zebra_record_abs_to_dom($record_abs_config, $marcflavour);

Given a string containing the contents of a records.abs configuration file as
used by Zebra's GRS-1 filter, emit an equivalent DOM configuration.

=cut

our $idxNS = 'http://www.koha-community.org/schemas/index-defs';

sub zebra_record_abs_to_dom {
    my $grs1_cfg = shift;
    my $marcflavour = shift;

    chomp $grs1_cfg;
    my @grs1_cfg_lines = split /\n/, $grs1_cfg, -1;
    my $grs1_defs = [];

    # generate an arrayref of structures representing
    # each records.abs line
    for (my $i = 0; $i <= $#grs1_cfg_lines; $i++) {
        my $line = $grs1_cfg_lines[$i];
        next if _can_ignore_grs1_cfg_line($line);
        my $grs1_def = _parse_grs1_cfg_line($line);
        $grs1_def->{orig_def} = $line;
        $grs1_def->{lineno} = $i + 1;
        push @$grs1_defs, $grs1_def;
    }

    # map the index definitions to a DOM tree representing
    # the index definitions -- if you squint hard, you
    # can see the beginnings of a more general definition language
    # for Koha index definitions
    my $dom_cfg = XML::LibXML::Document->new('1.0', 'utf-8');
    my $root = $dom_cfg->createElement('index_defs');
    $root->setNamespace($idxNS, 'kohaidx');
    foreach my $grs1_def (@$grs1_defs) {
        _append_grs1_def_to_dom_cfg($dom_cfg, $root, $grs1_def, $marcflavour);
    }

    # and emit the result as a string
    $dom_cfg->setDocumentElement($root);
    return $dom_cfg->toString(1);
}

#
# bunch of utility functions for zebra_record_abs_to_dom
#
sub _can_ignore_grs1_cfg_line {
    my $line = shift;
    return 1 if $line =~ /^\s*$/ or
                $line =~ /^#/ or
                $line =~ /^(encoding|name|attset|esetname|marc|systag|xpath)/ or
                $line =~ /^all/; # DOM filter automatically indexes all tokens, so
                                 # no need to deal with 'all any' lines in record.abs
    return 0;
}

sub _parse_grs1_cfg_line {
    my $line = shift;
    my $grs1_def;

    if ($line =~ /^melm\s+(.*)/ || $line =~ m!^xelm /record/(.*)!) {
        $grs1_def = _parse_xelm_melm($1);
    }
    return $grs1_def;
}

sub _parse_xelm_melm {
    my $line = shift;

    my ($field, $index_defs) = split /\s+/, $line, 2;

    # munge fixed field range indicators
    $index_defs =~ s/range\(data,(\d+),(\d+)\)/$1:$2/g;

    my ($tag, $subfield) = split /\$/, $field, 2;
    return {
        tag         => $tag,
        subfield    => $subfield,
        index_defs  => [ map { _parse_grs1_index_def($_) } split /,/, $index_defs ],
    };
}

sub _parse_grs1_index_def {
    my $index_def = shift;

    my @parts = split /:/, $index_def, -1;
    my $parsed_def = {};
    $parsed_def->{name}       = shift @parts;
    $parsed_def->{index_type} = shift @parts;
    $parsed_def->{offset}     = shift @parts;
    $parsed_def->{length}     = shift @parts;
    # if the original index definition didn't specify an index
    # type, set it 'w' -- the DOM filter needs the index type
    # to be specified explicitly
    $parsed_def->{index_type} = 'w' unless defined $parsed_def->{index_type};
    return $parsed_def;
}

sub _append_grs1_def_to_dom_cfg {
    my $dom_cfg = shift;
    my $root = shift;
    my $grs1_def = shift;
    my $marcflavour = shift;

    my $comment = $dom_cfg->createComment('record.abs line ' .
                                          $grs1_def->{lineno} . ': ' .
                                          $grs1_def->{orig_def});
    $root->appendChild($comment);

    if (defined $grs1_def->{tag} && defined $grs1_def->{subfield}) {
        my $dom_def = $dom_cfg->createElementNS($idxNS, 'index_subfields');
        $dom_def->setAttribute('tag', $grs1_def->{tag});
        $dom_def->setAttribute('subfields', $grs1_def->{subfield});
        _append_target_indexes($dom_cfg, $dom_def, $grs1_def);
        $root->appendChild($dom_def);
    } elsif (defined $grs1_def->{tag} and $grs1_def->{tag} eq 'leader') {
        # we're the leader
        _append_grs1_defs_for_leader($dom_cfg, $root, $grs1_def);
    } elsif (defined $grs1_def->{tag} and $grs1_def->{tag} < 10) {
        # we're a control field
        _append_grs1_defs_for_control_field($dom_cfg, $root, $grs1_def);
    } elsif (defined $grs1_def->{tag}) {
        # we're indexing an entire variable data field
        my $dom_def = $dom_cfg->createElementNS($idxNS, 'index_data_field');
        $dom_def->setAttribute('tag', $grs1_def->{tag});
        _append_target_indexes($dom_cfg, $dom_def, $grs1_def);
        $root->appendChild($dom_def);
    }
}

sub _append_target_indexes {
    my $dom_cfg = shift;
    my $dom_def = shift;
    my $grs1_def = shift;

    foreach my $index_def (@{ $grs1_def->{index_defs} }) {
        _append_one_target_index($dom_cfg, $dom_def, $index_def);
    }
}

sub _append_one_target_index {
    my $dom_cfg = shift;
    my $dom_def = shift;
    my $index_def = shift;
    my $tgt_idx = $dom_cfg->createElementNS($idxNS, 'target_index');
    my $index_name = "$index_def->{name}:$index_def->{index_type}";
    $tgt_idx->appendText($index_name);
    $dom_def->appendChild($tgt_idx);
}

sub _append_grs1_defs_for_leader {
    my $dom_cfg = shift;
    my $root = shift;
    my $grs1_def = shift;
    foreach my $index_def (@{ $grs1_def->{index_defs} }) {
        my $dom_def = $dom_cfg->createElementNS($idxNS, 'index_leader');
        if (defined $index_def->{offset} && defined $index_def->{length}) {
            $dom_def->setAttribute('offset', $index_def->{offset});
            $dom_def->setAttribute('length', $index_def->{length});
        }
        _append_one_target_index($dom_cfg, $dom_def, $index_def);
        $root->appendChild($dom_def);
    }
}

sub _append_grs1_defs_for_control_field {
    my $dom_cfg = shift;
    my $root = shift;
    my $grs1_def = shift;
    foreach my $index_def (@{ $grs1_def->{index_defs} }) {
        my $dom_def = $dom_cfg->createElementNS($idxNS, 'index_control_field');
        $dom_def->setAttribute('tag', $grs1_def->{tag});
        if (defined $index_def->{offset} && defined $index_def->{length}) {
            $dom_def->setAttribute('offset', $index_def->{offset});
            $dom_def->setAttribute('length', $index_def->{length});
        }
        _append_one_target_index($dom_cfg, $dom_def, $index_def);
        $root->appendChild($dom_def);
    }
}

1;
