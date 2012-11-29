package C4::Koha;

# Copyright 2000-2002 Katipo Communications
# Parts Copyright 2010 Nelsonville Public Library
# Parts copyright 2010 BibLibre
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
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.


use strict;
#use warnings; FIXME - Bug 2505

use C4::Context;
use C4::Branch qw(GetBranchesCount);
use Memoize;
use DateTime;
use DateTime::Format::MySQL;
use autouse 'Data::Dumper' => qw(Dumper);

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK $DEBUG);

BEGIN {
    $VERSION = 3.07.00.049;
	require Exporter;
	@ISA    = qw(Exporter);
	@EXPORT = qw(
		&slashifyDate
		&subfield_is_koha_internal_p
		&GetPrinters &GetPrinter
		&GetItemTypes &getitemtypeinfo
		&GetCcodes
		&GetSupportName &GetSupportList
		&get_itemtypeinfos_of
		&getframeworks &getframeworkinfo
		&getauthtypes &getauthtype
		&getallthemes
		&getFacets
		&displayServers
		&getnbpages
		&get_infos_of
		&get_notforloan_label_of
		&getitemtypeimagedir
		&getitemtypeimagesrc
		&getitemtypeimagelocation
		&GetAuthorisedValues
		&GetAuthorisedValueCategories
		&GetKohaAuthorisedValues
		&GetKohaAuthorisedValuesFromField
    &GetKohaAuthorisedValueLib
    &GetAuthorisedValueByCode
    &GetKohaImageurlFromAuthorisedValues
		&GetAuthValCode
		&GetNormalizedUPC
		&GetNormalizedISBN
		&GetNormalizedEAN
		&GetNormalizedOCLCNumber
        &xml_escape

		$DEBUG
	);
	$DEBUG = 0;
@EXPORT_OK = qw( GetDailyQuote );
}

# expensive functions
memoize('GetAuthorisedValues');

=head1 NAME

C4::Koha - Perl Module containing convenience functions for Koha scripts

=head1 SYNOPSIS

use C4::Koha;

=head1 DESCRIPTION

Koha.pm provides many functions for Koha scripts.

=head1 FUNCTIONS

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

# FIXME.. this should be moved to a MARC-specific module
sub subfield_is_koha_internal_p {
    my ($subfield) = @_;

    # We could match on 'lib' and 'tab' (and 'mandatory', & more to come!)
    # But real MARC subfields are always single-character
    # so it really is safer just to check the length

    return length $subfield != 1;
}

=head2 GetSupportName

  $itemtypename = &GetSupportName($codestring);

Returns a string with the name of the itemtype.

=cut

sub GetSupportName{
	my ($codestring)=@_;
	return if (! $codestring); 
	my $resultstring;
	my $advanced_search_types = C4::Context->preference("AdvancedSearchTypes");
	if (!$advanced_search_types or $advanced_search_types eq 'itemtypes') {  
		my $query = qq|
			SELECT description
			FROM   itemtypes
			WHERE itemtype=?
			order by description
		|;
		my $sth = C4::Context->dbh->prepare($query);
		$sth->execute($codestring);
		($resultstring)=$sth->fetchrow;
		return $resultstring;
	} else {
        my $sth =
            C4::Context->dbh->prepare(
                    "SELECT lib FROM authorised_values WHERE category = ? AND authorised_value = ?"
                    );
        $sth->execute( $advanced_search_types, $codestring );
        my $data = $sth->fetchrow_hashref;
        return $$data{'lib'};
	}

}
=head2 GetSupportList

  $itemtypes = &GetSupportList();

Returns an array ref containing informations about Support (since itemtype is rather a circulation code when item-level-itypes is used).

build a HTML select with the following code :

=head3 in PERL SCRIPT

    my $itemtypes = GetSupportList();
    $template->param(itemtypeloop => $itemtypes);

