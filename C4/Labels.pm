package C4::Labels;

# Copyright 2006 Katipo Communications.
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
# use warnings;   # FIXME
use vars qw($VERSION @ISA @EXPORT);

use PDF::Reuse;
use Text::Wrap;
use Algorithm::CheckDigits;
use C4::Members;
use C4::Branch;
use C4::Debug;
use C4::Biblio;
use Text::CSV_XS;
use Data::Dumper;

BEGIN {
	$VERSION = 0.03;
	require Exporter;
	@ISA    = qw(Exporter);
	@EXPORT = qw(
		&get_label_options &GetLabelItems
		&build_circ_barcode &draw_boundaries
		&drawbox &GetActiveLabelTemplate
		&GetAllLabelTemplates &DeleteTemplate
		&GetSingleLabelTemplate &SaveTemplate
		&CreateTemplate &SetActiveTemplate
		&SaveConf &GetTextWrapCols
		&GetUnitsValue
                &DrawSpineText
                &DrawBarcode
                &DrawPatronCardText
		&get_printingtypes &GetPatronCardItems
		&get_layouts
		&get_barcode_types
		&get_batches &delete_batch
		&add_batch &printText
		&GetItemFields
		&get_text_fields
		get_layout &save_layout &add_layout
		&set_active_layout
		&build_text_dropbox
		&delete_layout &get_active_layout
		&get_highest_batch
		&deduplicate_batch
        &GetAllPrinterProfiles &GetSinglePrinterProfile
        &SaveProfile &CreateProfile &DeleteProfile
        &GetAssociatedProfile &SetAssociatedProfile
	);
}


=head1 NAME

C4::Labels - Functions for printing spine labels and barcodes in Koha

=head1 FUNCTIONS

=head2 get_label_options;

	$options = get_label_options()

Return a pointer on a hash list containing info from labels_conf table in Koha DB.

=cut

sub get_label_options {
    my $query2 = " SELECT * FROM labels_conf where active = 1";		# FIXME: exact same as get_active_layout
    my $sth    = C4::Context->dbh->prepare($query2);
    $sth->execute();
    return $sth->fetchrow_hashref;
}

sub get_layouts {
    my $dbh = C4::Context->dbh;
    my $query = " Select * from labels_conf";
    my $sth   = $dbh->prepare($query);
    $sth->execute();
    my @resultsloop;
    while ( my $data = $sth->fetchrow_hashref ) {
        $data->{'fieldlist'} = get_text_fields( $data->{'id'} );
        push( @resultsloop, $data );
    }
    return @resultsloop;
}

sub get_layout {
    my ($layout_id) = @_;
    my $dbh = C4::Context->dbh;
    # get the actual items to be printed.
    my $query = " Select * from labels_conf where id = ?";
    my $sth   = $dbh->prepare($query);
    $sth->execute($layout_id);
    my $data = $sth->fetchrow_hashref;
    return $data;
}

sub get_active_layout {
    my $query = " Select * from labels_conf where active = 1";		# FIXME: exact same as get_label_options
    my $sth   = C4::Context->dbh->prepare($query);
    $sth->execute();
    return $sth->fetchrow_hashref;
}

sub delete_layout {
    my ($layout_id) = @_;
    my $dbh = C4::Context->dbh;
    # get the actual items to be printed.
    my $query = "delete from  labels_conf where id = ?";
    my $sth   = $dbh->prepare($query);
    $sth->execute($layout_id);
}

sub get_printingtypes {
    my ($layout_id) = @_;
    my @printtypes;
# FIXME hard coded print types
    push( @printtypes, { code => 'BAR',    desc => "barcode only" } );
    push( @printtypes, { code => 'BIB',    desc => "biblio only" } );
    push( @printtypes, { code => 'BARBIB', desc => "barcode / biblio" } );
    push( @printtypes, { code => 'BIBBAR', desc => "biblio / barcode" } );
    push( @printtypes, { code => 'ALT',    desc => "alternating labels" } );
    push( @printtypes, { code => 'CSV',    desc => "csv output" } );
    push( @printtypes, { code => 'PATCRD', desc => "patron cards" } );

    my $conf             = get_layout($layout_id);
    my $active_printtype = $conf->{'printingtype'};

    # lop thru layout, insert selected to hash

    foreach my $printtype (@printtypes) {
        if ( $printtype->{'code'} eq $active_printtype ) {
            $printtype->{'active'} = 1;
        }
    }
    return @printtypes;
}

# this sub (build_text_dropbox) is deprecated and should be deleted. 
# rch 2008.04.15
#
sub build_text_dropbox {
    my ($order) = @_;
    my $field_count = 7;    # <-----------       FIXME hard coded
    my @lines;
    !$order
      ? push( @lines, { num => '', selected => '1' } )
      : push( @lines, { num => '' } );
    for ( my $i = 1 ; $i <= $field_count ; $i++ ) {
        my $line = { num => "$i" };
        $line->{'selected'} = 1 if $i eq $order;
        push( @lines, $line );
    }
    return @lines;
}

sub get_text_fields {
    my ( $layout_id, $sorttype ) = @_;
    my @sorted_fields;
    my $error;
    my $sortorder = get_layout($layout_id);
    if ( $sortorder->{formatstring} ) {
        if ( !$sorttype ) {
            return $sortorder->{formatstring};
        }
        else {
            my $csv    = Text::CSV_XS->new( { allow_whitespace => 1 } );
            my $line   = $sortorder->{formatstring};
            my $status = $csv->parse($line);
            @sorted_fields =
              map { { 'code' => $_, desc => $_ } } $csv->fields();
            $error = $csv->error_input();
            warn $error if $error;    # TODO - do more with this.
        }
    }
    else {

     # These fields are hardcoded based on the template for label-edit-layout.pl
        my @text_fields = (
            {
                code  => 'itemtype',
                desc  => "Item Type",
                order => $sortorder->{'itemtype'}
            },
            {
                code  => 'issn',
                desc  => "ISSN",
                order => $sortorder->{'issn'}
            },
            {
                code  => 'isbn',
                desc  => "ISBN",
                order => $sortorder->{'isbn'}
            },
            {
                code  => 'barcode',
                desc  => "Barcode",
                order => $sortorder->{'barcode'}
            },
            {
                code  => 'author',
                desc  => "Author",
                order => $sortorder->{'author'}
            },
            {
                code  => 'title',
                desc  => "Title",
                order => $sortorder->{'title'}
            },
            {
                code  => 'itemcallnumber',
                desc  => "Call Number",
                order => $sortorder->{'itemcallnumber'}
            },
        );

        my @new_fields = ();
        foreach my $field (@text_fields) {
            push( @new_fields, $field ) if $field->{'order'} > 0;
        }

        @sorted_fields = sort { $$a{order} <=> $$b{order} } @new_fields;
    }

    # if we have a 'formatstring', then we ignore these hardcoded fields.
    my $active_fields;

    if ( $sorttype eq 'codes' )
    { # FIXME: This sub should really always return the array of hashrefs and let the caller take what he wants from that -fbcit
        return @sorted_fields;
    }
    else {
        foreach my $field (@sorted_fields) {
            $active_fields .= "$field->{'desc'} ";
        }
        return $active_fields;
    }
}

