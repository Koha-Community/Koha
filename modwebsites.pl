#!/usr/bin/perl

use strict;

use C4::Search;
use CGI;
use C4::Output;

my $input = new CGI;
my $biblionumber       = $input->param('biblionumber');
my ($count, @websites) = &getwebsites($biblionumber);

if ($biblionumber eq '') {
  print $input->redirect("/catalogue/");
} # if

print $input->header;
print startpage();
print startmenu();

print << "EOF";
<p />
<a href="detail.pl?type=intra&bib=$biblionumber">Return to Details Page</a>
EOF

for (my $i = 0; $i < $count; $i++) {
    print << "EOF"
<p />
<form action="updatewebsite.pl" method="post">
<input type="hidden" name="biblionumber" value="$biblionumber">
<input type="hidden" name="websitenumber" value="$websites[$i]->{'websitenumber'}">
<table>
<tr valign="top">
<td>Title</td>
<td><input type="text" name="title" value="$websites[$i]->{'title'}"></td>
</tr>
<tr valign="top">
<td>Description</td>
<td><textarea name="description" cols="40" rows="4">$websites[$i]->{'description'}</textarea></td>
</tr>
<tr valign="top">
<td>URL</td>
<td><input type="text" name="url" value="$websites[$i]->{'url'}"></td>
</tr>
</table>
<input type="submit" value="Update this Website Link">   <input type="submit" name="delete" value="Delete this Website link">
</form>
EOF
} # for

print << "EOF";
<p />
<h2><b>Add another Website Link</b></h2>
<form action="addwebsite.pl" method="post">
<input type="hidden" name="biblionumber" value="$biblionumber">
<table>
<tr valign="top">
<td>Title</td>
<td><input type="text" name="title"></td>
</tr>
<tr valign="top">
<td>Description</td>
<td><textarea name="description" cols="40" rows="4"></textarea></td>
</tr>
<tr valign="top">
<td>URL</td>
<td><input type="text" name="url"></td>
</tr>
</table>
<input type="submit" value="Add this Website Link">
</form>
EOF

print endmenu();
print endpage();
