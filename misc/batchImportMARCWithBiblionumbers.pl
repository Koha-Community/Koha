#!/usr/bin/perl
# load records that already have biblionumber set into a koha system
# Written by TG on 10/04/2006
use strict;
#use warnings; FIXME - Bug 2505
BEGIN {
    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    eval { require "$FindBin::Bin/kohalib.pl" };
}

# Koha modules used

use C4::Context;
use C4::Biblio;
use MARC::Record;
use MARC::File::USMARC;
use MARC::File::XML;
use MARC::Batch;
use Time::HiRes qw(gettimeofday);
use Getopt::Long;
use IO::File;

my  $input_marc_file = '';
my ($version);
GetOptions(
    'file:s'    => \$input_marc_file,
    'h' => \$version,
);

if ($version || ($input_marc_file eq '')) {
	print <<EOF
If your ISO2709 file already has biblionumbers, you can use this script
to import the MARC into your database.
parameters :
\th : this version/help screen
\tfile /path/to/file/to/dump : the file to dump
SAMPLE : 
\t\$ export KOHA_CONF=/etc/koha.conf
\t\$ perl misc/marcimport_to_biblioitems.pl  -file /home/jmf/koha.mrc 
EOF
;#'
	die;
}
my $starttime = gettimeofday;
my $timeneeded;
my $dbh = C4::Context->dbh;

my $sth2=$dbh->prepare("update biblioitems  set marc=? where biblionumber=?");
my $fh = IO::File->new($input_marc_file); # don't let MARC::Batch open the file, as it applies the ':utf8' IO layer
my $batch = MARC::Batch->new( 'USMARC', $fh );
$batch->warnings_off();
$batch->strict_off();
my ($tagfield,$biblionumtagsubfield) = &GetMarcFromKohaField("biblio.biblionumber","");

my $i=0;
while ( my $record = $batch->next() ) {
	my $biblionumber = ($tagfield < 10) ? $record->field($tagfield)->data : $record->subfield($tagfield, $biblionumtagsubfield);
	$i++;
	$sth2->execute($record->as_usmarc,$biblionumber) if $biblionumber;
	print "$biblionumber \n";
}

$timeneeded = gettimeofday - $starttime ;
print "$i records in $timeneeded s\n" ;

END;
# IS THIS SUPPOSED TO BE __END__ ??  If not, then what is it?  --JBA

sub search {
	my ($query)=@_;
	my $nquery="\ \@attr 1=1007  ".$query;
	my $oAuth=C4::Context->Zconn("biblioserver");
	if ($oAuth eq "error"){
		warn "Error/CONNECTING \n";
		return("error",undef);
	}
	my $oAResult;
	my $Anewq= new ZOOM::Query::PQF($nquery);
	eval {
	$oAResult= $oAuth->search_pqf($nquery) ; 
	};
	if($@){
		warn " /Cannot search:", $@->code()," /MSG:",$@->message(),"\n";
		return("error",undef);
	}
	my $authrecord;
	my $nbresults="0";
	$nbresults=$oAResult->size();
	if ($nbresults eq "1" ){
		my $rec=$oAResult->record(0);
		my $marcdata=$rec->raw();
		$authrecord = MARC::File::USMARC::decode($marcdata);
	}
	return ($authrecord,$nbresults);
}
