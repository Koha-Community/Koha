package C4::Output;

# $Id$

#package to deal with marking up output
#You will need to edit parts of this pm
#set the value of path to be where your html lives


# Copyright 2000-2002 Katipo Communications
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

use strict;
require Exporter;

use HTML::Template;
use C4::Database;
use C4::Koha;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

# set the version for version checking
$VERSION = 0.01;

=head1 NAME

C4::Output - Functions for generating HTML for the Koha web interface

=head1 SYNOPSIS

  use C4::Output;

  $str = &mklink("http://www.koha.org/", "Koha web page");
  print $str;

=head1 DESCRIPTION

The functions in this module generate HTML, and return the result as a
printable string.

=head1 FUNCTIONS

=over 2

=cut

@ISA = qw(Exporter);
@EXPORT = qw(&startpage &endpage 
	     &mktablehdr &mktableft &mktablerow &mklink
	     &startmenu &endmenu &mkheadr 
	     &center &endcenter 
	     &mkform &mkform2 &bold
	     &gotopage &mkformnotable &mkform3
	     &getkeytableselectoptions
	     &picktemplate &themelanguage &gettemplate
);
%EXPORT_TAGS = ( );     # eg: TAG => [ qw!name1 name2! ],

# your exported package globals go here,
# as well as any optionally exported functions

@EXPORT_OK   = qw($Var1 %Hashit);	# FIXME - These are never used


# non-exported package globals go here
use vars qw(@more $stuff);		# FIXME - These are never used

# initalize package globals, first exported ones

# FIXME - These are never used
my $Var1   = '';
my %Hashit = ();


# then the others (which are still accessible as $Some::Module::stuff)
# FIXME - These are never used
my $stuff  = '';
my @more   = ();

# all file-scoped lexicals must be created before
# the functions below that use them.

#
# Change this value to reflect where you will store your includes
#
my $configfile=configfile();

my $path=$configfile->{'includes'};
($path) || ($path="/usr/local/www/hdl/htdocs/includes");

# make all your functions, whether exported or not;

sub gettemplate {
    my ($tmplbase, $opac) = @_;

    my $htdocs;
    if ($opac) {
	$htdocs = $configfile->{'opachtdocs'};
	($htdocs) || ($htdocs=$configfile->{opacdir}."/htdocs");
    } else {
	$htdocs = $configfile->{'intrahtdocs'};
	($htdocs) || ($htdocs=$configfile->{intranetdir}."/htdocs");
    }

    my ($theme, $lang) = themelanguage($htdocs, $tmplbase);

    my $template = HTML::Template->new(filename      => "$htdocs/$theme/$lang/$tmplbase", 
				   die_on_bad_params => 0,
				   global_vars       => 1,
				   path              => ["$htdocs/$theme/$lang/includes"]);

    $template->param(themelang => "/$theme/$lang");
    return $template;
}

=item picktemplate

  $template = &picktemplate($includes, $base);

Returns the preferred template for a given page. C<$base> is the
basename of the script that will generate the page (with the C<.pl>
extension stripped off), and C<$includes> is the directory in which
HTML include files are located.

The preferred template is given by the C<template> entry in the
C<systempreferences> table in the Koha database. If
C<$includes>F</templates/preferred-template/>C<$base.tmpl> exists,
C<&picktemplate> returns the preferred template; otherwise, it returns
the string C<default>.

