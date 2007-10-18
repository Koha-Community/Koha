#!/usr/bin/perl
#

use strict;
use C4::Boolean;

use vars qw( @tests );
use vars qw( $loaded );

sub f ($) {
   my($x) = @_;
   my $it;
   # Returns either the value returned prefixed with 'OK:',
   # or the caught exception (string expected)
   local($@);
   eval {
      $it = 'OK:' . C4::Boolean::true_p($x);
   };
   if ($@) {
      $it = $@;
      $it =~ s/ at \S+ line \d+$\.\n//s;
   }
   return $it;
}

BEGIN {
   @tests = (
   [
      'control',
      sub { C4::Boolean::INVALID_BOOLEAN_STRING_EXCEPTION },
      'The given value does not seem to be interpretable as a Boolean value',
      undef

   # False strings
   ], [
      '"0"',     \&f, 'OK:0', '0'
   ], [
      '"false"', \&f, 'OK:0', 'false'
   ], [
      '"off"',   \&f, 'OK:0', 'off'
   ], [
      '"no"',    \&f, 'OK:0', 'no'

   # True strings
   ], [
      '"1"',     \&f, 'OK:1', '1'
   ], [
      '"true"',  \&f, 'OK:1', 'true'
   ], [
      '"on"',    \&f, 'OK:1', 'on'
   ], [
      '"yes"',   \&f, 'OK:1', 'yes'
   ], [
      '"YES"',   \&f, 'OK:1', 'YES'	# verify case insensitivity

   # Illegal strings
   ], [
      'undef',   \&f, C4::Boolean::INVALID_BOOLEAN_STRING_EXCEPTION, undef
   ], [
      '"foo"',   \&f, C4::Boolean::INVALID_BOOLEAN_STRING_EXCEPTION, 'foo'
   ],
);
}

BEGIN { $| = 1; printf "1..%d\n", scalar(@tests); }
END {print "not ok 1\n" unless $loaded;}
$loaded = 1;


# Run all tests in sequence
for (my $i = 1; $i <= scalar @tests; $i += 1) {
   my $test = $tests[$i - 1];
   my($title, $f, $expected, $input) = @$test;
   die "not ok $i (malformed test case)\n"
      unless @$test == 4 && ref $f eq 'CODE';

   my $output = &$f($input);
   if (
	 (!defined $output && !defined $expected)
      || (defined $output && defined $expected && $output eq $expected)
   ) {
      print "ok $i - $title\n";
   } else {
      print "not ok $i - $title: got ",
	    (defined $output? "\"$output\"": 'undef'),
	    ', expected ',
	    (defined $expected? "\"$expected\"": 'undef'),
	    "\n";
   }
}





