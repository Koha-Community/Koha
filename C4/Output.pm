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

@EXPORT_OK   = qw($Var1 %Hashit);


# non-exported package globals go here
use vars qw(@more $stuff);

# initalize package globals, first exported ones

my $Var1   = '';
my %Hashit = ();


# then the others (which are still accessible as $Some::Module::stuff)
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
    } else {
	$htdocs = $configfile->{'intrahtdocs'};
    }

    my ($theme, $lang) = themelanguage($htdocs, $tmplbase);

    my $template = HTML::Template->new(filename          => "$htdocs/$theme/$lang/$tmplbase", 
				   die_on_bad_params => 0, 
				   path              => ["$htdocs/$theme/$lang/includes"]);

    $template->param(themelang => "/$theme/$lang");
    return $template;
}

sub picktemplate {
  my ($includes, $base) = @_;
  my $dbh=C4Connect;
  my $templates;
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
  $sth->finish;
  my @languages = split " ", $lang;
  warn "Lang = @languages\n";

# theme preferences....
  my $sth=$dbh->prepare("SELECT value FROM systempreferences WHERE variable='opacthemes'");
  $sth->execute;
  my ($theme) = $sth->fetchrow;
  $sth->finish;
  my @themes = split " ", $theme;
  warn "Theme = @themes \n";

  $dbh->disconnect;

  my ($theme, $lang);
# searches through the themes and languages. First template it find it returns.
# Priority is for getting the theme right.
  THEME: 
  foreach my $th (@themes) {
    foreach my $la (@languages) {
	warn "File = $htdocs/$th/$la/$tmpl\n";
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


sub startmenu($) {
  # edit the paths in here
  my ($type)=shift;
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

sub mktablehdr() {
    return("<table border=0 cellspacing=0 cellpadding=5>\n");
}


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

sub mktableft() {
  return("</table>\n");
}

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

sub mkform3 {
  my ($action, %inputs) = @_;
  my $string = "<form action=\"$action\" method=\"post\">\n";
  $string   .= mktablehdr();
  my $key;
  my @keys = sort(keys(%inputs));
  my @order;
  my $count = @keys;
  my $i2 = 0;
  while ($i2 < $count) {
    my $value=$inputs{$keys[$i2]};
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
      if ($data[0] eq 'text') {
        $text="<input type=$data[0] name=$keys[$i2] value=\"$data[1]\" size=40>";
      }
      if ($data[0] eq 'textarea') {
        $text="<textarea name=$keys[$i2] cols=40 rows=4>$data[1]</textarea>";
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
#      $string=$string.mktablerow(2,'white',$keys[$i2],$text);
      $order[$posn]=mktablerow(2,'white',$keys[$i2],$text);
    }
    $i2++;
  }
  my $temp=join("\n",@order);
  $string=$string.$temp;
  $string=$string.mktablerow(1,'white','<input type=submit>');
  $string=$string.mktableft;
  $string=$string."</form>";
}

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

=pod

=head2 &endpage

 &endpage does not expect any arguments, it returns the string:
   </body></html>\n

=cut

sub endpage() {
  return("</body></html>\n");
}

=pod

=head2 &mklink

 &mklink expects two arguments, the url to link to and the text of the link.
 It returns this string:
   <a href="$url">$text</a>
 where $url is the first argument and $text is the second.

=cut

sub mklink($$) {
  my ($url,$text)=@_;
  my $string="<a href=\"$url\">$text</a>";
  return ($string);
}

=pod

=head2 &mkheadr

 &mkeadr expects two strings, a type and the text to use in the header.
 types are:

=over

=item 1  ends with <br>

=item 2  no special ending tag

=item 3  ends with <p>

=back

 Other than this, the return value is the same:
   <FONT SIZE=6><em>$text</em></FONT>$string
 Where $test is the text passed in and $string is the tag generated from 
 the type value.

=cut

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
    $string="<FONT SIZE=6><em>$text</em></FONT><br>";
  }
  if ($type eq '3'){
    $string="<FONT SIZE=6><em>$text</em></FONT><p>";
  }
  return ($string);
}

=pod

=head2 &center and &endcenter

 &center and &endcenter take no arguments and return html tags <CENTER> and
 </CENTER> respectivley.

=cut

sub center() {
  return ("<CENTER>\n");
}  

sub endcenter() {
  return ("</CENTER>\n");
}  

=pod

=head2 &bold

 &bold requires that a single string be passed in by the caller.  &bold 
 will return "<b>$text</b>" where $text is the string passed in.

=cut

sub bold($) {
  my ($text)=shift;
  return("<b>$text</b>");
}

#---------------------------------------------
# Create an HTML option list for a <SELECT> form tag by using
#    values from a DB file
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
