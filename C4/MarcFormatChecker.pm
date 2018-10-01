package C4::MarcFormatChecker;

use strict;

use C4::Context;
use Koha::Caches;
use XML::Simple;

use vars qw(@ISA @EXPORT);

BEGIN {

	require Exporter;
    @ISA = qw( Exporter );

    # function exports
    @EXPORT = qw(
        CheckMARC21FormatErrors
    );
}


# It's not currently possible to get this info out of the xml file
my %field_data = (
    'valid_fields' => {},
    'not_repeatable' => {},
    'allow_indicators' => {},
    'typed' => {},
    'fixed_length' => {
	'000' => 24,
	'005' => 16,
	'006' => 18,
	'008' => 40
    },
    'regex' => {},
    'allow_regex' => {
	'000' => {
	    '00' => '[0-9]',
	    '01' => '[0-9]',
	    '02' => '[0-9]',
	    '03' => '[0-9]',
	    '04' => '[0-9]',
	    '12' => '[0-9]',
	    '13' => '[0-9]',
	    '14' => '[0-9]',
	    '15' => '[0-9]',
	    '16' => '[0-9]',
	},
	'005' => {
	    'x' => '^[0-9]{14}\.[0-9]$',
	},
	'006' => {
	    '00' => '[acdefgijkmoprst]',
	},
	'007' => {
	    '00' => '[acdfghkmoqrstvz]',
	},
    },
    );

# convert 006/00 to material code
my %convert_006_material = (
    'a' => 'BK',
    't' => 'BK',
    'm' => 'CF',
    's' => 'CR',
    'e' => 'MP',
    'f' => 'MP',
    'c' => 'MU',
    'd' => 'MU',
    'i' => 'MU',
    'j' => 'MU',
    'p' => 'MX',
    'g' => 'VM',
    'k' => 'VM',
    'o' => 'VM',
    'r' => 'VM',
    );

sub get_field_tagntype {
    my ($tag, $record) = @_;

    if ($tag eq '006') {
        my $f = $record->field($tag);
        if ($f) {
            my $data = substr($f->data(), 0, 1) || '';
            return $tag.'-'.$convert_006_material{$data} if (defined($convert_006_material{$data}));
        }
    } elsif ($tag eq '007') {
        my $f = $record->field($tag);
        if ($f) {
            my $data = substr($f->data(), 0, 1) || '';
            return $tag.'-'.$data if ($data ne '');
        }
    } elsif ($tag eq '008') {
        my $ldr = $record->leader();
        my $l6 = substr($ldr, 6, 1);
        my $l7 = substr($ldr, 7, 1);
        my $data = '';
	# FIXME: Same as 006, but also checks ldr/07
        $data = 'BK' if (($l6 eq 'a' || $l6 eq 't') && !($l7 eq 'b' || $l7 eq 'i' || $l7 eq 's'));
        $data = 'CF' if ($l6 eq 'm');
        $data = 'CR' if (($l6 eq 'a' || $l6 eq 't') &&  ($l7 eq 'b' || $l7 eq 'i' || $l7 eq 's'));
        $data = 'MP' if ($l6 eq 'e' || $l6 eq 'f');
        $data = 'MU' if ($l6 eq 'c' || $l6 eq 'd' || $l6 eq 'i' || $l6 eq 'j');
        $data = 'MX' if ($l6 eq 'p');
        $data = 'VM' if ($l6 eq 'g' || $l6 eq 'k' || $l6 eq 'o' || $l6 eq 'r');
        return $tag.'-'.$data if ($data ne '');
    }
    return $tag;
}

