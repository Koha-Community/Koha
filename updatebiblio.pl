#!/usr/bin/perl

use C4::Database;
use CGI;
use strict;
use C4::Acquisitions;
use C4::Output;

my $input= new CGI;
#print $input->header;
#print $input->dump;


my $title=checkinp($input->param('Title'));
my $author=checkinp($input->param('Author'));
my $bibnum=checkinp($input->param('bibnum'));
my $copyright=checkinp($input->param('Copyright'));
my $seriestitle=checkinp($input->param('Series'));
my $serial=checkinp($input->param('Serial'));
my $unititle=checkinp($input->param('Unititle'));
my $notes=checkinp($input->param('Notes'));

modbiblio($bibnum,$title,$author,$copyright,$seriestitle,$serial,$unititle,$notes);

my $subtitle=checkinp($input->param('Subtitle'));
modsubtitle($bibnum,$subtitle);

my $subject=checkinp($input->param('Subject'));
$subject=uc $subject;
my @sub=split(/\|/,$subject);
#print @sub;
#

my $addauthor=checkinp($input->param('Additional'));
modaddauthor($bibnum,$addauthor);
my $count1=@sub;

for (my $i=0; $i<$count1; $i++){
  $sub[$i]=~ s/ +$//;
}

#print $input->header;
my $force=$input->param('Force');
my $error=modsubject($bibnum,$force,@sub);

if ($error ne ''){
  print $input->header;
  print startpage();
  print startmenu();
  print $error;
  my @subs=split('\n',$error);
  print "<p> Click submit to force the subject";
  my @names=$input->param;
  my %data;
  my $count=@names;
  for (my $i=0;$i<$count;$i++){
    if ($names[$i] ne 'Force'){
      my $value=$input->param("$names[$i]");
      $data{$names[$i]}="hidden\t$value\t$i";
    }
  }
  $data{"Force"}="hidden\t$subs[0]\t$count";
  print mkform3('updatebiblio.pl',%data);
  print endmenu();
  print endpage();
} else {
  print $input->redirect("detail.pl?type=intra&bib=$bibnum");
}

sub checkinp{
  my ($inp)=@_;
  $inp=~ s/\'/\\\'/g;
  $inp=~ s/\"/\\\"/g;
  return($inp);
}
