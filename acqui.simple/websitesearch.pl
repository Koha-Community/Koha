#!/usr/bin/perl

use CGI;
use strict;
use C4::Acquisitions;
use C4::Output;

my $input    = new CGI;
my $keywords = $input->param('keyword');
my $offset   = $input->param('offset');
my $num      = $input->param('num');
my $total;
my $count;
my @results;

if (! $keywords) {
    print $input->redirect('addbooks.pl');
} else {
    if (! $offset) { $offset = 0 };
    if (! $num) { $num = 10 };

    ($count, @results) = &websitesearch($keywords);

    if ($count < ($offset + $num)) {
        $total = $count;
    } else {
	$total = $offset + $num;
    } # else

    print $input->header;
    print startpage();
    print startmenu('acquisitions');

    print << "EOF";
<font size="6"><em>Website Search Results</em></font><br />
<CENTER>
You searched on <b>keywords $keywords,</b> $count results found <br />
Results $offset to $total displayed
<div align="right">
<h2><a href="addbiblio.pl">Add New Biblio</a></h2>
</div>
<p />
<table border="0" cellspacing="0" cellpadding="5">
<tr valign=top bgcolor=#cccc99>
<td background="/images/background-mem.gif"><b>TITLE</b></td>
<td background="/images/background-mem.gif"><b>AUTHOR</b></td>
<td background="/images/background-mem.gif"><b>&copy;</b></td>
</tr>
EOF

    for (my $i = $offset; $i < $total; $i++) {
	if ($i % 2) {
	    print << "EOF";
<tr valign="top" bgcolor="#ffffcc">
EOF
	} else {
	    print << "EOF";
<tr valign="top" bgcolor="#ffffff">
EOF
	} # else

	print << "EOF";
<td><a href="addbiblioitem.pl?biblionumber=$results[$i]->{'biblionumber'}">$results[$i]->{'title'}</a></td>
<td><a href="addbiblioitem.pl?biblionumber=$results[$i]->{'biblionumber'}">$results[$i]->{'author'}</a></td>
<td>$results[$i]->{'copyrightdate'}</td>
</tr>
EOF
    } # for
    print << "EOF";
<tr valign=top bgcolor=#cccc99>
<td background="/images/background-mem.gif">&nbsp;</td>
<td background="/images/background-mem.gif">&nbsp;</td>
<td background="/images/background-mem.gif">&nbsp;</td>
</tr>
</table>
<br />
EOF

    for (my $i = 0; ($i * $num) < $count; $i++) {
	my $newoffset = $i * $num;
	print << "EOF";
<a href="keywordsearch.pl?keyword=$keywords&offset=$newoffset&num=$num">$i</a>
EOF
    } # for

    print << "EOF";
<p />
Results per page:
<a href="keywordsearch.pl?keyword=$keywords&offset=$offset&num=5">5</a>
<a href="keywordsearch.pl?keyword=$keywords&offset=$offset&num=10">10</a>
<a href="keywordsearch.pl?keyword=$keywords&offset=$offset&num=20">20</a>
<a href="keywordsearch.pl?keyword=$keywords&offset=$offset&num=50">50</a>
</CENTER>
<br clear="all" />
<p>&nbsp;</p>
EOF

    print endmenu();
    print endpage();
} # else
