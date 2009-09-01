package C4::Labels::Label;

# Copyright 2006 Katipo Communications.
# Some parts Copyright 2009 Foundations Bible College.
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
use warnings;

use Sys::Syslog qw(syslog);
use Text::Wrap;
use Algorithm::CheckDigits;
use Text::CSV_XS;

use C4::Context;
use C4::Debug;
use C4::Biblio;
use Data::Dumper;

BEGIN {
    use version; our $VERSION = qv('1.0.0_1');
}

sub _guide_box {
    my ( $llx, $lly, $width, $height ) = @_;
    my $obj_stream = "q\n";                            # save the graphic state
    $obj_stream .= "0.5 w\n";                          # border line width
    $obj_stream .= "1.0 0.0 0.0  RG\n";                # border color red
    $obj_stream .= "1.0 1.0 1.0  rg\n";                # fill color white
    $obj_stream .= "$llx $lly $width $height re\n";    # a rectangle
    $obj_stream .= "B\n";                              # fill (and a little more)
    $obj_stream .= "Q\n";                              # restore the graphic state
    return $obj_stream;
}

sub _get_label_item {
    my $item_number = shift;
    my $barcode_only = shift || 0;
    my $dbh = C4::Context->dbh;
    my $query =
#        FIXME This makes for a very bulky data structure; data from tables w/duplicate col names also gets overwritten.
#        Something like this, perhaps, but this also causes problems because we need more fields sometimes.
#        SELECT i.barcode, i.itemcallnumber, i.itype, bi.isbn, bi.issn, b.title, b.author
       "SELECT bi.*, i.*, b.*
        FROM items AS i, biblioitems AS bi ,biblio AS b
        WHERE itemnumber=? AND i.biblioitemnumber=bi.biblioitemnumber AND bi.biblionumber=b.biblionumber";
    my $sth = $dbh->prepare($query);
    $sth->execute($item_number);
    if ($sth->err) {
        syslog("LOG_ERR", "C4::Labels::Label::_get_label_item : Database returned the following error: %s", $sth->errstr);
    }
    my $data = $sth->fetchrow_hashref;
    # Replaced item's itemtype with the more user-friendly description...
    my $sth1 = $dbh->prepare("SELECT itemtype,description FROM itemtypes WHERE itemtype = ?");
    $sth1->execute($data->{'itemtype'});
    if ($sth1->err) {
        syslog("LOG_ERR", "C4::Labels::Label::_get_label_item : Database returned the following error: %s", $sth1->errstr);
    }
    my $data1 = $sth->fetchrow_hashref;
    $data->{'itemtype'} = $data1->{'description'};
    $data->{'itype'} = $data1->{'description'};
    $barcode_only ? return $data->{'barcode'} : return $data;
}

sub _get_text_fields {
    my $format_string = shift;
    my $csv = Text::CSV_XS->new({allow_whitespace => 1});
    my $status = $csv->parse($format_string);
    my @sorted_fields = map {{ 'code' => $_, desc => $_ }} $csv->fields();
    my $error = $csv->error_input();
    syslog("LOG_ERR", "C4::Labels::Label::_get_text_fields : Text field sort failed with this error: %s", $error) if $error;
    return \@sorted_fields;
}

sub _split_lccn {
    my ($lccn) = @_;    
    my ($ll, $wnl, $dec, $cutter, $pubdate) = (0, 0, 0, 0, 0);
    $_ = $lccn;
    # lccn example 'HE8700.7 .P6T44 1983';
    my    @splits   = m/
        (^[a-zA-Z]+)            # HE
        ([0-9]+\.*[0-9]*)             # 8700.7
        \s*
        (\.*[a-zA-Z0-9]*)       # P6T44
        \s*
        ([0-9]*)                # 1983
        /x;  

    # strip something occuring spaces too
    $splits[0] =~ s/\s+$//;
    $splits[1] =~ s/\s+$//;
    $splits[2] =~ s/\s+$//;

    return @splits;
}