sub generate_tag_sequence {
    my ($tag) = @_;

    my @fields;

    if ($tag =~ /,/) {
	foreach my $tmp (split(/,/, $tag)) {
	    push(@fields, generate_tag_sequence($tmp));
	}
	return @fields;
    }

    if (defined($tag) && $tag =~ /x/i && $tag =~ /^([0-9x])([0-9x])([0-9x])(.*)$/i) {
        my ($p1, $p2, $p3, $p4) = ($1, $2, $3, $4);
        my @c1 = (($p1 =~ /x/i) ? 0..9 : $p1);
        my @c2 = (($p2 =~ /x/i) ? 0..9 : $p2);
        my @c3 = (($p3 =~ /x/i) ? 0..9 : $p3);

        foreach my $a1 (@c1) {
            foreach my $a2 (@c2) {
                foreach my $a3 (@c3) {
                    my $fld = $a1.$a2.$a3.$p4;
                    push @fields, $fld;
                }
            }
        }
    } else {
        push @fields, $tag;
    }

    return @fields;
}

sub parse_single_field {
    my ($field, $data) = @_;

    #my $name = $field->{'name'};
    my $tag = $field->{'tag'};
    my $type = $field->{'type'} || '';
    my $repeatable = $field->{'repeatable'} || '';

    if ($tag =~ /x/i) {
        my @tags = generate_tag_sequence($tag);
        foreach my $tmptag (@tags) {
            $field->{'tag'} = $tmptag;
            parse_single_field($field, $data);
        }
        return;
    }

    my %valid_fields = %{$data->{'valid_fields'}};
    my %not_repeatable = %{$data->{'not_repeatable'}};
    my %allow_indicators = %{$data->{'allow_indicators'}};
    my %typed_field = %{$data->{'typed'}};
    my %regex_field = %{$data->{'regex'}};
    my %allow_regex = %{$data->{'allow_regex'}};

    $type = '' if ($type eq 'yleista');
    $type = "-".$type if ($type ne '');
    $typed_field{$tag} = 1 if ($type ne '');

    $valid_fields{$tag} = 1;
    $not_repeatable{$tag . $type} = 1 if ($repeatable eq 'N');

    if (defined($field->{'indicators'}{'indicator'})) {
        my $indicators = $field->{'indicators'}{'indicator'};
        my @indicatorarr;

        if (ref($indicators) eq 'ARRAY') {
            @indicatorarr = @{$indicators};
        } else {
            @indicatorarr = $indicators;
        }

        foreach my $ind (@indicatorarr) {
            my $ind_num = $ind->{'num'};
            my $ind_values = $ind->{'values'}{'value'};
            my @ind_valuearr;
            my $allowed_ind_values = '';

            next if (!defined($ind_values));

            if (ref($ind_values) eq 'ARRAY') {
                @ind_valuearr = @{$ind_values};
            } else {
                @ind_valuearr = $ind_values;
            }
            foreach my $indval (@ind_valuearr) {
                my $ivcode = $indval->{'code'};
                $ivcode =~ s/#/ /g;
                $allowed_ind_values .= $ivcode;
            }
            $allow_indicators{$tag . $ind_num} = $allowed_ind_values;
        }
    }


    if (defined($field->{'subfields'}{'subfield'})) {
        my $subfields = $field->{'subfields'}{'subfield'};
        my @subfieldarr;

        if (ref($subfields) eq 'ARRAY') {
            @subfieldarr = @{$subfields};
        } else {
            @subfieldarr = $subfields;
        }

        foreach my $sf (@subfieldarr) {
            my $sf_code = $sf->{'code'};
            my $sf_repeatable = $sf->{'repeatable'};
            my $sf_name = $sf->{'name'};

            $valid_fields{$tag . $sf_code} = 1;
            $not_repeatable{$tag . $sf_code . $type} = 1 if ($sf_repeatable eq 'N');
        }
    }

    if (defined($field->{'positions'}{'position'})) {
        my $positions = $field->{'positions'}{'position'};
        my @positionarr;

        if (ref($positions) eq 'ARRAY') {
            @positionarr = @{$positions};
        } else {
            @positionarr = $positions;
        }

        foreach my $p (@positionarr) {
            my $pos = $p->{'pos'};
            my $equals = $p->{'equals'};
            my @vals;

            if (defined($p->{'values'}{'value'})) {
                my $pvalues = $p->{'values'}{'value'};
                my @pvaluearr;
                if (ref($pvalues) eq 'ARRAY') {
                    @pvaluearr = @{$pvalues};
                } else {
                    @pvaluearr = $pvalues;
                }
                foreach my $pv (@pvaluearr) {
                    my $pv_code = $pv->{'code'};
                    $pv_code =~ s/#/ /g;
                    $regex_field{$tag . $type}{$pos} = [] if (!defined($regex_field{$tag . $type}{$pos}));
                    push @{$regex_field{$tag . $type}{$pos}}, $pv_code;

                    $allow_regex{$tag . $type}{$pos} = [] if (!defined($allow_regex{$tag . $type}{$pos}));
                    push @{$allow_regex{$tag . $type}{$pos}}, $pv_code;
                }

                if (defined($equals)) {
                    my $eq_tag = $equals->{'tag'};
                    my $eq_pos = $equals->{'positions'};
                    $regex_field{$eq_tag . $type}{$eq_pos} = [] if (!defined($regex_field{$eq_tag . $type}{$eq_pos}));
                    @{$regex_field{$eq_tag . $type}{$eq_pos}} = @{$regex_field{$tag . $type}{$pos}};

                    $allow_regex{$eq_tag . $type}{$eq_pos} = [] if (!defined($allow_regex{$eq_tag . $type}{$eq_pos}));
                    @{$allow_regex{$eq_tag . $type}{$eq_pos}} = @{$allow_regex{$tag . $type}{$pos}};
                }
            }
        }
    }

    $data->{'valid_fields'} = \%valid_fields;
    $data->{'not_repeatable'} = \%not_repeatable;
    $data->{'allow_indicators'} = \%allow_indicators;
    $data->{'typed'} = \%typed_field;
    $data->{'regex'} = \%regex_field;
    $data->{'allow_regex'} = \%allow_regex;
}

