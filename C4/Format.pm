package C4::Format; #assummes C4/Format

use strict;
require Exporter;


use vars qw($VERSION @ISA @EXPORT);
  
# set the version for version checking
$VERSION = 0.01;
    
@ISA = qw(Exporter);
@EXPORT = qw(&fmtstr &fmtdec);

sub fmtstr {
  # format (space pad) a string
  # $fmt is Ln.. or Rn.. where n is the length
  my ($env,$strg,$fmt)=@_;
  my $align = substr($fmt,0,1);
  my $lenst = substr($fmt,1,length($fmt)-1);
  if ($align eq"R" ) {
     $strg = substr((" "x$lenst).$strg,0-$lenst,$lenst);
  } elsif  ($align eq "C" ) {
     $strg = 
       substr((" "x(($lenst/2)-(length($strg)/2))).$strg.(" "x$lenst),0,$lenst);
  } else {
     $strg = substr($strg.(" "x$lenst),0,$lenst);
  } 
  return ($strg);
}

sub fmtdec {
  # format a decimal
  # $fmt is [$][,]n[m]
  my ($env,$numb,$fmt)=@_;
  my $curr = substr($fmt,0,1);
  if ($curr eq "\$") {
    $fmt = substr($fmt,1,length($fmt)-1);
  };
  my $comma = substr($fmt,0,1);
  if ($comma eq ",") {
    $fmt = substr($fmt,1,length($fmt)-1);
  };
  my $right;
  my $left = substr($fmt,0,1);
  if (length($fmt) == 1) {
    $right = 0;
  } else {
    $right = substr($fmt,1,1);
  }
  my $fnumb = "";
  my $tempint = "";
  my $tempdec = "";
  if (index($numb,".") == 0 ){
     $tempint = 0;
     $tempdec = substr($numb,1,length($numb)-1); 
  } else {
     if (index($numb,".") > 0) {
       my $decpl = index($numb,".");
       $tempint = substr($numb,0,$decpl);
       $tempdec = substr($numb,$decpl+1,length($numb)-1-$decpl);
     } else {
       $tempint = $numb;
       $tempdec = 0;
     }
     if ($comma eq ",") {
        while (length($tempdec) > 3) {
           $fnumb = ",".substr($tempint,-3,3).$fnumb;
	   substr($tempint,-3,3) = "";
	}
	$fnumb = substr($tempint,-3,3).$fnumb;
     } else { 
        $fnumb = $tempint; 
     } 
  }
  if ($curr eq "\$") {
     $fnumb = fmtstr($env,$curr.$fnumb,"R".$left+1);
  } else {
     if ($left==0) {
        $fnumb = "";
     } else {
        $fnumb = fmtstr($env,$fnumb,"R".$left);
     }
  }   
  if ($right > 0) {
     $tempdec = $tempdec.("0"x$right);
     $tempdec = substr($tempdec,0,$right);
     $fnumb = $fnumb.".".$tempdec;
  }
  return ($fnumb);
}

END { }       # module clean-up code here (global destructor)