=head3 in TEMPLATE

    <form action='<!-- TMPL_VAR name="script_name" -->' method=post>
        <select name="itemtype">
            <option value="">Default</option>
        <!-- TMPL_LOOP name="itemtypeloop" -->
            <option value="<!-- TMPL_VAR name="itemtype" -->" <!-- TMPL_IF name="selected" -->selected<!-- /TMPL_IF -->> <!--TMPL_IF Name="imageurl"--><img alt="<!-- TMPL_VAR name="description" -->" src="<!--TMPL_VAR Name="imageurl"-->><!--TMPL_ELSE-->"<!-- TMPL_VAR name="description" --><!--/TMPL_IF--></option>
        <!-- /TMPL_LOOP -->
        </select>
        <input type=text name=searchfield value="<!-- TMPL_VAR name="searchfield" -->">
        <input type="submit" value="OK" class="button">
    </form>

=cut

sub GetSupportList{
	my $advanced_search_types = C4::Context->preference("AdvancedSearchTypes");
	if (!$advanced_search_types or $advanced_search_types eq 'itemtypes') {  
		my $query = qq|
			SELECT *
			FROM   itemtypes
			order by description
		|;
		my $sth = C4::Context->dbh->prepare($query);
		$sth->execute;
		return $sth->fetchall_arrayref({});
	} else {
		my $advsearchtypes = GetAuthorisedValues($advanced_search_types);
		my @results= map {{itemtype=>$$_{authorised_value},description=>$$_{lib},imageurl=>$$_{imageurl}}} @$advsearchtypes;
		return \@results;
	}
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

    # returns a reference to a hash of references to itemtypes...
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

    my $placeholders = join( ', ', map { '?' } @itemtypes );
    my $query = <<"END_SQL";
SELECT itemtype,
       description,
       imageurl,
       notforloan
  FROM itemtypes
  WHERE itemtype IN ( $placeholders )
END_SQL

    return get_infos_of( $query, 'itemtype', undef, \@itemtypes );
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

  $itemtype = &getitemtype($itemtype, [$interface]);

Returns information about an itemtype. The optional $interface argument
sets which interface ('opac' or 'intranet') to return the imageurl for.
Defaults to intranet.

=cut

sub getitemtypeinfo {
    my ($itemtype, $interface) = @_;
    my $dbh        = C4::Context->dbh;
    my $sth        = $dbh->prepare("select * from itemtypes where itemtype=?");
    $sth->execute($itemtype);
    my $res = $sth->fetchrow_hashref;

    $res->{imageurl} = getitemtypeimagelocation( ( $interface eq 'opac' ? 'opac' : 'intranet' ), $res->{imageurl} );

    return $res;
}

=head2 getitemtypeimagedir

  my $directory = getitemtypeimagedir( 'opac' );

pass in 'opac' or 'intranet'. Defaults to 'opac'.

returns the full path to the appropriate directory containing images.

=cut

sub getitemtypeimagedir {
	my $src = shift || 'opac';
	if ($src eq 'intranet') {
		return C4::Context->config('intrahtdocs') . '/' .C4::Context->preference('template') . '/img/itemtypeimg';
	} else {
		return C4::Context->config('opachtdocs') . '/' . C4::Context->preference('opacthemes') . '/itemtypeimg';
	}
}

sub getitemtypeimagesrc {
	my $src = shift || 'opac';
	if ($src eq 'intranet') {
		return '/intranet-tmpl' . '/' .	C4::Context->preference('template') . '/img/itemtypeimg';
	} else {
		return '/opac-tmpl' . '/' . C4::Context->preference('opacthemes') . '/itemtypeimg';
	}
}

sub getitemtypeimagelocation {
	my ( $src, $image ) = @_;

	return '' if ( !$image );
    require URI::Split;

	my $scheme = ( URI::Split::uri_split( $image ) )[0];

	return $image if ( $scheme );

	return getitemtypeimagesrc( $src ) . '/' . $image;
}

=head3 _getImagesFromDirectory

Find all of the image files in a directory in the filesystem

parameters: a directory name

returns: a list of images in that directory.

Notes: this does not traverse into subdirectories. See
_getSubdirectoryNames for help with that.
Images are assumed to be files with .gif or .png file extensions.
The image names returned do not have the directory name on them.

=cut

sub _getImagesFromDirectory {
    my $directoryname = shift;
    return unless defined $directoryname;
    return unless -d $directoryname;

    if ( opendir ( my $dh, $directoryname ) ) {
        my @images = grep { /\.(gif|png)$/i } readdir( $dh );
        closedir $dh;
        @images = sort(@images);
        return @images;
    } else {
        warn "unable to opendir $directoryname: $!";
        return;
    }
}

=head3 _getSubdirectoryNames

Find all of the directories in a directory in the filesystem

parameters: a directory name

returns: a list of subdirectories in that directory.

Notes: this does not traverse into subdirectories. Only the first
level of subdirectories are returned.
The directory names returned don't have the parent directory name on them.

=cut

sub _getSubdirectoryNames {
    my $directoryname = shift;
    return unless defined $directoryname;
    return unless -d $directoryname;

    if ( opendir ( my $dh, $directoryname ) ) {
        my @directories = grep { -d File::Spec->catfile( $directoryname, $_ ) && ! ( /^\./ ) } readdir( $dh );
        closedir $dh;
        return @directories;
    } else {
        warn "unable to opendir $directoryname: $!";
        return;
    }
}

=head3 getImageSets

returns: a listref of hashrefs. Each hash represents another collection of images.

 { imagesetname => 'npl', # the name of the image set (npl is the original one)
         images => listref of image hashrefs
 }

each image is represented by a hashref like this:

 { KohaImage     => 'npl/image.gif',
   StaffImageUrl => '/intranet-tmpl/prog/img/itemtypeimg/npl/image.gif',
   OpacImageURL  => '/opac-tmpl/prog/itemtypeimg/npl/image.gif'
   checked       => 0 or 1: was this the image passed to this method?
                    Note: I'd like to remove this somehow.
 }

=cut

sub getImageSets {
    my %params = @_;
    my $checked = $params{'checked'} || '';

    my $paths = { staff => { filesystem => getitemtypeimagedir('intranet'),
                             url        => getitemtypeimagesrc('intranet'),
                        },
                  opac => { filesystem => getitemtypeimagedir('opac'),
                             url       => getitemtypeimagesrc('opac'),
                        }
                  };

    my @imagesets = (); # list of hasrefs of image set data to pass to template
    my @subdirectories = _getSubdirectoryNames( $paths->{'staff'}{'filesystem'} );
    foreach my $imagesubdir ( @subdirectories ) {
    warn $imagesubdir if $DEBUG;
        my @imagelist     = (); # hashrefs of image info
        my @imagenames = _getImagesFromDirectory( File::Spec->catfile( $paths->{'staff'}{'filesystem'}, $imagesubdir ) );
        my $imagesetactive = 0;
        foreach my $thisimage ( @imagenames ) {
            push( @imagelist,
                  { KohaImage     => "$imagesubdir/$thisimage",
                    StaffImageUrl => join( '/', $paths->{'staff'}{'url'}, $imagesubdir, $thisimage ),
                    OpacImageUrl  => join( '/', $paths->{'opac'}{'url'}, $imagesubdir, $thisimage ),
                    checked       => "$imagesubdir/$thisimage" eq $checked ? 1 : 0,
               }
             );
             $imagesetactive = 1 if "$imagesubdir/$thisimage" eq $checked;
        }
        push @imagesets, { imagesetname => $imagesubdir,
                           imagesetactive => $imagesetactive,
                           images       => \@imagelist };
        
    }
    return \@imagesets;
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

sub GetPrinter {
    my ( $query, $printers ) = @_;    # get printer for this query from printers
    my $printer = $query->param('printer');
    my %cookie = $query->cookie('userenv');
    ($printer) || ( $printer = $cookie{'printer'} ) || ( $printer = '' );
    ( $printers->{$printer} ) || ( $printer = ( keys %$printers )[0] );
    return $printer;
}

=head2 getnbpages

Returns the number of pages to display in a pagination bar, given the number
of items and the number of items per page.

=cut

sub getnbpages {
    my ( $nb_items, $nb_items_per_page ) = @_;

    return int( ( $nb_items - 1 ) / $nb_items_per_page ) + 1;
}

=head2 getallthemes

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
        next if $directory eq 'lib';
        -d "$htdocs/$directory/en" and push @themes, $directory;
    }
    return @themes;
}

