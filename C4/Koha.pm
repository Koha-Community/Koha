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


use strict;
use C4::Context;
use C4::Output;
use vars qw($VERSION @ISA @EXPORT $DEBUG);

BEGIN {
	$VERSION = 3.01;
	require Exporter;
	@ISA    = qw(Exporter);
	@EXPORT = qw(
		&slashifyDate
		&DisplayISBN
		&subfield_is_koha_internal_p
		&GetPrinters &GetPrinter
		&GetItemTypes &getitemtypeinfo
		&GetCcodes
		&get_itemtypeinfos_of
		&getframeworks &getframeworkinfo
		&getauthtypes &getauthtype
		&getallthemes
		&getFacets
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
		&GetAuthValCode
		&GetManagedTagSubfields

		$DEBUG
	);
	$DEBUG = 0;
}

=head1 NAME

    C4::Koha - Perl Module containing convenience functions for Koha scripts

=head1 SYNOPSIS

  use C4::Koha;


=head1 DESCRIPTION

    Koha.pm provides many functions for Koha scripts.

=head1 FUNCTIONS

=over 2

=cut
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
    if (length ($isbn)<13){
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

        # if(sTmp2 < 10) sTmp2 = "0" sTmp2;
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
    } else {
      my $seg1;
      $seg1 = substr( $isbn, 0, 3 );
      my $seg2;
      if ( substr( $isbn, 3, 1 ) <= 7 ) {
          $seg2 = substr( $isbn, 3, 1 );
      }
      elsif ( substr( $isbn, 3, 2 ) <= 94 ) {
          $seg2 = substr( $isbn, 3, 2 );
      }
      elsif ( substr( $isbn, 3, 3 ) <= 995 ) {
          $seg2 = substr( $isbn, 3, 3 );
      }
      elsif ( substr( $isbn, 3, 4 ) <= 9989 ) {
          $seg2 = substr( $isbn, 3, 4 );
      }
      else {
          $seg2 = substr( $isbn, 3, 5 );
      }
      my $x = substr( $isbn, length($seg2) +3);
      my $seg3;
      if ( substr( $x, 0, 2 ) <= 19 ) {
  
          # if(sTmp2 < 10) sTmp2 = "0" sTmp2;
          $seg3 = substr( $x, 0, 2 );
      }
      elsif ( substr( $x, 0, 3 ) <= 699 ) {
          $seg3 = substr( $x, 0, 3 );
      }
      elsif ( substr( $x, 0, 4 ) <= 8399 ) {
          $seg3 = substr( $x, 0, 4 );
      }
      elsif ( substr( $x, 0, 5 ) <= 89999 ) {
          $seg3 = substr( $x, 0, 5 );
      }
      elsif ( substr( $x, 0, 6 ) <= 9499999 ) {
          $seg3 = substr( $x, 0, 6 );
      }
      else {
          $seg3 = substr( $x, 0, 7 );
      }
      my $seg4 = substr( $x, length($seg3) );
      $seg4 = substr( $seg4, 0, length($seg4) - 1 );
      my $seg5 = substr( $x, -1, 1 );
      return "$seg1-$seg2-$seg3-$seg4-$seg5";       
    }    
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
       imageurl,
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
	my $src = shift;
	if ($src eq 'intranet') {
		return C4::Context->config('intrahtdocs') . '/' .C4::Context->preference('template') . '/img/itemtypeimg';
	}
	else {
		return C4::Context->config('opachtdocs') . '/' . C4::Context->preference('template') . '/itemtypeimg';
	}
}

sub getitemtypeimagesrc {
	 my $src = shift;
	if ($src eq 'intranet') {
		return '/intranet-tmpl' . '/' .	C4::Context->preference('template') . '/img/itemtypeimg';
	} 
	else {
		return '/opac-tmpl' . '/' . C4::Context->preference('template') . '/itemtypeimg';
	}
}

=head2 GetPrinters

  $printers = &GetPrinters();
  @queues = keys %$printers;

Returns information about existing printer queues.

C<$printers> is a reference-to-hash whose keys are the print queues
defined in the printers table of the Koha database. The values are
references-to-hash, whose keys are the fields in the printers table.

=cut

