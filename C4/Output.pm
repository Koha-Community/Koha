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

# NOTE: I'm pretty sure this module is deprecated in favor of
# templates.

use strict;
require Exporter;

use C4::Context;
use C4::Database;
use HTML::Template;

use vars qw($VERSION @ISA @EXPORT);

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
	     &pathtotemplate
		&themelanguage &gettemplate
	     );

#FIXME: this is a quick fix to stop rc1 installing broken
#Still trying to figure out the correct fix.
my $path = C4::Context->config('intrahtdocs')."/intranet-tmpl/default/en/includes/";

#---------------------------------------------------------------------------------------------------------
# FIXME - POD
sub gettemplate {
	my ($tmplbase, $opac) = @_;

	my $htdocs;
	if ($opac ne "intranet") {
		$htdocs = C4::Context->config('opachtdocs');
	} else {
		$htdocs = C4::Context->config('intrahtdocs');
	}

	my ($theme, $lang) = themelanguage($htdocs, $tmplbase, $opac);

	my $template = HTML::Template->new(filename      => "$htdocs/$theme/$lang/$tmplbase",
				   die_on_bad_params => 0,
				   global_vars       => 1,
				   path              => ["$htdocs/$theme/$lang/includes"]);

	# XXX temporary patch for Bug 182 for themelang
	$template->param(themelang => ($opac ne 'intranet'? '/opac-tmpl': '/intranet-tmpl') . "/$theme/$lang",
							interface => ($opac ne 'intranet'? '/opac-tmpl': '/intranet-tmpl'),
							theme => $theme,
							lang => $lang);
	return $template;
}

#---------------------------------------------------------------------------------------------------------
# FIXME - POD
sub themelanguage {
  my ($htdocs, $tmpl, $section) = @_;

  my $dbh = C4::Context->dbh;
  my @languages;
  my @themes;
  if ( $section eq "intranet")
  {
    @languages = split " ", C4::Context->preference("opaclanguages");
    @themes = split " ", C4::Context->preference("template");
  }
  else
  {
    @languages = split " ", C4::Context->preference("opaclanguages");
    @themes = split " ", C4::Context->preference("opacthemes");
  }

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


=item pathtotemplate

  %values = &pathtotemplate(template => $template,
	theme => $themename,
	language => $language,
	type => $ptype,
	path => $includedir);

Finds a directory containing the desired template. The C<template>
argument specifies the template you're looking for (this should be the
name of the script you're using to generate an HTML page, without the
C<.pl> extension). Only the C<template> argument is required; the
others are optional.

C<theme> specifies the name of the theme to use. This will be used
only if it is allowed by the C<allowthemeoverride> system preference
option (in the C<systempreferences> table of the Koha database).

C<language> specifies the desired language. If not specified,
C<&pathtotemplate> will use the list of acceptable languages specified
by the browser, then C<all>, and finally C<en> as fallback options.

C<type> may be C<intranet>, C<opac>, C<none>, or some other value.
C<intranet> and C<opac> specify that you want a template for the
internal web site or the public OPAC, respectively. C<none> specifies
that the template you're looking for is at the top level of one of the
include directories. Any other value is taken as-is, as a subdirectory
of one of the include directories.

C<path> specifies an include directory.

C<&pathtotemplate> searches first in the directory given by the
C<path> argument, if any, then in the directories given by the
C<templatedirectory> and C<includes> directives in F</etc/koha.conf>,
in that order.

C<&pathtotemplate> returns a hash with the following keys:

=over 4

=item C<path>

The full pathname to the desired template.

=item C<foundlanguage>

The value is set to 1 if a template in the desired language was found,
or 0 otherwise.

=item C<foundtheme>

The value is set to 1 if a template of the desired theme was found, or
0 otherwise.

=back

If C<&pathtotemplate> cannot find an acceptable template, it returns 0.

Note that if a template of the desired language or theme cannot be
found, C<&pathtotemplate> will print a warning message. Unless you've
set C<$SIG{__WARN__}>, though, this won't show up in the output HTML
document.

