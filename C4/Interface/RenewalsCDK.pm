package C4::Interface::RenewalsCDK; #asummes C4/Interface/RenewalsCDK

#uses Newt
use strict;
use Cdk;
use C4::Format;
use C4::InterfaceCDK;
use Date::Manip;
#use C4::Circulation;

require Exporter;
use DBI;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
  
# set the version for version checking
$VERSION = 0.01;
    
@ISA = qw(Exporter);
@EXPORT = qw(renew_window);
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
# the functions below that se them.
		
# file-private lexicals go here
my $priv_var    = '';
my %secret_hash = ();

#defining keystrokes used for screens

# here's a file-private function as a closure,
# callable as &$priv_func;  it cannot be prototyped.
my $priv_func = sub {
  # stuff goes here.
};
						    
# make all your functions, whether exported or not;

sub renew_window {
  my ($env,$issueditems,$borrower,$amountowing,$odues)=@_;
  my $titlepanel = C4::InterfaceCDK::titlepanel($env,$env->{'sysarea'},"Renewals");
  my @sel = ("N ","Y ");
  my $issuelist = new Cdk::Selection ('Title'=>"Renew items",
    'List'=>\@$issueditems,'Choices'=>\@sel,
    'Height'=> 14,'Width'=>78,'Ypos'=>8);
  my $x = 0;
  my $borrbox = C4::InterfaceCDK::borrowerbox($env,$borrower,$amountowing);
  $borrbox->draw();
  my @renews = $issuelist->activate();
  $issuelist->erase();
  undef $titlepanel;
  undef $issuelist;
  undef $borrbox;
  return \@renews;
}  
			       
END { }       # module clean-up code here (global destructor)