=cut
#'
sub picktemplate {
  my ($includes, $base) = @_;
  my $dbh=C4Connect;
  my $templates;
  # FIXME - Instead of generating the list of possible templates, and
  # then querying the database to see if, by chance, one of them has
  # been selected, wouldn't it be better to query the database first,
  # and then see whether the selected template file exists?
  opendir (D, "$includes/templates");
  my @dirlist=readdir D;
  foreach (@dirlist) {
    (next) if (/^\./);
    #(next) unless (/\.tmpl$/);
    (next) unless (-e "$includes/templates/$_/$base");
    $templates->{$_}=1;
  }							    
  my $sth=$dbh->prepare("select value from systempreferences where
  variable='template'");
  $sth->execute;
  my ($preftemplate) = $sth->fetchrow;
  $sth->finish;
  $dbh->disconnect;
  if ($templates->{$preftemplate}) {
    return $preftemplate;
  } else {
    return 'default';
  }
}

sub themelanguage {
  my ($htdocs, $tmpl) = @_;

# language preferences....
  my $dbh=C4Connect;
  my $sth=$dbh->prepare("SELECT value FROM systempreferences WHERE variable='opaclanguages'");
  $sth->execute;
  my ($lang) = $sth->fetchrow;
  $lang.=" en";
  $sth->finish;
  my @languages = split " ", $lang;

# theme preferences....
  my $sth=$dbh->prepare("SELECT value FROM systempreferences WHERE variable='opacthemes'");
  $sth->execute;
  my ($theme) = $sth->fetchrow;
  $theme.=" default";
  $sth->finish;
  my @themes = split " ", $theme;

  $dbh->disconnect;

  my ($theme, $lang);
# searches through the themes and languages. First template it find it returns.
# Priority is for getting the theme right.
  THEME: 
  foreach my $th (@themes) {
    foreach my $la (@languages) {
	if (-e "$htdocs/$th/$la/$tmpl") {
	    $theme = $th;
	    $lang = $la;
	    last THEME;
	}
    }
  }
  if ($theme and $lang) {
    return ($theme, $lang);
  } else {
    return ('default', 'en');
  }  
}

 
sub startpage() {
  return("<html>\n");
}

sub gotopage($) {
  my ($target) = shift;
  #print "<br>goto target = $target<br>";
  my $string = "<META HTTP-EQUIV=Refresh CONTENT=\"0;URL=http:$target\">";
  return $string;
}

=item startmenu

  @lines = &startmenu($type);
  print join("", @lines);

Given a page type, or category, returns a set of lines of HTML which,
when concatenated, generate the menu at the top of the web page.

C<$type> may be one of C<issue>, C<opac>, C<member>, C<acquisitions>,
C<report>, C<circulation>, or something else, in which case the menu
will be for the catalog pages.

=cut
#'
sub startmenu($) {
  # edit the paths in here
  my ($type)=shift;
  # FIXME - It's bad form to die in a CGI script. It's even worse form
  # to die without issuing an error message.
  if ($type eq 'issue') {
    open (FILE,"$path/issues-top.inc") || die;
  } elsif ($type eq 'opac') {
    open (FILE,"$path/opac-top.inc") || die;
  } elsif ($type eq 'member') {
    open (FILE,"$path/members-top.inc") || die;
  } elsif ($type eq 'acquisitions'){
    open (FILE,"$path/acquisitions-top.inc") || die;
  } elsif ($type eq 'report'){
    open (FILE,"$path/reports-top.inc") || die;
  } elsif ($type eq 'circulation') {
    open (FILE,"$path/circulation-top.inc") || die;
  } else {
    open (FILE,"$path/cat-top.inc") || die;
  }
  my @string=<FILE>;
  close FILE;
  # my $count=@string;
  # $string[$count]="<BLOCKQUOTE>";
  return @string;
}


sub endmenu {
  my ($type) = @_;
  if ($type eq 'issue') {
    open (FILE,"$path/issues-bottom.inc") || die;
  } elsif ($type eq 'opac') {
    open (FILE,"$path/opac-bottom.inc") || die;
  } elsif ($type eq 'member') {
    open (FILE,"$path/members-bottom.inc") || die;
  } elsif ($type eq 'acquisitions') {
    open (FILE,"$path/acquisitions-bottom.inc") || die;
  } elsif ($type eq 'report') {
    open (FILE,"$path/reports-bottom.inc") || die;
  } elsif ($type eq 'circulation') {
    open (FILE,"$path/circulation-bottom.inc") || die;
  } else {
    open (FILE,"$path/cat-bottom.inc") || die;
  }
  my @string=<FILE>;
  close FILE;
  return @string;
}

=item mktablehdr

  $str = &mktablehdr();
  print $str;

Returns a string of HTML, which generates the beginning of a table
declaration.

=cut
#'
sub mktablehdr() {
    return("<table border=0 cellspacing=0 cellpadding=5>\n");
}

=item mktablerow

  $str = &mktablerow($columns, $color, @column_data, $bgimage);
  print $str;

Returns a string of HTML, which generates a row of data inside a table
(see also C<&mktablehdr>, C<&mktableft>).

C<$columns> specifies the number of columns in this row of data.

C<$color> specifies the background color for the row, e.g., C<"white">
or C<"#ffacac">.

C<@column_data> is an array of C<$columns> elements, each one a string
of HTML. These are the contents of the row.

The optional C<$bgimage> argument specifies the pathname to an image
to use as the background for each cell in the row. This pathname will
used as is in the output, so it should be relative to the HTTP
document root.

=cut
#'
sub mktablerow {
    #the last item in data may be a backgroundimage
    
    # FIXME
    # should this be a foreach (1..$cols) loop?

  my ($cols,$colour,@data)=@_;
  my $i=0;
  my $string="<tr valign=top bgcolor=$colour>";
  while ($i <$cols){
      if (defined $data[$cols]) { # if there is a background image
	  $string.="<td background=\"$data[$cols]\">";
      } else { # if there's no background image
	  $string.="<td>";
      }
      if ($data[$i] eq "") {
	  $string.=" &nbsp; </td>";
      } else {
	  $string.="$data[$i]</td>";
      } 
      $i++;
  }
  $string=$string."</tr>\n";
  return($string);
}

=item mktableft

  $str = &mktableft();
  print $str;

Returns a string of HTML, which generates the end of a table
declaration.

=cut
#'
sub mktableft() {
  return("</table>\n");
}

# XXX - POD
sub mkform{
  my ($action,%inputs)=@_;
  my $string="<form action=$action method=post>\n";
  $string=$string.mktablehdr();
  my $key;
  my @keys=sort keys %inputs;
  
  my $count=@keys;
  my $i2=0;
  while ( $i2<$count) {
    my $value=$inputs{$keys[$i2]};
    my @data=split('\t',$value);
    #my $posn = shift(@data);
    if ($data[0] eq 'hidden'){
      $string=$string."<input type=hidden name=$keys[$i2] value=\"$data[1]\">\n";
    } else {
      my $text;
      if ($data[0] eq 'radio') {
        $text="<input type=radio name=$keys[$i2] value=$data[1]>$data[1]
	<input type=radio name=$keys[$i2] value=$data[2]>$data[2]";
      } 
      if ($data[0] eq 'text') {
        $text="<input type=$data[0] name=$keys[$i2] value=\"$data[1]\">";
      }
      if ($data[0] eq 'textarea') {
        $text="<textarea name=$keys[$i2] wrap=physical cols=40 rows=4>$data[1]</textarea>";
      }
      if ($data[0] eq 'select') {
        $text="<select name=$keys[$i2]>";
	my $i=1;
       	while ($data[$i] ne "") {
	  my $val = $data[$i+1];
      	  $text = $text."<option value=$data[$i]>$val";
	  $i = $i+2;
	}
	$text=$text."</select>";
      }	
      $string=$string.mktablerow(2,'white',$keys[$i2],$text);
      #@order[$posn] =mktablerow(2,'white',$keys[$i2],$text);
    }
    $i2++;
  }
  #$string=$string.join("\n",@order);
  $string=$string.mktablerow(2,'white','<input type=submit>','<input type=reset>');
  $string=$string.mktableft;
  $string=$string."</form>";
}

=item mkform3

  $str = &mkform3($action,
	$fieldname => "$fieldtype\t$fieldvalue\t$fieldpos",
	...
	);
  print $str;

Takes a set of arguments that define an input form, generates an HTML
string for the form, and returns the string.

C<$action> is the action for the form, usually the URL of the script
that will process it.

The remaining arguments define the fields in the form. C<$fieldname>
is the field's name. This is for the script's benefit, and will not be
shown to the user.

C<$fieldpos> is an integer; fields will be output in order of
increasing C<$fieldpos>. This number must be unique: if two fields
have the same C<$fieldpos>, one will be picked at random, and the
other will be ignored. See below for special considerations, however.

C<$fieldtype> specifies the type of the input field. It may be one of
the following:

=over 4

=item C<hidden>

Generates a hidden field, used to pass data to the script without
showing it to the user. C<$fieldvalue> is the value.

=item C<radio>

Generates a pair of radio buttons, with values C<$fieldvalue> and
C<$fieldpos>. In both cases, C<$fieldvalue> and C<$fieldpos> will be
shown to the user.

=item C<text>

Generates a one-line text input field. It initially contains
C<$fieldvalue>.

=item C<textarea>

Generates a four-line text input area. The initial text (which, of
course, may not contain any tabs) is C<$fieldvalue>.

=item C<select>

Generates a list of items, from which the user may choose one. This is
somewhat different from other input field types, and should be
specified as:
  "myselectfield" => "select\t<label0>\t<text0>\t<label1>\t<text1>...",
where the C<text>N strings are the choices that will be presented to
the user, and C<label>N are the labels that will be passed to the
script.

However, C<text0> should be an integer, since it will be used to
determine the order in which this field appears in the form. If any of
the C<label>Ns are empty, the rest of the list will be ignored.

=back

=cut
#'
sub mkform3 {
  my ($action, %inputs) = @_;
  my $string = "<form action=\"$action\" method=\"post\">\n";
  $string   .= mktablehdr();
  my $key;
  my @keys = sort(keys(%inputs));	# FIXME - Why do these need to be
					# sorted?
  my @order;
  # FIXME - Use
  #	while (my ($key, $value) = each %inputs)
  # Then $count and $i2 can go away.
  my $count = @keys;
  my $i2 = 0;
  while ($i2 < $count) {
    my $value=$inputs{$keys[$i2]};
    # FIXME - Why use a tab-separated string? Why not just use an
    # anonymous array?
    my @data=split('\t',$value);
	# FIXME - $data[2] is used in two contradictory ways: first,
	# it is always used as the order in which this field should be
	# output. Secondly, for radio and select fields, it contains
	# data used to define the input field. Thus, for instance, you
	# can't have
	#	fuzzy => "radio\ttrue\tfalse",
	#	color => "radio\tblue\tred",
	# because both "false" and "red" have numeric value 0, and will
	# wind up as the first element of the output.
	# The obvious way to fix this is to change %inputs into an
	# array; then just read (name, definition) pairs, and output
	# them in the order in which they were specified.
    my $posn = $data[2];
    if ($data[0] eq 'hidden'){
      $order[$posn]="<input type=hidden name=$keys[$i2] value=\"$data[1]\">\n";
    } else {
      my $text;
      if ($data[0] eq 'radio') {
        $text="<input type=radio name=$keys[$i2] value=$data[1]>$data[1]
	<input type=radio name=$keys[$i2] value=$data[2]>$data[2]";
      }
      # FIXME - Is 40 the right size in all cases?
      if ($data[0] eq 'text') {
        $text="<input type=$data[0] name=$keys[$i2] value=\"$data[1]\" size=40>";
      }
      # FIXME - Is 40x4 the right size in all cases?
      if ($data[0] eq 'textarea') {
        $text="<textarea name=$keys[$i2] cols=40 rows=4>$data[1]</textarea>";
      }
      if ($data[0] eq 'select') {
        $text="<select name=$keys[$i2]>";
	my $i=1;
       	while ($data[$i] ne "") {
	  my $val = $data[$i+1];
      	  $text = $text."<option value=$data[$i]>$val";
	  $i = $i+2;		# FIXME - Use $i += 2.
	}
	$text=$text."</select>";
      }	
#      $string=$string.mktablerow(2,'white',$keys[$i2],$text);
      $order[$posn]=mktablerow(2,'white',$keys[$i2],$text);
    }
    $i2++;
  }
  my $temp=join("\n",@order);
  # FIXME - Use ".=". That's what it's for.
  $string=$string.$temp;
  $string=$string.mktablerow(1,'white','<input type=submit>');
  $string=$string.mktableft;
  $string=$string."</form>";
  # FIXME - A return statement, while not strictly necessary, would be nice.
}

# XXX - POD
sub mkformnotable{
  my ($action,@inputs)=@_;
  my $string="<form action=$action method=post>\n";
  foreach my $input (@inputs){
      if ($$input[0] eq 'textarea') {
	  $string .= 
	      "<textarea name=$$input[1] wrap=physical cols=40 rows=4>";
	  $string .= 
	      "$$input[2]</textarea>";
      } else {
	  $string .= 
	      "<input type=$$input[0] name=$$input[1] value=\"$$input[2]\">";
	  if ($$input[0] eq 'radio') {
	      $string .= 
	      "$$input[2]";
	  }  
      }
      $string .= "\n";
  }
  $string=$string."</form>";
}

=item mkform2

  $str = &mkform2($action,
	$fieldname => "$fieldpos\t$required\t$label\t$fieldtype\t$value0\t$value1\t...",
	...
	);
  print $str;

Takes a set of arguments that define an input form, generates an HTML
string for the form, and returns the string.

C<$action> is the action for the form, usually the URL of the script
that will process it.

The remaining arguments define the fields in the form. C<$fieldname>
is the field's name. This is for the script's benefit, and will not be
shown to the user.

C<$fieldpos> is an integer; fields will be output in order of
increasing C<$fieldpos>. This number must be unique: if two fields
have the same C<$fieldpos>, one will be picked at random, and the
other will be ignored. See below for special considerations, however.

If C<$required> is the string C<R>, then the field is required, and
the label will have C< (Req.)> appended.

C<$label> is a string that will appear next to the input field.

C<$fieldtype> specifies the type of the input field. It may be one of
the following:

=over 4

=item C<hidden>

Generates a hidden field, used to pass data to the script without
showing it to the user. C<$value0> is its value.

=item C<radio>

Generates a pair of radio buttons, with values C<$value0> and
C<$value1>. In both cases, C<$value0> and C<$value1> will be shown to
the user, next to the radio button.

=item C<text>

Generates a one-line text input field. Its size may be specified by
C<$value0>. The default is 40. The initial text of the field may be
specified by C<$value1>.

=item C<textarea>

Generates a text input area. C<$value0> may be a string of the form
"WWWxHHH", in which case the text input area will be WWW columns wide
and HHH rows tall. The size defaults to 40x4.

The initial text (which, of course, may not contain any tabs) may be
specified by C<$value1>.

=item C<select>

Generates a list of items, from which the user may choose one. Here,
C<$value1>, C<$value2>, etc. are a list of key-value pairs. In each
pair, the key specifies an internal label for a choice, and the value
specifies the description of the choice that will be shown the user.

If C<$value0> is the same as one of the keys that follows, then the
corresponding choice will initially be selected.

=back

=cut
#'
sub mkform2{
    # FIXME
    # no POD and no tests yet.  Once tests are written,
    # this function can be cleaned up with the following steps:
    #  turn the while loop into a foreach loop
    #  pull the nested if,elsif structure back up to the main level
    #  pull the code for the different kinds of inputs into separate
    #   functions
  my ($action,%inputs)=@_;
  my $string="<form action=$action method=post>\n";
  $string=$string.mktablehdr();
  my $key;
  my @order;
  while ( my ($key, $value) = each %inputs) {
    my @data=split('\t',$value);
    my $posn = shift(@data);
    my $reqd = shift(@data);
    my $ltext = shift(@data);    
    if ($data[0] eq 'hidden'){
      $string=$string."<input type=hidden name=$key value=\"$data[1]\">\n";
    } else {
      my $text;
      if ($data[0] eq 'radio') {
        $text="<input type=radio name=$key value=$data[1]>$data[1]
	<input type=radio name=$key value=$data[2]>$data[2]";
      } elsif ($data[0] eq 'text') {
        my $size = $data[1];
        if ($size eq "") {
          $size=40;
        }
        $text="<input type=$data[0] name=$key size=$size value=\"$data[2]\">";
      } elsif ($data[0] eq 'textarea') {
        my @size=split("x",$data[1]);
        if ($data[1] eq "") {
          $size[0] = 40;
          $size[1] = 4;
        }
        $text="<textarea name=$key wrap=physical cols=$size[0] rows=$size[1]>$data[2]</textarea>";
      } elsif ($data[0] eq 'select') {
        $text="<select name=$key>";
	my $sel=$data[1];
	my $i=2;
       	while ($data[$i] ne "") {
	  my $val = $data[$i+1];
       	  $text = $text."<option value=\"$data[$i]\"";
	  if ($data[$i] eq $sel) {
	     $text = $text." selected";
	  }   
          $text = $text.">$val";
	  $i = $i+2;
	}
	$text=$text."</select>";
      }
      if ($reqd eq "R") {
        $ltext = $ltext." (Req)";
	}
      $order[$posn] =mktablerow(2,'white',$ltext,$text);
    }
  }
  $string=$string.join("\n",@order);
  $string=$string.mktablerow(2,'white','<input type=submit>','<input type=reset>');
  $string=$string.mktableft;
  $string=$string."</form>";
}

=item endpage

  $str = &endpage();
  print $str;

Returns a string of HTML, the end of an HTML document.

=cut
#'
sub endpage() {
  return("</body></html>\n");
}

=item mklink

  $str = &mklink($url, $text);
  print $str;

Returns an HTML string, where C<$text> is a link to C<$url>.

=cut
#'
sub mklink($$) {
  my ($url,$text)=@_;
  my $string="<a href=\"$url\">$text</a>";
  return ($string);
}

=item mkheadr

  $str = &mkheadr($type, $text);
  print $str;

Takes a header type and header text, and returns a string of HTML,
where C<$text> is rendered with emphasis in a large font size (not an
actual HTML header).

C<$type> may be 1, 2, or 3. A type 1 "header" ends with a line break;
Type 2 has no special tag at the end; Type 3 ends with a paragraph
break.

=cut
#'
sub mkheadr {
    # FIXME
    # would it be better to make this more generic by accepting an optional
    # argument with a closing tag instead of a numeric type?

  my ($type,$text)=@_;
  my $string;
  if ($type eq '1'){
    $string="<FONT SIZE=6><em>$text</em></FONT><br>";
  }
  if ($type eq '2'){
    $string="<FONT SIZE=6><em>$text</em></FONT>";
  }
  if ($type eq '3'){
    $string="<FONT SIZE=6><em>$text</em></FONT><p>";
  }
  return ($string);
}

=item center and endcenter

  print &center(), "This is a line of centered text.", &endcenter();

C<&center> and C<&endcenter> take no arguments and return HTML tags
<CENTER> and </CENTER> respectivley.

=cut
#'
sub center() {
  return ("<CENTER>\n");
}  

sub endcenter() {
  return ("</CENTER>\n");
}  

=item bold

  $str = &bold($text);
  print $str;

Returns a string of HTML that renders C<$text> in bold.

=cut
#'
sub bold($) {
  my ($text)=shift;
  return("<b>$text</b>");
}

=item getkeytableselectoptions

  $str = &getkeytableselectoptions($dbh, $tablename,
	$keyfieldname, $descfieldname,
	$showkey, $default);
  print $str;

Builds an HTML selection box from a database table. Returns a string
of HTML that implements this.

C<$dbh> is a DBI::db database handle.

C<$tablename> is the database table in which to look up the possible
values for the selection box.

C<$keyfieldname> is field in C<$tablename>. It will be used as the
internal label for the selection.

C<$descfieldname> is a field in C<$tablename>. It will be used as the
option shown to the user.

If C<$showkey> is true, then both the key and value will be shown to
the user.

If the C<$default> argument is given, then if a value (from
C<$keyfieldname>) matches C<$default>, it will be selected by default.

=cut
#'
#---------------------------------------------
# Create an HTML option list for a <SELECT> form tag by using
#    values from a DB file
# XXX - POD
sub getkeytableselectoptions {
	use strict;
	# inputs
	my (
		$dbh,		# DBI handle
		$tablename,	# name of table containing list of choices
		$keyfieldname,	# column name of code to use in option list
		$descfieldname,	# column name of descriptive field
		$showkey,	# flag to show key in description
		$default,	# optional default key
	)=@_;
	my $selectclause;	# return value

	my (
		$sth, $query, 
		$key, $desc, $orderfieldname,
	);
	my $debug=0;

    	requireDBI($dbh,"getkeytableselectoptions");

	if ( $showkey ) {
		$orderfieldname=$keyfieldname;
	} else {
		$orderfieldname=$descfieldname;
	}
	$query= "select $keyfieldname,$descfieldname
		from $tablename
		order by $orderfieldname ";
	print "<PRE>Query=$query </PRE>\n" if $debug; 
	$sth=$dbh->prepare($query);
	$sth->execute;
	while ( ($key, $desc) = $sth->fetchrow) {
	    if ($showkey || ! $desc ) { $desc="$key - $desc"; }
	    $selectclause.="<option";
	    if (defined $default && $default eq $key) {
		$selectclause.=" selected";
	    }
	    $selectclause.=" value='$key'>$desc\n";
	    print "<PRE>Sel=$selectclause </PRE>\n" if $debug; 
	}
	return $selectclause;
} # sub getkeytableselectoptions

#---------------------------------

END { }       # module clean-up code here (global destructor)