sub getFacets {
    my $facets;
    if ( C4::Context->preference("marcflavour") eq "UNIMARC" ) {
        $facets = [
            {
                idx   => 'su-to',
                label => 'Topics',
                tags  => [ qw/ 600ab 601ab 602a 604at 605a 606ax 610a / ],
                sep   => ' - ',
            },
            {
                idx   => 'su-geo',
                label => 'Places',
                tags  => [ qw/ 607a / ],
                sep   => ' - ',
            },
            {
                idx   => 'su-ut',
                label => 'Titles',
                tags  => [ qw/ 500a 501a 503a / ],
                sep   => ', ',
            },
            {
                idx   => 'au',
                label => 'Authors',
                tags  => [ qw/ 700ab 701ab 702ab / ],
                sep   => ', ',
            },
            {
                idx   => 'se',
                label => 'Series',
                tags  => [ qw/ 225a / ],
                sep   => ', ',
            },
            ];

            my $library_facet;
            unless ( C4::Context->preference("singleBranchMode") || GetBranchesCount() == 1 ) {
                $library_facet = {
                    idx  => 'branch',
                    label => 'Libraries',
                    tags        => [ qw/ 995b / ],
                };
            } else {
                $library_facet = {
                    idx  => 'location',
                    label => 'Location',
                    tags        => [ qw/ 995c / ],
                };
            }
            push( @$facets, $library_facet );
    }
    else {
        $facets = [
            {
                idx   => 'su-to',
                label => 'Topics',
                tags  => [ qw/ 650a / ],
                sep   => '--',
            },
            #        {
            #        idx   => 'su-na',
            #        label => 'People and Organizations',
            #        tags  => [ qw/ 600a 610a 611a / ],
            #        sep   => 'a',
            #        },
            {
                idx   => 'su-geo',
                label => 'Places',
                tags  => [ qw/ 651a / ],
                sep   => '--',
            },
            {
                idx   => 'su-ut',
                label => 'Titles',
                tags  => [ qw/ 630a / ],
                sep   => '--',
            },
            {
                idx   => 'au',
                label => 'Authors',
                tags  => [ qw/ 100a 110a 700a / ],
                sep   => ', ',
            },
            {
                idx   => 'se',
                label => 'Series',
                tags  => [ qw/ 440a 490a / ],
                sep   => ', ',
            },
            {
                idx   => 'itype',
                label => 'ItemTypes',
                tags  => [ qw/ 952y 942c / ],
                sep   => ', ',
            },
            ];

            my $library_facet;
            unless ( C4::Context->preference("singleBranchMode") || GetBranchesCount() == 1 ) {
                $library_facet = {
                    idx  => 'branch',
                    label => 'Libraries',
                    tags        => [ qw / 952b / ],
                };
            } else {
                $library_facet = {
                    idx => 'location',
                    label => 'Location',
                    tags => [ qw / 952c / ],
                };
            }
            push( @$facets, $library_facet );
    }
    return $facets;
}