=cut
#'
# FIXME - Fix POD: it doesn't look in the directory given by the
# 'includes' option in /etc/koha.conf.
sub pathtotemplate {
  my %params = @_;
  my $template = $params{'template'};
  my $themeor = $params{'theme'};
  my $languageor = lc($params{'language'});
  my $ptype = lc($params{'type'} or 'intranet');

  # FIXME - Make sure $params{'template'} was given. Or else assume
  # "default".
  my $type;
  if ($ptype eq 'opac') {$type = 'opac-tmpl/'; }
  elsif ($ptype eq 'none') {$type = ''; }
  elsif ($ptype eq 'intranet') {$type = 'intranet-tmpl/'; }
  else {$type = $ptype . '/'; }

  my %returns;
  my $theme = C4::Context->preference("theme") || "default";
  if ($themeor and
      C4::Context->preference("allowthemeoverride") =~ qr/$themeor/i)
  {
    $theme = $themeor;
  }
  my @languageorder = getlanguageorder();
  my $language = $languageor || shift(@languageorder);

  #where to search for templates
  my @tmpldirs = ("$path/templates", $path);
  unshift (@tmpldirs, C4::Context->config('templatedirectory')) if C4::Context->config('templatedirectory');
  unshift (@tmpldirs, $params{'path'}) if $params{'path'};

  my ($etheme, $elanguage, $epath);

  CHECK: foreach my $edir (@tmpldirs) {
    foreach $etheme ($theme, 'all', 'default') {
      foreach $elanguage ($language, @languageorder, 'all','en') {
				# 'en' is the fallback-language
      	if (-e "$edir/$type$etheme/$elanguage/$template") {
      	  $epath = "$edir/$type$etheme/$elanguage/$template";
      	  last CHECK;
      	}
      }
    }
  }

  unless ($epath) {
    warn "Could not find $template in @tmpldirs";
    return 0;
  }

  if ($language eq $elanguage) {
    $returns{'foundlanguage'} = 1;
  } else {
    $returns{'foundlanguage'} = 0;
    warn "The language $language could not be found for $template of $theme.\nServing $elanguage instead.\n";
  }
  if ($theme eq $etheme) {
    $returns{'foundtheme'} = 1;
  } else {
    $returns{'foundtheme'} = 0;
    warn "The template $template could not be found for theme $theme.\nServing $template of $etheme instead.\n";
  }

  $returns{'path'} = $epath;

  return (%returns);
}

=item getlanguageorder

  @languages = &getlanguageorder();

Returns the list of languages that the user will accept, and returns
them in order of decreasing preference. This is retrieved from the
browser's headers, if possible; otherwise, C<&getlanguageorder> uses
the C<languageorder> setting from the C<systempreferences> table in
the Koha database. If neither is set, it defaults to C<en> (English).

=cut
#'
sub getlanguageorder () {
  my @languageorder;

  if ($ENV{'HTTP_ACCEPT_LANGUAGE'}) {
    @languageorder = split (/\s*,\s*/ ,lc($ENV{'HTTP_ACCEPT_LANGUAGE'}));
  } elsif (my $order = C4::Context->preference("languageorder")) {
    @languageorder = split (/\s*,\s*/ ,lc($order));
  } else { # here should be another elsif checking for apache's languageorder
    @languageorder = ('en');
  }

  return (@languageorder);
}

=item startpage

  $str = &startpage();
  print $str;

Returns a string of HTML, the beginning of a new HTML document.

=cut
#'
sub startpage() {
  return("<html>\n");
}

=item gotopage

  $str = &gotopage("//opac.koha.org/index.html");
  print $str;

Generates a snippet of HTML code that will redirect to the given URL
(which should not include the initial C<http:>), and returns it.

=cut
#'
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
  if ($type eq 'issue') {
    open (FILE,"$path/issues-top.inc") || die "could not find : $path/issues-top.inc";
  } elsif ($type eq 'opac') {
    open (FILE,"$path/opac-top.inc") || die "could not find : $path/opac-top.inc";
  } elsif ($type eq 'member') {
    open (FILE,"$path/members-top.inc") || die "could not find : $path/members-top.inc";
  } elsif ($type eq 'acquisitions'){
    open (FILE,"$path/acquisitions-top.inc") || die "could not find : $path/acquisition-top.inc";
  } elsif ($type eq 'report'){
    open (FILE,"$path/reports-top.inc") || die "could not find : $path/reports-top.inc";
  } elsif ($type eq 'circulation') {
    open (FILE,"$path/circulation-top.inc") || die "could not find : $path/circulation-top.inc";
  } elsif ($type eq 'admin') {
    open (FILE,"$path/parameters-top.inc") || die "could not find : $path/parameters-top.inc";
  } else {
    open (FILE,"$path/cat-top.inc") || die "could not find : $path/cat-top.inc";
  }
  my @string=<FILE>;
  close FILE;
  # my $count=@string;
  # $string[$count]="<BLOCKQUOTE>";
  return @string;
}

