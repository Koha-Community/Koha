#!/usr/bin/perl

# Copyright 2003-2004 Nathan Walp <faceprint@faceprint.com>
# Adapted for Koha by Ambrose Li <acli@ada.dhs.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 50 Temple Place, Suite 330, Boston, MA 02111-1307  USA
#


my $PACKAGE="koha";


use Locale::Language;

$lang{en_AU} = "English (Australian)";
$lang{en_CA} = "English (Canadian)";
$lang{en_GB} = "English (British)";
$lang{es_AR} = "Spanish (Argentinian)";
$lang{fr_FR} = "French"; # FIXME: should be just "fr"
$lang{it_IT} = "Italian"; # FIXME: should be just "it"
$lang{my_MM} = "Burmese (Myanmar)";
$lang{pl_PL} = "Polish"; # FIXME: should be just "pl"
$lang{pt_BR} = "Portuguese (Brazilian)";
$lang{'sr@Latn'} = "Serbian (Latin)";
$lang{zh_CN} = "Chinese (Simplified)";
$lang{zh_TW} = "Chinese (Traditional)";

$ENV{LANG} = $ENV{LC_ALL} = 'C';

opendir(DIR, ".") || die "can't open directory: $!";
@pos = grep { /\.po$/ && -f } readdir(DIR);
foreach (@pos) { s/\.po$//; };
closedir DIR;

@pos = sort @pos;

$now = `date`;

system("./update.pl --pot > /dev/null");

print "<html>\n";
print "<head><title>$PACKAGE i18n statistics</title></head>\n";
print "<body>\n";

opendir(DIR, ".") || die "can't open directory: $!";
@templates = grep { /\.pot$/ && -f } readdir(DIR);
foreach (@templates) { s/\.pot$//; };
closedir DIR;
for my $PACKAGE (sort {
	    my($theme1, $module1) = ($1, $2) if $a =~ /^(.*)_([^_]+)$/;
	    my($theme2, $module2) = ($1, $2) if $b =~ /^(.*)_([^_]+)$/;
	    return $module1 cmp $module2 || $theme1 cmp $theme2
	} @templates) {
    my @pos_orig = @pos;
    my @pos = grep { /^${PACKAGE}_/ } @pos_orig;
    my($theme, $module) = ($1, $2) if $PACKAGE =~ /^(.*)_([^_]+)$/;

$_ = `msgfmt --statistics $PACKAGE.pot -o /dev/null 2>&1`;

die "unable to get total: $!" unless (/(\d+) untranslated messages/);

$total = $1;

print "<h1>Module $module, theme $theme</h1>\n";
print "<table cellspacing='0' cellpadding='0' border='0' bgcolor='#888888' width='100%'><tr><td><table cellspacing='1' cellpadding='2' border='0' width='100%'>\n";

print"<tr bgcolor='#e0e0e0'><th>language</th><th style='background: #339933;'>trans</th><th style='background: #339933;'>%</th><th style='background: #333399;'>fuzzy</th><th style='background: #333399;'>%</th><th style='background: #dd3333;'>untrans</th><th style='background: #dd3333;'>%</th><th>&nbsp;</th></tr>\n";

foreach $index (0 .. $#pos) {
	$trans = $fuzz = $untrans = 0;
	$po = $pos[$index];
	next if $po =~ /_en_EN/; # Koha-specific
	print STDERR "$po..." if($ARGV[0] eq '-v');
	system("msgmerge $po.po $PACKAGE.pot -o $po.new 2>/dev/null");
	$_ = `msgfmt --statistics $po.new -o /dev/null 2>&1`;
	chomp;
	if(/(\d+) translated message/) { $trans = $1; }
	if(/(\d+) fuzzy translation/) { $fuzz = $1; }
	if(/(\d+) untranslated message/) { $untrans = $1; }
	$transp = 100 * $trans / $total;
	$fuzzp = 100 * $fuzz / $total;
	$untransp = 100 * $untrans / $total;
	if($index % 2) {
		$color = " bgcolor='#e0e0e0'";
	} else {
		$color = " bgcolor='#d0e0ff'";
	}
	my $lang = $1 if $po =~ /^${PACKAGE}_(.*)$/; # Koha-specific
	$name = "";
	$name = $lang{$lang}; # NOTE
	$name = code2language($lang) unless $name ne ""; # NOTE
	$name = "???" unless $name ne "";
	printf "<tr$color><td>%s(%s.po)</td><td>%d</td><td>%0.2f</td><td>%d</td><td>%0.2f</td><td>%d</td><td>%0.2f</td><td>",
	$name, $po, $trans, $transp, $fuzz, $fuzzp, $untrans, $untransp;
	printf "<img src='bar_g.gif' height='15' width='%0.0f' />", $transp*2
	unless $transp*2 < 0.5;
	printf "<img src='bar_b.gif' height='15' width='%0.0f' />", $fuzzp*2
	unless $fuzzp*2 < 0.5;
	printf "<img src='bar_r.gif' height='15' width='%0.0f' />", $untransp*2
	unless $untransp*2 < 0.5;
	print "</tr>\n";
	unlink("$po.new");
	print STDERR "done ($untrans untranslated strings).\n" if($ARGV[0] eq '-v');
}
print "</table></td></tr></table>\n";
print "Latest $PACKAGE.pot generated $now: <a href='$PACKAGE.pot'>$PACKAGE.pot</a><br />\n";
}
print "</body>\n";
print "</html>\n";