=head2 get_infos_of

Return a href where a key is associated to a href. You give a query,
the name of the key among the fields returned by the query. If you
also give as third argument the name of the value, the function
returns a href of scalar. The optional 4th argument is an arrayref of
items passed to the C<execute()> call. It is designed to bind
parameters to any placeholders in your SQL.

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
    my ( $query, $key_name, $value_name, $bind_params ) = @_;

    my $dbh = C4::Context->dbh;

    my $sth = $dbh->prepare($query);
    $sth->execute( @$bind_params );

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

=head2 displayServers

   my $servers = displayServers();
   my $servers = displayServers( $position );
   my $servers = displayServers( $position, $type );

displayServers returns a listref of hashrefs, each containing
information about available z3950 servers. Each hashref has a format
like:

    {
      'checked'    => 'checked',
      'encoding'   => 'MARC-8'
      'icon'       => undef,
      'id'         => 'LIBRARY OF CONGRESS',
      'label'      => '',
      'name'       => 'server',
      'opensearch' => '',
      'value'      => 'z3950.loc.gov:7090/',
      'zed'        => 1,
    },

=cut

sub displayServers {
    my ( $position, $type ) = @_;
    my $dbh = C4::Context->dbh;

    my $strsth = 'SELECT * FROM z3950servers';
    my @where_clauses;
    my @bind_params;

    if ($position) {
        push @bind_params,   $position;
        push @where_clauses, ' position = ? ';
    }

    if ($type) {
        push @bind_params,   $type;
        push @where_clauses, ' type = ? ';
    }

    # reassemble where clause from where clause pieces
    if (@where_clauses) {
        $strsth .= ' WHERE ' . join( ' AND ', @where_clauses );
    }

    my $rq = $dbh->prepare($strsth);
    $rq->execute(@bind_params);
    my @primaryserverloop;

    while ( my $data = $rq->fetchrow_hashref ) {
        push @primaryserverloop,
          { label    => $data->{description},
            id       => $data->{name},
            name     => "server",
            value    => $data->{host} . ":" . $data->{port} . "/" . $data->{database},
            encoding => ( $data->{encoding} ? $data->{encoding} : "iso-5426" ),
            checked  => "checked",
            icon     => $data->{icon},
            zed        => $data->{type} eq 'zed',
            opensearch => $data->{type} eq 'opensearch'
          };
    }
    return \@primaryserverloop;
}