sub GetPrinters {
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
                label_value => 'Libraries',
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
                label_value => 'Libraries',
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

# FIXME - why not use GetAuthorisedValues ??
#
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
            encoding   => ($data->{encoding}?$data->{encoding}:"iso-5426"),
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

=head2 GetAuthValCode

$authvalcode = GetAuthValCode($kohafield,$frameworkcode);

=cut

sub GetAuthValCode {
	my ($kohafield,$fwcode) = @_;
	my $dbh = C4::Context->dbh;
	$fwcode='' unless $fwcode;
	my $sth = $dbh->prepare('select authorised_value from marc_subfield_structure where kohafield=? and frameworkcode=?');
	$sth->execute($kohafield,$fwcode);
	my ($authvalcode) = $sth->fetchrow_array;
	return $authvalcode;
}

=head2 GetAuthorisedValues

$authvalues = GetAuthorisedValues($category);

this function get all authorised values from 'authosied_value' table into a reference to array which
each value containt an hashref.

Set C<$category> on input args if you want to limits your query to this one. This params is not mandatory.

=cut

sub GetAuthorisedValues {
    my ($category,$selected) = @_;
	my $count = 0;
	my @results;
    my $dbh      = C4::Context->dbh;
    my $query    = "SELECT * FROM authorised_values";
    $query .= " WHERE category = '" . $category . "'" if $category;

    my $sth = $dbh->prepare($query);
    $sth->execute;
	while (my $data=$sth->fetchrow_hashref) {
		if ($selected eq $data->{'authorised_value'} ) {
			$data->{'selected'} = 1;
		}
		$results[$count] = $data;
		$count++;
	}
    #my $data = $sth->fetchall_arrayref({});
    return \@results; #$data;
}

=head2 GetKohaAuthorisedValues
	
	Takes $dbh , $kohafield as parameters.
	returns hashref of authvalCode => liblibrarian
	or undef if no authvals defined for kohafield.

=cut

sub GetKohaAuthorisedValues {
  my ($kohafield,$fwcode) = @_;
  $fwcode='' unless $fwcode;
  my %values;
  my $dbh = C4::Context->dbh;
  my $avcode = GetAuthValCode($kohafield,$fwcode);
  if ($avcode) {  
    my $sth = $dbh->prepare("select authorised_value, lib from authorised_values where category=? ");
    $sth->execute($avcode);
	while ( my ($val, $lib) = $sth->fetchrow_array ) { 
   		$values{$val}= $lib;
   	}
  }
  return \%values;
}

=head2 GetManagedTagSubfields

=over 4

$res = GetManagedTagSubfields();

=back

Returns a reference to a big hash of hash, with the Marc structure fro the given frameworkcode

NOTE: This function is used only by the (incomplete) bulk editing feature.  Since
that feature currently does not deal with items and biblioitems changes 
correctly, those tags are specifically excluded from the list prepared
by this function.

For future reference, if a bulk item editing feature is implemented at some point, it
needs some design thought -- for example, circulation status fields should not 
be changed willy-nilly.

=cut

sub GetManagedTagSubfields{
  my $dbh=C4::Context->dbh;
  my $rq=$dbh->prepare(qq|
SELECT 
  DISTINCT CONCAT( marc_subfield_structure.tagfield, tagsubfield ) AS tagsubfield, 
  marc_subfield_structure.liblibrarian as subfielddesc, 
  marc_tag_structure.liblibrarian as tagdesc
FROM marc_subfield_structure
  LEFT JOIN marc_tag_structure 
    ON marc_tag_structure.tagfield = marc_subfield_structure.tagfield
    AND marc_tag_structure.frameworkcode = marc_subfield_structure.frameworkcode
WHERE marc_subfield_structure.tab>=0
AND marc_tag_structure.tagfield NOT IN (SELECT tagfield FROM marc_subfield_structure WHERE kohafield like 'items.%')
AND marc_tag_structure.tagfield NOT IN (SELECT tagfield FROM marc_subfield_structure WHERE kohafield = 'biblioitems.itemtype')
AND marc_subfield_structure.kohafield <> 'biblio.biblionumber'
AND marc_subfield_structure.kohafield <>  'biblioitems.biblioitemnumber'
ORDER BY marc_subfield_structure.tagfield, tagsubfield|);
  $rq->execute;
  my $data=$rq->fetchall_arrayref({});
  return $data;
}


=item fixEncoding

  $marcrecord = &fixEncoding($marcblob);

Returns a well encoded marcrecord.

=cut
sub FixEncoding {
  my $marc=shift;
  my $encoding=shift;
  my $record = MARC::Record->new_from_usmarc($marc);
#   if (C4::Context->preference("marcflavour") eq "UNIMARC"){
    my $targetcharset="utf8";
    if ($encoding  && $targetcharset ne $encoding){   
        my $newRecord=MARC::Record->new();
        if ($encoding!~/5426/){  
            use Text::Iconv;
            my $decoder = Text::Iconv->new($encoding,$targetcharset);
            my $newRecord=MARC::Record->new();
            foreach my $field ($record->fields()){
                if ($field->tag()<'010'){
                    $newRecord->insert_grouped_field($field);
                } else {
                    my $newField;
                    my $createdfield=0;
                    foreach my $subfield ($field->subfields()){
                    if ($createdfield){
                        if ((C4::Context->preference("marcflavour") eq "UNIMARC") && ($newField->tag eq '100')) {
                            substr($subfield->[1],26,4,"5050") if ($targetcharset eq "utf8");
                        } elsif (C4::Context->preference("marcflavour") eq "USMARC"){
                            $newRecord->encoding("UTF-8");                
                        }                
                        map {$decoder->convert($_)} @$subfield;
                        $newField->add_subfields($subfield->[0]=>$subfield->[1]);
                    } else {
                        map {$decoder->convert($_)} @$subfield;
                        $newField=MARC::Field->new($field->tag(),$field->indicator(1),$field->indicator(2),$subfield->[0]=>$subfield->[1]);
                        $createdfield=1;
                    }
                    }
                    $newRecord->insert_grouped_field($newField);
                }
            }        
        }elsif ($encoding=~/5426/){
            foreach my $field ($record->fields()){
                if ($field->tag()<'010'){
                    $newRecord->insert_grouped_field($field);
                } else {
                    my $newField;
                    my $createdfield=0;
                    foreach my $subfield ($field->subfields()){
#                     my $utf8=eval{MARC::Charset::marc8_to_utf8($subfield->[1])};
#                     if ($@) {warn "z3950 character conversion error $@ ";$utf8=$subfield->[1]};
                    my $utf8=char_decode5426($subfield->[1]);
                    if ((C4::Context->preference("marcflavour") eq "UNIMARC") && ($field->tag eq '100')) {
                        substr($utf8,26,4,"5050");
                    } elsif (C4::Context->preference("marcflavour") eq "USMARC"){
                        $newRecord->encoding("UTF-8");                
                    }                
                    if ($createdfield){
                        $newField->add_subfields($subfield->[0]=>$utf8);
                    } else {
                        $newField=MARC::Field->new($field->tag(),$field->indicator(1),$field->indicator(2),$subfield->[0]=>$utf8);
                        $createdfield=1;
                    }
                    }
                    $newRecord->insert_grouped_field($newField);
                }
            }        
        }
#         warn $newRecord->as_formatted(); 
        return $newRecord;            
     }
     return $record;  
#   }
#   return $record;
}


sub char_decode5426 {
    my ( $string) = @_;
    my $result;
my %chars;
$chars{0xb0}=0x0101;#3/0ayn[ain]
$chars{0xb1}=0x0623;#3/1alif/hamzah[alefwithhamzaabove]
#$chars{0xb2}=0x00e0;#'à';
$chars{0xb2}=0x00e0;#3/2leftlowsinglequotationmark
#$chars{0xb3}=0x00e7;#'ç';
$chars{0xb3}=0x00e7;#3/2leftlowsinglequotationmark
# $chars{0xb4}='è';
$chars{0xb4}=0x00e8;
# $chars{0xb5}='é';
$chars{0xb5}=0x00e9;
$chars{0x97}=0x003c;#3/2leftlowsinglequotationmark
$chars{0x98}=0x003e;#3/2leftlowsinglequotationmark
$chars{0xfa}=0x0153;#oe
$chars{0x81d1}=0x00b0;

####
## combined characters iso5426

$chars{0xc041}=0x1ea2; # capital a with hook above
$chars{0xc045}=0x1eba; # capital e with hook above
$chars{0xc049}=0x1ec8; # capital i with hook above
$chars{0xc04f}=0x1ece; # capital o with hook above
$chars{0xc055}=0x1ee6; # capital u with hook above
$chars{0xc059}=0x1ef6; # capital y with hook above
$chars{0xc061}=0x1ea3; # small a with hook above
$chars{0xc065}=0x1ebb; # small e with hook above
$chars{0xc069}=0x1ec9; # small i with hook above
$chars{0xc06f}=0x1ecf; # small o with hook above
$chars{0xc075}=0x1ee7; # small u with hook above
$chars{0xc079}=0x1ef7; # small y with hook above
    
        # 4/1 grave accent
$chars{0xc141}=0x00c0; # capital a with grave accent
$chars{0xc145}=0x00c8; # capital e with grave accent
$chars{0xc149}=0x00cc; # capital i with grave accent
$chars{0xc14f}=0x00d2; # capital o with grave accent
$chars{0xc155}=0x00d9; # capital u with grave accent
$chars{0xc157}=0x1e80; # capital w with grave
$chars{0xc159}=0x1ef2; # capital y with grave
$chars{0xc161}=0x00e0; # small a with grave accent
$chars{0xc165}=0x00e8; # small e with grave accent
$chars{0xc169}=0x00ec; # small i with grave accent
$chars{0xc16f}=0x00f2; # small o with grave accent
$chars{0xc175}=0x00f9; # small u with grave accent
$chars{0xc177}=0x1e81; # small w with grave
$chars{0xc179}=0x1ef3; # small y with grave
        # 4/2 acute accent
$chars{0xc241}=0x00c1; # capital a with acute accent
$chars{0xc243}=0x0106; # capital c with acute accent
$chars{0xc245}=0x00c9; # capital e with acute accent
$chars{0xc247}=0x01f4; # capital g with acute
$chars{0xc249}=0x00cd; # capital i with acute accent
$chars{0xc24b}=0x1e30; # capital k with acute
$chars{0xc24c}=0x0139; # capital l with acute accent
$chars{0xc24d}=0x1e3e; # capital m with acute
$chars{0xc24e}=0x0143; # capital n with acute accent
$chars{0xc24f}=0x00d3; # capital o with acute accent
$chars{0xc250}=0x1e54; # capital p with acute
$chars{0xc252}=0x0154; # capital r with acute accent
$chars{0xc253}=0x015a; # capital s with acute accent
$chars{0xc255}=0x00da; # capital u with acute accent
$chars{0xc257}=0x1e82; # capital w with acute
$chars{0xc259}=0x00dd; # capital y with acute accent
$chars{0xc25a}=0x0179; # capital z with acute accent
$chars{0xc261}=0x00e1; # small a with acute accent
$chars{0xc263}=0x0107; # small c with acute accent
$chars{0xc265}=0x00e9; # small e with acute accent
$chars{0xc267}=0x01f5; # small g with acute
$chars{0xc269}=0x00ed; # small i with acute accent
$chars{0xc26b}=0x1e31; # small k with acute
$chars{0xc26c}=0x013a; # small l with acute accent
$chars{0xc26d}=0x1e3f; # small m with acute
$chars{0xc26e}=0x0144; # small n with acute accent
$chars{0xc26f}=0x00f3; # small o with acute accent
$chars{0xc270}=0x1e55; # small p with acute
$chars{0xc272}=0x0155; # small r with acute accent
$chars{0xc273}=0x015b; # small s with acute accent
$chars{0xc275}=0x00fa; # small u with acute accent
$chars{0xc277}=0x1e83; # small w with acute
$chars{0xc279}=0x00fd; # small y with acute accent
$chars{0xc27a}=0x017a; # small z with acute accent
$chars{0xc2e1}=0x01fc; # capital ae with acute
$chars{0xc2f1}=0x01fd; # small ae with acute
       # 4/3 circumflex accent
$chars{0xc341}=0x00c2; # capital a with circumflex accent
$chars{0xc343}=0x0108; # capital c with circumflex
$chars{0xc345}=0x00ca; # capital e with circumflex accent
$chars{0xc347}=0x011c; # capital g with circumflex
$chars{0xc348}=0x0124; # capital h with circumflex
$chars{0xc349}=0x00ce; # capital i with circumflex accent
$chars{0xc34a}=0x0134; # capital j with circumflex
$chars{0xc34f}=0x00d4; # capital o with circumflex accent
$chars{0xc353}=0x015c; # capital s with circumflex
$chars{0xc355}=0x00db; # capital u with circumflex
$chars{0xc357}=0x0174; # capital w with circumflex
$chars{0xc359}=0x0176; # capital y with circumflex
$chars{0xc35a}=0x1e90; # capital z with circumflex
$chars{0xc361}=0x00e2; # small a with circumflex accent
$chars{0xc363}=0x0109; # small c with circumflex
$chars{0xc365}=0x00ea; # small e with circumflex accent
$chars{0xc367}=0x011d; # small g with circumflex
$chars{0xc368}=0x0125; # small h with circumflex
$chars{0xc369}=0x00ee; # small i with circumflex accent
$chars{0xc36a}=0x0135; # small j with circumflex
$chars{0xc36e}=0x00f1; # small n with tilde
$chars{0xc36f}=0x00f4; # small o with circumflex accent
$chars{0xc373}=0x015d; # small s with circumflex
$chars{0xc375}=0x00fb; # small u with circumflex
$chars{0xc377}=0x0175; # small w with circumflex
$chars{0xc379}=0x0177; # small y with circumflex
$chars{0xc37a}=0x1e91; # small z with circumflex
        # 4/4 tilde
$chars{0xc441}=0x00c3; # capital a with tilde
$chars{0xc445}=0x1ebc; # capital e with tilde
$chars{0xc449}=0x0128; # capital i with tilde
$chars{0xc44e}=0x00d1; # capital n with tilde
$chars{0xc44f}=0x00d5; # capital o with tilde
$chars{0xc455}=0x0168; # capital u with tilde
$chars{0xc456}=0x1e7c; # capital v with tilde
$chars{0xc459}=0x1ef8; # capital y with tilde
$chars{0xc461}=0x00e3; # small a with tilde
$chars{0xc465}=0x1ebd; # small e with tilde
$chars{0xc469}=0x0129; # small i with tilde
$chars{0xc46e}=0x00f1; # small n with tilde
$chars{0xc46f}=0x00f5; # small o with tilde
$chars{0xc475}=0x0169; # small u with tilde
$chars{0xc476}=0x1e7d; # small v with tilde
$chars{0xc479}=0x1ef9; # small y with tilde
    # 4/5 macron
$chars{0xc541}=0x0100; # capital a with macron
$chars{0xc545}=0x0112; # capital e with macron
$chars{0xc547}=0x1e20; # capital g with macron
$chars{0xc549}=0x012a; # capital i with macron
$chars{0xc54f}=0x014c; # capital o with macron
$chars{0xc555}=0x016a; # capital u with macron
$chars{0xc561}=0x0101; # small a with macron
$chars{0xc565}=0x0113; # small e with macron
$chars{0xc567}=0x1e21; # small g with macron
$chars{0xc569}=0x012b; # small i with macron
$chars{0xc56f}=0x014d; # small o with macron
$chars{0xc575}=0x016b; # small u with macron
$chars{0xc572}=0x0159; # small r with macron
$chars{0xc5e1}=0x01e2; # capital ae with macron
$chars{0xc5f1}=0x01e3; # small ae with macron
        # 4/6 breve
$chars{0xc641}=0x0102; # capital a with breve
$chars{0xc645}=0x0114; # capital e with breve
$chars{0xc647}=0x011e; # capital g with breve
$chars{0xc649}=0x012c; # capital i with breve
$chars{0xc64f}=0x014e; # capital o with breve
$chars{0xc655}=0x016c; # capital u with breve
$chars{0xc661}=0x0103; # small a with breve
$chars{0xc665}=0x0115; # small e with breve
$chars{0xc667}=0x011f; # small g with breve
$chars{0xc669}=0x012d; # small i with breve
$chars{0xc66f}=0x014f; # small o with breve
$chars{0xc675}=0x016d; # small u with breve
        # 4/7 dot above
$chars{0xc7b0}=0x01e1; # Ain with dot above
$chars{0xc742}=0x1e02; # capital b with dot above
$chars{0xc743}=0x010a; # capital c with dot above
$chars{0xc744}=0x1e0a; # capital d with dot above
$chars{0xc745}=0x0116; # capital e with dot above
$chars{0xc746}=0x1e1e; # capital f with dot above
$chars{0xc747}=0x0120; # capital g with dot above
$chars{0xc748}=0x1e22; # capital h with dot above
$chars{0xc749}=0x0130; # capital i with dot above
$chars{0xc74d}=0x1e40; # capital m with dot above
$chars{0xc74e}=0x1e44; # capital n with dot above
$chars{0xc750}=0x1e56; # capital p with dot above
$chars{0xc752}=0x1e58; # capital r with dot above
$chars{0xc753}=0x1e60; # capital s with dot above
$chars{0xc754}=0x1e6a; # capital t with dot above
$chars{0xc757}=0x1e86; # capital w with dot above
$chars{0xc758}=0x1e8a; # capital x with dot above
$chars{0xc759}=0x1e8e; # capital y with dot above
$chars{0xc75a}=0x017b; # capital z with dot above
$chars{0xc761}=0x0227; # small b with dot above
$chars{0xc762}=0x1e03; # small b with dot above
$chars{0xc763}=0x010b; # small c with dot above
$chars{0xc764}=0x1e0b; # small d with dot above
$chars{0xc765}=0x0117; # small e with dot above
$chars{0xc766}=0x1e1f; # small f with dot above
$chars{0xc767}=0x0121; # small g with dot above
$chars{0xc768}=0x1e23; # small h with dot above
$chars{0xc76d}=0x1e41; # small m with dot above
$chars{0xc76e}=0x1e45; # small n with dot above
$chars{0xc770}=0x1e57; # small p with dot above
$chars{0xc772}=0x1e59; # small r with dot above
$chars{0xc773}=0x1e61; # small s with dot above
$chars{0xc774}=0x1e6b; # small t with dot above
$chars{0xc777}=0x1e87; # small w with dot above
$chars{0xc778}=0x1e8b; # small x with dot above
$chars{0xc779}=0x1e8f; # small y with dot above
$chars{0xc77a}=0x017c; # small z with dot above
        # 4/8 trema, diaresis
$chars{0xc820}=0x00a8; # diaeresis
$chars{0xc841}=0x00c4; # capital a with diaeresis
$chars{0xc845}=0x00cb; # capital e with diaeresis
$chars{0xc848}=0x1e26; # capital h with diaeresis
$chars{0xc849}=0x00cf; # capital i with diaeresis
$chars{0xc84f}=0x00d6; # capital o with diaeresis
$chars{0xc855}=0x00dc; # capital u with diaeresis
$chars{0xc857}=0x1e84; # capital w with diaeresis
$chars{0xc858}=0x1e8c; # capital x with diaeresis
$chars{0xc859}=0x0178; # capital y with diaeresis
$chars{0xc861}=0x00e4; # small a with diaeresis
$chars{0xc865}=0x00eb; # small e with diaeresis
$chars{0xc868}=0x1e27; # small h with diaeresis
$chars{0xc869}=0x00ef; # small i with diaeresis
$chars{0xc86f}=0x00f6; # small o with diaeresis
$chars{0xc874}=0x1e97; # small t with diaeresis
$chars{0xc875}=0x00fc; # small u with diaeresis
$chars{0xc877}=0x1e85; # small w with diaeresis
$chars{0xc878}=0x1e8d; # small x with diaeresis
$chars{0xc879}=0x00ff; # small y with diaeresis
        # 4/9 umlaut
$chars{0xc920}=0x00a8; # [diaeresis]
$chars{0xc961}=0x00e4; # a with umlaut 
$chars{0xc965}=0x00eb; # e with umlaut
$chars{0xc969}=0x00ef; # i with umlaut
$chars{0xc96f}=0x00f6; # o with umlaut
$chars{0xc975}=0x00fc; # u with umlaut
        # 4/10 circle above 
$chars{0xca41}=0x00c5; # capital a with ring above
$chars{0xcaad}=0x016e; # capital u with ring above
$chars{0xca61}=0x00e5; # small a with ring above
$chars{0xca75}=0x016f; # small u with ring above
$chars{0xca77}=0x1e98; # small w with ring above
$chars{0xca79}=0x1e99; # small y with ring above
        # 4/11 high comma off centre
        # 4/12 inverted high comma centred
        # 4/13 double acute accent
$chars{0xcd4f}=0x0150; # capital o with double acute
$chars{0xcd55}=0x0170; # capital u with double acute
$chars{0xcd6f}=0x0151; # small o with double acute
$chars{0xcd75}=0x0171; # small u with double acute
        # 4/14 horn
$chars{0xce54}=0x01a0; # latin capital letter o with horn
$chars{0xce55}=0x01af; # latin capital letter u with horn
$chars{0xce74}=0x01a1; # latin small letter o with horn
$chars{0xce75}=0x01b0; # latin small letter u with horn
        # 4/15 caron (hacek
$chars{0xcf41}=0x01cd; # capital a with caron
$chars{0xcf43}=0x010c; # capital c with caron
$chars{0xcf44}=0x010e; # capital d with caron
$chars{0xcf45}=0x011a; # capital e with caron
$chars{0xcf47}=0x01e6; # capital g with caron
$chars{0xcf49}=0x01cf; # capital i with caron
$chars{0xcf4b}=0x01e8; # capital k with caron
$chars{0xcf4c}=0x013d; # capital l with caron
$chars{0xcf4e}=0x0147; # capital n with caron
$chars{0xcf4f}=0x01d1; # capital o with caron
$chars{0xcf52}=0x0158; # capital r with caron
$chars{0xcf53}=0x0160; # capital s with caron
$chars{0xcf54}=0x0164; # capital t with caron
$chars{0xcf55}=0x01d3; # capital u with caron
$chars{0xcf5a}=0x017d; # capital z with caron
$chars{0xcf61}=0x01ce; # small a with caron
$chars{0xcf63}=0x010d; # small c with caron
$chars{0xcf64}=0x010f; # small d with caron
$chars{0xcf65}=0x011b; # small e with caron
$chars{0xcf67}=0x01e7; # small g with caron
$chars{0xcf69}=0x01d0; # small i with caron
$chars{0xcf6a}=0x01f0; # small j with caron
$chars{0xcf6b}=0x01e9; # small k with caron
$chars{0xcf6c}=0x013e; # small l with caron
$chars{0xcf6e}=0x0148; # small n with caron
$chars{0xcf6f}=0x01d2; # small o with caron
$chars{0xcf72}=0x0159; # small r with caron
$chars{0xcf73}=0x0161; # small s with caron
$chars{0xcf74}=0x0165; # small t with caron
$chars{0xcf75}=0x01d4; # small u with caron
$chars{0xcf7a}=0x017e; # small z with caron
        # 5/0 cedilla
$chars{0xd020}=0x00b8; # cedilla
$chars{0xd043}=0x00c7; # capital c with cedilla
$chars{0xd044}=0x1e10; # capital d with cedilla
$chars{0xd047}=0x0122; # capital g with cedilla
$chars{0xd048}=0x1e28; # capital h with cedilla
$chars{0xd04b}=0x0136; # capital k with cedilla
$chars{0xd04c}=0x013b; # capital l with cedilla
$chars{0xd04e}=0x0145; # capital n with cedilla
$chars{0xd052}=0x0156; # capital r with cedilla
$chars{0xd053}=0x015e; # capital s with cedilla
$chars{0xd054}=0x0162; # capital t with cedilla
$chars{0xd063}=0x00e7; # small c with cedilla
$chars{0xd064}=0x1e11; # small d with cedilla
$chars{0xd065}=0x0119; # small e with cedilla
$chars{0xd067}=0x0123; # small g with cedilla
$chars{0xd068}=0x1e29; # small h with cedilla
$chars{0xd06b}=0x0137; # small k with cedilla
$chars{0xd06c}=0x013c; # small l with cedilla
$chars{0xd06e}=0x0146; # small n with cedilla
$chars{0xd072}=0x0157; # small r with cedilla
$chars{0xd073}=0x015f; # small s with cedilla
$chars{0xd074}=0x0163; # small t with cedilla
        # 5/1 rude
        # 5/2 hook to left
        # 5/3 ogonek (hook to right
$chars{0xd320}=0x02db; # ogonek
$chars{0xd341}=0x0104; # capital a with ogonek
$chars{0xd345}=0x0118; # capital e with ogonek
$chars{0xd349}=0x012e; # capital i with ogonek
$chars{0xd34f}=0x01ea; # capital o with ogonek
$chars{0xd355}=0x0172; # capital u with ogonek
$chars{0xd361}=0x0105; # small a with ogonek
$chars{0xd365}=0x0119; # small e with ogonek
$chars{0xd369}=0x012f; # small i with ogonek
$chars{0xd36f}=0x01eb; # small o with ogonek
$chars{0xd375}=0x0173; # small u with ogonek
        # 5/4 circle below
$chars{0xd441}=0x1e00; # capital a with ring below
$chars{0xd461}=0x1e01; # small a with ring below
        # 5/5 half circle below
$chars{0xf948}=0x1e2a; # capital h with breve below
$chars{0xf968}=0x1e2b; # small h with breve below
        # 5/6 dot below
$chars{0xd641}=0x1ea0; # capital a with dot below
$chars{0xd642}=0x1e04; # capital b with dot below
$chars{0xd644}=0x1e0c; # capital d with dot below
$chars{0xd645}=0x1eb8; # capital e with dot below
$chars{0xd648}=0x1e24; # capital h with dot below
$chars{0xd649}=0x1eca; # capital i with dot below
$chars{0xd64b}=0x1e32; # capital k with dot below
$chars{0xd64c}=0x1e36; # capital l with dot below
$chars{0xd64d}=0x1e42; # capital m with dot below
$chars{0xd64e}=0x1e46; # capital n with dot below
$chars{0xd64f}=0x1ecc; # capital o with dot below
$chars{0xd652}=0x1e5a; # capital r with dot below
$chars{0xd653}=0x1e62; # capital s with dot below
$chars{0xd654}=0x1e6c; # capital t with dot below
$chars{0xd655}=0x1ee4; # capital u with dot below
$chars{0xd656}=0x1e7e; # capital v with dot below
$chars{0xd657}=0x1e88; # capital w with dot below
$chars{0xd659}=0x1ef4; # capital y with dot below
$chars{0xd65a}=0x1e92; # capital z with dot below
$chars{0xd661}=0x1ea1; # small a with dot below
$chars{0xd662}=0x1e05; # small b with dot below
$chars{0xd664}=0x1e0d; # small d with dot below
$chars{0xd665}=0x1eb9; # small e with dot below
$chars{0xd668}=0x1e25; # small h with dot below
$chars{0xd669}=0x1ecb; # small i with dot below
$chars{0xd66b}=0x1e33; # small k with dot below
$chars{0xd66c}=0x1e37; # small l with dot below
$chars{0xd66d}=0x1e43; # small m with dot below
$chars{0xd66e}=0x1e47; # small n with dot below
$chars{0xd66f}=0x1ecd; # small o with dot below
$chars{0xd672}=0x1e5b; # small r with dot below
$chars{0xd673}=0x1e63; # small s with dot below
$chars{0xd674}=0x1e6d; # small t with dot below
$chars{0xd675}=0x1ee5; # small u with dot below
$chars{0xd676}=0x1e7f; # small v with dot below
$chars{0xd677}=0x1e89; # small w with dot below
$chars{0xd679}=0x1ef5; # small y with dot below
$chars{0xd67a}=0x1e93; # small z with dot below
        # 5/7 double dot below
$chars{0xd755}=0x1e72; # capital u with diaeresis below
$chars{0xd775}=0x1e73; # small u with diaeresis below
        # 5/8 underline
$chars{0xd820}=0x005f; # underline
        # 5/9 double underline
$chars{0xd920}=0x2017; # double underline
        # 5/10 small low vertical bar
$chars{0xda20}=0x02cc; # 
        # 5/11 circumflex below
        # 5/12 (this position shall not be used)
        # 5/13 left half of ligature sign and of double tilde
        # 5/14 right half of ligature sign
        # 5/15 right half of double tilde
#     map {printf "%x :%x\n",$_,$chars{$_};}keys %chars;
    my @data = unpack("C*", $string);
    my @characters;
    my $length=scalar(@data);
    for (my $i = 0; $i < scalar(@data); $i++) {
      my $char= $data[$i];
      if ($char >= 0x00 && $char <= 0x7F){
        #IsAscii
              
          push @characters,$char unless ($char<0x02 ||$char== 0x0F);
      }elsif (($char >= 0xC0 && $char <= 0xDF)) {
        #Combined Char
        my $convchar ;
        if ($chars{$char*256+$data[$i+1]}) {
          $convchar= $chars{$char * 256 + $data[$i+1]};
          $i++;     
#           printf "char %x $char, char to convert %x , converted %x\n",$char,$char * 256 + $data[$i - 1],$convchar;       
        } elsif ($chars{$char})  {
          $convchar= $chars{$char};
#           printf "0xC char %x, converted %x\n",$char,$chars{$char};       
        }else {
          $convchar=$char;
        }     
        push @characters,$convchar;
      } else {
        my $convchar;    
        if ($chars{$char})  {
          $convchar= $chars{$char};
#            printf "char %x,  converted %x\n",$char,$chars{$char};   
        }else {
#            printf "char %x $char\n",$char;   
          $convchar=$char;    
        }  
        push @characters,$convchar;    
      }        
    }
    $result=pack "U*",@characters; 
#     $result=~s/\x01//;  
#     $result=~s/\x00//;  
     $result=~s/\x0f//;  
     $result=~s/\x1b.//;  
     $result=~s/\x0e//;  
     $result=~s/\x1b\x5b//;  
#   map{printf "%x",$_} @characters;  
#   printf "\n"; 
  return $result;
}

1;

__END__

=head1 AUTHOR

Koha Team

=cut
