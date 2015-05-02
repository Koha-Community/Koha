#!/usr/bin/perl

use strict;
use warnings;

$| = 1;
use Test::More tests => 29;
use Test::Warn;

BEGIN {
	use FindBin;
	use lib $FindBin::Bin;
	use_ok('C4::Scrubber');
}

sub pretty_line {
	my $max = 54;
	(@_) or return "#" x $max . "\n";
	my $phrase = "  " . shift() . "  ";
	my $half = "#" x (($max - length($phrase))/2);
	return $half . $phrase . $half . "\n";
}

my ($scrubber,$html,$result,@types,$collapse);
$collapse = 1;
@types = qw(default comment tag staff);
$html = q|
<![CDATA[selfdestruct]]&#x5d;>
<?php  echo(" EVIL EVIL EVIL "); ?>    <!-- COMMENT -->
<hr> <!-- TMPL_VAR NAME="password" -->
<style type="text/css">body{display:none;}</style>
<link media="screen" type="text/css" rev="stylesheet" rel="stylesheet" href="css.css">
<I FAKE="attribute" > I am ITALICS with fake="attribute" </I><br />
<em FAKE="attribute" > I am em with fake="attribute" </em><br />
<B> I am BOLD </B><br />
<span style="background-image: url(http://hackersite.cn/porno.jpg);"> I am a span w/ style.  Bad style.</span>
<span> I am a span trying to inject a link: &lt;a href="badlink.html"&gt; link &lt;/a&gt;</span>
<br>
<A NAME="evil">
	<A HREF="javascript:alert('OMG YOO R HACKED');">I am a link firing javascript.</A>
	<br />
	<A HREF="image/bigone.jpg" ONMOUSEOVER="alert('OMG YOO R HACKED');"> 
		<IMG SRC="image/smallone.jpg" ALT="ONMOUSEOVER JAVASCRIPT">
	</A>
</A> <br> 
At the end here, I actually have some regular text.
|;

ok($scrubber = C4::Scrubber->new(), "Constructor: C4::Scrubber->new()");

isa_ok($scrubber, 'HTML::Scrubber', 'Constructor returns HTML::Scrubber object');

warning_like { $scrubber->default() } '', "\$scrubber->default ran without fault.";
warning_like { $scrubber->comment() } '', "\$scrubber->comment ran without fault.";
warning_like { $scrubber->process() } '', "\$scrubber->process ran without fault.";

ok($result = $scrubber->scrub($html), "Getting scrubbed text (type: [default])");

foreach(@types) {
	ok($scrubber = C4::Scrubber->new($_), "testing Constructor: C4::Scrubber->new($_)");

        warning_like { $scrubber->default() } '', "\$scrubber->default ran without fault.";
        warning_like { $scrubber->comment() } '', "\$scrubber->comment ran without fault.";
        warning_like { $scrubber->process() } '', "\$scrubber->process ran without fault.";

	ok($result = $scrubber->scrub($html), "Getting scrubbed text (type: $_)");
}

#Test for invalid new entry
eval{
	C4::Scrubber->new("");
	fail("test should fail on entry of ''");
};
if ($@) {
    pass("Test should have failed on entry of '' (empty string) and it did. YAY!");
}

eval{
	C4::Scrubber->new("Client");
	fail("test should fail on entry of 'Client'");
};
if ($@) {
    pass("Test should have failed on entry of 'Client' and it did. YAY!");
}
