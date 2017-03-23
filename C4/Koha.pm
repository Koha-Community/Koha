package C4::Koha;

# Copyright 2000-2002 Katipo Communications
# Parts Copyright 2010 Nelsonville Public Library
# Parts copyright 2010 BibLibre
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


use strict;
#use warnings; FIXME - Bug 2505

use C4::Context;
use Koha::Caches;
use Koha::DateUtils qw(dt_from_string);
use Koha::AuthorisedValues;
use Koha::Libraries;
use Koha::MarcSubfieldStructures;
use DateTime::Format::MySQL;
use Business::ISBN;
use Business::ISSN;
use autouse 'Data::cselectall_arrayref' => qw(Dumper);
use DBI qw(:sql_types);
use vars qw(@ISA @EXPORT @EXPORT_OK $DEBUG);

BEGIN {
	require Exporter;
	@ISA    = qw(Exporter);
	@EXPORT = qw(
        &GetPrinters &GetPrinter
        &GetItemTypesCategorized
        &getallthemes
        &getFacets
        &getnbpages
		&getitemtypeimagedir
		&getitemtypeimagesrc
		&getitemtypeimagelocation
		&GetAuthorisedValues
		&GetNormalizedUPC
		&GetNormalizedISBN
		&GetNormalizedEAN
		&GetNormalizedOCLCNumber
        &xml_escape

        &GetVariationsOfISBN
        &GetVariationsOfISBNs
        &NormalizeISBN
        &GetVariationsOfISSN
        &GetVariationsOfISSNs
        &NormalizeISSN

		$DEBUG
	);
	$DEBUG = 0;
@EXPORT_OK = qw( GetDailyQuote );
}

=head1 NAME

C4::Koha - Perl Module containing convenience functions for Koha scripts

=head1 SYNOPSIS

use C4::Koha;

=head1 DESCRIPTION

Koha.pm provides many functions for Koha scripts.

=head1 FUNCTIONS

=cut

=head2 GetItemTypesCategorized

    $categories = GetItemTypesCategorized();

Returns a hashref containing search categories.
A search category will be put in the hash if at least one of its itemtypes is visible in OPAC.
The categories must be part of Authorized Values (ITEMTYPECAT)

=cut

sub GetItemTypesCategorized {
    my $dbh   = C4::Context->dbh;
    # Order is important, so that partially hidden (some items are not visible in OPAC) search
    # categories will be visible. hideinopac=0 must be last.
    my $query = q|
        SELECT itemtype, description, imageurl, hideinopac, 0 as 'iscat' FROM itemtypes WHERE ISNULL(searchcategory) or length(searchcategory) = 0
        UNION
        SELECT DISTINCT searchcategory AS `itemtype`,
                        authorised_values.lib_opac AS description,
                        authorised_values.imageurl AS imageurl,
                        hideinopac, 1 as 'iscat'
        FROM itemtypes
        LEFT JOIN authorised_values ON searchcategory = authorised_value
        WHERE searchcategory > '' and hideinopac=1
        UNION
        SELECT DISTINCT searchcategory AS `itemtype`,
                        authorised_values.lib_opac AS description,
                        authorised_values.imageurl AS imageurl,
                        hideinopac, 1 as 'iscat'
        FROM itemtypes
        LEFT JOIN authorised_values ON searchcategory = authorised_value
        WHERE searchcategory > '' and hideinopac=0
        |;
return ($dbh->selectall_hashref($query,'itemtype'));
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
                sep   => C4::Context->preference("UNIMARCAuthorsFacetsSeparator"),
            },
            {
                idx   => 'se',
                label => 'Series',
                tags  => [ qw/ 225a / ],
                sep   => ', ',
            },
            {
                idx  => 'location',
                label => 'Location',
                tags        => [ qw/ 995e / ],
            },
            {
                idx => 'ccode',
                label => 'CollectionCodes',
                tags => [ qw / 099t 955h / ],
            }
            ];

            unless ( Koha::Libraries->search->count == 1 )
            {
                my $DisplayLibraryFacets = C4::Context->preference('DisplayLibraryFacets');
                if (   $DisplayLibraryFacets eq 'both'
                    || $DisplayLibraryFacets eq 'holding' )
                {
                    push(
                        @$facets,
                        {
                            idx   => 'holdingbranch',
                            label => 'HoldingLibrary',
                            tags  => [qw / 995c /],
                        }
                    );
                }

                if (   $DisplayLibraryFacets eq 'both'
                    || $DisplayLibraryFacets eq 'home' )
                {
                push(
                    @$facets,
                    {
                        idx   => 'homebranch',
                        label => 'HomeLibrary',
                        tags  => [qw / 995b /],
                    }
                );
                }
            }
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
            {
                idx => 'location',
                label => 'Location',
                tags => [ qw / 952c / ],
            },
            {
                idx => 'ccode',
                label => 'CollectionCodes',
                tags => [ qw / 9528 / ],
            }
            ];

            unless ( Koha::Libraries->search->count == 1 )
            {
                my $DisplayLibraryFacets = C4::Context->preference('DisplayLibraryFacets');
                if (   $DisplayLibraryFacets eq 'both'
                    || $DisplayLibraryFacets eq 'holding' )
                {
                    push(
                        @$facets,
                        {
                            idx   => 'holdingbranch',
                            label => 'HoldingLibrary',
                            tags  => [qw / 952b /],
                        }
                    );
                }

                if (   $DisplayLibraryFacets eq 'both'
                    || $DisplayLibraryFacets eq 'home' )
                {
                push(
                    @$facets,
                    {
                        idx   => 'homebranch',
                        label => 'HomeLibrary',
                        tags  => [qw / 952a /],
                    }
                );
                }
            }
    }
    return $facets;
}

