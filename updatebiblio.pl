#!/usr/bin/perl

use C4::Database;
use CGI;
use strict;
use C4::Acquisitions;
use C4::Output;

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
    print $input->header;
    print startpage();
    print startmenu();
    print $error;
    @subs = split('\n',$error);
    print "<p> Click submit to force the subject";
    @names = $input->param;
    $count = @names;
    for (my $i = 0; $i < $count; $i++) {
	if ($names[$i] ne 'Force') {
	    my $value = $input->param("$names[$i]");
	    $data{$names[$i]} = "hidden\t$value\t$i";
	} # if
    } # for
    $data{"Force"} = "hidden\t$subs[0]\t$count";
    print mkform3('updatebiblio.pl', %data);
    print endmenu();
    print endpage();
} else {
    print $input->redirect("detail.pl?type=intra&bib=$bibnum");
} # else

sub checkinp{
  my ($inp)=@_;
  $inp =~ s/\'/\\\'/g;
  $inp =~ s/\"/\\\"/g;
  return($inp);
}
