#!/usr/bin/perl

#script to modify/delete biblios
#written 8/11/99
# modified 11/11/99 by chris@katipo.co.nz

use strict;

use C4::Search;
use CGI;
use C4::Output;

my $input = new CGI;

my $submit = $input->param('submit.x');
my $bibnum = $input->param('bibnum');
my $data   = &bibdata($bibnum);
my ($subjectcount, $subject)     = &subject($data->{'biblionumber'});
my ($subtitlecount, $subtitle)   = &subtitle($data->{'biblionumber'});
my ($addauthorcount, $addauthor) = &addauthor($data->{'biblionumber'});
my $sub        = $subject->[0]->{'subject'};
my $additional = $addauthor->[0]->{'author'};
my %inputs;
my $dewey;

if ($submit eq '') {
  print $input->redirect("/cgi-bin/koha/delbiblio.pl?biblio=$bibnum");
} # if

print $input->header;
# my ($analytictitle)  = &analytic($biblionumber,'t');
# my ($analyticauthor) = &analytic($biblionumber,'a');
print startpage();
print startmenu();

# have to get all subtitles, subjects and additional authors
for (my $i = 1; $i < $subjectcount; $i++) {
  $sub = $sub . "|" . $subject->[$i]->{'subject'};
} # for

for (my $i = 1; $i < $addauthorcount; $i++) {
  $additional = $additional . "|" . $addauthor->[$i]->{'author'};
} # for


$dewey = $data->{'dewey'};
$dewey =~ s/0+$//;
if ($dewey eq "000.") {
    $dewey = "";
} # if
if ($dewey < 10) {
    $dewey = '00' . $dewey;
} # if
if ($dewey < 100 && $dewey > 10) {
    $dewey = '0' . $dewey;
} # if
if ($dewey <= 0){
  $dewey='';
} # if
$dewey = ~ s/\.$//;

$data->{'title'} = &tidyhtml($data->{'title'});

print << "EOF";
<a href="modwebsites.pl?biblionumber=$data->{'biblionumber'}">Modify Website Links</a>
<form action="updatebiblio.pl" method="post" name="f">
<input type="hidden" name="biblionumber" value="$data->{'biblionumber'}">
<input type="hidden" name="biblioitemnumber" value="$data=>{'biblioitemnumber'}">
<table border="0" cellspacing="0" cellpadding="5">
<tr valign="top">
<td>Author</td>
<td><input type="text" name="author" value="$data->{'author'}"></td>
</tr>
<tr valign="top">
<td>Title</td>
<td><input type="text" name="title" value="$data->{'title'}"></td>
</tr>
<tr valign="top">
<td>Abstract</td>
<td><textarea name="abstract" cols="40" rows="4">$data->{'abstract'}</textarea></td>
</tr>
<tr valign="top">
<td>Subject</td>
<td><textarea name="subject" cols="40" rows="4">$sub</textarea>
<a href="javascript:Dopop()">...</a>
</td>
</tr>
<tr valign="top">
<td>Copyright Date</td>
<td><input type="text" name="copyrightdate" value="$data->{'copyrightdate'}"></td>
</tr>
<tr valign="top">
<td>Series Title</td>
<td><input type="text" name="seriestitle" value="$data->{'seriestitle'}"></td>
</tr>
<tr valign="top">
<td>Additional Author</td>
<td><input type="text" name="additionalauthor" value="$additional"></td>
</tr>
<tr valign="top">
<td>Subtitle</td>
<td><input type="text" name="subtitle" value="$data->{'subtitle'}"></td>
</tr>
<tr valign="top">
<td>Unititle</td>
<td><input type="text" name="unititle" value="$data->{'untitle'}"></td>
</tr>
<tr valign="top">
<td>Notes</td>
<td><textarea name="notes" cols="40" rows="4">$data->{'notes'}</textarea></td>
</tr>
<tr valign="top">
<td>Serial</td>
<td><input type="text" name="serial" value="$data->{'serial'}"></td>
</tr>
<tr valign="top">
<td>Analytic Author</td>
<td><input type="text" name="analyticauthor"></td>
</tr>
<tr valign="top">
<td>Analytic Title</td>
<td><input type="text" name="analytictitle"></td>
</tr>
</table>
<br>
<input type="submit" name="submit" value="Save Changes">
</form>
<script>
function Dopop() {
        newin=window.open("thesaurus_popup.pl?subject="+document.f.subject.value,"thesaurus",'width=500,height=400,toolbar=false,scrollbars=yes');
}
</script>
EOF

print endmenu();
print endpage();

sub tidyhtml {
  my ($inp)=@_;
  $inp=~ s/\"/\&quot\;/g;
  return($inp);
}