=head2 sub add_batch

=over 4

 add_batch($batch_type,\@batch_list);
 if $batch_list is supplied,
   create a new batch with those items.
 else, return the next available batch_id.

=back

=cut

sub add_batch ($;$) {
	my $table = (@_ and 'patroncards' eq shift) ? 'patroncards' : 'labels';
    my $batch_list = (@_) ? shift : undef;
    my $dbh = C4::Context->dbh;
    # FIXME : batch_id  should be an auto_incr INT.  Temporarily casting as int ( see koha bug 2555 )
    # until a label_batches table is added, and we can convert batch_id to int.
    my $q ="SELECT MAX( CAST(batch_id AS SIGNED) ) FROM $table";
    my $sth = $dbh->prepare($q);
    $sth->execute();
    my ($batch_id) = $sth->fetchrow_array || 0;
	$batch_id++;
	if ($batch_list) {
		if ($table eq 'patroncards') {
	 		$sth = $dbh->prepare("INSERT INTO $table (`batch_id`,`borrowernumber`) VALUES (?,?)"); 
		} else {
	 		$sth = $dbh->prepare("INSERT INTO $table (`batch_id`,`itemnumber`    ) VALUES (?,?)"); 
		}
		for (@$batch_list) {
			$sth->execute($batch_id,$_);
		}
	}
	return $batch_id;
}

#FIXME: Needs to be ported to receive $batch_type
# ... this looks eerily like add_batch() ...
sub get_highest_batch {
	my $table = (@_ and 'patroncards' eq shift) ? 'patroncards' : 'labels';
    my $q =
      "select distinct batch_id from $table order by batch_id desc limit 1";
    my $sth = C4::Context->dbh->prepare($q);
    $sth->execute();
    my $data = $sth->fetchrow_hashref or return 1;
	return ($data->{'batch_id'} || 1);
}


sub get_batches (;$) {
	my $table = (@_ and 'patroncards' eq shift) ? 'patroncards' : 'labels';
    my $q   = "SELECT batch_id, COUNT(*) AS num FROM $table GROUP BY batch_id";
    my $sth = C4::Context->dbh->prepare($q);
    $sth->execute();
	my $batches = $sth->fetchall_arrayref({});
	return @$batches;
}

sub delete_batch {
    my ($batch_id, $batch_type) = @_;
    warn "Deleteing batch (id:$batch_id) of type $batch_type";
    my $q   = "DELETE FROM $batch_type WHERE batch_id  = ?";
    my $sth = C4::Context->dbh->prepare($q);
    $sth->execute($batch_id);
}

sub get_barcode_types {
    my ($layout_id) = @_;
    my $layout      = get_layout($layout_id);
    my $barcode     = $layout->{'barcodetype'};
    my @array;

    push( @array, { code => 'CODE39',      desc => 'Code 39' } );
    push( @array, { code => 'CODE39MOD',   desc => 'Code39 + Modulo43' } );
    push( @array, { code => 'CODE39MOD10', desc => 'Code39 + Modulo10' } ); 
    push( @array, { code => 'ITF',         desc => 'Interleaved 2 of 5' } );

    foreach my $line (@array) {
        if ( $line->{'code'} eq $barcode ) {
            $line->{'active'} = 1;
        }
    }
    return @array;
}

sub GetUnitsValue {
    my ($units) = @_;
    my $unitvalue;
    $unitvalue = '1'          if ( $units eq 'POINT' );
    $unitvalue = '2.83464567' if ( $units eq 'MM' );
    $unitvalue = '28.3464567' if ( $units eq 'CM' );
    $unitvalue = 72           if ( $units eq 'INCH' );
    return $unitvalue;
}

sub GetTextWrapCols {
    my ( $font, $fontsize, $label_width, $left_text_margin ) = @_;
    my $string = '0';
    my $strwidth;
    my $count = 0;
#    my $textlimit = $label_width - ($left_text_margin);
    my $textlimit = $label_width - ( 3 * $left_text_margin);

    while ( $strwidth < $textlimit ) {
        $strwidth = prStrWidth( $string, $font, $fontsize );
        $string = $string . '0';
        #warn "strwidth:$strwidth, textlimit:$textlimit, count:$count string:$string";
        $count++;
    }
    return $count;
}

sub GetActiveLabelTemplate {
    my $dbh   = C4::Context->dbh;
    my $query = " SELECT * FROM labels_templates where active = 1 limit 1";
    my $sth   = $dbh->prepare($query);
    $sth->execute();
    my $active_tmpl = $sth->fetchrow_hashref;
    return $active_tmpl;
}

sub GetSingleLabelTemplate {
    my ($tmpl_id) = @_;
    my $dbh       = C4::Context->dbh;
    my $query     = " SELECT * FROM labels_templates where tmpl_id = ?";
    my $sth       = $dbh->prepare($query);
    $sth->execute($tmpl_id);
    my $template = $sth->fetchrow_hashref;
    return $template;
}

sub SetActiveTemplate {
    my ($tmpl_id) = @_;
    my $dbh   = C4::Context->dbh;
    my $query = " UPDATE labels_templates SET active = NULL";
    my $sth   = $dbh->prepare($query);
    $sth->execute();

    $query = "UPDATE labels_templates SET active = 1 WHERE tmpl_id = ?";
    $sth   = $dbh->prepare($query);
    $sth->execute($tmpl_id);
}

sub set_active_layout {
    my ($layout_id) = @_;
    my $dbh         = C4::Context->dbh;
    my $query       = " UPDATE labels_conf SET active = NULL";
    my $sth         = $dbh->prepare($query);
    $sth->execute();

    $query = "UPDATE labels_conf SET active = 1 WHERE id = ?";
    $sth   = $dbh->prepare($query);
    $sth->execute($layout_id);
}

sub DeleteTemplate {
    my ($tmpl_id) = @_;
    my $dbh       = C4::Context->dbh;
    my $query     = " DELETE  FROM labels_templates where tmpl_id = ?";
    my $sth       = $dbh->prepare($query);
    $sth->execute($tmpl_id);
}

