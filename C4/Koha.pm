package C4::Koha;

# Copyright 2000-2002 Katipo Communications
#
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
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

# $Id$

use strict;
require Exporter;
use C4::Context;
use C4::Output;
use vars qw($VERSION @ISA @EXPORT);

$VERSION = do { my @v = '$Revision$' =~ /\d+/g; shift(@v) . "." . join( "_", map { sprintf "%03d", $_ } @v ); };

=head1 NAME

C4::Koha - Perl Module containing convenience functions for Koha scripts

=head1 SYNOPSIS

  use C4::Koha;


=head1 DESCRIPTION

Koha.pm provides many functions for Koha scripts.

=head1 FUNCTIONS

=over 2

=cut

@ISA    = qw(Exporter);
@EXPORT = qw(
  &slashifyDate
  &DisplayISBN
  &subfield_is_koha_internal_p
  &GetPrinters &GetPrinter
  &GetItemTypes &getitemtypeinfo
  &GetCcodes
  &GetAuthItemlost
  &GetAuthItembinding
  &get_itemtypeinfos_of
  &getframeworks &getframeworkinfo
  &getauthtypes &getauthtype
  &getallthemes
  &getFacets
  &displaySortby
  &displayIndexes
  &displaySubtypesLimit
  &displayLimitTypes
  &displayServers
  &getnbpages
  &getitemtypeimagesrcfromurl
  &get_infos_of
  &get_notforloan_label_of
  &getitemtypeimagedir
  &getitemtypeimagesrc
  &GetAuthorisedValues
  &FixEncoding
  &GetKohaAuthorisedValues
  $DEBUG
  );

my $DEBUG = 0;

=head2 slashifyDate

  $slash_date = &slashifyDate($dash_date);

Takes a string of the form "DD-MM-YYYY" (or anything separated by
dashes), converts it to the form "YYYY/MM/DD", and returns the result.

=cut

sub slashifyDate {

    # accepts a date of the form xx-xx-xx[xx] and returns it in the
    # form xx/xx/xx[xx]
    my @dateOut = split( '-', shift );
    return ("$dateOut[2]/$dateOut[1]/$dateOut[0]");
}


=head2 DisplayISBN

my $string = DisplayISBN( $isbn );

=cut

sub DisplayISBN {
    my ($isbn) = @_;
    my $seg1;
    if ( substr( $isbn, 0, 1 ) <= 7 ) {
        $seg1 = substr( $isbn, 0, 1 );
    }
    elsif ( substr( $isbn, 0, 2 ) <= 94 ) {
        $seg1 = substr( $isbn, 0, 2 );
    }
    elsif ( substr( $isbn, 0, 3 ) <= 995 ) {
        $seg1 = substr( $isbn, 0, 3 );
    }
    elsif ( substr( $isbn, 0, 4 ) <= 9989 ) {
        $seg1 = substr( $isbn, 0, 4 );
    }
    else {
        $seg1 = substr( $isbn, 0, 5 );
    }
    my $x = substr( $isbn, length($seg1) );
    my $seg2;
    if ( substr( $x, 0, 2 ) <= 19 ) {

        #         if(sTmp2 < 10) sTmp2 = "0" sTmp2;
        $seg2 = substr( $x, 0, 2 );
    }
    elsif ( substr( $x, 0, 3 ) <= 699 ) {
        $seg2 = substr( $x, 0, 3 );
    }
    elsif ( substr( $x, 0, 4 ) <= 8399 ) {
        $seg2 = substr( $x, 0, 4 );
    }
    elsif ( substr( $x, 0, 5 ) <= 89999 ) {
        $seg2 = substr( $x, 0, 5 );
    }
    elsif ( substr( $x, 0, 6 ) <= 9499999 ) {
        $seg2 = substr( $x, 0, 6 );
    }
    else {
        $seg2 = substr( $x, 0, 7 );
    }
    my $seg3 = substr( $x, length($seg2) );
    $seg3 = substr( $seg3, 0, length($seg3) - 1 );
    my $seg4 = substr( $x, -1, 1 );
    return "$seg1-$seg2-$seg3-$seg4";
}

# FIXME.. this should be moved to a MARC-specific module
sub subfield_is_koha_internal_p ($) {
    my ($subfield) = @_;

    # We could match on 'lib' and 'tab' (and 'mandatory', & more to come!)
    # But real MARC subfields are always single-character
    # so it really is safer just to check the length

    return length $subfield != 1;
}

=head2 GetItemTypes

  $itemtypes = &GetItemTypes();

Returns information about existing itemtypes.

build a HTML select with the following code :

=head3 in PERL SCRIPT

