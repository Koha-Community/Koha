package C4::Format; #asummes C4/Format

use strict;
require Exporter;


use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  
# set the version for version checking
$VERSION = 0.01;
    
@ISA = qw(Exporter);
@EXPORT = qw(&fmtstr &fmtdec);
%EXPORT_TAGS = ( );     # eg: TAG => [ qw!name1 name2! ],
		  
# your exported package globals go here,
# as well as any optionally exported functions

@EXPORT_OK   = qw($Var1 %Hashit);


# non-exported package globals go here
use vars qw(@more $stuff);
	
# initalize package globals, first exported ones

my $Var1   = '';
my %Hashit = ();
		    
# then the others (which are still accessible as $Some::Module::stuff)
my $stuff  = '';
my @more   = ();
	
# all file-scoped lexicals must be created before
# the functions below that use them.
		
# file-private lexicals go here
my $priv_var    = '';
my %secret_hash = ();
			    
# here's a file-private function as a closure,
# callable as &$priv_func;  it cannot be prototyped.
my $priv_func = sub {
  # stuff goes here.
};
						    
# make all your functions, whether exported or not;

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
