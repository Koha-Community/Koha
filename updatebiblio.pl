#!/usr/bin/perl


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
use CGI;
use C4::Acquisitions;
use C4::Output;
use HTML::Template;

# FIXME - This script uses a bunch of functions that appear in both
# C4::Acquisitions and C4::Biblio. But I gather that the latter are
# preferred. So should this script "use C4::Biblio;" ?

my $input       = new CGI;
my $bibnum      = checkinp($input->param('biblionumber'));
my $biblio = {
    biblionumber => $bibnum,
    title        => $input->param('title')?$input->param('title'):"",
    author       => $input->param('author')?$input->param('author'):"",
    abstract     => $input->param('abstract')?$input->param('abstract'):"",
    copyright    => $input->param('copyrightdate')?$input->param('copyrightdate'):"",
    seriestitle  => $input->param('seriestitle')?$input->param('seriestitle'):"",
    serial       => $input->param('serial')?$input->param('serial'):"",
    unititle     => $input->param('unititle')?$input->param('unititle'):"",
    notes        => $input->param('notes')?$input->param('notes'):"",
}; # my $biblio
my $subtitle    = checkinp($input->param('subtitle'));
my $subject     = checkinp($input->param('subject'));
my $addauthor   = checkinp($input->param('additionalauthor'));
my $force       = $input->param('Force');
my %data;
my @sub;
my @subs;
my @names;
my $count;
my $error;

&modbiblio($biblio);
&modsubtitle($bibnum, $subtitle);
&modaddauthor($bibnum, $addauthor);

$subject = uc($subject);
@sub     = split(/\|/, $subject);
$count   = @sub;

for (my $i = 0; $i < $count; $i++) {
    $sub[$i] =~ s/ +$//;
} # for

$error = &modsubject($bibnum,$force,@sub);

if ($error ne ''){
	my $template = gettemplate("updatebiblio.tmpl");

    my @subs=split('\n',$error);
    my @names=$input->param;
    my $count=@names;
	my @dataloop;
    for (my $i=0;$i<$count;$i++) {
	if ($names[$i] ne 'Force') {
		my %line;
	    $line{'value'}=$input->param("$names[$i]");
		$line{'name'}=$names[$i];
		push(@dataloop, \%line);
	} # if
    } # for
    template->param(substring =>$subs[0]);
    template->param(error =>$error);
    template->param(dataloop => \@dataloop);
	print "Content-Type: text/html\n\n", $template->output;
} else {
    print $input->redirect("detail.pl?type=intra&bib=$bibnum");
} # else

sub checkinp{
  my ($inp)=@_;
  $inp=~ s/\'/\\\'/g;
  $inp=~ s/\"/\\\"/g;
  return($inp);
}