my $itemtypes = GetItemTypes;
my @itemtypesloop;
foreach my $thisitemtype (sort keys %$itemtypes) {
    my $selected = 1 if $thisitemtype eq $itemtype;
    my %row =(value => $thisitemtype,
                selected => $selected,
                description => $itemtypes->{$thisitemtype}->{'description'},
            );
    push @itemtypesloop, \%row;
}
$template->param(itemtypeloop => \@itemtypesloop);

=head3 in TEMPLATE

<form action='<!-- TMPL_VAR name="script_name" -->' method=post>
    <select name="itemtype">
        <option value="">Default</option>
    <!-- TMPL_LOOP name="itemtypeloop" -->
        <option value="<!-- TMPL_VAR name="value" -->" <!-- TMPL_IF name="selected" -->selected<!-- /TMPL_IF -->><!-- TMPL_VAR name="description" --></option>
    <!-- /TMPL_LOOP -->
    </select>
    <input type=text name=searchfield value="<!-- TMPL_VAR name="searchfield" -->">
    <input type="submit" value="OK" class="button">
</form>


=cut

sub GetItemTypes {

    # returns a reference to a hash of references to branches...
    my %itemtypes;
    my $dbh   = C4::Context->dbh;
    my $query = qq|
        SELECT *
        FROM   itemtypes
    |;
    my $sth = $dbh->prepare($query);
    $sth->execute;
    while ( my $IT = $sth->fetchrow_hashref ) {
        $itemtypes{ $IT->{'itemtype'} } = $IT;
    }
    return ( \%itemtypes );
}

sub get_itemtypeinfos_of {
    my @itemtypes = @_;

    my $query = '
SELECT itemtype,
       description,
       notforloan
  FROM itemtypes
  WHERE itemtype IN (' . join( ',', map( { "'" . $_ . "'" } @itemtypes ) ) . ')
';

    return get_infos_of( $query, 'itemtype' );
}

# this is temporary until we separate collection codes and item types
sub GetCcodes {
    my $count = 0;
    my @results;
    my $dbh = C4::Context->dbh;
    my $sth =
      $dbh->prepare(
        "SELECT * FROM authorised_values ORDER BY authorised_value");
    $sth->execute;
    while ( my $data = $sth->fetchrow_hashref ) {
        if ( $data->{category} eq "CCODE" ) {
            $count++;
            $results[$count] = $data;

            #warn "data: $data";
        }
    }
    $sth->finish;
    return ( $count, @results );
}

=head2

grab itemlost authorized values

=cut

sub GetAuthItemlost {
    my $itemlost = shift;
    my $count    = 0;
    my @results;
    my $dbh = C4::Context->dbh;
    my $sth =
      $dbh->prepare(
        "SELECT * FROM authorised_values ORDER BY authorised_value");
    $sth->execute;
    while ( my $data = $sth->fetchrow_hashref ) {
        if ( $data->{category} eq "ITEMLOST" ) {
            $count++;
            if ( $itemlost eq $data->{'authorised_value'} ) {
                $data->{'selected'} = 1;
            }
            $results[$count] = $data;

            #warn "data: $data";
        }
    }
    $sth->finish;
    return ( $count, @results );
}

=head2 GetAuthItembinding

grab itemlost authorized values

=cut

sub GetAuthItembinding {
    my $itembinding = shift;
    my $count       = 0;
    my @results;
    my $dbh = C4::Context->dbh;
    my $sth =
      $dbh->prepare(
        "SELECT * FROM authorised_values ORDER BY authorised_value");
    $sth->execute;
    while ( my $data = $sth->fetchrow_hashref ) {
        if ( $data->{category} eq "BINDING" ) {
            $count++;
            if ( $itembinding eq $data->{'authorised_value'} ) {
                $data->{'selected'} = 1;
            }
            $results[$count] = $data;

            #warn "data: $data";
        }
    }
    $sth->finish;
    return ( $count, @results );
}

=head2 getauthtypes

  $authtypes = &getauthtypes();

Returns information about existing authtypes.

build a HTML select with the following code :

=head3 in PERL SCRIPT

my $authtypes = getauthtypes;
my @authtypesloop;
foreach my $thisauthtype (keys %$authtypes) {
    my $selected = 1 if $thisauthtype eq $authtype;
    my %row =(value => $thisauthtype,
                selected => $selected,
                authtypetext => $authtypes->{$thisauthtype}->{'authtypetext'},
            );
    push @authtypesloop, \%row;
}
$template->param(itemtypeloop => \@itemtypesloop);

=head3 in TEMPLATE