sub SaveTemplate {
    my (
        $tmpl_id,     $tmpl_code,   $tmpl_desc,    $page_width,
        $page_height, $label_width, $label_height, $topmargin,
        $leftmargin,  $cols,        $rows,         $colgap,
        $rowgap,      $font,        $fontsize,     $units
    ) = @_;
    $debug and warn "Passed \$font:$font";
    my $dbh = C4::Context->dbh;
    my $query =
      " UPDATE labels_templates SET tmpl_code=?, tmpl_desc=?, page_width=?,
               page_height=?, label_width=?, label_height=?, topmargin=?,
               leftmargin=?, cols=?, rows=?, colgap=?, rowgap=?, font=?, fontsize=?,
	  		   units=? 
                  WHERE tmpl_id = ?";

    my $sth = $dbh->prepare($query);
    $sth->execute(
        $tmpl_code,   $tmpl_desc,    $page_width, $page_height,
        $label_width, $label_height, $topmargin,  $leftmargin,
        $cols,        $rows,         $colgap,     $rowgap,
        $font,        $fontsize,     $units,      $tmpl_id
    );
    my $dberror = $sth->errstr;
    return $dberror;
}

sub CreateTemplate {
    my $tmpl_id;
    my (
        $tmpl_code,   $tmpl_desc,    $page_width, $page_height,
        $label_width, $label_height, $topmargin,  $leftmargin,
        $cols,        $rows,         $colgap,     $rowgap,
        $font,        $fontsize,     $units
    ) = @_;

    my $dbh = C4::Context->dbh;

    my $query = "INSERT INTO labels_templates (tmpl_code, tmpl_desc, page_width,
                         page_height, label_width, label_height, topmargin,
                         leftmargin, cols, rows, colgap, rowgap, font, fontsize, units)
                         VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";

    my $sth = $dbh->prepare($query);
    $sth->execute(
        $tmpl_code,   $tmpl_desc,    $page_width, $page_height,
        $label_width, $label_height, $topmargin,  $leftmargin,
        $cols,        $rows,         $colgap,     $rowgap,
        $font,        $fontsize,    $units
    );
    my $dberror = $sth->errstr;
    return $dberror;
}

sub GetAllLabelTemplates {
    my $dbh = C4::Context->dbh;
    # get the actual items to be printed.
    my @data;
    my $query = " Select * from labels_templates ";
    my $sth   = $dbh->prepare($query);
    $sth->execute();
    my @resultsloop;
    while ( my $data = $sth->fetchrow_hashref ) {
        push( @resultsloop, $data );
    }
    #warn Dumper @resultsloop;
    return @resultsloop;
}

#sub SaveConf {
sub add_layout {

    my (
        $barcodetype,  $title,         	$subtitle, 	$isbn,       $issn,
        $itemtype,     $bcn,            $text_justify,        $callnum_split,
        $itemcallnumber, $author,     $tmpl_id,
        $printingtype, $guidebox,       $startlabel, $layoutname, $formatstring
    ) = @_;

    my $dbh    = C4::Context->dbh;
    my $query2 = "update labels_conf set active = NULL";
    my $sth2   = $dbh->prepare($query2);
    $sth2->execute();
    $query2 = "INSERT INTO labels_conf
            ( barcodetype, title, subtitle, isbn,issn, itemtype, barcode,
              text_justify, callnum_split, itemcallnumber, author, printingtype,
                guidebox, startlabel, layoutname, formatstring, active )
               values ( ?, ?,?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,?,?, 1 )";
    $sth2 = $dbh->prepare($query2);
    $sth2->execute(
        $barcodetype, $title, $subtitle, $isbn, $issn,
        $itemtype, $bcn,            $text_justify,    $callnum_split,
        $itemcallnumber, $author, $printingtype,
        $guidebox, $startlabel,     $layoutname, $formatstring
    );
    SetActiveTemplate($tmpl_id);
}

sub save_layout {

    my (
        $barcodetype,  $title,          $subtitle,	$isbn,       $issn,
        $itemtype,     $bcn,            $text_justify,        $callnum_split,
        $itemcallnumber, $author,     $tmpl_id,
        $printingtype, $guidebox,       $startlabel, $layoutname, $formatstring,
        $layout_id
    ) = @_;
### $layoutname
### $layout_id

    my $dbh    = C4::Context->dbh;
    my $query2 = "update labels_conf set 
             barcodetype=?, title=?, subtitle=?, isbn=?,issn=?, 
            itemtype=?, barcode=?,    text_justify=?, callnum_split=?,
            itemcallnumber=?, author=?,  printingtype=?,  
               guidebox=?, startlabel=?, layoutname=?, formatstring=? where id = ?";
    my $sth2 = $dbh->prepare($query2);
    $sth2->execute(
        $barcodetype, $title,          $subtitle,	$isbn,       $issn,
        $itemtype,    $bcn,            $text_justify,        $callnum_split,
        $itemcallnumber, $author,     $printingtype,
        $guidebox,    $startlabel,     $layoutname, $formatstring,  $layout_id
    );
}

=head2 GetAllPrinterProfiles;

    @profiles = GetAllPrinterProfiles()

Returns an array of references-to-hash, whos keys are .....

=cut

sub GetAllPrinterProfiles {
    my $dbh = C4::Context->dbh;
    my @data;
    my $query = "SELECT * FROM printers_profile AS pp INNER JOIN labels_templates AS lt ON pp.tmpl_id = lt.tmpl_id";
    my $sth = $dbh->prepare($query);
    $sth->execute();
    my @resultsloop;
    while ( my $data = $sth->fetchrow_hashref ) {
        push( @resultsloop, $data );
    }
    return @resultsloop;
}

=head2 GetSinglePrinterProfile;

    $profile = GetSinglePrinterProfile()

Returns a hashref whos keys are...

=cut

sub GetSinglePrinterProfile {
    my ($prof_id) = @_;
    my $query     = "SELECT * FROM printers_profile WHERE prof_id = ?";
    my $sth       = C4::Context->dbh->prepare($query);
    $sth->execute($prof_id);
    my $template = $sth->fetchrow_hashref;
    return $template;
}

=head2 SaveProfile;

    SaveProfile('parameters')

When passed a set of parameters, this function updates the given profile with the new parameters.

=cut

sub SaveProfile {
    my (
        $prof_id,       $offset_horz,   $offset_vert,   $creep_horz,    $creep_vert,    $units
    ) = @_;
    my $dbh = C4::Context->dbh;
    my $query =
      " UPDATE printers_profile
        SET offset_horz=?, offset_vert=?, creep_horz=?, creep_vert=?, unit=? 
        WHERE prof_id = ? ";
    my $sth = $dbh->prepare($query);
    $sth->execute(
        $offset_horz,   $offset_vert,   $creep_horz,    $creep_vert,    $units,         $prof_id
    );
}

=head2 CreateProfile;

    CreateProfile('parameters')

When passed a set of parameters, this function creates a new profile containing those parameters
and returns any errors.

=cut

