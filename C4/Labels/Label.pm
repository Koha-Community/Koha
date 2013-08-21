package C4::Labels::Label;

use strict;
use warnings;

use Text::Wrap;
use Algorithm::CheckDigits;
use Text::CSV_XS;
use Data::Dumper;
use Library::CallNumber::LC;
use Text::Bidi qw( log2vis );

use C4::Context;
use C4::Debug;
use C4::Biblio;

BEGIN {
    use version; our $VERSION = qv('3.07.00.049');
}

my $possible_decimal = qr/\d{3,}(?:\.\d+)?/; # at least three digits for a DDCN

sub _check_params {
    my $given_params = {};
    my $exit_code = 0;
    my @valid_label_params = (
        'batch_id',
        'item_number',
        'llx',
        'lly',
        'height',
        'width',
        'top_text_margin',
        'left_text_margin',
        'barcode_type',
        'printing_type',
        'guidebox',
        'font',
        'font_size',
        'callnum_split',
        'justify',
        'format_string',
        'text_wrap_cols',
        'barcode',
    );
    if (scalar(@_) >1) {
        $given_params = {@_};
        foreach my $key (keys %{$given_params}) {
            if (!(grep m/$key/, @valid_label_params)) {
                warn sprintf('Unrecognized parameter type of "%s".', $key);
                $exit_code = 1;
            }
        }
    }
    else {
        if (!(grep m/$_/, @valid_label_params)) {
            warn sprintf('Unrecognized parameter type of "%s".', $_);
            $exit_code = 1;
        }
    }
    return $exit_code;
}

sub _guide_box {
    my ( $llx, $lly, $width, $height ) = @_;
    return unless ( defined $llx and defined $lly and
                    defined $width and defined $height );
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
#        FIXME This makes for a very bulky data structure; data from tables w/duplicate col names also gets overwritten.
#        Something like this, perhaps, but this also causes problems because we need more fields sometimes.
#        SELECT i.barcode, i.itemcallnumber, i.itype, bi.isbn, bi.issn, b.title, b.author
    my $sth = $dbh->prepare("SELECT bi.*, i.*, b.*,br.* FROM items AS i, biblioitems AS bi ,biblio AS b, branches AS br WHERE itemnumber=? AND i.biblioitemnumber=bi.biblioitemnumber AND bi.biblionumber=b.biblionumber AND i.homebranch=br.branchcode;");
    $sth->execute($item_number);
    if ($sth->err) {
        warn sprintf('Database returned the following error: %s', $sth->errstr);
    }
    my $data = $sth->fetchrow_hashref;
    # Replaced item's itemtype with the more user-friendly description...
    my $sth1 = $dbh->prepare("SELECT itemtype,description FROM itemtypes WHERE itemtype = ?");
    $sth1->execute($data->{'itemtype'});
    if ($sth1->err) {
        warn sprintf('Database returned the following error: %s', $sth1->errstr);
    }
    my $data1 = $sth1->fetchrow_hashref;
    $data->{'itemtype'} = $data1->{'description'};
    $data->{'itype'} = $data1->{'description'};
    # add *_description fields
    if ($data->{'homebranch'} || $data->{'holdingbranch'}){
        require C4::Branch;
        $data->{'homebranch_description'} = C4::Branch::GetBranchName($data->{'homebranch'}) if $data->{'homebranch'};
        $data->{'holdingbranch_description'} = C4::Branch::GetBranchName($data->{'holdingbranch'}) if $data->{'holdingbranch'};
    }
    $data->{'ccode_description'} = C4::Biblio::GetAuthorisedValueDesc('','', $data->{'ccode'} ,'','','CCODE', 1) if $data->{'ccode'};
    $data->{'location_description'} = C4::Biblio::GetAuthorisedValueDesc('','', $data->{'location'} ,'','','LOC', 1) if $data->{'location'};
    $data->{'permanent_location_description'} = C4::Biblio::GetAuthorisedValueDesc('','', $data->{'permanent_location'} ,'','','LOC', 1) if $data->{'permanent_location'};

    $barcode_only ? return $data->{'barcode'} : return $data;
}