<form action='<!-- TMPL_VAR name="script_name" -->' method=post>
    <select name="authtype">
    <!-- TMPL_LOOP name="authtypeloop" -->
        <option value="<!-- TMPL_VAR name="value" -->" <!-- TMPL_IF name="selected" -->selected<!-- /TMPL_IF -->><!-- TMPL_VAR name="authtypetext" --></option>
    <!-- /TMPL_LOOP -->
    </select>
    <input type=text name=searchfield value="<!-- TMPL_VAR name="searchfield" -->">
    <input type="submit" value="OK" class="button">
</form>


=cut

sub getauthtypes {

    # returns a reference to a hash of references to authtypes...
    my %authtypes;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("select * from auth_types order by authtypetext");
    $sth->execute;
    while ( my $IT = $sth->fetchrow_hashref ) {
        $authtypes{ $IT->{'authtypecode'} } = $IT;
    }
    return ( \%authtypes );
}

sub getauthtype {
    my ($authtypecode) = @_;

    # returns a reference to a hash of references to authtypes...
    my %authtypes;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("select * from auth_types where authtypecode=?");
    $sth->execute($authtypecode);
    my $res = $sth->fetchrow_hashref;
    return $res;
}

=head2 getframework

  $frameworks = &getframework();

Returns information about existing frameworks

build a HTML select with the following code :

=head3 in PERL SCRIPT

my $frameworks = frameworks();
my @frameworkloop;
foreach my $thisframework (keys %$frameworks) {
    my $selected = 1 if $thisframework eq $frameworkcode;
    my %row =(value => $thisframework,
                selected => $selected,
                description => $frameworks->{$thisframework}->{'frameworktext'},
            );
    push @frameworksloop, \%row;
}
$template->param(frameworkloop => \@frameworksloop);

=head3 in TEMPLATE

<form action='<!-- TMPL_VAR name="script_name" -->' method=post>
    <select name="frameworkcode">
        <option value="">Default</option>
    <!-- TMPL_LOOP name="frameworkloop" -->
        <option value="<!-- TMPL_VAR name="value" -->" <!-- TMPL_IF name="selected" -->selected<!-- /TMPL_IF -->><!-- TMPL_VAR name="frameworktext" --></option>
    <!-- /TMPL_LOOP -->
    </select>
    <input type=text name=searchfield value="<!-- TMPL_VAR name="searchfield" -->">
    <input type="submit" value="OK" class="button">
</form>


=cut

sub getframeworks {

    # returns a reference to a hash of references to branches...
    my %itemtypes;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("select * from biblio_framework");
    $sth->execute;
    while ( my $IT = $sth->fetchrow_hashref ) {
        $itemtypes{ $IT->{'frameworkcode'} } = $IT;
    }
    return ( \%itemtypes );
}

=head2 getframeworkinfo

  $frameworkinfo = &getframeworkinfo($frameworkcode);

Returns information about an frameworkcode.

=cut

sub getframeworkinfo {
    my ($frameworkcode) = @_;
    my $dbh             = C4::Context->dbh;
    my $sth             =
      $dbh->prepare("select * from biblio_framework where frameworkcode=?");
    $sth->execute($frameworkcode);
    my $res = $sth->fetchrow_hashref;
    return $res;
}

=head2 getitemtypeinfo

  $itemtype = &getitemtype($itemtype);

Returns information about an itemtype.

=cut

sub getitemtypeinfo {
    my ($itemtype) = @_;
    my $dbh        = C4::Context->dbh;
    my $sth        = $dbh->prepare("select * from itemtypes where itemtype=?");
    $sth->execute($itemtype);
    my $res = $sth->fetchrow_hashref;

    $res->{imageurl} = getitemtypeimagesrcfromurl( $res->{imageurl} );

    return $res;
}

sub getitemtypeimagesrcfromurl {
    my ($imageurl) = @_;

    if ( defined $imageurl and $imageurl !~ m/^http/ ) {
        $imageurl = getitemtypeimagesrc() . '/' . $imageurl;
    }

    return $imageurl;
}

sub getitemtypeimagedir {
    return C4::Context->opachtdocs . '/'
      . C4::Context->preference('template')
      . '/itemtypeimg';
}

sub getitemtypeimagesrc {
    return '/opac-tmpl' . '/'
      . C4::Context->preference('template')
      . '/itemtypeimg';
}

=head2 GetPrinters

  $printers = &GetPrinters($env);
  @queues = keys %$printers;

Returns information about existing printer queues.

C<$env> is ignored.

C<$printers> is a reference-to-hash whose keys are the print queues
defined in the printers table of the Koha database. The values are
references-to-hash, whose keys are the fields in the printers table.