sub CreateProfile {
    my (
        $prof_id,       $printername,   $paper_bin,     $tmpl_id,     $offset_horz,
        $offset_vert,   $creep_horz,    $creep_vert,    $units
    ) = @_;
    my $dbh = C4::Context->dbh;
    my $query = 
        " INSERT INTO printers_profile (prof_id, printername, paper_bin, tmpl_id,
                                        offset_horz, offset_vert, creep_horz, creep_vert, unit)
          VALUES(?,?,?,?,?,?,?,?,?) ";
    my $sth = $dbh->prepare($query);
    $sth->execute(
        $prof_id,       $printername,   $paper_bin,     $tmpl_id,     $offset_horz,
        $offset_vert,   $creep_horz,    $creep_vert,    $units
    );
    my $error =  $sth->errstr;
    return $error;
}

=head2 DeleteProfile;

    DeleteProfile(prof_id)

When passed a profile id, this function deletes that profile from the database and returns any errors.

=cut

sub DeleteProfile {
    my ($prof_id) = @_;
    my $dbh       = C4::Context->dbh;
    my $query     = " DELETE FROM printers_profile WHERE prof_id = ?";
    my $sth       = $dbh->prepare($query);
    $sth->execute($prof_id);
    my $error = $sth->errstr;
    return $error;
}

=head2 GetAssociatedProfile;

    $assoc_prof = GetAssociatedProfile(tmpl_id)

When passed a template id, this function returns the parameters from the currently associated printer profile
in a hashref where key=fieldname and value=fieldvalue.

=cut

sub GetAssociatedProfile {
    my ($tmpl_id) = @_;
    my $dbh   = C4::Context->dbh;
    # First we find out the prof_id for the associated profile...
    my $query = "SELECT * FROM labels_profile WHERE tmpl_id = ?";
    my $sth   = $dbh->prepare($query);
    $sth->execute($tmpl_id);
    my $assoc_prof = $sth->fetchrow_hashref or return;
    # Then we retrieve that profile and return it to the caller...
    $assoc_prof = GetSinglePrinterProfile($assoc_prof->{'prof_id'});
    return $assoc_prof;
}

=head2 SetAssociatedProfile;

    SetAssociatedProfile($prof_id, $tmpl_id)

When passed both a profile id and template id, this function establishes an association between the two. No more
than one profile may be associated with any given template at the same time.

=cut

sub SetAssociatedProfile {
    my ($prof_id, $tmpl_id) = @_;
    my $dbh = C4::Context->dbh;
    my $query = "INSERT INTO labels_profile (prof_id, tmpl_id) VALUES (?,?) ON DUPLICATE KEY UPDATE prof_id = ?";
    my $sth = $dbh->prepare($query);
    $sth->execute($prof_id, $tmpl_id, $prof_id);
}


=head2 GetLabelItems;

        $options = GetLabelItems()

Returns an array of references-to-hash, whos keys are the fields from the biblio, biblioitems, items and labels tables in the Koha database.

=cut

sub GetLabelItems {
    my ($batch_id) = @_;
    my $dbh = C4::Context->dbh;

    my @resultsloop = ();
    my $count;
    my @data;
    my $sth;
    
    if ($batch_id) {
        my $query3 = "
            SELECT *
            FROM labels
            WHERE batch_id = ?
            ORDER BY labelid";
        $sth = $dbh->prepare($query3);
        $sth->execute($batch_id);
    }
    else {
        my $query3 = "
            SELECT *
            FROM labels";
        $sth = $dbh->prepare($query3);
        $sth->execute();
    }
    my $cnt = $sth->rows;
    my $i1  = 1;
    while ( my $data = $sth->fetchrow_hashref ) {

        # lets get some summary info from each item
        my $query1 =
#            FIXME This makes for a very bulky data structure; data from tables w/duplicate col names also gets overwritten.
#            Something like this, perhaps, but this also causes problems because we need more fields sometimes.
#            SELECT i.barcode, i.itemcallnumber, i.itype, bi.isbn, bi.issn, b.title, b.author
           "SELECT bi.*, i.*, b.*
            FROM items AS i, biblioitems AS bi ,biblio AS b
            WHERE itemnumber=? AND i.biblioitemnumber=bi.biblioitemnumber AND bi.biblionumber=b.biblionumber";
        my $sth1 = $dbh->prepare($query1);
        $sth1->execute( $data->{'itemnumber'} );

        my $data1 = $sth1->fetchrow_hashref();
        $data1->{'labelno'}  = $i1;
        $data1->{'labelid'}  = $data->{'labelid'};
        $data1->{'batch_id'} = $batch_id;
        $data1->{'summary'} = "$data1->{'barcode'}, $data1->{'title'}, $data1->{'isbn'}";

        push( @resultsloop, $data1 );
        $sth1->finish;

        $i1++;
    }
    $sth->finish;
    return @resultsloop;

}

sub GetItemFields {
    my @fields = qw (
      barcode           title
      isbn              issn
      author            itemtype
      itemcallnumber
    );
    return @fields;
}

=head2 GetBarcodeData

=over 4

Parse labels_conf.formatstring value
(one value of the csv, which has already been split)
and return string from koha tables or MARC record.

=back

=cut

sub GetBarcodeData {
    my ( $f, $item, $record ) = @_;
    my $kohatables = &_descKohaTables();
    my $datastring = '';
    my $match_kohatable = join(
        '|',
        (
            @{ $kohatables->{biblio} },
            @{ $kohatables->{biblioitems} },
            @{ $kohatables->{items} }
        )
    );
    while ($f) {  
        $f =~ s/^\s?//;
        if ( $f =~ /^'(.*)'.*/ ) {
            # single quotes indicate a static text string.
            $datastring .= $1;
            $f = $';
        }
        elsif ( $f =~ /^($match_kohatable).*/ ) {
            $datastring .= $item->{$f};
            $f = $';
        }
        elsif ( $f =~ /^([0-9a-z]{3})(\w)(\W?).*?/ ) {
            my ($field,$subf,$ws) = ($1,$2,$3);
            my $subf_data;
            my ($itemtag, $itemsubfieldcode) = &GetMarcFromKohaField("items.itemnumber",'');
            my @marcfield = $record->field($field);
            if(@marcfield) {
                if($field eq $itemtag) {  # item-level data, we need to get the right item.
                    foreach my $itemfield (@marcfield) {
                        if ( $itemfield->subfield($itemsubfieldcode) eq $item->{'itemnumber'} ) {
                            $datastring .= $itemfield->subfield($subf ) . $ws;
                            last;
                        }
                    }
                } else {  # bib-level data, we'll take the first matching tag/subfield.
                    $datastring .= $marcfield[0]->subfield($subf) . $ws ;
                }
            }
            $f = $';
        }
        else {
            warn "failed to parse label formatstring: $f";
            last;    # Failed to match
        }
    }
    return $datastring;
}