sub _get_text_fields {
    my $format_string = shift;
    my $csv = Text::CSV_XS->new({allow_whitespace => 1});
    my $status = $csv->parse($format_string);
    my @sorted_fields = map {{ 'code' => $_, desc => $_ }} 
                        map { $_ eq 'callnumber' ? 'itemcallnumber' : $_ } # see bug 5653
                        $csv->fields();
    my $error = $csv->error_input();
    warn sprintf('Text field sort failed with this error: %s', $error) if $error;
    return \@sorted_fields;
}


sub _split_lccn {
    my ($lccn) = @_;
    $_ = $lccn;
    # lccn examples: 'HE8700.7 .P6T44 1983', 'BS2545.E8 H39 1996';
    my @parts = Library::CallNumber::LC->new($lccn)->components();
    unless (scalar @parts && defined $parts[0])  {
        warn sprintf('regexp failed to match string: %s', $_);
        @parts = $_;     # if no match, just use the whole string.
    }
    push @parts, split /\s+/, pop @parts;   # split the last piece into an arbitrary number of pieces at spaces
    $debug and warn "split_lccn array: ", join(" | ", @parts), "\n";
    return @parts;
}

sub _split_ddcn {
    my ($ddcn) = @_;
    $_ = $ddcn;
    s/\///g;   # in theory we should be able to simply remove all segmentation markers and arrive at the correct call number...
    my (@parts) = m/
        ^([-a-zA-Z]*\s?(?:$possible_decimal)?) # R220.3  CD-ROM 787.87 # will require extra splitting
        \s+
        (.+)                               # H2793Z H32 c.2 EAS # everything else (except bracketing spaces)
        \s*
        /x;
    unless (scalar @parts)  {
        warn sprintf('regexp failed to match string: %s', $_);
        push @parts, $_;     # if no match, just push the whole string.
    }

    if ($parts[0] =~ /^([-a-zA-Z]+)\s?($possible_decimal)$/) {
          shift @parts;         # pull off the mathching first element, like example 1
        unshift @parts, $1, $2; # replace it with the two pieces
    }

    push @parts, split /\s+/, pop @parts;   # split the last piece into an arbitrary number of pieces at spaces
    $debug and print STDERR "split_ddcn array: ", join(" | ", @parts), "\n";
    return @parts;
}

## NOTE: Custom call number types go here. It may be necessary to create additional splitting algorithms if some custom call numbers
##      cannot be made to work here. Presently this splits standard non-ddcn, non-lccn fiction and biography call numbers.

sub _split_ccn {
    my ($fcn) = @_;
    my @parts = ();
    # Split call numbers based on spaces
    push @parts, split /\s+/, $fcn;   # split the call number into an arbitrary number of pieces at spaces
    if ($parts[-1] !~ /^.*\d-\d.*$/ && $parts[-1] =~ /^(.*\d+)(\D.*)$/) {
        pop @parts;            # pull off the matching last element
        push @parts, $1, $2;    # replace it with the two pieces
    }
    unless (scalar @parts) {
        warn sprintf('regexp failed to match string: %s', $_);
        push (@parts, $_);
    }
    $debug and print STDERR "split_ccn array: ", join(" | ", @parts), "\n";
    return @parts;
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
            @{ $kohatables->{'items'} },
            @{ $kohatables->{'branches'} }
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
            } else {
                $debug and warn sprintf("The '%s' field contains no data.", $f);
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
                                warn sprintf("The '%s' field contains no data.", $f);
                            }
                            last ITEM_FIELDS;
                        }
                    }
                } else {  # bib-level data, we'll take the first matching tag/subfield.
                    if ($marcfield[0]->subfield($subf)) {
                        $datastring .= $marcfield[0]->subfield($subf) . $ws;
                    }
                    else {
                        warn sprintf("The '%s' field contains no data.", $f);
                    }
                }
            }
            $f = $';
            next FIELD_LIST;
        }
        else {
            warn sprintf('Failed to parse label format string: %s', $f);
            last FIELD_LIST;    # Failed to match
        }
    }
    return $datastring;
}