=cut

sub GetPrinters {
    my ($env) = @_;
    my %printers;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("select * from printers");
    $sth->execute;
    while ( my $printer = $sth->fetchrow_hashref ) {
        $printers{ $printer->{'printqueue'} } = $printer;
    }
    return ( \%printers );
}

=head2 GetPrinter

$printer = GetPrinter( $query, $printers );

=cut

sub GetPrinter ($$) {
    my ( $query, $printers ) = @_;    # get printer for this query from printers
    my $printer = $query->param('printer');
    my %cookie = $query->cookie('userenv');
    ($printer) || ( $printer = $cookie{'printer'} ) || ( $printer = '' );
    ( $printers->{$printer} ) || ( $printer = ( keys %$printers )[0] );
    return $printer;
}

=item getnbpages

Returns the number of pages to display in a pagination bar, given the number
of items and the number of items per page.

=cut

sub getnbpages {
    my ( $nb_items, $nb_items_per_page ) = @_;

    return int( ( $nb_items - 1 ) / $nb_items_per_page ) + 1;
}

=item getallthemes

  (@themes) = &getallthemes('opac');
  (@themes) = &getallthemes('intranet');

Returns an array of all available themes.

=cut

sub getallthemes {
    my $type = shift;
    my $htdocs;
    my @themes;
    if ( $type eq 'intranet' ) {
        $htdocs = C4::Context->config('intrahtdocs');
    }
    else {
        $htdocs = C4::Context->config('opachtdocs');
    }
    opendir D, "$htdocs";
    my @dirlist = readdir D;
    foreach my $directory (@dirlist) {
        -d "$htdocs/$directory/en" and push @themes, $directory;
    }
    return @themes;
}

sub getFacets {
    my $facets;
    if ( C4::Context->preference("marcflavour") eq "UNIMARC" ) {
        $facets = [
            {
                link_value  => 'su-to',
                label_value => 'Topics',
                tags        =>
                  [ '600', '601', '602', '603', '604', '605', '606', '610' ],
                subfield => 'a',
            },
            {
                link_value  => 'su-geo',
                label_value => 'Places',
                tags        => ['651'],
                subfield    => 'a',
            },
            {
                link_value  => 'su-ut',
                label_value => 'Titles',
                tags        => [ '500', '501', '502', '503', '504', ],
                subfield    => 'a',
            },
            {
                link_value  => 'au',
                label_value => 'Authors',
                tags        => [ '700', '701', '702', ],
                subfield    => 'a',
            },
            {
                link_value  => 'se',
                label_value => 'Series',
                tags        => ['225'],
                subfield    => 'a',
            },
            {
                link_value  => 'branch',
                label_value => 'Branches',
                tags        => [ '995', ],
                subfield    => 'b',
                expanded    => '1',
            },
        ];
    }
    else {
        $facets = [
            {
                link_value  => 'su-to',
                label_value => 'Topics',
                tags        => ['650'],
                subfield    => 'a',
            },

            #        {
            #        link_value => 'su-na',
            #        label_value => 'People and Organizations',
            #        tags => ['600', '610', '611'],
            #        subfield => 'a',
            #        },
            {
                link_value  => 'su-geo',
                label_value => 'Places',
                tags        => ['651'],
                subfield    => 'a',
            },
            {
                link_value  => 'su-ut',
                label_value => 'Titles',
                tags        => ['630'],
                subfield    => 'a',
            },
            {
                link_value  => 'au',
                label_value => 'Authors',
                tags        => [ '100', '110', '700', ],
                subfield    => 'a',
            },
            {
                link_value  => 'se',
                label_value => 'Series',
                tags        => [ '440', '490', ],
                subfield    => 'a',
            },
            {
                link_value  => 'branch',
                label_value => 'Branches',
                tags        => [ '952', ],
                subfield    => 'b',
                expanded    => '1',
            },
        ];
    }
    return $facets;
}

=head2 get_infos_of

Return a href where a key is associated to a href. You give a query, the
name of the key among the fields returned by the query. If you also give as
third argument the name of the value, the function returns a href of scalar.

  my $query = '
SELECT itemnumber,
       notforloan,
       barcode
  FROM items
';

  # generic href of any information on the item, href of href.
  my $iteminfos_of = get_infos_of($query, 'itemnumber');
  print $iteminfos_of->{$itemnumber}{barcode};

  # specific information, href of scalar
  my $barcode_of_item = get_infos_of($query, 'itemnumber', 'barcode');
  print $barcode_of_item->{$itemnumber};

=cut