=item endmenu

  @lines = &endmenu($type);
  print join("", @lines);

Given a page type, or category, returns a set of lines of HTML which,
when concatenated, generate the menu at the bottom of the web page.

C<$type> may be one of C<issue>, C<opac>, C<member>, C<acquisitions>,
C<report>, C<circulation>, or something else, in which case the menu
will be for the catalog pages.

=cut
#'
sub endmenu {
  my ($type) = @_;
  if ( ! defined $type ) { $type=''; }
  # FIXME - It's bad form to die in a CGI script. It's even worse form
  # to die without issuing an error message.
  if ($type eq 'issue') {
    open (FILE,"<$path/issues-bottom.inc") || die;
  } elsif ($type eq 'opac') {
    open (FILE,"<$path/opac-bottom.inc") || die;
  } elsif ($type eq 'member') {
    open (FILE,"<$path/members-bottom.inc") || die;
  } elsif ($type eq 'acquisitions') {
    open (FILE,"<$path/acquisitions-bottom.inc") || die;
  } elsif ($type eq 'report') {
    open (FILE,"<$path/reports-bottom.inc") || die;
  } elsif ($type eq 'circulation') {
    open (FILE,"<$path/circulation-bottom.inc") || die;
  } elsif ($type eq 'admin') {
    open (FILE,"<$path/parameters-bottom.inc") || die;
  } else {
    open (FILE,"<$path/cat-bottom.inc") || die;
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
      if (! defined $data[$i]) {$data[$i]="";}
      if ($data[$i] eq "") {
	  $string.=" &nbsp; </td>";
      } else {
	  $string.="$data[$i]</td>";
      }
      $i++;
  }
  $string .= "</tr>\n";
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

# FIXME - This is never used.
sub mkform{
  my ($action,%inputs)=@_;
  my $string="<form action=$action method=post>\n";
  $string .= mktablehdr();
  my $key;
  my @keys=sort keys %inputs;

  my $count=@keys;
  my $i2=0;
  while ( $i2<$count) {
    my $value=$inputs{$keys[$i2]};
    my @data=split('\t',$value);
    #my $posn = shift(@data);
    if ($data[0] eq 'hidden'){
      $string .= "<input type=hidden name=$keys[$i2] value=\"$data[1]\">\n";
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
      	  $text .= "<option value=$data[$i]>$val";
      	  $i += 2;
	}
	$text .= "</select>";
      }
      $string .= mktablerow(2,'white',$keys[$i2],$text);
      #@order[$posn] =mktablerow(2,'white',$keys[$i2],$text);
    }
    $i2++;
  }
  #$string=$string.join("\n",@order);
  $string .= mktablerow(2,'white','<input type=submit>','<input type=reset>');
  $string .= mktableft;
  $string .= "</form>";
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
  my $count = @keys;
  my $i2 = 0;
  while ($i2 < $count) {
    my $value=$inputs{$keys[$i2]};
    # FIXME - Why use a tab-separated string? Why not just use an
    # anonymous array?
    my @data=split('\t',$value);
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
      	  $text .= "<option value=$data[$i]>$val";
      	  $i += 2;
	}
	$text .= "</select>";
      }
#      $string=$string.mktablerow(2,'white',$keys[$i2],$text);
      $order[$posn]=mktablerow(2,'white',$keys[$i2],$text);
    }
    $i2++;
  }
  my $temp=join("\n",@order);
  $string .= $temp;
  $string .= mktablerow(1,'white','<input type=submit>');
  $string .= mktableft;
  $string .= "</form>";
  # FIXME - A return statement, while not strictly necessary, would be nice.
}

=item mkformnotable

  $str = &mkformnotable($action, @inputs);
  print $str;

Takes a set of arguments that define an input form, generates an HTML
string for the form, and returns the string. Unlike C<&mkform2> and
C<&mkform3>, it does not put the form inside a table.

C<$action> is the action for the form, usually the URL of the script
that will process it.