sub _desc_koha_tables {
	my $dbh = C4::Context->dbh();
	my $kohatables;
	for my $table ( 'biblio','biblioitems','items','branches' ) {
		my $sth = $dbh->column_info(undef,undef,$table,'%');
		while (my $info = $sth->fetchrow_hashref()){
		        push @{$kohatables->{$table}} , $info->{'COLUMN_NAME'} ;
		}
		$sth->finish;
	}
	return $kohatables;
}

### This series of functions calculates the position of text and barcode on individual labels
### Please *do not* add printing types which are non-atomic. Instead, build code which calls the necessary atomic printing types to form the non-atomic types. See the ALT type
### in labels/label-create-pdf.pl as an example.
### NOTE: Each function must be passed seven parameters and return seven even if some are 0 or undef

sub _BIB {
    my $self = shift;
    my $line_spacer = ($self->{'font_size'} * 1);       # number of pixels between text rows (This is actually leading: baseline to baseline minus font size. Recommended starting point is 20% of font size.).
    my $text_lly = ($self->{'lly'} + ($self->{'height'} - $self->{'top_text_margin'}));
    return $self->{'llx'}, $text_lly, $line_spacer, 0, 0, 0, 0;
}

sub _BAR {
    my $self = shift;
    my $barcode_llx = $self->{'llx'} + $self->{'left_text_margin'};     # this places the bottom left of the barcode the left text margin distance to right of the left edge of the label ($llx)
    my $barcode_lly = $self->{'lly'} + $self->{'top_text_margin'};      # this places the bottom left of the barcode the top text margin distance above the bottom of the label ($lly)
    my $barcode_width = 0.8 * $self->{'width'};                         # this scales the barcode width to 80% of the label width
    my $barcode_y_scale_factor = 0.01 * $self->{'height'};              # this scales the barcode height to 10% of the label height
    return 0, 0, 0, $barcode_llx, $barcode_lly, $barcode_width, $barcode_y_scale_factor;
}

sub _BIBBAR {
    my $self = shift;
    my $barcode_llx = $self->{'llx'} + $self->{'left_text_margin'};     # this places the bottom left of the barcode the left text margin distance to right of the left edge of the label ($self->{'llx'})
    my $barcode_lly = $self->{'lly'} + $self->{'top_text_margin'};      # this places the bottom left of the barcode the top text margin distance above the bottom of the label ($lly)
    my $barcode_width = 0.8 * $self->{'width'};                         # this scales the barcode width to 80% of the label width
    my $barcode_y_scale_factor = 0.01 * $self->{'height'};              # this scales the barcode height to 10% of the label height
    my $line_spacer = ($self->{'font_size'} * 1);       # number of pixels between text rows (This is actually leading: baseline to baseline minus font size. Recommended starting point is 20% of font size.).
    my $text_lly = ($self->{'lly'} + ($self->{'height'} - $self->{'top_text_margin'}));
    $debug and warn  "Label: llx $self->{'llx'}, lly $self->{'lly'}, Text: lly $text_lly, $line_spacer, Barcode: llx $barcode_llx, lly $barcode_lly, $barcode_width, $barcode_y_scale_factor\n";
    return $self->{'llx'}, $text_lly, $line_spacer, $barcode_llx, $barcode_lly, $barcode_width, $barcode_y_scale_factor;
}

