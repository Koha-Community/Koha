package C4::Interface::AccountsCDK; #asummes C4/Interface/AccountsCDK

#uses Newt
use C4::Format;
use C4::InterfaceCDK;
use C4::Accounts2;
use strict;

require Exporter;
use DBI;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  
# set the version for version checking
$VERSION = 0.01;
    
@ISA = qw(Exporter);
@EXPORT = qw(&accountsdialog);
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


  
sub accountsdialog {
  my ($env,$title,$borrower,$accountlines,$amountowing)=@_;
  my $titlepanel = titlepanel($env,$env->{'sysarea'},"Money Owing");
  my @borinfo;
  my $reason;
  #$borinfo[0]  = "$borrower->{'cardnumber'}";
  #$borinfo[1] = "$borrower->{'surname'}, $borrower->{'title'} $borrower->{'firstname'} ";
  #$borinfo[2] = "$borrower->{'streetaddress'}, $borrower->{'city'}";
  #$borinfo[3] = "<R>Total Due:  </B>".fmtdec($env,$amountowing,"52");
  #my $borpanel = 
  #  new Cdk::Label ('Message' =>\@borinfo, 'Ypos'=>4, 'Xpos'=>"RIGHT");
  my $borpanel = borrowerbox($env,$borrower,$amountowing);
  $borpanel->draw();
  my @sel = ("N ","Y ");
  my $acctlist = new Cdk::Selection ('Title'=>"Outstanding Items",
      'List'=>\@$accountlines,'Choices'=>\@sel,'Height'=>12,'Width'=>80,
      'Xpos'=>1,'Ypos'=>10);
  my @amounts=$acctlist->activate();
  my $accountno;
  my $amount2;
  my $count=@amounts;
  my $amount;
  my $check=0;
  for (my $i=0;$i<$count;$i++){
    if ($amounts[$i] == 1){
      $check=1;
      if ($accountlines->[$i]=~ /(^[0-9]+)/){
        $accountno=$1;
      }
      if ($accountlines->[$i]=~/([0-9]+\.[0-9]+)/){
        $amount2=$1;
      }
      my $borrowerno=$borrower->{'borrowernumber'};
      makepayment($borrowerno,$accountno,$amount2);
      $amount+=$amount2;
    }
    
  }
  my $amountentry = new Cdk::Entry('Label'=>"Amount:  ",
     'Max'=>"10",'Width'=>"10",
     'Xpos'=>"1",'Ypos'=>"3",
     'Type'=>"INT");
  $amountentry->preProcess ('Function' => sub{preamt(@_,$env,$acctlist);});
  #
  
  if ($amount eq ''){
    $amount =$amountentry->activate();                                                                
  } else {
    $amountentry->set('Value'=>$amount);
    $amount=$amountentry->activate();
  }
#  debug_msg($env,"accounts $amount barcode=$accountno");
  if (!defined $amount) {
     #debug_msg($env,"escaped");
     #$reason="Finished user";
  }
  $borpanel->erase();
  $acctlist->erase();
  $amountentry->erase();
  undef $acctlist;
  undef $borpanel;
  undef $borpanel;
  undef $titlepanel;
  if ($check == 1){
    $amount=0;
  }
  return($amount,$reason);
}

sub preamt {
  my ($input,$env,$acctlist)= @_;
  my $key_tab  = chr(9);
  if ($input eq $key_tab) {
    actlist ($env,$acctlist);
    return 0;
  }
  return 1;
}

sub actlist {
  my ($env,$acctlist) = @_;
  $acctlist->activate();
}


END { }       # module clean-up code here (global destructor)
