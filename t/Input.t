# $Id$

#use strict;

BEGIN { $| = 1; print "1..13\n"; }
END {print "not ok 1\n" unless $loaded;}
use C4::Input;
$loaded = 1;
print "ok 1\n";

my $TestCount=1;

#-----------------
# Test ISBN validation

my $isbn;

# Good numbers
foreach $isbn ('0836213092','087784805X','087784805x','1878685899') {
    PrintNextTestResult ( &checkvalidisbn($isbn), "Good ISBN: $isbn" ) 
}

# Bad numbers
foreach $isbn ('0836213192','087784804X','087784806x','1878685898', 
		'', ' ', 'abc', '1234567890123') {
    PrintNextTestResult ( ! &checkvalidisbn($isbn), "Bad ISBN: $isbn" ) 
}



#-----------------------
sub PrintNextTestResult {
    # modifies global var $TestCount
    my ($ThisTestResult, $TestComment )=@_;

    $TestCount++;

    if ( $ThisTestResult ) {
        print "ok $TestCount\n";
    } else {
	print STDERR "\nTest failed: $TestComment\n";
        print "not ok $TestCount\n";
    }

} # sub PrintNextTestResult

#-----------------------
# $Log$
# Revision 1.1.2.1  2002/06/20 15:19:34  amillar
# Test valid ISBN numbers in Input.pm
#