sub _BARBIB {
    my $self = shift;
    my $barcode_llx = $self->{'llx'} + $self->{'left_text_margin'};                             # this places the bottom left of the barcode the left text margin distance to right of the left edge of the label ($self->{'llx'})
    my $barcode_lly = ($self->{'lly'} + $self->{'height'}) - $self->{'top_text_margin'};        # this places the bottom left of the barcode the top text margin distance below the top of the label ($self->{'lly'})
    my $barcode_width = 0.8 * $self->{'width'};                                                 # this scales the barcode width to 80% of the label width
    my $barcode_y_scale_factor = 0.01 * $self->{'height'};                                      # this scales the barcode height to 10% of the label height
    my $line_spacer = ($self->{'font_size'} * 1);                               # number of pixels between text rows (This is actually leading: baseline to baseline minus font size. Recommended starting point is 20% of font size.).
    my $text_lly = (($self->{'lly'} + $self->{'height'}) - $self->{'top_text_margin'} - (($self->{'lly'} + $self->{'height'}) - $barcode_lly));
    return $self->{'llx'}, $text_lly, $line_spacer, $barcode_llx, $barcode_lly, $barcode_width, $barcode_y_scale_factor;
}

sub new {
    my ($invocant, %params) = @_;
    my $type = ref($invocant) || $invocant;
    my $self = {
        batch_id                => $params{'batch_id'},
        item_number             => $params{'item_number'},
        llx                     => $params{'llx'},
        lly                     => $params{'lly'},
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

sub get_attr {
    my $self = shift;
    if (_check_params(@_) eq 1) {
        return -1;
    }
    my ($attr) = @_;
    if (exists($self->{$attr})) {
        return $self->{$attr};
    }
    else {
        return -1;
    }
    return;
}

sub create_label {
    my $self = shift;
    my $label_text = '';
    my ($text_llx, $text_lly, $line_spacer, $barcode_llx, $barcode_lly, $barcode_width, $barcode_y_scale_factor);
    {
        no strict 'refs';
        ($text_llx, $text_lly, $line_spacer, $barcode_llx, $barcode_lly, $barcode_width, $barcode_y_scale_factor) = &{"_$self->{'printing_type'}"}($self); # an obfuscated call to the correct printing type sub
    }
    if ($self->{'printing_type'} =~ /BIB/) {
        $label_text = draw_label_text(  $self,
                                        llx             => $text_llx,
                                        lly             => $text_lly,
                                        line_spacer     => $line_spacer,
                                    );
    }
    if ($self->{'printing_type'} =~ /BAR/) {
        barcode(    $self,
                    llx                 => $barcode_llx,
                    lly                 => $barcode_lly,
                    width               => $barcode_width,
                    y_scale_factor      => $barcode_y_scale_factor,
        );
    }
    return $label_text if $label_text;
    return;
}

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
        #FIXME: We should not force the title to oblique; this should be selectible in the layout configuration
        ($field->{'code'} eq 'title') ? (($font =~ /T/) ? ($font = 'TI') : ($font = ($font . 'O'))) : ($font = $font);
        my $field_data = $field->{'data'};
        if ($field_data) {
            $field_data =~ s/\n//g;
            $field_data =~ s/\r//g;
        }
        my @label_lines;
        # Fields which hold call number data  FIXME: ( 060? 090? 092? 099? )
        my @callnumber_list = qw(itemcallnumber 050a 050b 082a 952o 995k);
        if ((grep {$field->{'code'} =~ m/$_/} @callnumber_list) and ($self->{'printing_type'} eq 'BIB') and ($self->{'callnum_split'})) { # If the field contains the call number, we do some sp
            if ($cn_source eq 'lcc' || $cn_source eq 'nlm') { # NLM and LCC should be split the same way
                @label_lines = _split_lccn($field_data);
                @label_lines = _split_ccn($field_data) if !@label_lines;    # If it was not a true lccn, try it as a custom call number
                push (@label_lines, $field_data) if !@label_lines;         # If it was not that, send it on unsplit
            } elsif ($cn_source eq 'ddc') {
                @label_lines = _split_ddcn($field_data);
                @label_lines = _split_ccn($field_data) if !@label_lines;
                push (@label_lines, $field_data) if !@label_lines;
            } else {
                warn sprintf('Call number splitting failed for: %s. Please add this call number to bug #2500 at bugs.koha-community.org', $field_data);
                push @label_lines, $field_data;
            }
        }
        else {
            if ($field_data) {
                $field_data =~ s/\/$//g;       # Here we will strip out all trailing '/' in fields other than the call number...
                # Escaping the parens was causing odd output, see bug 13124
                # $field_data =~ s/\(/\\\(/g;    # Escape '(' and ')' for the pdf object stream...
                # $field_data =~ s/\)/\\\)/g;
            }
            eval{$Text::Wrap::columns = $self->{'text_wrap_cols'};};
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
            my $fontName = C4::Creators::PDF->Font($font);
            $line = log2vis( $line );
            my $string_width = C4::Creators::PDF->StrWidth($line, $fontName, $self->{'font_size'});
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

sub draw_guide_box {
    return $_[0]->{'guidebox'};
}

sub barcode {
    my $self = shift;
    my %params = @_;
    $params{'barcode_data'} = _get_label_item($self->{'item_number'}, 1) if !$params{'barcode_data'};
    $params{'barcode_type'} = $self->{'barcode_type'} if !$params{'barcode_type'};
    my $x_scale_factor = 1;
    my $num_of_bars = length($params{'barcode_data'});
    my $tot_bar_length = 0;
    my $bar_length = 0;
    my $guard_length = 10;
    my $hide_text = 'yes';
    if ($params{'barcode_type'} =~ m/CODE39/) {
        $bar_length = '17.5';
        $tot_bar_length = ($bar_length * $num_of_bars) + ($guard_length * 2);
        $x_scale_factor = ($params{'width'} / $tot_bar_length);
        if ($params{'barcode_type'} eq 'CODE39MOD') {
            my $c39 = CheckDigits('code_39');   # get modulo43 checksum
            $params{'barcode_data'} = $c39->complete($params{'barcode_data'});
        }
        elsif ($params{'barcode_type'} eq 'CODE39MOD10') {
            my $c39_10 = CheckDigits('siret');   # get modulo43 checksum
            $params{'barcode_data'} = $c39_10->complete($params{'barcode_data'});
            $hide_text = '';
        }
        eval {
            PDF::Reuse::Barcode::Code39(
                x                   => $params{'llx'},
                y                   => $params{'lly'},
                value               => "*$params{barcode_data}*",
                xSize               => $x_scale_factor,
                ySize               => $params{'y_scale_factor'},
                hide_asterisk       => 1,
                text                => $hide_text,
                mode                => 'graphic',
            );
        };
        if ($@) {
            warn sprintf('Barcode generation failed for item %s with this error: %s', $self->{'item_number'}, $@);
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
                value               => "*$params{barcode_data}*",
                xSize               => $x_scale_factor,
                ySize               => $params{'y_scale_factor'},
                mode                    => 'graphic',
            );
        };
        if ($@) {
            warn sprintf('Barcode generation failed for item %s with this error: %s', $self->{'item_number'}, $@);
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
                value               => "*$params{barcode_data}*",
                xSize               => $x_scale_factor,
                ySize               => $params{'y_scale_factor'},
                mode                    => 'graphic',
            );
        };
        if ($@) {
            warn sprintf('Barcode generation failed for item %s with this error: %s', $self->{'item_number'}, $@);
        }
    }
    elsif ($params{'barcode_type'} eq 'EAN13') {
        $bar_length = 4; # FIXME
    $num_of_bars = 13;
        $tot_bar_length = ($bar_length * $num_of_bars) + ($guard_length * 2);
        $x_scale_factor = ($params{'width'} / $tot_bar_length) * 0.9;
        eval {
            PDF::Reuse::Barcode::EAN13(
                x                   => $params{'llx'},
                y                   => $params{'lly'},
                value               => sprintf('%013d',$params{barcode_data}),
#                xSize               => $x_scale_factor,
#                ySize               => $params{'y_scale_factor'},
                mode                    => 'graphic',
            );
        };
        if ($@) {
            warn sprintf('Barcode generation failed for item %s with this error: %s', $self->{'item_number'}, $@);
        }
    }
    else {
    warn "unknown barcode_type: $params{barcode_type}";
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

=head1 NAME

C4::Labels::Label - A class for creating and manipulating label objects in Koha

=head1 ABSTRACT

This module provides methods for creating, and otherwise manipulating single label objects used by Koha to create and export labels.

=head1 METHODS

=head2 new()

    Invoking the I<new> method constructs a new label object containing the supplied values. Depending on the final output format of the label data
    the minimal required parameters change. (See the implimentation of this object type in labels/label-create-pdf.pl and labels/label-create-csv.pl
    and labels/label-create-xml.pl for examples.) The following parameters are optionally accepted as key => value pairs:

        C<batch_id>             Batch id with which this label is associated
        C<item_number>          Item number of item to be the data source for this label
        C<height>               Height of this label (All measures passed to this method B<must> be supplied in postscript points)
        C<width>                Width of this label
        C<top_text_margin>      Top margin of this label
        C<left_text_margin>     Left margin of this label
        C<barcode_type>         Defines the barcode type to be used on labels. NOTE: At present only the following barcode types are supported in the label creator code:

=over 9

=item .
            CODE39          = Code 3 of 9

=item .
            CODE39MOD       = Code 3 of 9 with modulo 43 checksum

=item .
            CODE39MOD10     = Code 3 of 9 with modulo 10 checksum

=item .
            COOP2OF5        = A varient of 2 of 5 barcode based on NEC's "Process 8000" code

=item .
            INDUSTRIAL2OF5  = The standard 2 of 5 barcode (a binary level bar code developed by Identicon Corp. and Computer Identics Corp. in 1970)

=item .
            EAN13           = The standard EAN-13 barcode

=back

        C<printing_type>        Defines the general layout to be used on labels. NOTE: At present there are only five printing types supported in the label creator code:

=over 9

=item .
BIB     = Only the bibliographic data is printed

=item .
BARBIB  = Barcode proceeds bibliographic data

=item .
BIBBAR  = Bibliographic data proceeds barcode

=item .
ALT     = Barcode and bibliographic data are printed on alternating labels

=item .
BAR     = Only the barcode is printed

=back

        C<guidebox>             Setting this to '1' will result in a guide box being drawn around the labels marking the edge of each label
        C<font>                 Defines the type of font to be used on labels. NOTE: The following fonts are available by default on most systems:

=over 9

=item .
TR      = Times-Roman

=item .
TB      = Times Bold

=item .
TI      = Times Italic

=item .
TBI     = Times Bold Italic

=item .
C       = Courier

=item .
CB      = Courier Bold

=item .
CO      = Courier Oblique (Italic)

=item .
CBO     = Courier Bold Oblique

=item .
H       = Helvetica

=item .
HB      = Helvetica Bold

=item .
HBO     = Helvetical Bold Oblique

=back

        C<font_size>            Defines the size of the font in postscript points to be used on labels
        C<callnum_split>        Setting this to '1' will enable call number splitting on labels
        C<text_justify>         Defines the text justification to be used on labels. NOTE: The following justification styles are currently supported by label creator code:

=over 9

=item .
L       = Left

=item .
C       = Center

=item .
R       = Right

=back

        C<format_string>        Defines what fields will be printed and in what order they will be printed on labels. These include any of the data fields that may be mapped
                                to your MARC frameworks. Specify MARC subfields as a 4-character tag-subfield string: ie. 254a Enclose a whitespace-separated list of fields
                                to concatenate on one line in double quotes. ie. "099a 099b" or "itemcallnumber barcode" Static text strings may be entered in single-quotes:
                                ie. 'Some static text here.'
        C<text_wrap_cols>       Defines the column after which the text will wrap to the next line.

=head2 get_label_type()

   Invoking the I<get_label_type> method will return the printing type of the label object.

   example:
        C<my $label_type = $label->get_label_type();>

=head2 get_attr($attribute)

    Invoking the I<get_attr> method will return the value of the requested attribute or -1 on errors.

    example:
        C<my $value = $label->get_attr($attribute);>

=head2 create_label()

    Invoking the I<create_label> method generates the text for that label and returns it as an arrayref of an array contianing the formatted text as well as creating the barcode
    and writing it directly to the pdf stream. The handling of the barcode is not quite good OO form due to the linear format of PDF::Reuse::Barcode. Be aware that the instantiating
    code is responsible to properly format the text for insertion into the pdf stream as well as the actual insertion.

    example:
        my $label_text = $label->create_label();

=head2 draw_label_text()

    Invoking the I<draw_label_text> method generates the label text for the label object and returns it as an arrayref of an array containing the formatted text. The same caveats
    apply to this method as to C<create_label()>. This method accepts the following parameters as key => value pairs: (NOTE: The unit is the postscript point - 72 per inch)

        C<llx>                  The lower-left x coordinate for the text block (The point of origin for all PDF's is the lower left of the page per ISO 32000-1)
        C<lly>                  The lower-left y coordinate for the text block
        C<top_text_margin>      The top margin for the text block.
        C<line_spacer>          The number of pixels between text rows (This is actually leading: baseline to baseline minus font size. Recommended starting point is 20% of font size)
        C<font>                 The font to use for this label. See documentation on the new() method for supported fonts.
        C<font_size>            The font size in points to use for this label.
        C<justify>              The style of justification to use for this label. See documentation on the new() method for supported justification styles.

    example:
       C<my $label_text = $label->draw_label_text(
                                                llx                 => $text_llx,
                                                lly                 => $text_lly,
                                                top_text_margin     => $label_top_text_margin,
                                                line_spacer         => $text_leading,
                                                font                => $text_font,
                                                font_size           => $text_font_size,
                                                justify             => $text_justification,
                        );>

=head2 barcode()

    Invoking the I<barcode> method generates a barcode for the label object and inserts it into the current pdf stream. This method accepts the following parameters as key => value
    pairs (C<barcode_data> is optional and omitting it will cause the barcode from the current item to be used. C<barcode_type> is also optional. Omission results in the barcode
    type of the current template being used.):

        C<llx>                  The lower-left x coordinate for the barcode block (The point of origin for all PDF's is the lower left of the page per ISO 32000-1)
        C<lly>                  The lower-left y coordinate for the barcode block
        C<width>                The width of the barcode block
        C<y_scale_factor>       The scale factor to be applied to the y axis of the barcode block
        C<barcode_data>         The data to be encoded in the barcode
        C<barcode_type>         The barcode type (See the C<new()> method for supported barcode types)

    example:
       C<$label->barcode(
                    llx                 => $barcode_llx,
                    lly                 => $barcode_lly,
                    width               => $barcode_width,
                    y_scale_factor      => $barcode_y_scale_factor,
                    barcode_data        => $barcode,
                    barcode_type        => $barcodetype,
        );>

=head2 csv_data()

    Invoking the I<csv_data> method returns an arrayref of an array containing the label data suitable for passing to Text::CSV_XS->combine() to produce csv output.

    example:
        C<my $csv_data = $label->csv_data();>

=head1 AUTHOR

Mason James <mason@katipo.co.nz>

Chris Nighswonger <cnighswonger AT foundations DOT edu>

=head1 COPYRIGHT

Copyright 2006 Katipo Communications.

Copyright 2009 Foundations Bible College.

=head1 LICENSE

This file is part of Koha.

Koha is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 of the License, or (at your option) any later version.

You should have received a copy of the GNU General Public License along with Koha; if not, write to the Free Software Foundation, Inc., 51 Franklin Street,
Fifth Floor, Boston, MA 02110-1301 USA.

=head1 DISCLAIMER OF WARRANTY

Koha is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

=cut