=head2 descKohaTables

Return a hashref of an array of hashes,
with name,type keys.

=cut

sub _descKohaTables {
	my $dbh = C4::Context->dbh();
	my $kohatables;
	for my $table ( 'biblio','biblioitems','items' ) {
		my $sth = $dbh->column_info(undef,undef,$table,'%');
		while (my $info = $sth->fetchrow_hashref()){
		        push @{$kohatables->{$table}} , $info->{'COLUMN_NAME'} ;
		}
	}
	return $kohatables;
}

sub GetPatronCardItems {
    my ( $batch_id ) = @_;
    my @resultsloop;
    
    my $dbh = C4::Context->dbh;
#    my $query = "SELECT * FROM patroncards WHERE batch_id = ? ORDER BY borrowernumber";
    my $query = "SELECT * FROM patroncards WHERE batch_id = ? ORDER BY cardid";
    my $sth = $dbh->prepare($query);
    $sth->execute($batch_id);
    my $cardno = 1;
    while ( my $data = $sth->fetchrow_hashref ) {
        my $patron_data = GetMember( $data->{'borrowernumber'} );
        $patron_data->{'branchname'} = GetBranchName( $patron_data->{'branchcode'} );
        $patron_data->{'cardno'} = $cardno;
        $patron_data->{'cardid'} = $data->{'cardid'};
        $patron_data->{'batch_id'} = $batch_id;
        push( @resultsloop, $patron_data );
        $cardno++;
    }
    return @resultsloop;
}

sub deduplicate_batch {
	my ( $batch_id, $batch_type ) = @_;
	my $query = "
	SELECT DISTINCT
			batch_id," . (($batch_type eq 'labels') ? 'itemnumber' : 'borrowernumber') . ",
			count(". (($batch_type eq 'labels') ? 'labelid' : 'cardid') . ") as count 
	FROM $batch_type 
	WHERE batch_id = ?
	GROUP BY " . (($batch_type eq 'labels') ? 'itemnumber' : 'borrowernumber') . ",batch_id
	HAVING count > 1
	ORDER BY batch_id,
	count DESC  ";
	my $sth = C4::Context->dbh->prepare($query);
	$sth->execute($batch_id);
        warn $sth->errstr if $sth->errstr;
	$sth->rows or return undef, $sth->errstr;

	my $del_query = "
	DELETE 
	FROM     $batch_type
	WHERE    batch_id = ?
	AND      " . (($batch_type eq 'labels') ? 'itemnumber' : 'borrowernumber') . " = ?
	ORDER BY timestamp ASC
	";
	my $killed = 0;
	while (my $data = $sth->fetchrow_hashref()) {
		my $itemnumber = $data->{(($batch_type eq 'labels') ? 'itemnumber' : 'borrowernumber')} or next;
		my $limit      = $data->{count} - 1  or next;
		my $sth2 = C4::Context->dbh->prepare("$del_query  LIMIT $limit");
		# die sprintf "$del_query LIMIT %s\n (%s, %s)", $limit, $batch_id, $itemnumber;
		# $sth2->execute($batch_id, C4::Context->dbh->quote($data->{itemnumber}), $data->{count} - 1)
		$sth2->execute($batch_id, $itemnumber) and
			$killed += ($data->{count} - 1);
                warn $sth2->errstr if $sth2->errstr;
	}
	return $killed, undef;
}

sub split_lccn {
    my ($lccn) = @_;    
    $_ = $lccn;
    # lccn examples: 'HE8700.7 .P6T44 1983', 'BS2545.E8 H39 1996';
    my (@parts) = m/
        ^([a-zA-Z]+)      # HE          # BS
        (\d+(?:\.\d)*)    # 8700.7      # 2545
        \s*
        (\.*\D+\d*)       # .P6         # .E8
        \s*
        (.*)              # T44 1983    # H39 1996   # everything else (except any bracketing spaces)
        \s*
        /x;
    unless (scalar @parts)  {
        $debug and print STDERR "split_lccn regexp failed to match string: $_\n";
        push @parts, $_;     # if no match, just push the whole string.
    }
    push @parts, split /\s+/, pop @parts;   # split the last piece into an arbitrary number of pieces at spaces
    $debug and print STDERR "split_lccn array: ", join(" | ", @parts), "\n";
    return @parts;
}

our $possible_decimal = qr/\d{3,}(?:\.\d+)?/; # at least three digits for a DDCN

sub split_ddcn {
    my ($ddcn) = @_;
    $_ = $ddcn;
    s/\///g;   # in theory we should be able to simply remove all segmentation markers and arrive at the correct call number...
    # ddcn examples: 'R220.3 H2793Z H32 c.2', 'BIO JP2 R5c.1'

    my (@parts) = m/
        ^([a-zA-Z-]+(?:$possible_decimal)?) # R220.3            # BIO   # first example will require extra splitting
        \s+
        (.+)                               # H2793Z H32 c.2   # R5c.1   # everything else (except bracketing spaces)
        \s*
        /x;
    unless (scalar @parts)  {
        $debug and print STDERR "split_ddcn regexp failed to match string: $_\n";
        push @parts, $_;     # if no match, just push the whole string.
    }

    if ($parts[ 0] =~ /^([a-zA-Z]+)($possible_decimal)$/) {
          shift @parts;         # pull off the mathching first element, like example 1
        unshift @parts, $1, $2; # replace it with the two pieces
    }

    push @parts, split /\s+/, pop @parts;   # split the last piece into an arbitrary number of pieces at spaces

    if ($parts[-1] !~ /^.*\d-\d.*$/ && $parts[-1] =~ /^(.*\d+)(\D.*)$/) {
         pop @parts;            # pull off the mathching last element, like example 2
        push @parts, $1, $2;    # replace it with the two pieces
    }

    $debug and print STDERR "split_ddcn array: ", join(" | ", @parts), "\n";
    return @parts;
}

sub split_fcn {
    my ($fcn) = @_;
    my @fcn_split = ();
    # Split fiction call numbers based on spaces
    SPLIT_FCN:
    while ($fcn) {
        if ($fcn =~ m/([A-Za-z0-9]+\.?[0-9]?)(\W?).*?/x) {
            push (@fcn_split, $1);
            $fcn = $';
        }
        else {
            last SPLIT_FCN;     # No match, break out of the loop
        }
    }
    return @fcn_split;
}

my %itemtypemap;
# Class variable to avoid querying itemtypes for every DrawSpineText call!!
sub get_itemtype_descriptions () {
    unless (scalar keys %itemtypemap) {
        my $sth = C4::Context->dbh->prepare("SELECT itemtype,description FROM itemtypes");
        $sth->execute();
        while (my $data = $sth->fetchrow_hashref) {
            $itemtypemap{$data->{itemtype}} = $data->{description};
        }
    }
    return \%itemtypemap;
}