sub parse_multiple_fields {
    my ($fieldsref, $data) = @_;

    my @fieldarr;

    if (ref($fieldsref) eq 'ARRAY') {
        @fieldarr = @{$fieldsref};
    } else {
        @fieldarr = $fieldsref;
    }

    foreach my $field (@fieldarr) {
        parse_single_field($field, $data);
    }
}

sub parse_xml_data {
    my ($filename, $data) = @_;

    my $tpp = XML::Simple->new();
    my $tree = $tpp->XMLin($filename, KeyAttr => []);

    if (defined($tree->{'leader-directory'})) {
        $tree->{'leader-directory'}{'leader'}{'tag'} = '000';
        parse_multiple_fields($tree->{'leader-directory'}{'leader'}, $data);
    } elsif (defined($tree->{'controlfields'})) {
        parse_multiple_fields($tree->{'controlfields'}{'controlfield'}, $data);
    } elsif (defined($tree->{'datafields'})) {
        parse_multiple_fields($tree->{'datafields'}{'datafield'}, $data);
    } else {
        warn "parse_marc21_format_xml: unhandled file $filename";
    }
}

sub fix_regex_data {
    my ($data) = @_;

    my %re = %{$data};

    foreach my $rekey (sort keys(%re)) {
        my %sr = %{$re{$rekey}};
        foreach my $srkey (sort keys(%sr)) {
            my $dat = $sr{$srkey};
            my $rdat = ref($sr{$srkey});
            next if ($rdat eq 'Regexp');

            my $srkeylen = 1;
            if ($srkey =~ /(\d+)-(\d+)/) {
                my ($startpos, $endpos) = ($1, $2);
                $srkeylen = ($endpos - $startpos) + 1;
            }

            if ($rdat eq 'ARRAY') {
                my @vals;
                for (my $idx = 0; $idx < scalar(@{$dat}); $idx++) {
                    my $val = @{$dat}[$idx];
                    if ($val =~ /^(\d+)-(\d+)$/) {
                        push(@vals, ($1 .. $2));
                        next;
                    }
                    push(@vals, $val);
                }

                my %reparts;
                foreach my $val (@vals) {
                    my $lval = length($val);
                    $val =~ s/\|/\\|/g;
                    $reparts{$lval} = () if (!defined($reparts{$lval}));
                    push(@{$reparts{$lval}}, $val);
                }

                my @restr;
                for my $key (sort keys(%reparts)) {
                    if (int($key) == $srkeylen) {
                        push(@restr, @{$reparts{$key}});
                    } else {
                        my $reps = ($srkeylen / int($key));
                        if ($reps == int($reps)) {
                            my $s = '(' . join('|', @{$reparts{$key}}) . '){'.int($reps).'}';
                            push(@restr, $s);
                        } else {
                            warn "Regexp repeat not an int: (".join('|', @{$reparts{$key}})."){".$reps."}";
                        }
                    }
                }

                my $s = join('|', @restr);
                $re{$rekey}{$srkey} = qr/^($s)$/;

            } else {
                warn "marc21 format regex is not array";
            }
        }
    }
    return $data;
}