sub get_infos_of {
    my ( $query, $key_name, $value_name ) = @_;

    my $dbh = C4::Context->dbh;

    my $sth = $dbh->prepare($query);
    $sth->execute();

    my %infos_of;
    while ( my $row = $sth->fetchrow_hashref ) {
        if ( defined $value_name ) {
            $infos_of{ $row->{$key_name} } = $row->{$value_name};
        }
        else {
            $infos_of{ $row->{$key_name} } = $row;
        }
    }
    $sth->finish;

    return \%infos_of;
}

=head2 get_notforloan_label_of

  my $notforloan_label_of = get_notforloan_label_of();

Each authorised value of notforloan (information available in items and
itemtypes) is link to a single label.

Returns a href where keys are authorised values and values are corresponding
labels.

  foreach my $authorised_value (keys %{$notforloan_label_of}) {
    printf(
        "authorised_value: %s => %s\n",
        $authorised_value,
        $notforloan_label_of->{$authorised_value}
    );
  }

=cut

sub get_notforloan_label_of {
    my $dbh = C4::Context->dbh;

    my $query = '
SELECT authorised_value
  FROM marc_subfield_structure
  WHERE kohafield = \'items.notforloan\'
  LIMIT 0, 1
';
    my $sth = $dbh->prepare($query);
    $sth->execute();
    my ($statuscode) = $sth->fetchrow_array();

    $query = '
SELECT lib,
       authorised_value
  FROM authorised_values
  WHERE category = ?
';
    $sth = $dbh->prepare($query);
    $sth->execute($statuscode);
    my %notforloan_label_of;
    while ( my $row = $sth->fetchrow_hashref ) {
        $notforloan_label_of{ $row->{authorised_value} } = $row->{lib};
    }
    $sth->finish;

    return \%notforloan_label_of;
}

sub displaySortby {
    my ($sort_by) = @_;
    $sort_by =~ s/</\&lt;/;
    $sort_by =~ s/>/\&gt;/;
    my $sort_by_loop = [
        { value => "1=9523 &gt;i", label => "Popularity (Most to Least)" },
        { value => "1=9523 &lt;i", label => "Popularity (Least to Most)" },
        { value => "1=1003 &lt;i", label => "Author (A-Z)" },
        { value => "1=1003 &gt;i", label => "Author (Z-A)" },
        {
            value => "1=20 &lt;i",
            label => "Call Number (Non-fiction 0-9 to Fiction A-Z)"
        },
        {
            value => "1=20 &gt;i",
            label => "Call Number (Fiction Z-A to Non-fiction 9-0)"
        },
        { value => "1=31 &gt;i", label => "Dates" },
        {
            value => "1=31 &gt;i",
            label =>
              "&nbsp;&nbsp;&nbsp;Publication/Copyright Date: Newest to Oldest"
        },
        {
            value => "1=31 &lt;i",
            label =>
              "&nbsp;&nbsp;&nbsp;Publication/Copyright Date: Oldest to Newest"
        },
        {
            value => "1=32 &gt;i",
            label => "&nbsp;&nbsp;&nbsp;Acquisition Date: Newest to Oldest"
        },
        {
            value => "1=32 &lt;i",
            label => "&nbsp;&nbsp;&nbsp;Acquisition Date: Oldest to Newest"
        },
        { value => "1=36 &lt;i", label => "Title (A-Z)" },
        { value => "1=36 &gt;i", label => "Title (Z-A)" },
    ];
    for my $hash (@$sort_by_loop) {

        #warn "sort by: $sort_by ... hash:".$hash->{value};
        if ($sort_by && $hash->{value} eq $sort_by ) {
            $hash->{selected} = "selected";
        }
    }
    return $sort_by_loop;

}

