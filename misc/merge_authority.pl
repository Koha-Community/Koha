#!/usr/bin/perl


use strict;

# Koha modules used
use C4::Context;
use C4::Biblio;
use C4::AuthoritiesMarc; ###merge routine moved to there
use Time::HiRes qw(gettimeofday);

use Getopt::Long;
my ($version, $verbose, $mergefrom,$mergeto,$noconfirm,$batch);
GetOptions(
    'h' => \$version,
    'f:s' => \$mergefrom,
    't:s' => \$mergeto,
    'v' => \$verbose,
	'n' => \$noconfirm,
	'b' => \$batch,
);

if ($version || ($mergefrom eq '' && !$batch)) {
	print <<EOF
Script to merge an authority into another
parameters :
\th : this version/help screen
\tv : verbose mode (show many things on screen)
\tf : the authority number to merge (the one that can be deleted after the merge).
\tt : the authority number where to merge
\tb : batch merging.
\tn : don't ask for confirmation (useful for batch mergings, should not be used on command line)

All biblios with the authority in -t will be modified to be "connected" to authority -f
SAMPLE :
./merge_authority.pl -f 2457 -t 531

Before doing anything, the script will show both authorities and ask for confirmation. Of course, you can merge only 2 authorities of the same kind.

BATCH MODE :
The batch mode is done to report modifs. On every authority modif, a file is generated in KOHAROOT/localfile/modified_authorities/ If this script is called with -b, it parses the directory, finding & updating biblios using the modified authority.

./merge_authority.pl -b

(don't forget to export PERL5LIB and KOHA_CONF. Here is my cron job :
SHELL=/bin/bash
*/5 * * * *       export PERL5LIB=/home/httpd/koha;export KOHA_CONF=/etc/mykoha.conf;/home/httpd/koha/scripts/misc/merge_authority.pl -b -n

EOF
;#
exit;
}#

my $dbh = C4::Context->dbh;
# my @subf = $subfields =~ /(##\d\d\d##.)/g;

$|=1; # flushes output
my $starttime = gettimeofday;
if ($batch) {
	my @authlist;
	my $cgidir = C4::Context->intranetdir ."/cgi-bin";
	unless (opendir(DIR, "$cgidir/localfile/modified_authorities")) {
		$cgidir = C4::Context->intranetdir;
		opendir(DIR, "$cgidir/localfile/modified_authorities") || die "can't opendir $cgidir/localfile/modified_authorities: $!";
	} 
	while (my $authid = readdir(DIR)) {
		if ($authid =~ /\.authid$/) {
			$authid =~ s/\.authid$//;
			print "managing $authid\n" if $verbose;
			my $MARCauth = XMLgetauthorityhash($dbh,$authid);
			&merge($dbh,$authid,$MARCauth,$authid,$MARCauth) if ($MARCauth);
			unlink $cgidir.'/localfile/modified_authorities/'.$authid.'.authid';
		}
	}
	closedir DIR;
} else {
	my $MARCfrom = XMLgetauthorityhash($dbh,$mergefrom);
	my $MARCto = XMLgetauthorityhash($dbh,$mergeto);
	&merge($dbh,$mergefrom,$MARCfrom,$mergeto,$MARCto);
}
my $timeneeded = gettimeofday - $starttime;
print "Done in $timeneeded seconds" unless $noconfirm;

