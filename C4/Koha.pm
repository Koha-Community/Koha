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
use URI::Split qw(uri_split);

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
		&get_infos_of
		&get_notforloan_label_of
		&getitemtypeimagedir
		&getitemtypeimagesrc
		&getitemtypeimagelocation
		&GetAuthorisedValues
		&GetAuthorisedValueCategories
		&GetKohaAuthorisedValues
		&GetAuthValCode
		&GetNormalizedUPC
		&GetNormalizedISBN
		&GetNormalizedEAN
		&GetNormalizedOCLCNumber

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

  $itemtype = &getitemtype($itemtype);

Returns information about an itemtype.

=cut

sub getitemtypeinfo {
    my ($itemtype) = @_;
    my $dbh        = C4::Context->dbh;
    my $sth        = $dbh->prepare("select * from itemtypes where itemtype=?");
    $sth->execute($itemtype);
    my $res = $sth->fetchrow_hashref;

    $res->{imageurl} = getitemtypeimagelocation( 'intranet', $res->{imageurl} );

    return $res;
}

=head2 getitemtypeimagedir

=over

=item 4

  my $directory = getitemtypeimagedir( 'opac' );

pass in 'opac' or 'intranet'. Defaults to 'opac'.

returns the full path to the appropriate directory containing images.

=back

=cut

sub getitemtypeimagedir {
	my $src = shift || 'opac';
	if ($src eq 'intranet') {
		return C4::Context->config('intrahtdocs') . '/' .C4::Context->preference('template') . '/img/itemtypeimg';
	} else {
		return C4::Context->config('opachtdocs') . '/' . C4::Context->preference('template') . '/itemtypeimg';
	}
}

sub getitemtypeimagesrc {
	my $src = shift || 'opac';
	if ($src eq 'intranet') {
		return '/intranet-tmpl' . '/' .	C4::Context->preference('template') . '/img/itemtypeimg';
	} else {
		return '/opac-tmpl' . '/' . C4::Context->preference('template') . '/itemtypeimg';
	}
}

sub getitemtypeimagelocation($$) {
	my ( $src, $image ) = @_;

	return '' if ( !$image );

	my $scheme = ( uri_split( $image ) )[0];

	return $image if ( $scheme );

	return getitemtypeimagesrc( $src ) . '/' . $image;
}

=head3 _getImagesFromDirectory

  Find all of the image files in a directory in the filesystem

  parameters:
    a directory name

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
        return @images;
    } else {
        warn "unable to opendir $directoryname: $!";
        return;
    }
}

=head3 _getSubdirectoryNames

  Find all of the directories in a directory in the filesystem

  parameters:
    a directory name

  returns: a list of subdirectories in that directory.

  Notes: this does not traverse into subdirectories. Only the first
      level of subdirectories are returned.
    The directory names returned don't have the parent directory name
      on them.

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
        my @imagelist     = (); # hashrefs of image info
        my @imagenames = _getImagesFromDirectory( File::Spec->catfile( $paths->{'staff'}{'filesystem'}, $imagesubdir ) );
        foreach my $thisimage ( @imagenames ) {
            push( @imagelist,
                  { KohaImage     => "$imagesubdir/$thisimage",
                    StaffImageUrl => join( '/', $paths->{'staff'}{'url'}, $imagesubdir, $thisimage ),
                    OpacImageUrl  => join( '/', $paths->{'opac'}{'url'}, $imagesubdir, $thisimage ),
                    checked       => "$imagesubdir/$thisimage" eq $checked ? 1 : 0,
               }
             );
        }
        push @imagesets, { imagesetname => $imagesubdir,
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

sub GetPrinter ($$) {
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
            ];

            my $library_facet;

            $library_facet = {
                link_value  => 'branch',
                label_value => 'Libraries',
                tags        => [ '995', ],
                subfield    => 'b',
                expanded    => '1',
            };
            push @$facets, $library_facet unless C4::Context->preference("singleBranchMode");
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
            ];
            my $library_facet;
            $library_facet = {
                link_value  => 'branch',
                label_value => 'Libraries',
                tags        => [ '952', ],
                subfield    => 'b',
                expanded    => '1',
            };
            push @$facets, $library_facet unless C4::Context->preference("singleBranchMode");
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

=over 4

my $servers = displayServers();

my $servers = displayServers( $position );

my $servers = displayServers( $position, $type );

=back

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

$authvalues = GetAuthorisedValues([$category], [$selected]);