=head2 GetKohaImageurlFromAuthorisedValues

$authhorised_value = GetKohaImageurlFromAuthorisedValues( $category, $authvalcode );

Return the first url of the authorised value image represented by $lib.

=cut

sub GetKohaImageurlFromAuthorisedValues {
    my ( $category, $lib ) = @_;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("SELECT imageurl FROM authorised_values WHERE category=? AND lib =?");
    $sth->execute( $category, $lib );
    while ( my $data = $sth->fetchrow_hashref ) {
        return $data->{'imageurl'};
    }
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

=head2 GetAuthValCodeFromField

  $authvalcode = GetAuthValCodeFromField($field,$subfield,$frameworkcode);

C<$subfield> can be undefined

=cut

sub GetAuthValCodeFromField {
	my ($field,$subfield,$fwcode) = @_;
	my $dbh = C4::Context->dbh;
	$fwcode='' unless $fwcode;
	my $sth;
	if (defined $subfield) {
	    $sth = $dbh->prepare('select authorised_value from marc_subfield_structure where tagfield=? and tagsubfield=? and frameworkcode=?');
	    $sth->execute($field,$subfield,$fwcode);
	} else {
	    $sth = $dbh->prepare('select authorised_value from marc_tag_structure where tagfield=? and frameworkcode=?');
	    $sth->execute($field,$fwcode);
	}
	my ($authvalcode) = $sth->fetchrow_array;
	return $authvalcode;
}

=head2 GetAuthorisedValues

  $authvalues = GetAuthorisedValues([$category], [$selected]);

This function returns all authorised values from the'authorised_value' table in a reference to array of hashrefs.

C<$category> returns authorised values for just one category (optional).

C<$opac> If set to a true value, displays OPAC descriptions rather than normal ones when they exist.

=cut

sub GetAuthorisedValues {
    my ( $category, $selected, $opac ) = @_;
    my $branch_limit = C4::Context->userenv ? C4::Context->userenv->{"branch"} : "";
    my @results;
    my $dbh      = C4::Context->dbh;
    my $query = qq{
        SELECT *
        FROM authorised_values
    };
    $query .= qq{
          LEFT JOIN authorised_values_branches ON ( id = av_id )
    } if $branch_limit;
    my @where_strings;
    my @where_args;
    if($category) {
        push @where_strings, "category = ?";
        push @where_args, $category;
    }
    if($branch_limit) {
        push @where_strings, "( branchcode = ? OR branchcode IS NULL )";
        push @where_args, $branch_limit;
    }
    if(@where_strings > 0) {
        $query .= " WHERE " . join(" AND ", @where_strings);
    }
    $query .= " GROUP BY lib ORDER BY category, lib, lib_opac";

    my $sth = $dbh->prepare($query);

    $sth->execute( @where_args );
    while (my $data=$sth->fetchrow_hashref) {
        if ( defined $selected and $selected eq $data->{authorised_value} ) {
            $data->{selected} = 1;
        }
        else {
            $data->{selected} = 0;
        }

        if ($opac && $data->{lib_opac}) {
            $data->{lib} = $data->{lib_opac};
        }
        push @results, $data;
    }
    $sth->finish;
    return \@results;
}

=head2 GetAuthorisedValueCategories

  $auth_categories = GetAuthorisedValueCategories();

Return an arrayref of all of the available authorised
value categories.

=cut

sub GetAuthorisedValueCategories {
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("SELECT DISTINCT category FROM authorised_values ORDER BY category");
    $sth->execute;
    my @results;
    while (defined (my $category  = $sth->fetchrow_array) ) {
        push @results, $category;
    }
    return \@results;
}

=head2 GetAuthorisedValueByCode

$authhorised_value = GetAuthorisedValueByCode( $category, $authvalcode );

Return the lib attribute from authorised_values from the row identified
by the passed category and code

=cut

sub GetAuthorisedValueByCode {
    my ( $category, $authvalcode, $opac ) = @_;

    my $field = $opac ? 'lib_opac' : 'lib';
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("SELECT $field FROM authorised_values WHERE category=? AND authorised_value =?");
    $sth->execute( $category, $authvalcode );
    while ( my $data = $sth->fetchrow_hashref ) {
        return $data->{ $field };
    }
}

=head2 GetKohaAuthorisedValues

Takes $kohafield, $fwcode as parameters.

If $opac parameter is set to a true value, displays OPAC descriptions rather than normal ones when they exist.

Returns hashref of Code => description

Returns undef if no authorised value category is defined for the kohafield.

=cut

sub GetKohaAuthorisedValues {
  my ($kohafield,$fwcode,$opac) = @_;
  $fwcode='' unless $fwcode;
  my %values;
  my $dbh = C4::Context->dbh;
  my $avcode = GetAuthValCode($kohafield,$fwcode);
  if ($avcode) {  
	my $sth = $dbh->prepare("select authorised_value, lib, lib_opac from authorised_values where category=? ");
   	$sth->execute($avcode);
	while ( my ($val, $lib, $lib_opac) = $sth->fetchrow_array ) { 
		$values{$val} = ($opac && $lib_opac) ? $lib_opac : $lib;
   	}
   	return \%values;
  } else {
	return;
  }
}

=head2 GetKohaAuthorisedValuesFromField

Takes $field, $subfield, $fwcode as parameters.

If $opac parameter is set to a true value, displays OPAC descriptions rather than normal ones when they exist.
$subfield can be undefined

Returns hashref of Code => description

Returns undef if no authorised value category is defined for the given field and subfield 

=cut

sub GetKohaAuthorisedValuesFromField {
  my ($field, $subfield, $fwcode,$opac) = @_;
  $fwcode='' unless $fwcode;
  my %values;
  my $dbh = C4::Context->dbh;
  my $avcode = GetAuthValCodeFromField($field, $subfield, $fwcode);
  if ($avcode) {  
	my $sth = $dbh->prepare("select authorised_value, lib, lib_opac from authorised_values where category=? ");
   	$sth->execute($avcode);
	while ( my ($val, $lib, $lib_opac) = $sth->fetchrow_array ) { 
		$values{$val} = ($opac && $lib_opac) ? $lib_opac : $lib;
   	}
   	return \%values;
  } else {
	return;
  }
}

=head2 xml_escape

  my $escaped_string = C4::Koha::xml_escape($string);

Convert &, <, >, ', and " in a string to XML entities

=cut

sub xml_escape {
    my $str = shift;
    return '' unless defined $str;
    $str =~ s/&/&amp;/g;
    $str =~ s/</&lt;/g;
    $str =~ s/>/&gt;/g;
    $str =~ s/'/&apos;/g;
    $str =~ s/"/&quot;/g;
    return $str;
}

=head2 GetKohaAuthorisedValueLib

Takes $category, $authorised_value as parameters.

If $opac parameter is set to a true value, displays OPAC descriptions rather than normal ones when they exist.

Returns authorised value description

=cut

sub GetKohaAuthorisedValueLib {
  my ($category,$authorised_value,$opac) = @_;
  my $value;
  my $dbh = C4::Context->dbh;
  my $sth = $dbh->prepare("select lib, lib_opac from authorised_values where category=? and authorised_value=?");
  $sth->execute($category,$authorised_value);
  my $data = $sth->fetchrow_hashref;
  $value = ($opac && $$data{'lib_opac'}) ? $$data{'lib_opac'} : $$data{'lib'};
  return $value;
}

=head2 display_marc_indicators

  my $display_form = C4::Koha::display_marc_indicators($field);

C<$field> is a MARC::Field object

Generate a display form of the indicators of a variable
MARC field, replacing any blanks with '#'.

=cut

sub display_marc_indicators {
    my $field = shift;
    my $indicators = '';
    if ($field->tag() >= 10) {
        $indicators = $field->indicator(1) . $field->indicator(2);
        $indicators =~ s/ /#/g;
    }
    return $indicators;
}

sub GetNormalizedUPC {
 my ($record,$marcflavour) = @_;
    my (@fields,$upc);

    if ($marcflavour eq 'UNIMARC') {
        @fields = $record->field('072');
        foreach my $field (@fields) {
            my $upc = _normalize_match_point($field->subfield('a'));
            if ($upc ne '') {
                return $upc;
            }
        }

    }
    else { # assume marc21 if not unimarc
        @fields = $record->field('024');
        foreach my $field (@fields) {
            my $indicator = $field->indicator(1);
            my $upc = _normalize_match_point($field->subfield('a'));
            if ($indicator == 1 and $upc ne '') {
                return $upc;
            }
        }
    }
}

# Normalizes and returns the first valid ISBN found in the record
# ISBN13 are converted into ISBN10. This is required to get some book cover images.
sub GetNormalizedISBN {
    my ($isbn,$record,$marcflavour) = @_;
    my @fields;
    if ($isbn) {
        # Koha attempts to store multiple ISBNs in biblioitems.isbn, separated by " | "
        # anything after " | " should be removed, along with the delimiter
        $isbn =~ s/(.*)( \| )(.*)/$1/;
        return _isbn_cleanup($isbn);
    }
    return unless $record;

    if ($marcflavour eq 'UNIMARC') {
        @fields = $record->field('010');
        foreach my $field (@fields) {
            my $isbn = $field->subfield('a');
            if ($isbn) {
                return _isbn_cleanup($isbn);
            } else {
                return;
            }
        }
    }
    else { # assume marc21 if not unimarc
        @fields = $record->field('020');
        foreach my $field (@fields) {
            $isbn = $field->subfield('a');
            if ($isbn) {
                return _isbn_cleanup($isbn);
            } else {
                return;
            }
        }
    }
}

sub GetNormalizedEAN {
    my ($record,$marcflavour) = @_;
    my (@fields,$ean);

    if ($marcflavour eq 'UNIMARC') {
        @fields = $record->field('073');
        foreach my $field (@fields) {
            $ean = _normalize_match_point($field->subfield('a'));
            if ($ean ne '') {
                return $ean;
            }
        }
    }
    else { # assume marc21 if not unimarc
        @fields = $record->field('024');
        foreach my $field (@fields) {
            my $indicator = $field->indicator(1);
            $ean = _normalize_match_point($field->subfield('a'));
            if ($indicator == 3 and $ean ne '') {
                return $ean;
            }
        }
    }
}
sub GetNormalizedOCLCNumber {
    my ($record,$marcflavour) = @_;
    my (@fields,$oclc);

    if ($marcflavour eq 'UNIMARC') {
        # TODO: add UNIMARC fields
    }
    else { # assume marc21 if not unimarc
        @fields = $record->field('035');
        foreach my $field (@fields) {
            $oclc = $field->subfield('a');
            if ($oclc =~ /OCoLC/) {
                $oclc =~ s/\(OCoLC\)//;
                return $oclc;
            } else {
                return;
            }
        }
    }
}

=head2 GetDailyQuote($opts)

Takes a hashref of options

Currently supported options are:

'id'        An exact quote id
'random'    Select a random quote
noop        When no option is passed in, this sub will return the quote timestamped for the current day

The function returns an anonymous hash following this format:

        {
          'source' => 'source-of-quote',
          'timestamp' => 'timestamp-value',
          'text' => 'text-of-quote',
          'id' => 'quote-id'
        };

=cut

# This is definitely a candidate for some sort of caching once we finally settle caching/persistence issues...
# at least for default option

sub GetDailyQuote {
    my %opts = @_;
    my $dbh = C4::Context->dbh;
    my $query = '';
    my $sth = undef;
    my $quote = undef;
    if ($opts{'id'}) {
        $query = 'SELECT * FROM quotes WHERE id = ?';
        $sth = $dbh->prepare($query);
        $sth->execute($opts{'id'});
        $quote = $sth->fetchrow_hashref();
    }
    elsif ($opts{'random'}) {
        # Fall through... we also return a random quote as a catch-all if all else fails
    }
    else {
        $query = 'SELECT * FROM quotes WHERE timestamp LIKE CONCAT(CURRENT_DATE,\'%\') ORDER BY timestamp DESC LIMIT 0,1';
        $sth = $dbh->prepare($query);
        $sth->execute();
        $quote = $sth->fetchrow_hashref();
    }
    unless ($quote) {        # if there are not matches, choose a random quote
        # get a list of all available quote ids
        $sth = C4::Context->dbh->prepare('SELECT count(*) FROM quotes;');
        $sth->execute;
        my $range = ($sth->fetchrow_array)[0];
        if ($range > 1) {
            # chose a random id within that range if there is more than one quote
            my $id = int(rand($range));
            # grab it
            $query = 'SELECT * FROM quotes WHERE id = ?;';
            $sth = C4::Context->dbh->prepare($query);
            $sth->execute($id);
        }
        else {
            $query = 'SELECT * FROM quotes;';
            $sth = C4::Context->dbh->prepare($query);
            $sth->execute();
        }
        $quote = $sth->fetchrow_hashref();
        # update the timestamp for that quote
        $query = 'UPDATE quotes SET timestamp = ? WHERE id = ?';
        $sth = C4::Context->dbh->prepare($query);
        $sth->execute(DateTime::Format::MySQL->format_datetime(DateTime->now), $quote->{'id'});
    }
    return $quote;
}

sub _normalize_match_point {
    my $match_point = shift;
    (my $normalized_match_point) = $match_point =~ /([\d-]*[X]*)/;
    $normalized_match_point =~ s/-//g;

    return $normalized_match_point;
}

sub _isbn_cleanup {
    require Business::ISBN;
    my $isbn = Business::ISBN->new( $_[0] );
    if ( $isbn ) {
        $isbn = $isbn->as_isbn10 if $isbn->type eq 'ISBN13';
        if (defined $isbn) {
            return $isbn->as_string([]);
        }
    }
    return;
}

1;

__END__

=head1 AUTHOR

Koha Team

=cut
