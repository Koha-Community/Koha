#!/usr/bin/perl

use strict;

use locale;
use POSIX;
use Locale::gettext;

my $tofile;
if (exists $ENV{"HTTP_ACCEPT"}) {
  $tofile=0;
} else {
  $tofile=1;
}


print "Content-Type: text/html\n\n" unless($tofile);

my $path=$ENV{"PATH_TRANSLATED"};

textdomain("koha");

my %lang=(
  fr => "fr_FR",
  pl => "pl_PL",
);

my @lang=split/,/,$ENV{"HTTP_ACCEPT_LANGUAGE"};
my $lang="us_US";

foreach (@lang){
  my $lg=$lang{$_};
  setlocale(LC_MESSAGES,$lg);
  my $tmp = gettext($_);
  if ($tmp ne $_)
  {
    $lang=$tmp;
    last;
  }
}

setlocale(LC_MESSAGES,$lang);

my @katalog;
my $plik;

if ($tofile){

  @katalog=`ls -R`;

  $plik=$ARGV[0];
  if ($plik eq ''){ 
    $plik="koha.gettext.c"; 
  }

} else {
  @katalog=("cos");
}

my $kat;
my (%dgettxt, %dane, %dane2, @dane2);
my $i;

$dgettxt{'iso-8859-1'}=1;
my $txt =<<TXT;
<HTML>
<META http-equiv=Content-Type content="text/thml; 
    charset=${\(gettext('iso-8859-1'))}">
TXT

foreach(@katalog){

  if (/:$/){
    $kat="$`/";
    next;
  }

  if ($tofile){
    unless ($_=~/(\.html|\.inc)$/i) {
      next;
    }
  }

  print "$kat$_" if ($tofile);

  my $dane;
  {
    local $/;
    if ($tofile){
      open PL, "$kat$_";
    } else {
      open PL, "$path";
    }
    $dane=<PL>;
    close PL;
  }


  $dane=~s/<html>/$txt/i;
  
  $dane=~s/%/&zamien/ges;		# change %	(specjal symbol)
  $dane=~s/\\\'/&zamien/ges;		# change \'
  $dane=~s/\\\"/&zamien/ges;		# change \"
  
  # taka out graphics
  $dane=~s/[\"\']\/?([\w-\/\.]*?\.gif)[\"\']/&zamien($1)/ges;
  
#  $dane=~s/messenger\s*\((.*?)\)\s*[\}\{;]/&zamien($1)/ges;
#  $dane=~s/\.write(ln)?\s*\((.*?)\)\s*[\};]/&zamien($2)/ges;

  # take out string in field alt
  $dane=~s/alt\s*=\s*[\"]([^\"]*)[\"]/&zamien($1)/iges;
  $dane=~s/alt\s*=\s*[\']([^\']*)[\']/&zamien($1)/iges;
  
  $dane=~s/<!--.*?-->/&zamien/ges;
  $dane=~s/<script.*?<\/script>/&zamien/iges;

  $dane=~s/<[\w\/]\w*\s*((\w*\s*=\s*(\'[^\']*\'|\"[^\"]*\"|[\w-\/?&,\.=%#]*)|[%\d*%]|\w)\s*)*>/&zamien/ges;
  $dane=~s/<!\[.*?\]>/&zamien/ges;
  $dane=~s/<![^>]*>/&zamien/ges;
  $dane=~s/<#.*?#>/&zamien/ges;

  my $dane2=$dane;
  $dane2=~s/(\s*%\d+%\s*)+/%/gs;
  $dane2=~s/^%//g;
  $dane2=~s/%$//g;
  foreach my $tmp(split/%/,$dane2){
    my $tmp_ok = $tmp;
    $tmp_ok=~s/\s+/ /gs;
    next unless ($tmp_ok=~/\w+/);
    $dgettxt{$tmp_ok}++ unless $dgettxt{$tmp_ok};
    $tmp=~s/([\)\(])/\\$1/g;
    $dane=~s/$tmp/gettext($tmp_ok)/es;
  }
  unless ($tofile){
    while($dane=~/%\d+%/){
      $dane=~s/%(\d+)%/$dane2{$1}/g;
    }
    print $dane;
  }
}

if ($tofile) {

  open PK, ">$plik";
  foreach my $tmp(sort keys %dgettxt){
     $tmp=~s/\"/\\\"/gs;
     print PK "gettext(\"$tmp\");\n";
  }
  close PK;
}

exit;

###########################################################

sub zamien {
    my $tmp = $&;
    unless ($dgettxt{$_[0]}) {
    	$dgettxt{$_[0]}++;
    }
    $tmp=~s/$_[0]/gettext($&)/es;
    unless ($dane{$tmp}) {
        push @dane2, $tmp;
	$dane2{$i}=$tmp;
    	$dane{$tmp}=$i++;
    }
    return "%${\($dane{$tmp})}%";
}

