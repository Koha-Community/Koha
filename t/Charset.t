use strict;
use C4::Charset;

use vars qw( @tests );
use vars qw( $loaded );

BEGIN {
   @tests = (
   [
      'Normal HTML without meta tag',
      sub { C4::Charset::guesscharset($_[0]) },
      undef,
      <<EOF
<title>control case</title>
EOF
   ], [
      'Result of guesscharset with normal HTML with irrelevant meta tag',
      sub { C4::Charset::guesscharset($_[0]) },
      undef,
      <<EOF
<meta http-equiv="Content-Language" content="zh-TW">
EOF
   ], [
      'Result of guesscharset with normal HTML with irrelevant meta tag',
      sub { C4::Charset::guesstype($_[0]) },
      undef,
      <<EOF
<meta http-equiv="Content-Language" content="zh-TW">
EOF
   ], [
      'Result of guesscharset with normal HTML with relevant meta tag',
      sub { C4::Charset::guesscharset($_[0]) },
      'big5',
      <<EOF
<meta http-equiv="Content-Type" content="text/html; charset=big5">
EOF
   ], [
      'Result of guesstype with normal HTML with relevant meta tag',
      sub { C4::Charset::guesstype($_[0]) },
      'text/html; charset=big5',
      <<EOF
<meta http-equiv="Content-Type" content="text/html; charset=big5">
EOF
   ], [
      'Variant 1 using single quotes',
      sub { C4::Charset::guesstype($_[0]) },
      'text/html; charset=iso-2022-jp',
      <<EOF
<meta http-equiv="Content-Type" content='text/html; charset=iso-2022-jp'>
EOF
   ], [
      'Variant 2 using single quotes',
      sub { C4::Charset::guesstype($_[0]) },
      'text/html; charset=utf-8',
      <<EOF
<meta http-equiv='Content-Type' content="text/html; charset=utf-8">
EOF
   ], [
      'Unquoted Content-Type',
      sub { C4::Charset::guesstype($_[0]) },
      'text/html; charset=big5',
      <<EOF
<meta http-equiv=Content-Type content="text/html; charset=big5">
EOF
   ], [
      'XML syntax',
      sub { C4::Charset::guesstype($_[0]) },
      'text/html; charset=iso-8859-2',
      <<EOF
<meta http-equiv=Content-Type content="text/html; charset=iso-8859-2" />
EOF
   ], [
      'Expected attributes in reverse order',
      sub { C4::Charset::guesstype($_[0]) },
      'text/html; charset=big5',
      <<EOF
<meta content="text/html; charset=big5" http-equiv="Content-Type">
EOF
   ], [
      'Extra whitespace at end',
      sub { C4::Charset::guesstype($_[0]) },
      'text/html; charset=big5',
      <<EOF
<meta http-equiv="Content-Type" content="text/html; charset=big5"   >
EOF
   ], [
      'Multiple lines',
      sub { C4::Charset::guesstype($_[0]) },
      'text/html; charset=big5',
      <<EOF
<meta
http-equiv="Content-Type"
content="text/html; charset=big5"
>
EOF
   ], [
      'With surrounding HTML',
      sub { C4::Charset::guesstype($_[0]) },
      'text/html; charset=us-ascii',
      <<EOF
<html>
<head>
<title>Test case with surrounding HTML</title>
<meta http-equiv="Content-Type" content="text/html; charset=us-ascii">
</head>
<body>
The return value should not be contaiminated with any surround HTML
FIXME: Auth.pm returns in code that can contaminate the charset
FIXME: if we do not explicitly disallow whitespace in the charset
</body>
</html>
EOF
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
      print "ok $i ($title)\n";
   } else {
      print "not ok $i ($title: got ",
	    (defined $output? "\"$output\"": 'undef'),
	    ', expected ',
	    (defined $expected? "\"$expected\"": 'undef'),
	    ")\n";
   }
}