sub displayIndexes {
    my $indexes = [
        { value => '',   label => 'Keyword' },
        { value => 'au', label => 'Author' },
        {
            value => 'au,phr',
            label => '&nbsp;&nbsp;&nbsp;&nbsp; Author Phrase'
        },
        { value => 'cpn', label => '&nbsp;&nbsp;&nbsp;&nbsp; Corporate Name' },
        { value => 'cfn', label => '&nbsp;&nbsp;&nbsp;&nbsp; Conference Name' },
        {
            value => 'cpn,phr',
            label => '&nbsp;&nbsp;&nbsp;&nbsp; Corporate Name Phrase'
        },
        {
            value => 'cfn,phr',
            label => '&nbsp;&nbsp;&nbsp;&nbsp; Conference Name Phrase'
        },
        { value => 'pn', label => '&nbsp;&nbsp;&nbsp;&nbsp; Personal Name' },
        {
            value => 'pn,phr',
            label => '&nbsp;&nbsp;&nbsp;&nbsp; Personal Name Phrase'
        },
        { value => 'ln', label => 'Language' },

        #    { value => 'mt', label => 'Material Type' },
        #    { value => 'mt,phr', label => 'Material Type Phrase' },
        #    { value => 'mc', label => 'Musical Composition' },
        #    { value => 'mc,phr', label => 'Musical Composition Phrase' },

        { value => 'nt',  label => 'Notes/Comments' },
        { value => 'pb',  label => 'Publisher' },
        { value => 'pl',  label => 'Publisher Location' },
        { value => 'sn',  label => 'Standard Number' },
        { value => 'nb',  label => '&nbsp;&nbsp;&nbsp;&nbsp; ISBN' },
        { value => 'ns',  label => '&nbsp;&nbsp;&nbsp;&nbsp; ISSN' },
        { value => 'lcn', label => '&nbsp;&nbsp;&nbsp;&nbsp; Call Number' },
        { value => 'su',  label => 'Subject' },
        {
            value => 'su,phr',
            label => '&nbsp;&nbsp;&nbsp;&nbsp; Subject Phrase'
        },

#    { value => 'de', label => '&nbsp;&nbsp;&nbsp;&nbsp; Descriptor' },
#    { value => 'ge', label => '&nbsp;&nbsp;&nbsp;&nbsp; Genre/Form' },
#    { value => 'gc', label => '&nbsp;&nbsp;&nbsp;&nbsp; Geographic Coverage' },

#     { value => 'nc', label => '&nbsp;&nbsp;&nbsp;&nbsp; Named Corporation and Conference' },
#     { value => 'na', label => '&nbsp;&nbsp;&nbsp;&nbsp; Named Person' },

        { value => 'ti',     label => 'Title' },
        { value => 'ti,phr', label => '&nbsp;&nbsp;&nbsp;&nbsp; Title Phrase' },
        { value => 'se',     label => '&nbsp;&nbsp;&nbsp;&nbsp; Series Title' },
    ];
    return $indexes;
}

sub displaySubtypesLimit {
    my $outer_subtype_limits_loop = [

        {    # in MARC21, aud codes are stored in 008/22 (Target audience)
            name                      => "limit",
            inner_subtype_limits_loop => [
                {
                    value    => '',
                    label    => 'Any Audience',
                    selected => "selected"
                },
                { value => 'aud:a', label => 'Easy', },
                { value => 'aud:c', label => 'Juvenile', },
                { value => 'aud:d', label => 'Young Adult', },
                { value => 'aud:e', label => 'Adult', },

            ],
        },
        {    # in MARC21, fic is in 008/33, bio in 008/34, mus in LDR/06
            name                      => "limit",
            inner_subtype_limits_loop => [
                { value => '', label => 'Any Content', selected => "selected" },
                { value => 'fic:1', label => 'Fiction', },
                { value => 'fic:0', label => 'Non Fiction', },
                { value => 'bio:b', label => 'Biography', },
                { value => 'mus:j', label => 'Musical recording', },
                { value => 'mus:i', label => 'Non-musical recording', },

            ],
        },
        {    # MARC21, these are codes stored in 007/00-01
            name                      => "limit",
            inner_subtype_limits_loop => [
                { value => '', label => 'Any Format', selected => "selected" },
                { value => 'l-format:ta', label => 'Regular print', },
                { value => 'l-format:tb', label => 'Large print', },
                { value => 'l-format:fk', label => 'Braille', },
                { value => '',            label => '-----------', },
                { value => 'l-format:sd', label => 'CD audio', },
                { value => 'l-format:ss', label => 'Cassette recording', },
                {
                    value => 'l-format:vf',
                    label => 'VHS tape / Videocassette',
                },
                { value => 'l-format:vd', label => 'DVD video / Videodisc', },
                { value => 'l-format:co', label => 'CD Software', },
                { value => 'l-format:cr', label => 'Website', },

            ],
        },
        {    # in MARC21, these are codes in 008/24-28
            name                      => "limit",
            inner_subtype_limits_loop => [
                { value => '',        label => 'Additional Content Types', },
                { value => 'ctype:a', label => 'Abstracts/summaries', },
                { value => 'ctype:b', label => 'Bibliographies', },
                { value => 'ctype:c', label => 'Catalogs', },
                { value => 'ctype:d', label => 'Dictionaries', },
                { value => 'ctype:e', label => 'Encyclopedias ', },
                { value => 'ctype:f', label => 'Handbooks', },
                { value => 'ctype:g', label => 'Legal articles', },
                { value => 'ctype:i', label => 'Indexes', },
                { value => 'ctype:j', label => 'Patent document', },
                { value => 'ctype:k', label => 'Discographies', },
                { value => 'ctype:l', label => 'Legislation', },
                { value => 'ctype:m', label => 'Theses', },
                { value => 'ctype:n', label => 'Surveys', },
                { value => 'ctype:o', label => 'Reviews', },
                { value => 'ctype:p', label => 'Programmed texts', },
                { value => 'ctype:q', label => 'Filmographies', },
                { value => 'ctype:r', label => 'Directories', },
                { value => 'ctype:s', label => 'Statistics', },
                { value => 'ctype:t', label => 'Technical reports', },
                { value => 'ctype:v', label => 'Legal cases and case notes', },
                { value => 'ctype:w', label => 'Law reports and digests', },
                { value => 'ctype:z', label => 'Treaties ', },
            ],
        },
    ];
    return $outer_subtype_limits_loop;
}