sub quoted_str_list {
    my ($lst) = @_;
    my $ret = '';
    if (defined($lst)) {
	my @arr = @{$lst};
	my $haspipes = 0;
	my $len = 0;
	my %lens;
	foreach my $tmp (@arr) {
	    $haspipes = 1 if ($tmp =~ /\|/);
	    $len = length($tmp) if ($len == 0);
	    $len = -1 if ($len != length($tmp));
	}
	if (!$haspipes && $len != -1) {
	    $ret = join('', @arr) if ($len == 1);
	    $ret = join('|', @arr) if ($len > 1);
	} elsif ($len != -1) {
	    $ret = join('', @arr) if ($len == 1);
	    $ret = join(',', @arr) if ($len > 1);
	} else {
	    $ret = join('","', @arr);
	    $ret = '"'.$ret.'"' if ($ret ne '');
	}
    }
    return '['.$ret.']';
}

sub fix_allow_regex_data {
    my ($data) = @_;

    my %re = %{$data};

    foreach my $rekey (sort keys(%re)) {
        my %sr = %{$re{$rekey}};
        foreach my $srkey (sort keys(%sr)) {
            my $dat = $sr{$srkey};
	    if (ref($dat) eq 'ARRAY') {
		$re{$rekey}{$srkey} = quoted_str_list($dat);
	    }
        }
    }

    return $data;
}

sub copy_allow_to_regex {
    my ($allow, $regex) = @_;

    my %al = %{$allow};
    my %re = %{$regex};

    foreach my $alkey (keys (%al)) {
	foreach my $xlkey (sort keys (%{$al{$alkey}})) {
	    $re{$alkey} = {} if (!defined($re{$alkey}));
	    $re{$alkey}{$xlkey} = qr/$al{$alkey}{$xlkey}/ if (!defined($re{$alkey}{$xlkey}));
	}
    }
    return \%re;
}