sub DrawSpineText {
    my ( $x_pos, $y_pos, $label_height, $label_width, $fontname, $fontsize, $left_text_margin,
        $text_wrap_cols, $item, $conf_data, $printingtype ) = @_;
    
    # Replace item's itemtype with the more user-friendly description...
    my $descriptions = get_itemtype_descriptions();
    foreach (qw(itemtype itype)) {
        my $description = $descriptions->{$$item->{$_}} or next;
        $$item->{$_} = $description;
    }
    my $str = '';

    my $top_text_margin = ( $fontsize + 3 );    #FIXME: This should be a template parameter and passed in...
    my $line_spacer     = ( $fontsize * 1 );    # number of pixels between text rows (This is actually leading: baseline to baseline minus font size. Recommended starting point is 20% of font size.).

    my $layout_id = $$conf_data->{'id'};

    my $vPos = ( $y_pos + ( $label_height - $top_text_margin ) );

    my @str_fields = get_text_fields($layout_id, 'codes' );  
    my $record = GetMarcBiblio($$item->{biblionumber});
    # FIXME - returns all items, so you can't get data from an embedded holdings field.
    # TODO - add a GetMarcBiblio1item(bibnum,itemnum) or a GetMarcItem(itemnum).

    my $old_fontname = $fontname; # We need to keep track of the original font passed in...

    # Grab the cn_source and if that is NULL, the DefaultClassificationSource syspref
    my $cn_source = ($$item->{'cn_source'} ? $$item->{'cn_source'} : C4::Context->preference('DefaultClassificationSource'));
    for my $field (@str_fields) {
        $field->{'code'} or warn "get_text_fields($layout_id, 'codes') element missing 'code' field";
        if ($field->{'code'} eq 'itemtype') {
            $field->{'data'} = C4::Context->preference('item-level_itypes') ? $$item->{'itype'} : $$item->{'itemtype'};
        }
        elsif ($$conf_data->{'formatstring'}) {
            # if labels_conf.formatstring has a value, then it overrides the  hardcoded option.
            $field->{'data'} = GetBarcodeData($field->{'code'},$$item,$record) ;
        }
        else {
            $field->{'data'} = $$item->{$field->{'code'}};
        }
        # This allows us to print the title in italic (oblique) type... (Times Roman has a different nomenclature.)
        # It seems there should be a better way to handle fonts in the label/patron card tool altogether -fbcit
        ($field->{code} eq 'title') ? (($old_fontname =~ /T/) ? ($fontname = 'TI') : ($fontname = ($old_fontname . 'O'))) : ($fontname = $old_fontname);
        my $font = prFont($fontname);
        # if the display option for this field is selected in the DB,
        # and the item record has some values for this field, display it.
        # Or if there is a csv list of fields to display, display them.
        if ( ($$conf_data->{'formatstring'}) || ( $$conf_data->{$field->{code}} && $$item->{$field->{code}} ) ) {
            # get the string
            my $str = $field->{data} ;
            # strip out naughty existing nl/cr's
            $str =~ s/\n//g;
            $str =~ s/\r//g;
            my @strings;
            my @callnumber_list = ('itemcallnumber', '050a', '050b', '082a', '952o'); # Fields which hold call number data  ( 060? 090? 092? 099? )
            if ((grep {$field->{code} =~ m/$_/} @callnumber_list) and ($printingtype eq 'BIB') and ($$conf_data->{'callnum_split'})) { # If the field contains the call number, we do some sp
                if ($cn_source eq 'lcc') {
                    @strings = split_lccn($str);
                    @strings = split_fcn($str) if !@strings;    # If it was not a true lccn, try it as a fiction call number
                    push (@strings, $str) if !@strings;         # If it was not that, send it on unsplit
                } elsif ($cn_source eq 'ddc') {
                    @strings = split_ddcn($str);
                    @strings = split_fcn($str) if !@strings;
                    push (@strings, $str) if !@strings;
                } else {
                    # FIXME Need error trapping here; something to be informative to the user perhaps -crn
                    push @strings, $str;
                }
            } else {
                $str =~ s/\/$//g;       # Here we will strip out all trailing '/' in fields other than the call number...
                $str =~ s/\(/\\\(/g;    # Escape '(' and ')' for the postscript stream...
                $str =~ s/\)/\\\)/g;
                # Wrap text lines exceeding $text_wrap_cols length...
                $Text::Wrap::columns = $text_wrap_cols;
                my @line = split(/\n/ ,wrap('', '', $str));
                # If this is a title field, limit to two lines; all others limit to one...
                my $limit = ($field->{code} eq 'title') ? 2 : 1;
                while (scalar(@line) > $limit) {
                    pop @line;
                }
                push(@strings, @line);
            }
            # loop for each string line
            foreach my $str (@strings) {
                my $hPos = $x_pos;
                next if $str eq '';
                my $stringwidth = prStrWidth($str, $fontname, $fontsize);
                if ( $$conf_data->{'text_justify'} eq 'R' ) { 
                    $hPos += $label_width - ($left_text_margin + $stringwidth);
                } elsif($$conf_data->{'text_justify'} eq 'C') {
                    # some code to try and center each line on the label based on font size and string point width...
                    my $whitespace = ( $label_width - ( $stringwidth + (2 * $left_text_margin) ) );
                    $hPos += ($whitespace / 2) + $left_text_margin;
                    #warn "\$label_width=$label_width \$stringwidth=$stringwidth \$whitespace=$whitespace \$left_text_margin=$left_text_margin for $str\n";
                } else {
                    $hPos += $left_text_margin;
                }
# utf8::encode($str);
# Say $str has a diacritical like: The séance 
# WITOUT encode, PrintText crashes with: Wide character in syswrite at /usr/local/share/perl/5.8.8/PDF/Reuse.pm line 968
# WITH   encode, PrintText prints: The seÌ•ancee
# Neither is appropriate.
                PrintText( $hPos, $vPos, $font, $fontsize, $str );
                $vPos -= $line_spacer;
            }
    	}
    }	#foreach field
}

sub PrintText {
    my ( $hPos, $vPos, $font, $fontsize, $text ) = @_;
    my $str = "BT /$font $fontsize Tf $hPos $vPos Td ($text) Tj ET";
    prAdd($str);
}

