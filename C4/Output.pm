package C4::Output; #asummes C4/Output

#package to deal with marking up output
#You will need to edit parts of this pm
#set the value of path to be where your html lives

use strict;
require Exporter;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

# set the version for version checking
$VERSION = 0.01;

@ISA = qw(Exporter);
@EXPORT = qw(&startpage &endpage &mktablehdr &mktableft &mktablerow &mklink
&startmenu &endmenu &mkheadr &center &endcenter &mkform &mkform2 &bold
&gotopage &mkformnotable &mkform3);
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
my $path="/usr/local/www/hdl/htdocs/includes";


# here's a file-private function as a closure,
# callable as &$priv_func;  it cannot be prototyped.
my $priv_func = sub {
# stuff goes here.
  };
   
# make all your functions, whether exported or not;
 
sub startpage{
  my $string="<html>\n";
  return($string);
}

sub gotopage{
  my ($target) = @_;
  print "<br>goto target = $target<br>";
  my $string = "<META HTTP-EQUIV=Refresh CONTENT=\"0;URL=http:$target\">";
  return $string;
}


sub startmenu{
  # edit the paths in here
  my ($type)=@_;
  if ($type eq 'issue') {
    open (FILE,"$path/issues-top.inc") || die;
  } elsif ($type eq 'opac') {
    open (FILE,"$path/opac-top.inc") || die;
  } elsif ($type eq 'member') {
    open (FILE,"$path/members-top.inc") || die;
  } elsif ($type eq 'acquisitions'){
    open (FILE,"$path/aquisitions-top.inc")|| die;
  } elsif ($type eq 'report'){
    open (FILE,"$path/reports-top.inc") || die;
  } else {
    open (FILE,"$path/cat-top.inc") || die;
  }
  my @string=<FILE>;
  close FILE;
  my $count=@string;
  #  $string[$count]="<BLOCKQUOTE>";
  return @string;
}


sub endmenu{
  my ($type)=@_;
  if ($type eq 'issue'){
    open (FILE,"$path/issues-bottom.inc") || die;
  } elsif ($type eq 'opac') {
    open (FILE,"$path/opac-bottom.inc") || die;
  } elsif ($type eq 'member') {
    open (FILE,"$path/members-bottom.inc") || die;
  } elsif ($type eq 'acquisitions') {
    open (FILE,"$path/aquisitions-bottom.inc") || die;
  } elsif ($type eq 'report') {
    open (FILE,"$path/reports-bottom.inc") || die;
  } else {
    open (FILE,"$path/cat-bottom.inc") || die;
  }
  my @string=<FILE>;
  close FILE;
  return @string;
}

sub mktablehdr {
  my $string="<table border=0 cellspacing=0 cellpadding=5>\n";
  return($string);
}


sub mktablerow {
  #the last item in data may be a backgroundimage
  my ($cols,$colour,@data)=@_;
  my $i=0;
  my $string="<tr valign=top bgcolor=$colour>";
  while ($i <$cols){
    if ($data[$cols] ne ''){
    #check for backgroundimage
      $string.="<td background=\"$data[$cols]\">";
    } else {
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

sub mktableft {
  my $string="</table>\n";
  return($string);
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

sub mkform3{
  my ($action,%inputs)=@_;
  my $string="<form action=$action method=post>\n";
  $string=$string.mktablehdr();
  my $key;
  my @keys=sort keys %inputs;
  my @order;  
  my $count=@keys;
  my $i2=0;
  while ( $i2<$count) {
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
  my $count=@inputs;
  for (my $i=0; $i<$count; $i++){
    if ($inputs[$i][0] eq 'hidden'){
      $string=$string."<input type=hidden name=$inputs[$i][1] value=\"$inputs[$i][2]\">\n";
    }
    if ($inputs[$i][0] eq 'radio') {
      $string.="<input type=radio name=$inputs[1] value=$inputs[$i][2]>$inputs[$i][2]";
    } 
    if ($inputs[$i][0] eq 'text') {
      $string.="<input type=$inputs[$i][0] name=$inputs[$i][1] value=\"$inputs[$i][2]\">";
    }
    if ($inputs[$i][0] eq 'textarea') {
        $string.="<textarea name=$inputs[$i][1] wrap=physical cols=40 rows=4>$inputs[$i][2]</textarea>";
    }
    if ($inputs[$i][0] eq 'reset'){
      $string.="<input type=reset name=$inputs[$i][1] value=\"$inputs[$i][2]\">";
    }    
    if ($inputs[$i][0] eq 'submit'){
      $string.="<input type=submit name=$inputs[$i][1] value=\"$inputs[$i][2]\">";
    }    
  }
  $string=$string."</form>";
}

sub mkform2{
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
      @order[$posn] =mktablerow(2,'white',$ltext,$text);
    }
  }
  $string=$string.join("\n",@order);
  $string=$string.mktablerow(2,'white','<input type=submit>','<input type=reset>');
  $string=$string.mktableft;
  $string=$string."</form>";
}


sub endpage{
  my $string="</body></html>\n";
  return($string);
}

sub mklink {
  my ($url,$text)=@_;
  my $string="<a href=\"$url\">$text</a>";
  return ($string);
}

sub mkheadr {
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

sub center {
  my ($text)=@_;
  my $string="<CENTER>\n";
  return ($string);
}  

sub endcenter {
  my ($text)=@_;
  my $string="</CENTER>\n";
  return ($string);
}  

sub bold {
  my ($text)=@_;
  my $string="<b>$text</b>";
  return($string);
}

END { }       # module clean-up code here (global destructor)
    