sub displayLimitTypes {
    my $outer_limit_types_loop = [

        {
            inner_limit_types_loop => [
                {
                    label => "Books",
                    id    => "mc-books",
                    name  => "limit",
                    value => "(mc-collection:AF or mc-collection:MYS or mc-collection:SCI or mc-collection:NF or mc-collection:YA or mc-collection:BIO or mc-collection:LP or mc-collection:LPNF)",
                    icon  => "search-books.gif",
                    title =>
"Books, Pamphlets, Technical reports, Manuscripts, Legal papers, Theses and dissertations",
                },

                {
                    label => "Movies",
                    id    => "mc-movies",
                    name  => "limit",
                    value => "(mc-collection:DVD or mc-collection:AV or mc-collection:AVJ or mc-collection:AVJN or mc-collection:AVJNF or mc-collection:AVNF)",
                    icon  => "search-movies.gif",
                    title =>
"Motion pictures, Videorecordings, Filmstrips, Slides, Transparencies, Photos, Cards, Charts, Drawings",
                },

                {
					label => "Music",
    				id => "mc-music",
                    name  => "limit",
                    value => "(mc-collection:CDM)",
                    icon  => "search-music.gif",
                    title => "Spoken, Books on CD and Cassette",
                },
            ],
        },
        {
            inner_limit_types_loop => [
                {
                    label => "Audio Books",
					id => "mc-audio-books",
                    name  => "limit",
                    value => "(mc-collection:AB or mc-collection:AC or mc-collection:JAC or mc-collection:YAC)",
                    icon  => "search-audio-books.gif",
                    title => "Spoken, Books on CD and Cassette",
                },

                {
                    label => "Local History Materials",
    				id => "mc-local-history",
                    name  => "limit",
                    value => "mc-collection:LH",
                    icon  => "Local history.gif",
                    title => "Local History Materials",
                },

    {label => "Large Print",
    id => "mc-large-print",
                    name  => "limit",
    value => "(mc-collection:LP or mc-collection:LPNF)",
    icon => "search-large-print.gif ",
    title => "Large Print",},
            ],
        },
{ inner_limit_types_loop => [
    {label => "Kids",
    id => "mc-kids",
                    name  => "limit",
    value => "(mc-collection:EASY or mc-collection:JNF or mc-collection:JF or mc-collection:JREF or mc-collection:JB)",
    icon => "search-kids.gif",
    title => "Music",},

    {label => "Software/Internet",
    id => "mc-sofware-web",
                    name  => "limit",
    value => "(mc-collection:CDR)",
    icon => "search-software-web.gif",
    title => "Kits",},

    {label => "Reference",
    id => "mc-reference",
                    name  => "limit",
                    value => "mc-collection:REF",
    icon => "search-reference.gif",
    title => "Reference",},

            ],
        },

    ];
    return $outer_limit_types_loop;
}

sub displayServers {
    my ( $position, $type ) = @_;
    my $dbh    = C4::Context->dbh;
    my $strsth = "SELECT * FROM z3950servers where 1";
    $strsth .= " AND position=\"$position\"" if ($position);
    $strsth .= " AND type=\"$type\""         if ($type);
    my $rq = $dbh->prepare($strsth);
    $rq->execute;
    my @primaryserverloop;

    while ( my $data = $rq->fetchrow_hashref ) {
        my %cell;
        $cell{label} = $data->{'description'};
        $cell{id}    = $data->{'name'};
        $cell{value} =
            $data->{host}
          . ( $data->{port} ? ":" . $data->{port} : "" ) . "/"
          . $data->{database}
          if ( $data->{host} );
        $cell{checked} = $data->{checked};
        push @primaryserverloop,
          {
            label => $data->{description},
            id    => $data->{name},
            name  => "server",
            value => $data->{host} . ":"
              . $data->{port} . "/"
              . $data->{database},
            checked    => "checked",
            icon       => $data->{icon},
            zed        => $data->{type} eq 'zed',
            opensearch => $data->{type} eq 'opensearch'
          };
    }
    return \@primaryserverloop;
}

