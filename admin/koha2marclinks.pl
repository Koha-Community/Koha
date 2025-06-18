#!/usr/bin/perl

# Copyright 2000-2002 Katipo Communications
# Copyright 2017 Rijksmuseum
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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;
use CGI qw ( -utf8 );

use Koha::Database;
use C4::Auth   qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );
use Koha::BiblioFrameworks;
use Koha::Caches;
use Koha::MarcSubfieldStructures;

my $input = CGI->new;
my $op    = $input->param('op') // q{};

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name => "admin/koha2marclinks.tt",
        query         => $input,
        type          => "intranet",
        flagsrequired => { parameters => 'manage_marc_frameworks' },
    }
);

my $schema = Koha::Database->new->schema;
my $cache  = Koha::Caches->get_instance();

# Update data before showing the form
my $no_upd;

if ( $input->param('add_field') && $op eq 'cud-save' ) {

    # add a mapping to all frameworks
    my ( $kohafield, $tag, $sub ) = split /,/, $input->param('add_field'), 3;
    my $rs = Koha::MarcSubfieldStructures->search( { tagfield => $tag, tagsubfield => $sub } );
    if ( $rs->count ) {
        $rs->update( { kohafield => $kohafield } );
    } else {
        $template->param( error_add => 1, error_info => "$tag, $sub" );
    }

} elsif ( $input->param('remove_field') && $op eq 'cud-save' ) {

    # remove a mapping from all frameworks
    my ( $tag, $sub ) = split /,/, $input->param('remove_field'), 2;
    Koha::MarcSubfieldStructures->search( { tagfield => $tag, tagsubfield => $sub } )->update( { kohafield => undef } );

} else {
    $no_upd = 1;
}

# Clear the cache when needed
unless ($no_upd) {
    $cache->clear_from_cache("MarcSubfieldStructure-");
}

# Build/Show the form
my $dbix_map = {

    # Koha to MARC mappings are found in only three tables
    biblio      => 'Biblio',
    biblioitems => 'Biblioitem',
    items       => 'Item',
};
my @cols;
foreach my $tbl ( sort keys %{$dbix_map} ) {
    push @cols,
        map { "$tbl.$_" } $schema->source( $dbix_map->{$tbl} )->columns;
}
my $kohafields = Koha::MarcSubfieldStructures->search(
    {
        frameworkcode => q{},
        kohafield     => { '>', '' },
    }
);
my @loop_data;
foreach my $col (@cols) {
    my $found;
    my $readonly = $col =~ /\.(biblio|biblioitem|item)number$/;
    foreach my $row ( $kohafields->search( { kohafield => $col } )->as_list ) {
        $found = 1;
        push @loop_data, {
            kohafield    => $col,
            tagfield     => $row->tagfield,
            tagsubfield  => $row->tagsubfield,
            liblibrarian => $row->liblibrarian,
            readonly     => $readonly,
        };
    }
    push @loop_data, {
        kohafield => $col,
        readonly  => $readonly,
    } if !$found;
}

$template->param(
    loop => \@loop_data,
);

output_html_with_http_headers $input, $cookie, $template->output;