sub _split_ddcn {
    my ($ddcn) = @_;
    $ddcn =~ s/\///g;   # in theory we should be able to simply remove all segmentation markers and arrive at the correct call number...
    $_ = $ddcn;
    # ddcn example R220.3 H2793Z H32 c.2
    my @splits = m/^([A-Z]{0,3})                # R (OS, REF, etc. up do three letters)
                    ([0-9]+\.[0-9]*)            # 220.3
                    \s?                         # space (not requiring anything beyond the call number)
                    ([a-zA-Z0-9]*\.?[a-zA-Z0-9])# cutter number... maybe, but if so it is in this position (Z indicates literary criticism)
                    \s?                         # space if it exists
                    ([a-zA-Z]*\.?[0-9]*)        # other indicators such as cutter for author of literary criticism in this example if it exists
                    \s?                         # space if ie exists
                    ([a-zA-Z]*\.?[0-9]*)        # other indicators such as volume number, copy number, edition date, etc. if it exists
                    /x;
    return @splits;
}

sub _split_fcn {
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

sub _get_fields {
    my ( $layout_id, $sorttype ) = @_;
    my @sorted_fields;
    my $sortorder = get_layout($layout_id);
    if ( !$sorttype ) {
        return $sortorder->{'formatstring'};
    }
    else {
        my $csv    = Text::CSV_XS->new( { allow_whitespace => 1 } );
        my $line   = $sortorder->{'formatstring'};
        my $status = $csv->parse($line);
        @sorted_fields =
          map { { 'code' => $_, desc => $_ } } $csv->fields();
        if (my $error = $csv->error_input()) {
            syslog("LOG_ERR", "C4::Labels::Label::_get_fields : Text::CSV_XS returned the following error: %s", $error);
        }
    }
}

sub _get_item_fields {
    my @fields = qw (
      barcode           title
      isbn              issn
      author            itemtype
      itemcallnumber
    );
    return @fields;
}

sub _get_barcode_data {
    my ( $f, $item, $record ) = @_;
    my $kohatables = _desc_koha_tables();
    my $datastring = '';
    my $match_kohatable = join(
        '|',
        (
            @{ $kohatables->{'biblio'} },
            @{ $kohatables->{'biblioitems'} },
            @{ $kohatables->{'items'} }
        )
    );
    FIELD_LIST:
    while ($f) {  
        my $err = '';
        $f =~ s/^\s?//;
        if ( $f =~ /^'(.*)'.*/ ) {
            # single quotes indicate a static text string.
            $datastring .= $1;
            $f = $';
            next FIELD_LIST;
        }
        elsif ( $f =~ /^($match_kohatable).*/ ) {
            if ($item->{$f}) {
                $datastring .= $item->{$f};
            }
            else {
                syslog("LOG_ERR", "C4::Labels::Label::_get_barcode_data : The '%s' field contains no data.", $f);
            }
            $f = $';
            next FIELD_LIST;
        }
        elsif ( $f =~ /^([0-9a-z]{3})(\w)(\W?).*?/ ) {
            my ($field,$subf,$ws) = ($1,$2,$3);
            my $subf_data;
            my ($itemtag, $itemsubfieldcode) = &GetMarcFromKohaField("items.itemnumber",'');
            my @marcfield = $record->field($field);
            if(@marcfield) {
                if($field eq $itemtag) {  # item-level data, we need to get the right item.
                    ITEM_FIELDS:
                    foreach my $itemfield (@marcfield) {
                        if ( $itemfield->subfield($itemsubfieldcode) eq $item->{'itemnumber'} ) {
                            if ($itemfield->subfield($subf)) {
                                $datastring .= $itemfield->subfield($subf) . $ws;
                            }
                            else {
                                syslog("LOG_ERR", "C4::Labels::Label::_get_barcode_data : The '%s' field contains no data.", $f);
                            }
                            last ITEM_FIELDS;
                        }
                    }
                } else {  # bib-level data, we'll take the first matching tag/subfield.
                    if ($marcfield[0]->subfield($subf)) {
                        $datastring .= $marcfield[0]->subfield($subf) . $ws;
                    }
                    else {
                        syslog("LOG_ERR", "C4::Labels::Label::_get_barcode_data : The '%s' field contains no data.", $f);
                    }
                }
            }
            $f = $';
            next FIELD_LIST;
        }
        else {
            syslog("LOG_ERR", "C4::Labels::Label::_get_barcode_data : Failed to parse label format string: %s", $f);
            last FIELD_LIST;    # Failed to match
        }
    }
    return $datastring;
}

sub _desc_koha_tables {
	my $dbh = C4::Context->dbh();
	my $kohatables;
	for my $table ( 'biblio','biblioitems','items' ) {
		my $sth = $dbh->column_info(undef,undef,$table,'%');
		while (my $info = $sth->fetchrow_hashref()){
		        push @{$kohatables->{$table}} , $info->{'COLUMN_NAME'} ;
		}
		$sth->finish;
	}
	return $kohatables;
}

sub new {
    my ($invocant, %params) = @_;
    my $type = ref($invocant) || $invocant;
    my $self = {
        batch_id                => $params{'batch_id'},
        item_number             => $params{'item_number'},
        height                  => $params{'height'},
        width                   => $params{'width'},
        top_text_margin         => $params{'top_text_margin'},
        left_text_margin        => $params{'left_text_margin'},
        barcode_type            => $params{'barcode_type'},
        printing_type           => $params{'printing_type'},
        guidebox                => $params{'guidebox'},
        font                    => $params{'font'},
        font_size               => $params{'font_size'},
        callnum_split           => $params{'callnum_split'},
        justify                 => $params{'justify'},
        format_string           => $params{'format_string'},
        text_wrap_cols          => $params{'text_wrap_cols'},
        barcode                 => 0,
    };
    if ($self->{'guidebox'}) {
        $self->{'guidebox'} = _guide_box($self->{'llx'}, $self->{'lly'}, $self->{'width'}, $self->{'height'});
    }
    bless ($self, $type);
    return $self;
}

sub get_label_type {
    my $self = shift;
    return $self->{'printing_type'};
}

=head2 $label->get_attr("attr")

    Invoking the I<get_attr> method will return the value of the requested attribute or 1 on errors.

    example:
        my $value = $label->get_attr("attr");

=cut

sub get_attr {
    my $self = shift;
#    if (_check_params(@_) eq 1) {
#        return -1;
#    }
    my ($attr) = @_;
    if (exists($self->{$attr})) {
        return $self->{$attr};
    }
    else {
        return -1;
    }
    return;
}

=head2 $label->draw_label_text()

    Invoking the I<draw_label_text> method generates the label text for the label object.
    example:
       $label->draw_label_text(
                    llx                 => $text_llx,
                    lly                 => $text_lly,
                    top_text_margin     => $label_top_text_margin,
                    line_spacer         => $text_leading,
                    font                => $text_font,
                    font_size           => $text_font_size,
                    justify             => $text_justification,
        );
=cut

sub draw_label_text {
    my ($self, %params) = @_;
    my @label_text = ();
    my $text_llx = 0;
    my $text_lly = $params{'lly'};
    my $font = $self->{'font'};
    my $item = _get_label_item($self->{'item_number'});
    my $label_fields = _get_text_fields($self->{'format_string'});
    my $record = GetMarcBiblio($item->{'biblionumber'});
    # FIXME - returns all items, so you can't get data from an embedded holdings field.
    # TODO - add a GetMarcBiblio1item(bibnum,itemnum) or a GetMarcItem(itemnum).
    my $cn_source = ($item->{'cn_source'} ? $item->{'cn_source'} : C4::Context->preference('DefaultClassificationSource'));
    LABEL_FIELDS:       # process data for requested fields on current label
    for my $field (@$label_fields) {
        if ($field->{'code'} eq 'itemtype') {
            $field->{'data'} = C4::Context->preference('item-level_itypes') ? $item->{'itype'} : $item->{'itemtype'};
        }
        else {
            $field->{'data'} = _get_barcode_data($field->{'code'},$item,$record);
        }
        ($field->{'code'} eq 'title') ? (($font =~ /T/) ? ($font = 'TI') : ($font = ($font . 'O'))) : ($font = $font);
        my $field_data = $field->{'data'};
        $field_data =~ s/\n//g;
        $field_data =~ s/\r//g;
        my @label_lines;
        my @callnumber_list = ('itemcallnumber', '050a', '050b', '082a', '952o'); # Fields which hold call number data  FIXME: ( 060? 090? 092? 099? )
        if ((grep {$field->{'code'} =~ m/$_/} @callnumber_list) and ($self->{'printing_type'} eq 'BIB') and ($self->{'callnum_split'})) { # If the field contains the call number, we do some sp
            if ($cn_source eq 'lcc') {
                @label_lines = _split_lccn($field_data);
                @label_lines = _split_fcn($field_data) if !@label_lines;    # If it was not a true lccn, try it as a fiction call number
                push (@label_lines, $field_data) if !@label_lines;         # If it was not that, send it on unsplit
            } elsif ($cn_source eq 'ddc') {
                @label_lines = _split_ddcn($field_data);
                @label_lines = _split_fcn($field_data) if !@label_lines;
                push (@label_lines, $field_data) if !@label_lines;
            } else {
                syslog("LOG_ERR", "C4::Labels::Label->draw_label_text : Call number splitting failed for: %s. Please add this call number to bug #2500 at bugs.koha.org", $field_data);
                push @label_lines, $field_data;
            }
        }
        else {
            $field_data =~ s/\/$//g;       # Here we will strip out all trailing '/' in fields other than the call number...
            $field_data =~ s/\(/\\\(/g;    # Escape '(' and ')' for the pdf object stream...
            $field_data =~ s/\)/\\\)/g;
            eval{local($Text::Wrap::columns) = $self->{'text_wrap_cols'};};
            my @line = split(/\n/ ,wrap('', '', $field_data));
            # If this is a title field, limit to two lines; all others limit to one... FIXME: this is rather arbitrary
            if ($field->{'code'} eq 'title' && scalar(@line) >= 2) {
                while (scalar(@line) > 2) {
                    pop @line;
                }
            } else {
                while (scalar(@line) > 1) {
                    pop @line;
                }
            }
            push(@label_lines, @line);
        }
        LABEL_LINES:    # generate lines of label text for current field
        foreach my $line (@label_lines) {
            next LABEL_LINES if $line eq '';
            my $string_width = C4::Labels::PDF->StrWidth($line, $font, $self->{'font_size'});
            if ($self->{'justify'} eq 'R') { 
                $text_llx = $params{'llx'} + $self->{'width'} - ($self->{'left_text_margin'} + $string_width);
            } 
            elsif($self->{'justify'} eq 'C') {
                 # some code to try and center each line on the label based on font size and string point width...
                 my $whitespace = ($self->{'width'} - ($string_width + (2 * $self->{'left_text_margin'})));
                 $text_llx = (($whitespace  / 2) + $params{'llx'} + $self->{'left_text_margin'});
            } 
            else {
                $text_llx = ($params{'llx'} + $self->{'left_text_margin'});
            }
            push @label_text,   {
                                text_llx        => $text_llx,
                                text_lly        => $text_lly,
                                font            => $font,
                                font_size       => $self->{'font_size'},
                                line            => $line,
                                };
            $text_lly = $text_lly - $params{'line_spacer'};
        }
        $font = $self->{'font'};        # reset font for next field
    }	#foreach field
    return \@label_text;
}

=head2 $label->barcode()

    Invoking the I<barcode> method generates a barcode for the label object and inserts it into the current pdf stream. C<barcode_data> is optional
        and omitting it will cause the barcode from the current item to be used. C<barcode_type> is also optional. Omission results in the barcode
        type of the current template being used.

    example:
       $label->barcode(
                    llx                 => $barcode_llx,
                    lly                 => $barcode_lly,
                    width               => $barcode_width,
                    y_scale_factor      => $barcode_y_scale_factor,
                    barcode_data        => $barcode,
                    barcode_type        => $barcodetype,
        );
=cut

sub barcode {
    my $self = shift;
    my %params = @_;
    $params{'barcode'} = _get_label_item($self->{'item_number'}, 1) if !$params{'barcode'};
    $params{'barcode_type'} = $self->{'barcode_type'} if !$params{'barcode_type'};
    my $x_scale_factor = 1;
    my $num_of_bars = length($params{'barcode'});
    my $tot_bar_length = 0;
    my $bar_length = 0;
    my $guard_length = 10;
    my $hide_text = 'yes';
    if ($params{'barcode_type'} =~ m/CODE39/) {
        $bar_length = '17.5';
        $tot_bar_length = ($bar_length * $num_of_bars) + ($guard_length * 2);
        $x_scale_factor = ($params{'width'} / $tot_bar_length);
        if ($params{'barcode_type'} eq 'CODE39MOD') {
            my $c39 = CheckDigits('visa');   # get modulo43 checksum
            $params{'barcode'} = $c39->complete($params{'barcode'});
        }
        elsif ($params{'barcode_type'} eq 'CODE39MOD10') {
            my $c39_10 = CheckDigits('visa');   # get modulo43 checksum
            $params{'barcode'} = $c39_10->complete($params{'barcode'});
            $hide_text = '';
        }
        eval {
            PDF::Reuse::Barcode::Code39(
                x                   => $params{'llx'},
                y                   => $params{'lly'},
                value               => "*$params{barcode}*",
                xSize               => $x_scale_factor,
                ySize               => $params{'y_scale_factor'},
                hide_asterisk       => 1,
                text                => $hide_text,
                mode                => 'graphic',
            );
        };
        if ($@) {
            syslog("LOG_ERR", "Barcode generation failed for item %s with this error: %s", $self->{'item_number'}, $@);
        }
    }
    elsif ($params{'barcode_type'} eq 'COOP2OF5') {
        $bar_length = '9.43333333333333';
        $tot_bar_length = ($bar_length * $num_of_bars) + ($guard_length * 2);
        $x_scale_factor = ($params{'width'} / $tot_bar_length) * 0.9;
        eval {
            PDF::Reuse::Barcode::COOP2of5(
                x                   => $params{'llx'},
                y                   => $params{'lly'},
                value               => "*$params{barcode}*",
                xSize               => $x_scale_factor,
                ySize               => $params{'y_scale_factor'},
                mode                    => 'graphic',
            );
        };
        if ($@) {
            syslog("LOG_ERR", "Barcode generation failed for item %s with this error: %s", $self->{'item_number'}, $@);
        }
    }
    elsif ( $params{'barcode_type'} eq 'INDUSTRIAL2OF5' ) {
        $bar_length = '13.1333333333333';
        $tot_bar_length = ($bar_length * $num_of_bars) + ($guard_length * 2);
        $x_scale_factor = ($params{'width'} / $tot_bar_length) * 0.9;
        eval {
            PDF::Reuse::Barcode::Industrial2of5(
                x                   => $params{'llx'},
                y                   => $params{'lly'},
                value               => "*$params{barcode}*",
                xSize               => $x_scale_factor,
                ySize               => $params{'y_scale_factor'},
                mode                    => 'graphic',
            );
        };
        if ($@) {
            syslog("LOG_ERR", "Barcode generation failed for item %s with this error: %s", $self->{'item_number'}, $@);
        }
    }
}

sub csv_data {
    my $self = shift;
    my $label_fields = _get_text_fields($self->{'format_string'});
    my $item = _get_label_item($self->{'item_number'});
    my $bib_record = GetMarcBiblio($item->{biblionumber});
    my @csv_data = (map { _get_barcode_data($_->{'code'},$item,$bib_record) } @$label_fields);
    return \@csv_data;
}

1;
__END__

=head1 AUTHOR

Mason James <mason@katipo.co.nz>
Chris Nighswonger <cnighswonger AT foundations DOT edu>

=cut