=head2 GetAuthorisedValues

  $authvalues = GetAuthorisedValues([$category]);

This function returns all authorised values from the'authorised_value' table in a reference to array of hashrefs.

C<$category> returns authorised values for just one category (optional).

C<$opac> If set to a true value, displays OPAC descriptions rather than normal ones when they exist.

=cut

sub GetAuthorisedValues {
    my ( $category, $opac ) = @_;

    # Is this cached already?
    $opac = $opac ? 1 : 0;    # normalise to be safe
    my $branch_limit =
      C4::Context->userenv ? C4::Context->userenv->{"branch"} : "";
    my $cache_key =
      "AuthorisedValues-$category-$opac-$branch_limit";
    my $cache  = Koha::Caches->get_instance();
    my $result = $cache->get_from_cache($cache_key);
    return $result if $result;

    my @results;
    my $dbh      = C4::Context->dbh;
    my $query = qq{
        SELECT DISTINCT av.*
        FROM authorised_values av
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
    $query .= ' ORDER BY category, ' . (
                $opac ? 'COALESCE(lib_opac, lib)'
                      : 'lib, lib_opac'
              );

    my $sth = $dbh->prepare($query);

    $sth->execute( @where_args );
    while (my $data=$sth->fetchrow_hashref) {
        if ($opac && $data->{lib_opac}) {
            $data->{lib} = $data->{lib_opac};
        }
        push @results, $data;
    }
    $sth->finish;

    $cache->set_in_cache( $cache_key, \@results, { expiry => 5 } );
    return \@results;
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

=head2 display_marc_indicators

  my $display_form = C4::Koha::display_marc_indicators($field);

C<$field> is a MARC::Field object

Generate a display form of the indicators of a variable
MARC field, replacing any blanks with '#'.

=cut

sub display_marc_indicators {
    my $field = shift;
    my $indicators = '';
    if ($field && $field->tag() >= 10) {
        $indicators = $field->indicator(1) . $field->indicator(2);
        $indicators =~ s/ /#/g;
    }
    return $indicators;
}

sub GetNormalizedUPC {
    my ($marcrecord,$marcflavour) = @_;

    return unless $marcrecord;
    if ($marcflavour eq 'UNIMARC') {
        my @fields = $marcrecord->field('072');
        foreach my $field (@fields) {
            my $upc = _normalize_match_point($field->subfield('a'));
            if ($upc) {
                return $upc;
            }
        }

    }
    else { # assume marc21 if not unimarc
        my @fields = $marcrecord->field('024');
        foreach my $field (@fields) {
            my $indicator = $field->indicator(1);
            my $upc = _normalize_match_point($field->subfield('a'));
            if ($upc && $indicator == 1 ) {
                return $upc;
            }
        }
    }
}

# Normalizes and returns the first valid ISBN found in the record
# ISBN13 are converted into ISBN10. This is required to get some book cover images.
sub GetNormalizedISBN {
    my ($isbn,$marcrecord,$marcflavour) = @_;
    if ($isbn) {
        # Koha attempts to store multiple ISBNs in biblioitems.isbn, separated by " | "
        # anything after " | " should be removed, along with the delimiter
        ($isbn) = split(/\|/, $isbn );
        return _isbn_cleanup($isbn);
    }

    return unless $marcrecord;

    if ($marcflavour eq 'UNIMARC') {
        my @fields = $marcrecord->field('010');
        foreach my $field (@fields) {
            my $isbn = $field->subfield('a');
            if ($isbn) {
                return _isbn_cleanup($isbn);
            }
        }
    }
    else { # assume marc21 if not unimarc
        my @fields = $marcrecord->field('020');
        foreach my $field (@fields) {
            $isbn = $field->subfield('a');
            if ($isbn) {
                return _isbn_cleanup($isbn);
            }
        }
    }
}

sub GetNormalizedEAN {
    my ($marcrecord,$marcflavour) = @_;

    return unless $marcrecord;

    if ($marcflavour eq 'UNIMARC') {
        my @fields = $marcrecord->field('073');
        foreach my $field (@fields) {
            my $ean = _normalize_match_point($field->subfield('a'));
            if ( $ean ) {
                return $ean;
            }
        }
    }
    else { # assume marc21 if not unimarc
        my @fields = $marcrecord->field('024');
        foreach my $field (@fields) {
            my $indicator = $field->indicator(1);
            my $ean = _normalize_match_point($field->subfield('a'));
            if ( $ean && $indicator == 3  ) {
                return $ean;
            }
        }
    }
}

sub GetNormalizedOCLCNumber {
    my ($marcrecord,$marcflavour) = @_;
    return unless $marcrecord;

    if ($marcflavour ne 'UNIMARC' ) {
        my @fields = $marcrecord->field('035');
        foreach my $field (@fields) {
            my $oclc = $field->subfield('a');
            if ($oclc =~ /OCoLC/) {
                $oclc =~ s/\(OCoLC\)//;
                return $oclc;
            }
        }
    } else {
        # TODO for UNIMARC
    }
    return
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
        # chose a random id within that range if there is more than one quote
        my $offset = int(rand($range));
        # grab it
        $query = 'SELECT * FROM quotes ORDER BY id LIMIT 1 OFFSET ?';
        $sth = C4::Context->dbh->prepare($query);
        # see http://www.perlmonks.org/?node_id=837422 for why
        # we're being verbose and using bind_param
        $sth->bind_param(1, $offset, SQL_INTEGER);
        $sth->execute();
        $quote = $sth->fetchrow_hashref();
        # update the timestamp for that quote
        $query = 'UPDATE quotes SET timestamp = ? WHERE id = ?';
        $sth = C4::Context->dbh->prepare($query);
        $sth->execute(
            DateTime::Format::MySQL->format_datetime( dt_from_string() ),
            $quote->{'id'}
        );
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
    my ($isbn) = @_;
    return NormalizeISBN(
        {
            isbn          => $isbn,
            format        => 'ISBN-10',
            strip_hyphens => 1,
        }
    ) if $isbn;
}

=head2 NormalizedISBN

  my $isbns = NormalizedISBN({
    isbn => $isbn,
    strip_hyphens => [0,1],
    format => ['ISBN-10', 'ISBN-13']
  });

  Returns an isbn validated by Business::ISBN.
  Optionally strips hyphens and/or forces the isbn
  to be of the specified format.

  If the string cannot be validated as an isbn,
  it returns nothing.

=cut

sub NormalizeISBN {
    my ($params) = @_;

    my $string        = $params->{isbn};
    my $strip_hyphens = $params->{strip_hyphens};
    my $format        = $params->{format};

    return unless $string;

    my $isbn = Business::ISBN->new($string);

    if ( $isbn && $isbn->is_valid() ) {

        if ( $format eq 'ISBN-10' ) {
            $isbn = $isbn->as_isbn10();
        }
        elsif ( $format eq 'ISBN-13' ) {
            $isbn = $isbn->as_isbn13();
        }
        return unless $isbn;

        if ($strip_hyphens) {
            $string = $isbn->as_string( [] );
        } else {
            $string = $isbn->as_string();
        }

        return $string;
    }
}

=head2 GetVariationsOfISBN

  my @isbns = GetVariationsOfISBN( $isbn );

  Returns a list of variations of the given isbn in
  both ISBN-10 and ISBN-13 formats, with and without
  hyphens.

  In a scalar context, the isbns are returned as a
  string delimited by ' | '.

=cut

sub GetVariationsOfISBN {
    my ($isbn) = @_;

    return unless $isbn;

    my @isbns;

    push( @isbns, NormalizeISBN({ isbn => $isbn }) );
    push( @isbns, NormalizeISBN({ isbn => $isbn, format => 'ISBN-10' }) );
    push( @isbns, NormalizeISBN({ isbn => $isbn, format => 'ISBN-13' }) );
    push( @isbns, NormalizeISBN({ isbn => $isbn, format => 'ISBN-10', strip_hyphens => 1 }) );
    push( @isbns, NormalizeISBN({ isbn => $isbn, format => 'ISBN-13', strip_hyphens => 1 }) );

    # Strip out any "empty" strings from the array
    @isbns = grep { defined($_) && $_ =~ /\S/ } @isbns;

    return wantarray ? @isbns : join( " | ", @isbns );
}

=head2 GetVariationsOfISBNs

  my @isbns = GetVariationsOfISBNs( @isbns );

  Returns a list of variations of the given isbns in
  both ISBN-10 and ISBN-13 formats, with and without
  hyphens.

  In a scalar context, the isbns are returned as a
  string delimited by ' | '.

=cut

sub GetVariationsOfISBNs {
    my (@isbns) = @_;

    @isbns = map { GetVariationsOfISBN( $_ ) } @isbns;

    return wantarray ? @isbns : join( " | ", @isbns );
}

=head2 NormalizedISSN

  my $issns = NormalizedISSN({
          issn => $issn,
          strip_hyphen => [0,1]
          });

  Returns an issn validated by Business::ISSN.
  Optionally strips hyphen.

  If the string cannot be validated as an issn,
  it returns nothing.

=cut

sub NormalizeISSN {
    my ($params) = @_;

    my $string        = $params->{issn};
    my $strip_hyphen  = $params->{strip_hyphen};

    my $issn = Business::ISSN->new($string);

    if ( $issn && $issn->is_valid ){

        if ($strip_hyphen) {
            $string = $issn->_issn;
        }
        else {
            $string = $issn->as_string;
        }
        return $string;
    }

}

=head2 GetVariationsOfISSN

  my @issns = GetVariationsOfISSN( $issn );

  Returns a list of variations of the given issn in
  with and without a hyphen.

  In a scalar context, the issns are returned as a
  string delimited by ' | '.

=cut

sub GetVariationsOfISSN {
    my ( $issn ) = @_;

    return unless $issn;

    my @issns;
    my $str = NormalizeISSN({ issn => $issn });
    if( $str ) {
        push @issns, $str;
        push @issns, NormalizeISSN({ issn => $issn, strip_hyphen => 1 });
    }  else {
        push @issns, $issn;
    }

    # Strip out any "empty" strings from the array
    @issns = grep { defined($_) && $_ =~ /\S/ } @issns;

    return wantarray ? @issns : join( " | ", @issns );
}

=head2 GetVariationsOfISSNs

  my @issns = GetVariationsOfISSNs( @issns );

  Returns a list of variations of the given issns in
  with and without a hyphen.

  In a scalar context, the issns are returned as a
  string delimited by ' | '.

=cut

sub GetVariationsOfISSNs {
    my (@issns) = @_;

    @issns = map { GetVariationsOfISSN( $_ ) } @issns;

    return wantarray ? @issns : join( " | ", @issns );
}

1;

__END__

=head1 AUTHOR

Koha Team

=cut