sub parse_MARC21_format_definition {

    my $cache_key = 'MARC21-formatchecker-bib';
    my $cache = Koha::Caches->get_instance();
    my $cached = $cache->get_from_cache($cache_key);
    return $cached if $cached;

    my $xml_dir = C4::Context->config('intranetdir') . '/cataloguing/MARC21formatXML';
    my $xml_glob = $xml_dir . '/bib-*.xml';

    return undef if (! -d $xml_dir);

    my @xmlfiles = glob($xml_glob);

    return undef if (scalar(@xmlfiles) < 1);

    $field_data{'regex'} = copy_allow_to_regex($field_data{'allow_regex'}, $field_data{'regex'});

    foreach my $file (@xmlfiles) {
	parse_xml_data($file, \%field_data);
    }

    $field_data{'regex'} = fix_regex_data($field_data{'regex'});
    $field_data{'allow_regex'} = fix_allow_regex_data($field_data{'allow_regex'});

    # indicators are listed as sets of allowed chars. eg. ' ab' or '1-9'
    foreach my $tmp (keys(%{$field_data{'allow_indicators'}})) {
	$field_data{'allow_indicators'}{$tmp} = '[' . $field_data{'allow_indicators'}{$tmp} . ']';
    }

    my %tmpignores = map {($_, 1)} generate_tag_sequence(C4::Context->preference('MARC21FormatWarningsIgnoreFields'));
    $field_data{'ignore_fields'} = \%tmpignores;

    $cache->set_in_cache($cache_key, \%field_data);

    return \%field_data;
}

sub sort_by_number {
    my ( $anum ) = $a =~ /(\d+)/;
    my ( $bnum ) = $b =~ /(\d+)/;
    ( $anum || 0 ) <=> ( $bnum || 0 );
}