The remaining arguments define the fields in the form. Each is an
anonymous array, e.g.:

  &mkformnotable("/cgi-bin/foo",
	[ "hidden", "hiddenvar", "value" ],
	[ "text", "username", "" ]);

The first element of each argument defines its type. The remaining
ones are type-dependent. The supported types are:

=over 4

=item C<[ "hidden", $name, $value]>

Generates a hidden field, for passing information to a script without
showing it to the user. C<$name> is the name of the field, and
C<$value> is the value to pass.

=item C<[ "radio", $groupname, $value ]>

Generates a radio button. Its name (or button group name) is C<$name>.
C<$value> is the value associated with the button; this is both the
value that will be shown to the user, and that which will be passed on
to the C<$action> script.

=item C<[ "text", $name, $inittext ]>

Generates a text input field. C<$name> specifies its name, and
C<$inittext> specifies the text that the field should initially
contain.

=item C<[ "textarea", $name ]>

Creates a 40x4 text area, named C<$name>.

=item C<[ "reset", $name, $label ]>

Generates a reset button, with name C<$name>. C<$label> specifies the
text for the button.

=item C<[ "submit", $name, $label ]>

Generates a submit button, with name C<$name>. C<$label> specifies the
text for the button.

=back

=cut
#'
sub mkformnotable{
  my ($action,@inputs)=@_;
  my $string="<form action=$action method=post>\n";
  my $count=@inputs;
  for (my $i=0; $i<$count; $i++){
    if ($inputs[$i][0] eq 'hidden'){
      $string .= "<input type=hidden name=$inputs[$i][1] value=\"$inputs[$i][2]\">\n";
    }
    if ($inputs[$i][0] eq 'radio') {
      $string .= "<input type=radio name=$inputs[1] value=$inputs[$i][2]>$inputs[$i][2]";
    }
    if ($inputs[$i][0] eq 'text') {
      $string .= "<input type=$inputs[$i][0] name=$inputs[$i][1] value=\"$inputs[$i][2]\">";
    }
    if ($inputs[$i][0] eq 'textarea') {
        $string .= "<textarea name=$inputs[$i][1] wrap=physical cols=40 rows=4>$inputs[$i][2]</textarea>";
    }
    if ($inputs[$i][0] eq 'reset'){
      $string .= "<input type=reset name=$inputs[$i][1] value=\"$inputs[$i][2]\">";
    }
    if ($inputs[$i][0] eq 'submit'){
      $string .= "<input type=submit name=$inputs[$i][1] value=\"$inputs[$i][2]\">";
    }
  }
  $string .= "</form>";
}

=item mkform2

  $str = &mkform2($action,
	$fieldname =>
	  "$fieldpos\t$required\t$label\t$fieldtype\t$value0\t$value1\t...",
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
    # No tests yet.  Once tests are written,
    # this function can be cleaned up with the following steps:
    #  turn the while loop into a foreach loop
    #  pull the nested if,elsif structure back up to the main level
    #  pull the code for the different kinds of inputs into separate
    #   functions
  my ($action,%inputs)=@_;
  my $string="<form action=$action method=post>\n";
  $string .= mktablehdr();
  my $key;
  my @order;
  while ( my ($key, $value) = each %inputs) {
    my @data=split('\t',$value);
    my $posn = shift(@data);
    my $reqd = shift(@data);
    my $ltext = shift(@data);
    if ($data[0] eq 'hidden'){
      $string .= "<input type=hidden name=$key value=\"$data[1]\">\n";
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
       	  $text .= "<option value=\"$data[$i]\"";
	  if ($data[$i] eq $sel) {
	     $text .= " selected";
	  }
          $text .= ">$val";
          $i += 2;
	}
	$text .= "</select>";
      }
      if ($reqd eq "R") {
        $ltext .= " (Req)";
	}
      $order[$posn] =mktablerow(2,'white',$ltext,$text);
    }
  }
  $string .= join("\n",@order);
  $string .= mktablerow(2,'white','<input type=submit>','<input type=reset>');
  $string .= mktableft;
  $string .= "</form>";
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
<CENTER> and </CENTER> respectively.

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
sub getkeytableselectoptions {
	use strict;
	# inputs
	my (
		$dbh,		# DBI handle
				# FIXME - Obsolete argument
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

    	$dbh = C4::Context->dbh;

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

1;
__END__

=back

=head1 AUTHOR

Koha Developement team <info@koha.org>

=cut
