package C4::Interface::ReserveentCDK; #asummes C4/Interface/ReserveCDK

#uses Newt
use C4::Format;
use C4::InterfaceCDK;
use strict;
use Cdk;

require Exporter;
use DBI;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  
# set the version for version checking
$VERSION = 0.01;
    
@ISA = qw(Exporter);
@EXPORT = qw(&FindBiblioScreen &SelectBiblio &MakeReserveScreen);
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

sub FindBiblioScreen {
  my ($env,$title,$numflds,$flds,$fldlns)=@_;
  my $titlepanel = titlepanel($env,"Reserves","Find a title");
  #my @coltitles=("a","b");
  my @rowtitles;
  my $nflds =@$flds; 
  my $ow = 0;
  while ($ow < $nflds) {
    @rowtitles[$ow]=@$flds[$ow];
    $ow++;
  }  
  my @coltitles = ("");
  my @coltypes  = ("UMIXED");
  my @colwidths = (40);
  my $entrymatrix = new Cdk::Matrix (
    'ColTitles'=> \@coltitles,
    'RowTitles'=> \@rowtitles,
    'ColWidths'=> \@colwidths,
    'ColTypes'=>  \@coltypes,
    'Vrows'=>     7,
    'Vcols'=>     1,
    'RowSpace'=>  0);
  #$entrymatrix->set('BoxCell'=>"FALSE");
  #$entrymatrix->draw();
  $entrymatrix->inject('Input'=>"KEY_DOWN");
  my $reason;
  my ($rows,$cols,$info) = $entrymatrix->activate();
  my @responses;
  if (!defined $rows) {
     $reason = "Circ";
  } else {
     my $i = 0;
     while ($i < $numflds) {
        $responses[$i] =$info->[$i][0];
	$i++;
     }     
  } 
  return($reason,@responses);
}

sub SelectBiblio {
  my ($env,$count,$entries) = @_;
  my $titlepanel = titlepanel($env,"Reserves","Select title");  
  my $biblist = new Cdk::Alphalist('Title'=>"Select a Title",
     'List'=>\@$entries,'Height' => 22,'Width' => 76,
     'Ypos'=>1);
  my $selection = $biblist->activate();
  my $reason;
  my $result;
  if (!defined $selection) { 
     $reason="Circ";
  } else {
     $result=$selection;
  }
  return($reason,$result);
}

sub MakeReserveScreen {
  my ($env,$bibliorec,$bitems,$branches) = @_;
  my $titlepanel = titlepanel($env,"Reserves","Create Reservation");
  my $line = fmtstr($env,$bibliorec->{'title'},"L72");
  my $authlen = length($bibliorec->{'author'});
  my $testlen = length($bibliorec->{'title'}) + $authlen;
  if ($testlen < 72) {
     $line = substr($line,0,71-$authlen)." ".$bibliorec->{'author'};
     $line = fmtstr($env,$line,"L72");
  } else {
     my $split = int(($testlen-72)*0.7);
     $line = substr($line,0,72+$split-$authlen)." ".$bibliorec->{'author'};
     $line = fmtstr($env,$line,"L72");   
  } 
  my @book = ($line);
  my $bookpanel = new Cdk::Label ('Message' =>\@book,
      'Ypos'=>"2");
  $bookpanel->draw();
  my $branchlist =  new Cdk::Radio('Title'=>"Collection Branch",
     'List'=>\@$branches,
     'Xpos'=>"20",'Ypos'=>"5",'Width'=>"18",'Height'=>"6");
  $branchlist->draw();	    
  my $i = 0;
  my $brcnt = @$branches;
  my $brdef = 0;
  while (($brdef == 0) && ($i < $brcnt)) {
    my $brcode = substr(@$branches[$i],0,2);
    my $brtest = fmtstr($env,$env->{'branchcode'},"L2");
    if ($brcode eq $brtest) {
      $brdef = 1
    } else {  
      $branchlist->inject('Input'=>"KEY_DOWN");
      $i++;
    }  
  }  
  $branchlist->inject('Input'=>" ");
  my @constraintlist = ("Any item","Only Selected","Except Selected");
  my $constrainttype = new Cdk::Radio('Title'=>"Reserve Constraints",
     'List'=>\@constraintlist,
     'Xpos'=>"54",'Ypos'=>"5",'Width'=>"17",'Height'=>"6");
  $constrainttype->draw();
  my $numbit   = @$bitems;
  my @itemarr;
  my $i;
  while ($i < $numbit) {
     my $bitline = @$bitems[$i];
     my @blarr = split("\t",$bitline);
     my $line = @blarr[1]." ".@blarr[2];
     if (@blarr[3] > 0) {
       my $line = $line.@blarr[3];
     }
     my $line = $line.@blarr[4]." ".@blarr[5];
     $line = fmtstr($env,$line,"L40");
     #$bitx{$line} = @blarr[0];
     $itemarr[$i]=$line;
     $i++;
  }
  my @sel = ("Y ","N ");
  my $itemlist = new Cdk::Selection('Title'=>"Items Held",
     'List'=>\@itemarr,'Choices'=>\@sel,
     'Xpos'=>"1",'Ypos'=>"12",'Width'=>"70",'Height'=>"8");
  $itemlist->draw();
  my $borrowerentry = new Cdk::Entry('Label'=>"",'Title'=>"Borrower",
     'Max'=>"11",'Width'=>"11",
     'Xpos'=>"2",'Ypos'=>"5",
     'Type'=>"UMIXED");
  borrbind($env,$borrowerentry);
  # $borrowentry->bind('Key'=>"KEY_TAB",'Function'=>sub {$x = act($scroll1);});  
  my $complete = 0;
  my $reason = "";
  my @answers;
  while ($complete == 0) {
    my $borrowercode = $borrowerentry->activate();  
    if (!defined $borrowercode) {
      $reason="Circ";
      $complete = 1;
      @answers[0] = ""
    } else { 
      @answers[0] = $borrowercode;
      if ($borrowercode ne "") { $complete = 1; };
      while ($complete == 1) {
        my $x = $branchlist->activate();
	if (!defined $x) {
          $complete = 0;
          @answers[1] = "";
        } else {
          my @brline = split(" ",@$branches[$x]);
          @answers[1] = @brline[0]; 
          $complete = 2;
	  $answers[2] = "a";
	  $answers[3] = "";
	  while ($complete == 2) {
	    if ($numbit > 1) {
	      my @constarr = ("a", "o", "e");
              my $constans = $constrainttype->activate();
	      if (!defined $constans) {
  	        $complete = 1;  # go back a step
              } else {
	        @answers[2] = $constarr[$constans];
		$complete = 3;
		if ($answers[2] ne "a") {
		  while ($complete == 3) {		   
		    my @itemans = $itemlist->activate();
		    if (!defined @itemans) {
		      $complete = 2; # go back a step
		    } else {
		      $complete = 4;
		      my $no_ans = @itemans;
  		      my @items;
                      my $cnt = @itemans;
                      my $i = 0;
		      my $j = 0;
                      while ($i < $cnt) {
		        if ($itemans[$i] == 0) {
                          my $bitline = @$bitems[$i];
			  my @blarr = split("\t",$bitline);
			  @items[$j] = @blarr[0];
                          $j++;
	             	}  
                        $i++;
                      }
                      @answers[3] = \@items;
	            }
		  }
		}
	      }	  
            } else {
	      $complete = 3;
	    }  
	  }
	}
      }	 
    }
  }  
  return ($reason,@answers);
}
END { }       # module clean-up code here (global destructor)