This function returns all authorised values from the'authosied_value' table in a reference to array of hashrefs.

C<$category> returns authorised values for just one category (optional).

=cut

sub GetAuthorisedValues {
    my ($category,$selected) = @_;
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
        push @results, $data;
	}
    #my $data = $sth->fetchall_arrayref({});
    return \@results; #$data;
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
    while (my $category = $sth->fetchrow_array) {
        push @results, $category;
    }
    return \@results;
}

=head2 GetKohaAuthorisedValues
	
	Takes $kohafield, $fwcode as parameters.
	Returns hashref of Code => description
	Returns undef 
	  if no authorised value category is defined for the kohafield.

=cut

sub GetKohaAuthorisedValues {
  my ($kohafield,$fwcode,$codedvalue) = @_;
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
   	return \%values;
  } else {
  	return undef;
  }
}

=head2 display_marc_indicators

=over 4

# field is a MARC::Field object
my $display_form = C4::Koha::display_marc_indicators($field);

=back

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

    if ($marcflavour eq 'MARC21') {
        @fields = $record->field('024');
        foreach my $field (@fields) {
            my $indicator = $field->indicator(1);
            my $upc = _normalize_match_point($field->subfield('a'));
            if ($indicator == 1 and $upc ne '') {
                return $upc;
            }
        }
    }
    else { # assume unimarc if not marc21
        @fields = $record->field('072');
        foreach my $field (@fields) {
            my $upc = _normalize_match_point($field->subfield('a'));
            if ($upc ne '') {
                return $upc;
            }
        }
    }
}

# Normalizes and returns the first valid ISBN found in the record
sub GetNormalizedISBN {
    my ($isbn,$record,$marcflavour) = @_;
    my @fields;
    if ($isbn) {
        return _isbn_cleanup($isbn);
    }
    return undef unless $record;

    if ($marcflavour eq 'MARC21') {
        @fields = $record->field('020');
        foreach my $field (@fields) {
            $isbn = $field->subfield('a');
            if ($isbn) {
                return _isbn_cleanup($isbn);
            } else {
                return undef;
            }
        }
    }
    else { # assume unimarc if not marc21
        @fields = $record->field('010');
        foreach my $field (@fields) {
            my $isbn = $field->subfield('a');
            if ($isbn) {
                return _isbn_cleanup($isbn);
            } else {
                return undef;
            }
        }
    }

}

sub GetNormalizedEAN {
    my ($record,$marcflavour) = @_;
    my (@fields,$ean);

    if ($marcflavour eq 'MARC21') {
        @fields = $record->field('024');
        foreach my $field (@fields) {
            my $indicator = $field->indicator(1);
            $ean = _normalize_match_point($field->subfield('a'));
            if ($indicator == 3 and $ean ne '') {
                return $ean;
            }
        }
    }
    else { # assume unimarc if not marc21
        @fields = $record->field('073');
        foreach my $field (@fields) {
            $ean = _normalize_match_point($field->subfield('a'));
            if ($ean ne '') {
                return $ean;
            }
        }
    }
}
sub GetNormalizedOCLCNumber {
    my ($record,$marcflavour) = @_;
    my (@fields,$oclc);

    if ($marcflavour eq 'MARC21') {
        @fields = $record->field('035');
        foreach my $field (@fields) {
            $oclc = $field->subfield('a');
            if ($oclc =~ /OCoLC/) {
                $oclc =~ s/\(OCoLC\)//;
                return $oclc;
            } else {
                return undef;
            }
        }
    }
    else { # TODO: add UNIMARC fields
    }
}

sub _normalize_match_point {
    my $match_point = shift;
    (my $normalized_match_point) = $match_point =~ /([\d-]*[X]*)/;
    $normalized_match_point =~ s/-//g;

    return $normalized_match_point;
}

sub _isbn_cleanup ($) {
    my $normalized_isbn = shift;
    $normalized_isbn =~ s/-//g;
    $normalized_isbn =~/([0-9x]{1,})/i;
    $normalized_isbn = $1;
    if (
        $normalized_isbn =~ /\b(\d{13})\b/ or
        $normalized_isbn =~ /\b(\d{12})\b/i or
        $normalized_isbn =~ /\b(\d{10})\b/ or
        $normalized_isbn =~ /\b(\d{9}X)\b/i
    ) { 
        return $1;
    }
    return undef;
}

1;

__END__

=head1 AUTHOR

Koha Team

=cut