sub CheckMARC21FormatErrors {
    my ($origrecord) = @_;

    my $record = $origrecord->clone();

    if (substr($record->leader(), 1, 1) eq ' ') {
	$record->set_leader_lengths();
    }

    my $formatdata = parse_MARC21_format_definition();

    my %mainf;
    my %undeffs;

    my @errors;

    if (!defined($formatdata)) {
	warn "No MARC21 format data available";
	return \@errors;
    }

    my %ignore_fields = %{$formatdata->{'ignore_fields'}};
    my %valid_fields = %{$formatdata->{'valid_fields'}};
    my %not_repeatable = %{$formatdata->{'not_repeatable'}};
    my %allow_indicators = %{$formatdata->{'allow_indicators'}};
    my %typed_field = %{$formatdata->{'typed'}};
    my %format_regex = %{$formatdata->{'regex'}};

    my $test_field_data = 1;
    $record->append_fields(MARC::Field->new('000', $record->leader()));

    foreach my $f ($record->field('...')) {
	my $fi = $f->{'_tag'};
	my $fityp = get_field_tagntype($fi, $record);

	next if (defined($ignore_fields{$fi}) || defined($ignore_fields{$fityp}));

	if (!defined($valid_fields{$fi})) {
	    $undeffs{$fi} = 1;
	    #push(@errors, "field $fi not defined by format");
	    next;
	}

	if ($test_field_data) {
	    my $key = $fi.'.length';
	    if (!defined($ignore_fields{$key}) && defined($formatdata->{'fixed_length'}{$fi})) {
		my $tmp = $formatdata->{'fixed_length'}{$fi};
		if ($tmp != length($f->data())) {
		    my %tmphash = (
			'field' => $key,
			'length' => length($f->data()),
			'wanted' => $tmp,
			'error' => 'FIELD_LENGTH'
			);
		    push(@errors, \%tmphash);
		    next;
		}
	    }

	    my @regexkeys;
	    push(@regexkeys, $fi) if ($format_regex{$fi});
	    push(@regexkeys, $fityp) if ($fi ne $fityp && $format_regex{$fityp});
	    push(@regexkeys, $fi.'-kaikki') if ($format_regex{$fi.'-kaikki'});

	    if (scalar(@regexkeys)) {
		my $data = $f->data();
		foreach my $rk (sort @regexkeys ) {
		    my $s;
		    my $zf = $format_regex{$rk};
		    my %ff = %{$zf};

		    foreach my $ffk (sort(sort_by_number keys(%ff))) {
                        my $allow_vals = $formatdata->{'allow_regex'}{$rk}{$ffk};

			if ($ffk =~ /^\d+$/) {
			    $s = length($data) < int($ffk) ? '' : substr($data, int($ffk), 1);
			    if ($s !~ /$ff{$ffk}/) {
				my %tmphash = (
				    'field' => $fi,
				    'pos' => $ffk,
				    'value' => $s,
				    'required' => $allow_vals,
				    'error' => 'FIELD_VALUE_POS'
				    );
				push(@errors, \%tmphash);
				next;
			    }
			} elsif ($ffk =~ /^(\d+)-(\d+)$/) {
			    my ($kstart, $kend) = (int($1), int($2));
			    $s = length($data) < $kend ? '' : substr($data, $kstart, $kend - $kstart + 1);
			    if ($s !~ /$ff{$ffk}/) {
				my %tmphash = (
				    'field' => $fi,
				    'pos' => $ffk,
				    'value' => $s,
				    'required' => $allow_vals,
				    'error' => 'FIELD_VALUE_POS'
				    );
				push(@errors, \%tmphash);
				next;
			    }
			} else {
			    $s = $data || "";
			    if ($s !~ /$ff{$ffk}/) {
				my %tmphash = (
				    'field' => $fi,
				    'value' => $s,
				    'required' => $allow_vals,
				    'error' => 'FIELD_VALUE'
				    );
				push(@errors, \%tmphash);
				next;
			    }
			}
		    }
		}
	    }
	}

	if ($typed_field{$fi}) {

	    next if (defined($ignore_fields{$fityp}));

	    if ($fityp ne $fi) {
		$mainf{$fityp} = 0 if (!defined($mainf{$fityp}));
		$mainf{$fityp}++;
	    }
	}

	next if (scalar($fi) < 10);

	$mainf{$fi} = 0 if (!defined($mainf{$fi}));
	$mainf{$fi}++;

	my @subf = @{$f->{'_subfields'}};
	my %subff;

	while ($#subf > 0) {
	    my $key = shift @subf;
	    my $val = shift @subf;
	    my $fikey = $fi.$key;

	    next if (defined($ignore_fields{$fikey}));

	    if (!defined($valid_fields{$fikey})) {
		$undeffs{$fi . '$' . $key} = 1;
		#push(@errors, "field $fikey not defined by format");
		next;
	    }

	    $subff{$fikey} = 0 if (!defined($subff{$fikey}));
	    $subff{$fikey}++;
	}

	foreach my $k (keys(%subff)) {
	    if (($subff{$k} > 1) && defined($not_repeatable{$k})) {
		my %tmphash = (
		    'field' => $k,
		    'count' => $subff{$k},
		    'error' => 'NOT_REPEATABLE_SUBFIELD'
		    );
		push(@errors, \%tmphash);
	    }
	}

	foreach my $ind ((1, 2)) {
	    my $indv = $f->indicator($ind);
	    my $tmp = $allow_indicators{$fi.$ind};
	    my $key = $fi.'.ind'.$ind;

	    next if (defined($ignore_fields{$key}));

	    if (defined($tmp) && ($indv !~ /$tmp/)) {
		my %tmphash = (
		    'field' => $fi,
		    'indicator' => $ind,
		    'current' => $indv,
		    'valid' => $tmp,
		    'error' => 'INDICATOR'
		    );
		push(@errors, \%tmphash);
	    }
	}
    }

    if (scalar(keys(%undeffs)) > 0) {
	foreach my $undkey (keys(%undeffs)) {
	    my %tmphash = (
		'field' => $undkey,
		'error' => 'NOT_IN_FORMAT'
		);
	    push(@errors, \%tmphash);
	}
    }

    foreach my $k (keys(%mainf)) {
	if (($mainf{$k} > 1) && defined($not_repeatable{$k})) {
	    my %tmphash = (
		'field' => $k,
		'count' => $mainf{$k},
		'error' => 'NOT_REPEATABLE_FIELD'
		);
	    push(@errors, \%tmphash);
	}
    }

    my @tmperr = sort { $a->{'field'} cmp $b->{'field'} } @errors;
    return \@tmperr;
}

1;
