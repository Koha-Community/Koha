package C4::Scan; #assumes C4/Scan.pm

use strict;
require Exporter;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

# set the version for version checking
$VERSION = 0.01;

@ISA = qw(Exporter);
@EXPORT = qw(&getbarcode);

sub Getbarcode {
}

END { }       # module clean-up code here (global destructor)
  
    
