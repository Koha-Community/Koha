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
require Exporter;
use C4::Context;
use C4::Output;  # contains gettemplate
use C4::Search;
use C4::Auth;
use C4::Interface::CGI::Output;
use CGI;
use C4::Biblio;
use C4::Output;
use HTML::Template;

my $input       = new CGI;
my $bibnum      = checkinp($input->param('biblionumber'));
my $biblio = {
	biblionumber => $bibnum,
	title        => $input->param('title')?$input->param('title'):"",
	author       => $input->param('author')?$input->param('author'):"",
	abstract     => $input->param('abstract')?$input->param('abstract'):"",
	copyrightdate    => $input->param('copyrightdate')?$input->param('copyrightdate'):"",
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

&modsubtitle($bibnum, $subtitle);
&modaddauthor($bibnum, $addauthor);

$subject = uc($subject);
@sub     = split(/\|/, $subject);
$count   = @sub;

for (my $i = 0; $i < $count; $i++) {
	$sub[$i] =~ s/ +$//;
} # for

$error = &modsubject($bibnum,$force,@sub);

&modbiblio($biblio);

if ($error ne ''){
		my ($template, $loggedinuser, $cookie) = get_template_and_user({
			template_name   => "updatebiblio.tmpl",
			query           => $input,
			type            => "intranet",
			flagsrequired   => {catalogue => 1},
		});


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
	$template->param(substring =>$subs[0],
						error =>$error,
						dataloop => \@dataloop);
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