sub DrawPatronCardText {
    my ( $x_pos, $y_pos, $label_height, $label_width, $fontname, $fontsize, $left_text_margin,
        $text_wrap_cols, $text, $printingtype )
      = @_;

    my $top_text_margin = 25;    #FIXME: This should be a template parameter and passed in...

    my $vPos   = ( $y_pos + ( $label_height - $top_text_margin ) );
    my $font = prFont($fontname);

    my $hPos = 0;

    foreach my $line (keys %$text) {
        $debug and warn "Current text is \"$line\" and font size for \"$line\" is $text->{$line} points";
        # some code to try and center each line on the label based on font size and string point width...
        my $stringwidth = prStrWidth($line, $fontname, $text->{$line});
        my $whitespace = ( $label_width - ( $stringwidth + (2 * $left_text_margin) ) );
        $hPos = ( ( $whitespace  / 2 ) + $x_pos + $left_text_margin );

        PrintText( $hPos, $vPos, $font, $text->{$line}, $line );
        my $line_spacer = ( $text->{$line} * 1 );    # number of pixels between text rows (This is actually leading: baseline to baseline minus font size. Recommended starting point is 20% (0.20) of font size.).
        $vPos = $vPos - ($line_spacer + $text->{$line});   # Linefeed equiv: leading + font size
    }
}

# Not used anywhere.

#sub SetFontSize {
#
#    my ($fontsize) = @_;
#### fontsize
#    my $str = "BT/F13 30 Tf288 720 Td( AAAAAAAAAA ) TjET";
#    prAdd($str);
#}

sub DrawBarcode {
    # x and y are from the top-left :)
    my ( $x_pos, $y_pos, $height, $width, $barcode, $barcodetype ) = @_;
    my $num_of_bars = length($barcode);
    my $bar_width   = $width * .8;        # %80 of length of label width
    my $tot_bar_length = 0;
    my $bar_length = 0;
    my $guard_length = 10;
    my $xsize_ratio = 0;

    if ( $barcodetype eq 'CODE39' ) {
        $bar_length = '17.5';
        $tot_bar_length =
          ( $bar_length * $num_of_bars ) + ( $guard_length * 2 );
        $xsize_ratio = ( $bar_width / $tot_bar_length );
        eval {
            PDF::Reuse::Barcode::Code39(
                x => ( $x_pos + ( $width / 10 ) ),
                y => ( $y_pos + ( $height / 10 ) ),
                value         => "*$barcode*",
                ySize         => ( .02 * $height ),
                xSize         => $xsize_ratio,
                hide_asterisk => 1,
                mode          => 'graphic',  # the only other option here is Type3...
            );
        };
    }
    elsif ( $barcodetype eq 'CODE39MOD' ) {
        # get modulo43 checksum
        my $c39 = CheckDigits('code_39');
        $barcode = $c39->complete($barcode);

        $bar_length = '19';
        $tot_bar_length =
          ( $bar_length * $num_of_bars ) + ( $guard_length * 2 );
        $xsize_ratio = ( $bar_width / $tot_bar_length );
        eval {
            PDF::Reuse::Barcode::Code39(
                x => ( $x_pos + ( $width / 10 ) ),
                y => ( $y_pos + ( $height / 10 ) ),
                value         => "*$barcode*",
                ySize         => ( .02 * $height ),
                xSize         => $xsize_ratio,
                hide_asterisk => 1,
                mode          => 'graphic',  # the only other option here is Type3...
            );
        };
    }
    elsif ( $barcodetype eq 'CODE39MOD10' ) {
        # get modulo43 checksum
        my $c39_10 = CheckDigits('visa');
        $barcode = $c39_10->complete($barcode);

        $bar_length = '19';
        $tot_bar_length =
          ( $bar_length * $num_of_bars ) + ( $guard_length * 2 );
        $xsize_ratio = ( $bar_width / $tot_bar_length );
        eval {
            PDF::Reuse::Barcode::Code39(
                x => ( $x_pos + ( $width / 10 ) ),
                y => ( $y_pos + ( $height / 10 ) ),
                value         => "*$barcode*",
                ySize         => ( .02 * $height ),
                xSize         => $xsize_ratio,
                hide_asterisk => 1,
		text          => 0, 
                mode          => 'graphic',  # the only other option here is Type3...
            );
        };
    }
    elsif ( $barcodetype eq 'COOP2OF5' ) {
        $bar_length = '9.43333333333333';
        $tot_bar_length =
          ( $bar_length * $num_of_bars ) + ( $guard_length * 2 );
        $xsize_ratio = ( $bar_width / $tot_bar_length ) * .9;
        eval {
            PDF::Reuse::Barcode::COOP2of5(
                x => ( $x_pos + ( $width / 10 ) ),
                y => ( $y_pos + ( $height / 10 ) ),
                value => $barcode,
                ySize => ( .02 * $height ),
                xSize => $xsize_ratio,
            );
        };
    }
    elsif ( $barcodetype eq 'INDUSTRIAL2OF5' ) {
        $bar_length = '13.1333333333333';
        $tot_bar_length =
          ( $bar_length * $num_of_bars ) + ( $guard_length * 2 );
        $xsize_ratio = ( $bar_width / $tot_bar_length ) * .9;
        eval {
            PDF::Reuse::Barcode::Industrial2of5(
                x => ( $x_pos + ( $width / 10 ) ),
                y => ( $y_pos + ( $height / 10 ) ),
                value => $barcode,
                ySize => ( .02 * $height ),
                xSize => $xsize_ratio,
            );
        };
    } # else {die "Unknown barcodetype '$barcodetype'";}

    if ($@) {
        warn "DrawBarcode (type: $barcodetype) FAILED for value '$barcode' :$@";
    }

    my $moo2 = $tot_bar_length * $xsize_ratio;

    warn "x_pos,y_pos,barcode,barcodetype = $x_pos, $y_pos, $barcode, $barcodetype\n"
        . "BAR_WDTH = $bar_width, TOT.BAR.LGHT=$tot_bar_length  R*TOT.BAR =$moo2" if $debug;
}

=head2 build_circ_barcode;

  build_circ_barcode( $x_pos, $y_pos, $barcode, $barcodetype, \$item);

$item is the result of a previous call to GetLabelItems();

=cut