sub displaySecondaryServers {

# 	my $secondary_servers_loop = [
# 		{ inner_sup_servers_loop => [
#         	{label => "Google", id=>"GOOG", value=>"google",icon => "google.ico",opensearch => "1"},
#         	{label => "Yahoo", id=>"YAH", value=>"yahoo", icon =>"yahoo.ico", zed => "1"},
#         	{label => "Worldcat", id=>"WCT", value=>"worldcat", icon => "worldcat.gif", zed => "1"},
#         	{label => "Library of Congress", id=>"LOC", name=> "server", value=>"z3950.loc.gov:7090/Voyager", icon =>"loc.ico", zed => "1"},
#     	],
#     	},
# 	];
    return;    #$secondary_servers_loop;
}

=head2 GetAuthorisedValues

$authvalues = GetAuthorisedValues($category);

this function get all authorised values from 'authosied_value' table into a reference to array which
each value containt an hashref.

Set C<$category> on input args if you want to limits your query to this one. This params is not mandatory.

=cut

sub GetAuthorisedValues {
    my $category = shift;
    my $dbh      = C4::Context->dbh;
    my $query    = "SELECT * FROM authorised_values";
    $query .= " WHERE category = '" . $category . "'" if $category;

    my $sth = $dbh->prepare($query);
    $sth->execute;
    my $data = $sth->fetchall_arrayref({});
    return $data;
}

=item fixEncoding

  $marcrecord = &fixEncoding($marcblob);

Returns a well encoded marcrecord.

=cut
sub FixEncoding {
  my $marc=shift;
  my $record = MARC::Record->new_from_usmarc($marc);
  if (C4::Context->preference("MARCFLAVOUR") eq "UNIMARC"){
    use Encode::Guess;
    my $targetcharset="utf8" if (C4::Context->preference("TemplateEncoding") eq "utf-8");
    $targetcharset="latin1" if (C4::Context->preference("TemplateEncoding") eq "iso-8859-1");
    my $decoder = guess_encoding($marc, qw/utf8 latin1/);
#     die $decoder unless ref($decoder);
    if (ref($decoder)) {
        my $newRecord=MARC::Record->new();
        foreach my $field ($record->fields()){
        if ($field->tag()<'010'){
            $newRecord->insert_grouped_field($field);
        } else {
            my $newField;
            my $createdfield=0;
            foreach my $subfield ($field->subfields()){
            if ($createdfield){
                if (($newField->tag eq '100')) {
                substr($subfield->[1],26,2,"0103") if ($targetcharset eq "latin1");
                substr($subfield->[1],26,4,"5050") if ($targetcharset eq "utf8");
                }
                map {C4::Biblio::char_decode($_,"UNIMARC")} @$subfield;
                $newField->add_subfields($subfield->[0]=>$subfield->[1]);
            } else {
                map {C4::Biblio::char_decode($_,"UNIMARC")} @$subfield;
                $newField=MARC::Field->new($field->tag(),$field->indicator(1),$field->indicator(2),$subfield->[0]=>$subfield->[1]);
                $createdfield=1;
            }
            }
            $newRecord->insert_grouped_field($newField);
        }
        }
    #     warn $newRecord->as_formatted(); 
        return $newRecord;
    } else {
        return $record;
    }
  } else {
    return $record;
  }
}

=head2 GetKohaAuthorisedValues
	
	Takes $dbh , $kohafield as parameters.
	returns hashref of authvalCode => liblibrarian
	or undef if no authvals defined for kohafield.

=cut

sub GetKohaAuthorisedValues {
  my ($kohafield) = @_;
  my %values;
  my $dbh = C4::Context->dbh;
  my $sthnflstatus = $dbh->prepare('select authorised_value from marc_subfield_structure where kohafield=?');
  $sthnflstatus->execute($kohafield);
  my $authorised_valuecode = $sthnflstatus->fetchrow;
  if ($authorised_valuecode) {  
    $sthnflstatus = $dbh->prepare("select authorised_value, lib from authorised_values where category=? ");
    $sthnflstatus->execute($authorised_valuecode);
    while ( my ($val, $lib) = $sthnflstatus->fetchrow_array ) { 
      $values{$val}= $lib;
    }
  }
  return \%values;
}


1;

__END__

=back

=head1 AUTHOR

Koha Team

=cut
