package C4::MarcFormatChecker;

use strict;

use C4::Context;
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
    'fixed_length' => {
	'000' => 24,
	'005' => 16,
	'006' => 18,
	'008' => 40
    },
    'regex' => {
	'000' => {
	    '0' => qr/[0-9]/,
	    '1' => qr/[0-9]/,
	    '2' => qr/[0-9]/,
	    '3' => qr/[0-9]/,
	    '4' => qr/[0-9]/,
	    '10' => qr/[2]/,
	    '11' => qr/[2]/,
	    '12' => qr/[0-9]/,
	    '13' => qr/[0-9]/,
	    '14' => qr/[0-9]/,
	    '15' => qr/[0-9]/,
	    '16' => qr/[0-9]/,
	},
	'005' => {
	    'x' => qr/^[0-9]{14}\.[0-9]$/
	},
    }
    );


sub parse_MARC21_format_definition {

    my $xml_file = C4::Context->config('intranetdir') . '/cataloguing/MARC21formatBibs.xml';

    if ( ! -f $xml_file) {
	warn "Cannot check MARC format errors, $xml_file not readable";
	return undef;
    }

    my $tpp = XML::Simple->new();
    my $tree = $tpp->XMLin($xml_file, KeyAttr => []);

    my @treefields = $tree->{'field'};

    my %valid_fields;
    my %not_repeatable;
    my %allow_indicators;
    foreach my $tf (@treefields) {
	foreach my $tfx ($tf) {
	    my @arr = @{$tfx};
	    foreach my $tmph (@arr) {
		my %dat = %{$tmph};
		my $dsf = $dat{'subfield'};
		my $ind = $dat{'indicator'};
		my $pos = $dat{'position'};
		my @dsfar;

		$valid_fields{$dat{'tag'}} = 1;
		$not_repeatable{$dat{'tag'}} = 1 if ($dat{'repeatable'} eq 'false');
		if (defined($dsf)) {
		    if (ref($dat{'subfield'}) eq 'ARRAY') {
			@dsfar = @{$dsf};
		    } else {
			@dsfar = $dsf;
		    }
		    foreach my $subfield (@dsfar) {
			my %datsf = %{$subfield};
			$not_repeatable{$dat{'tag'}.$datsf{'code'}} = 1 if ($datsf{'repeatable'} eq 'false');
		    }
		}

		if (defined($ind)) {
		    my @indar;
		    if (ref($dat{'indicator'}) eq 'ARRAY') {
			@indar = @{$ind};
		    } else {
			@indar = $ind;
		    }
		    foreach my $indicator (@indar) {
			my %datind = %{$indicator};
			my $ipos = $datind{'position'};
			my $ival = $datind{'value'};
			$ival =~ s/#/ /;
			$allow_indicators{$dat{'tag'}.$ipos} = '' if (!defined($allow_indicators{$dat{'tag'}.$ipos}));
			$allow_indicators{$dat{'tag'}.$ipos} .= $ival;
		    }
		}

		if (defined($pos)) {
		    my @posar;
		    if (ref($dat{'position'}) eq 'ARRAY') {
			@posar = @{$pos};
		    } else {
			@posar = $pos;
		    }

		    foreach my $position (@posar) {
			my %postmp = %{$position};
			my $pospos = $postmp{'pos'};
			my $poscodes = $postmp{'codes'};

			$field_data{'regex'}{$dat{'tag'}}{int($pospos)} = $poscodes;
		    }
		}
	    }
	}
    }

    # indicators are listed as sets of allowed chars. eg. ' ab' or '1-9'
    foreach my $tmp (keys(%allow_indicators)) {
	$allow_indicators{$tmp} = '[' . $allow_indicators{$tmp} . ']';
    }

    my %ignore_fields  = map {($_, 1)} split(/,/, C4::Context->preference('MARC21FormatWarningsIgnoreFields'));

    foreach my $k (keys(%ignore_fields)) {
	if ($k =~ /[xX]/ && $k =~ /^([0-9x])([0-9x])([0-9x])(.*)$/i) {
	    my ($p1, $p2, $p3, $p4) = ($1, $2, $3, $4);
	    my @c1 = (($p1 =~ /x/i) ? 0..9 : $p1);
	    my @c2 = (($p2 =~ /x/i) ? 0..9 : $p2);
	    my @c3 = (($p3 =~ /x/i) ? 0..9 : $p3);

	    foreach my $a1 (@c1) {
		foreach my $a2 (@c2) {
		    foreach my $a3 (@c3) {
			my $fld = $a1.$a2.$a3.$p4;
			$ignore_fields{$fld} = 1;
		    }
		}
	    }
	    delete $ignore_fields{$k};
	}
    }

    my %ret = (
	'ignore_fields' => \%ignore_fields,
	'valid_fields' => \%valid_fields,
	'not_repeatable' => \%not_repeatable,
	'allow_indicators' => \%allow_indicators
	);

    return \%ret;
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

    return \@errors if (!defined($formatdata));

    # grumble ...
    $field_data{'regex'}{'000'}{10} = qr/[2]/;
    $field_data{'regex'}{'000'}{11} = qr/[2]/;

    my %ignore_fields = %{$formatdata->{'ignore_fields'}};
    my %valid_fields = %{$formatdata->{'valid_fields'}};
    my %not_repeatable = %{$formatdata->{'not_repeatable'}};
    my %allow_indicators = %{$formatdata->{'allow_indicators'}};

    my $test_field_data = 1;
    $record->append_fields(MARC::Field->new('000', $record->leader()));

    foreach my $f ($record->field('...')) {
	my $fi = $f->{'_tag'};

	next if (defined($ignore_fields{$fi}));

	if (!defined($valid_fields{$fi})) {
	    $undeffs{$fi} = 1;
	    #push(@errors, "field $fi not defined by format");
	    next;
	}

	if ($test_field_data) {
	    my $key = $fi.'.length';
	    next if (defined($ignore_fields{$key}));
	    if (defined($field_data{'fixed_length'}{$fi})) {
		my $tmp = $field_data{'fixed_length'}{$fi};
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

	    if (defined($field_data{'regex'}{$fi})) {
		my $data = $f->data();
		foreach my $k (sort(sort_by_number keys(%{$field_data{'regex'}{$fi}}))) {
		    my $s;
		    if ($k =~ /^\d+$/) {
			$s = substr($data, scalar($k), 1);
			if ($s !~ /$field_data{'regex'}{$fi}{$k}/) {
			    my %tmphash = (
				'field' => $fi,
				'pos' => $k,
				'value' => $s,
				'required' => $field_data{'regex'}{$fi}{$k},
				'error' => 'FIELD_VALUE_POS'
				);
			    push(@errors, \%tmphash);
			    next;
			}
		    } else {
			$s = $data || "";
			if ($s !~ /$field_data{'regex'}{$fi}{$k}/) {
			    my %tmphash = (
				'field' => $fi,
				'value' => $s,
				'required' => $field_data{'regex'}{$fi}{$k},
				'error' => 'FIELD_VALUE'
				);
			    push(@errors, \%tmphash);
			    next;
			}
		    }
		}
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
