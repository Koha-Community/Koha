package C4::Bull; #assumes C4/Bull.pm


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

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

# set the version for version checking
$VERSION = 0.01;

=head1 NAME

C4::Bull - Give functions for serializing.

=head1 SYNOPSIS

  use C4::Bull;

=head1 DESCRIPTION

Give all XYZ functions

=cut

@ISA = qw(Exporter);
@EXPORT = qw(&Initialize_Sequence &Find_Next_Date, &Get_Next_Seq);

# FIXME - Retirer ce FIXME il ne sert pas. 

sub GetValue(@) {
    my $seq = shift;
    my $X = shift;
    my $Y = shift;
    my $Z = shift;

    return $X if ($seq eq 'X');
    return $Y if ($seq eq 'Y');
    return $Z if ($seq eq 'Z');
    return "5 Syntax Error in Sequence";
}


sub Initialize_Sequence(@) {
    my $sequence = shift;
    my $X = shift;
    my $Xstate = shift;
    my $Xfreq = shift;
    my $Xstep = shift;
    my $Y = shift;
    my $Ystate = shift;
    my $Yfreq = shift;
    my $Ystep = shift;
    my $Z = shift;
    my $Zstate = shift;
    my $Zfreq = shift;
    my $Zstep = shift;
    my $finalstring = "";
    my @string = split //, $sequence;
    my $etat = 0;
    
    for (my $i = 0; $i < (scalar @string); $i++)
    {
	if ($string[$i] ne '{')
	    {
		    if (!$etat)
			    {
				$finalstring .= $string[$i];
				    }
		        else
			        {
				    return "1 Syntax Error in Sequence";
				        }
		    }
	else
	    {
#     if ($string[$i + 1] eq '\'')
#     {
# return "2 Syntax Error in Sequence"
#     if ($string[$i + 2] ne 'X' && $string[$i + 2] ne 'Y' && $string[$i + 2] ne 'Z');

# $finalstring .= GetValueAsc($string[$i + 2], $X, $Y, $Z);
# $i += 3;
#     }
#     else
#     {
		return "3 Syntax Error in Sequence"
		        if ($string[$i + 1] ne 'X' && $string[$i + 1] ne 'Y' && $string[$i + 1] ne 'Z');

		    
		$finalstring .= GetValue($string[$i + 1], $X, $Y, $Z);
		$i += 2;
#     }
		}
    }
    return "$finalstring";
}

sub Find_Next_Date(@) {
    return "2004-29-03";
}

sub Step(@) {
    my $X = shift;
    my $Xstate = shift;
    my $Xfreq = shift;
    my $Xstep = shift;
    my $Y = shift;
    my $Ystate = shift;
    my $Yfreq = shift;
    my $Ystep = shift;
    my $Z = shift;
    my $Zstate = shift;
    my $Zfreq = shift;
    my $Zstep = shift;
    my $Xpos = shift;
    my $Ypos = shift;
    my $Zpos = shift;
    
    
    $X += $Xstep if ($Xstate == 1);
    if ($Xstate == 2) { $Xpos += 1; if ($Xpos >= $Xfreq) {
	$Xpos = 0; $X += $Xstep; } }

    $Y += $Ystep if ($Ystate == 1);
    if ($Ystate == 2) { $Ypos += 1; if ($Ypos >= $Yfreq) {
	$Ypos = 0; $Y += $Ystep; } }

    $Z += $Zstep if ($Zstate == 1);
    if ($Zstate == 2) { $Zpos += 1; if ($Zpos >= $Zfreq) {
	$Zpos = 0; $Z += $Zstep; } }
    
#    $Y += $Ystep; if ($Ystate == 1);
 #   if ($Ystate == 2) { $Ypos += 1; if ($Ypos >= $Yfreq) {
	#$Ypos = 0; $Y += $Ystep; } }


   # $Z += $Zstep; if ($Zstate == 1);
   # if ($Zstate == 2) { $Zpos += 1; if ($Zpos >= $Zfreq) {
#	$Zpos = 0; $Z += $Zstep; } }

    return ($X, $Y, $Z, $Xpos, $Ypos, $Zpos);
}

sub Get_Next_Seq(@) {
    my $sequence = shift;
    my $X = shift;
    my $Xfreq = shift;
    my $Xstep = shift;
    my $Xstate = shift;
    my $Y = shift;
    my $Yfreq = shift;
    my $Ystep = shift;
    my $Ystate = shift;
    my $Z = shift;
    my $Zfreq = shift;
    my $Zstep = shift;
    my $Zstate = shift;
    my $Xpos = shift;
    my $Ypos = shift;
    my $Zpos = shift;

    return ("$sequence", $X, $Y, $Z)
	if (!defined($X) && !defined($Y) && !defined($Z));
    ($X, $Y, $Z, $Xpos, $Ypos, $Zpos) = 
	Step($X, $Xstate, $Xfreq, $Xstep, $Y, $Ystate, $Yfreq, 
	          $Ystep, $Z, $Zstate, $Zfreq, $Zstep, $Xpos, $Ypos, $Zpos);
    return (Initialize_Sequence($sequence, $X, $Xstate,
				$Xfreq, $Xstep, $Y, $Ystate, $Yfreq,
				$Ystep, $Z, $Zstate, $Zfreq, $Zstep),
	        $X, $Y, $Z, $Xpos, $Ypos, $Zpos);
}

END { }       # module clean-up code here (global destructor)