sub build_circ_barcode {
    my ( $x_pos_circ, $y_pos, $value, $barcodetype, $item ) = @_;

    #warn Dumper \$item;
    #warn "Barcode (type: $barcodetype) value = $value\n";
    #$DB::single = 1;

    if ( $barcodetype eq 'EAN13' ) {
        #testing EAN13 barcodes hack
        $value = $value . '000000000';
        $value =~ s/-//;
        $value = substr( $value, 0, 12 );
        #warn "revised value: $value";
        eval {
            PDF::Reuse::Barcode::EAN13(
                x     => ( $x_pos_circ + 27 ),
                y     => ( $y_pos + 15 ),
                value => $value,
                # prolong => 2.96,
                # xSize   => 1.5,
                # ySize   => 1.2,
# added for xpdf compat. doesnt use type3 fonts., but increases filesize from 20k to 200k
# i think its embedding extra fonts in the pdf file.
#  mode => 'graphic',
            );
        };
    }
    elsif ( $barcodetype eq 'Code39' ) {
        eval {
            PDF::Reuse::Barcode::Code39(
                x     => ( $x_pos_circ + 9 ),
                y     => ( $y_pos + 15 ),
                value => $value,
                # prolong => 2.96,
                xSize => .85,
                ySize => 1.3,
                mode            => 'graphic',  # the only other option here is Type3...
            );
        };
    }
    elsif ( $barcodetype eq 'Matrix2of5' ) {
        # testing MATRIX25  barcodes hack
        # $value = $value.'000000000';
        $value =~ s/-//;
        # $value = substr( $value, 0, 12 );
        #warn "revised value: $value";
        eval {
            PDF::Reuse::Barcode::Matrix2of5(
                x     => ( $x_pos_circ + 27 ),
                y     => ( $y_pos + 15 ),
                value => $value,
                # prolong => 2.96,
                # xSize   => 1.5,
                # ySize   => 1.2,
            );
        };
    }
    elsif ( $barcodetype eq 'EAN8' ) {
        #testing ean8 barcodes hack
        $value = $value . '000000000';
        $value =~ s/-//;
        $value = substr( $value, 0, 8 );
        #warn "revised value: $value";
        eval {
            PDF::Reuse::Barcode::EAN8(
                x       => ( $x_pos_circ + 42 ),
                y       => ( $y_pos + 15 ),
                value   => $value,
                prolong => 2.96,
                xSize   => 1.5,
                # ySize   => 1.2,
            );
        };
    }
    elsif ( $barcodetype eq 'UPC-E' ) {
        eval {
            PDF::Reuse::Barcode::UPCE(
                x       => ( $x_pos_circ + 27 ),
                y       => ( $y_pos + 15 ),
                value   => $value,
                prolong => 2.96,
                xSize   => 1.5,
                # ySize   => 1.2,
            );
        };
    }
    elsif ( $barcodetype eq 'NW7' ) {
        eval {
            PDF::Reuse::Barcode::NW7(
                x       => ( $x_pos_circ + 27 ),
                y       => ( $y_pos + 15 ),
                value   => $value,
                prolong => 2.96,
                xSize   => 1.5,
                # ySize   => 1.2,
            );
        };
    }
    elsif ( $barcodetype eq 'ITF' ) {
        eval {
            PDF::Reuse::Barcode::ITF(
                x       => ( $x_pos_circ + 27 ),
                y       => ( $y_pos + 15 ),
                value   => $value,
                prolong => 2.96,
                xSize   => 1.5,
                # ySize   => 1.2,
            );
        };
    }
    elsif ( $barcodetype eq 'Industrial2of5' ) {
        eval {
            PDF::Reuse::Barcode::Industrial2of5(
                x       => ( $x_pos_circ + 27 ),
                y       => ( $y_pos + 15 ),
                value   => $value,
                prolong => 2.96,
                xSize   => 1.5,
                # ySize   => 1.2,
            );
        };
    }
    elsif ( $barcodetype eq 'IATA2of5' ) {
        eval {
            PDF::Reuse::Barcode::IATA2of5(
                x       => ( $x_pos_circ + 27 ),
                y       => ( $y_pos + 15 ),
                value   => $value,
                prolong => 2.96,
                xSize   => 1.5,
                # ySize   => 1.2,
            );
        };
    }
    elsif ( $barcodetype eq 'COOP2of5' ) {
        eval {
            PDF::Reuse::Barcode::COOP2of5(
                x       => ( $x_pos_circ + 27 ),
                y       => ( $y_pos + 15 ),
                value   => $value,
                prolong => 2.96,
                xSize   => 1.5,
                # ySize   => 1.2,
            );
        };
    }
    elsif ( $barcodetype eq 'UPC-A' ) {
        eval {
            PDF::Reuse::Barcode::UPCA(
                x       => ( $x_pos_circ + 27 ),
                y       => ( $y_pos + 15 ),
                value   => $value,
                prolong => 2.96,
                xSize   => 1.5,
                # ySize   => 1.2,
            );
        };
    }
    if ($@) {
        $item->{'barcodeerror'} = 1;
        #warn "BARCODE (type: $barcodetype) FAILED:$@";
    }
}

=head2 draw_boundaries

 sub draw_boundaries ($x_pos_spine, $x_pos_circ1, $x_pos_circ2,
                $y_pos, $spine_width, $label_height, $circ_width)  

This sub draws boundary lines where the label outlines are, to aid in printer testing, and debugging.

=cut

sub draw_boundaries {
    my (
        $x_pos_spine, $x_pos_circ1,  $x_pos_circ2, $y_pos,
        $spine_width, $label_height, $circ_width
    ) = @_;

    my $y_pos_initial = ( ( 792 - 36 ) - 90 );
    $y_pos            = $y_pos_initial; # FIXME - why are we ignoring the y_pos parameter by redefining it?
    my $i             = 1;

    for ( $i = 1 ; $i <= 8 ; $i++ ) {
        &drawbox( $x_pos_spine, $y_pos, ($spine_width), ($label_height) );
   #warn "OLD BOXES  x=$x_pos_spine, y=$y_pos, w=$spine_width, h=$label_height";
        &drawbox( $x_pos_circ1, $y_pos, ($circ_width), ($label_height) );
        &drawbox( $x_pos_circ2, $y_pos, ($circ_width), ($label_height) );
        $y_pos = ( $y_pos - $label_height );
    }
}

=head2 drawbox

	sub drawbox { 	$lower_left_x, $lower_left_y, 
			$upper_right_x, $upper_right_y )

this is a low level sub, that draws a pdf box, it is called by draw_boxes

FYI: the  $upper_right_x and $upper_right_y values are RELATIVE to  $lower_left_x and $lower_left_y

and $lower_left_x, $lower_left_y are ABSOLUTE, this caught me out!

=cut

sub drawbox {
    my ( $llx, $lly, $urx, $ury ) = @_;
    #    warn "llx,y= $llx,$lly  ,   urx,y=$urx,$ury \n";

    my $str = "q\n";    # save the graphic state
    $str .= "0.5 w\n";              # border color red
    $str .= "1.0 0.0 0.0  RG\n";    # border color red
         #   $str .= "0.5 0.75 1.0 rg\n";           # fill color blue
    $str .= "1.0 1.0 1.0  rg\n";    # fill color white

    $str .= "$llx $lly $urx $ury re\n";    # a rectangle
    $str .= "B\n";                         # fill (and a little more)
    $str .= "Q\n";                         # save the graphic state

    prAdd($str);
}

1;
__END__

=head1 AUTHOR

Mason James <mason@katipo.co.nz>

=cut

