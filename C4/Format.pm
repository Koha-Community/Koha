package C4::Format; #assumes C4/Format


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


use vars qw($VERSION @ISA @EXPORT);

# set the version for version checking
$VERSION = 0.01;

=head1 NAME

C4::Format - Functions for pretty-printing strings and numbers

=head1 SYNOPSIS

  use C4::Format;

=head1 DESCRIPTION

These functions return pretty-printed versions of strings and numbers.

=head1 FUNCTIONS

=over 2

=cut

@ISA = qw(Exporter);
@EXPORT = qw(&fmtstr &fmtdec);

=item fmtstr

  $str = &fmtstr($env, $string, $format);

Returns C<$string>, padded with space to a given length.

C<$format> is either C<Ln> or C<Rn>, where I<n> is a positive integer.
C<$str> will be either left-padded or right-padded, respectively.

C<&fmtstr> is almost equivalent to

  sprintf("%-n.ns", $string);

or

  sprintf("%n.ns", $string);

The only difference is that if I<n> is less than the length of
C<$string>, then C<&fmtstr> will return the last I<n> characters of
C<$string>, whereas C<sprintf> will return the first I<n> characters.

C<$env> is ignored.

=cut
#'
sub fmtstr {
  # format (space pad) a string
  # $fmt is Ln.. or Rn.. where n is the length
  my ($env,$strg,$fmt)=@_;
  my $align = substr($fmt,0,1);
  my $lenst = substr($fmt,1,length($fmt)-1);
  if ($align eq"R" ) {
     $strg = substr((" "x$lenst).$strg,0-$lenst,$lenst);
  } elsif  ($align eq "C" ) {
     $strg =
       substr((" "x(($lenst/2)-(length($strg)/2))).$strg.(" "x$lenst),0,$lenst);
  } else {
     $strg = substr($strg.(" "x$lenst),0,$lenst);
  }
  return ($strg);
}

=item fmtdec

  $str = &fmtdec($env, $number, $format)

Returns a pretty-printed version of C<$number>.

C<$format> specifies how to print the number. It is of the form

  [$][,]n[m]

where I<n> and I<m> are digits, specifying the number of digits to use
before and after the decimal, respectively. Thus,

  &fmtdec(undef, 123.456, "42")

will return

  " 123.45"

If I<n> is smaller than the size of the integer part, only the last
I<n> digits will be returned. If I<m> is greater than the number of
digits after the decimal in C<$number>, the result will be
right-padded with zeros.

If C<$format> has a leading dollar sign, the number is assumed to be a
monetary amount. C<$str> will have a dollar sign prepended to the
value.

If C<$format> has a comma after the optional dollar sign, the integer
part will be split into three-digit groups separated by commas.

=cut
#'
# FIXME - This is all terribly provincial, not at all
# internationalized. I'm pretty sure there's already something out
# there that'll figure out the current locale, look up the local
# currency symbol (and whether it goes on the left or right), figure
# out how numbers are grouped (commas, periods, or what? And how many
# digits per group?), and will print the whole thing prettily.
# But I can't find it just now. Maybe POSIX::setlocale() or
# perllocale(1) might help.
# FIXME - Bug:
#	fmtdec(undef, 12345.6, ',82') prints "     345.60"
#	fmtdec(undef, 12345.6, '$,82') prints ".60"
sub fmtdec {
  # format a decimal
  # $fmt is [$][,]n[m]
  my ($env,$numb,$fmt)=@_;

  # FIXME - Use $fmt =~ /^(\$)?(,)?(\d)(\d)?$/ instead of this mess of
  # substr()s.

  # See if there's a leading dollar sign.
  my $curr = substr($fmt,0,1);
  if ($curr eq "\$") {
    $fmt = substr($fmt,1,length($fmt)-1);
  };
  # See if there's a leading comma
  my $comma = substr($fmt,0,1);
  if ($comma eq ",") {
    $fmt = substr($fmt,1,length($fmt)-1);
  };
  # See whether one number was given, or two.
  my $right;
  my $left = substr($fmt,0,1);
  if (length($fmt) == 1) {
    $right = 0;
  } else {
    $right = substr($fmt,1,1);
  }
  # See if $numb is a floating-point number.
  my $fnumb = "";
  my $tempint = "";
  my $tempdec = "";
  # FIXME - Use
  #	$numb =~ /(\d+)\.(\d+)/;
  #	$tempint = $1 + 0;
  #	$tempdec = $2;
  if (index($numb,".") == 0 ){
     $tempint = 0;
     $tempdec = substr($numb,1,length($numb)-1);
  } else {
     if (index($numb,".") > 0) {
       my $decpl = index($numb,".");
       $tempint = substr($numb,0,$decpl);
       $tempdec = substr($numb,$decpl+1,length($numb)-1-$decpl);
     } else {
       $tempint = $numb;
       $tempdec = 0;
     }
     # If a comma was specified, then comma-separate the integer part
     if ($comma eq ",") {
        while (length($tempdec) > 3) {
           $fnumb = ",".substr($tempint,-3,3).$fnumb;
	   substr($tempint,-3,3) = "";
	}
	$fnumb = substr($tempint,-3,3).$fnumb;
     } else {
        $fnumb = $tempint;
     }
  }
  # If a dollar sign was specified, prepend a dollar sign and
  # right-justify the number
  if ($curr eq "\$") {
     $fnumb = fmtstr($env,$curr.$fnumb,"R".$left+1);
  } else {
     if ($left==0) {
        $fnumb = "";
     } else {
        $fnumb = fmtstr($env,$fnumb,"R".$left);
     }
  }
  # Right-pad the decimal part to the given number of digits.
  if ($right > 0) {
     $tempdec = $tempdec.("0"x$right);
     $tempdec = substr($tempdec,0,$right);
     $fnumb = $fnumb.".".$tempdec;
  }
  return ($fnumb);	# FIXME - Shouldn't return a list.
}

END { }       # module clean-up code here (global destructor)

1;
__END__

=back

=head1 AUTHOR

Koha Developement team <info@koha.org>

=head1 SEE ALSO

L<perl>.

=cut
