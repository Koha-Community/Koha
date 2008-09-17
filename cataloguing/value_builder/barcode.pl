#!/usr/bin/perl

# $Id: barcode.pl,v 1.1.2.2 2006/09/20 02:24:42 kados Exp $

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


use C4::Context;

my $DEBUG = 0;

=head1

plugin_parameters : other parameters added when the plugin is called by the dopop function

=cut
sub plugin_parameters {
my ($dbh,$record,$tagslib,$i,$tabloop) = @_;
return "";
}

=head1

plugin_javascript : the javascript function called when the user enters the subfield.
contain 3 javascript functions :
* one called when the field is entered (OnFocus). Named FocusXXX
* one called when the field is leaved (onBlur). Named BlurXXX
* one called when the ... link is clicked (<a href="javascript:function">) named ClicXXX

returns :
* XXX
* a variable containing the 3 scripts.
the 3 scripts are inserted after the <input> in the html code

=cut
sub plugin_javascript {
	my ($dbh,$record,$tagslib,$field_number,$tabloop) = @_;
	my $function_name= "barcode".(int(rand(100000))+1);

	# find today's date
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =
                                                               localtime(time);
	$year +=1900;
	$mon +=1;
	if (length($mon)==1) {
		$mon = "0".$mon;
	}
	if (length($mday)==1) {
		$mday = "0".$mday;
	}
	if (length($hour)==1) {
   	     $hour = "0".$hour;
	}
	if (length($min)==1) {
        $min = "0".$min;
	}
	if (length($sec)==1) {
        $hour = "0".$sec;
	}

	my $date = "$year";

	my ($tag,$subfield) =  GetMarcFromKohaField("items.barcode");
	my ($loctag,$locsubfield) =  GetMarcFromKohaField("items.homebranch");

	my $nextnum;
	my $query;
        my $scr;
	my $autoBarcodeType = C4::Context->preference("autoBarcode");
        warn "Barcode type = $autoBarcodeType" if $DEBUG;
	unless ($autoBarcodeType eq 'OFF' or !$autoBarcodeType) {

	if ($autoBarcodeType eq 'annual') {
		$query = "select max(cast( substring_index(barcode, '-',-1) as signed)) from items where barcode like ?";
		my $sth=$dbh->prepare($query);
		$sth->execute("$year%");
		while (my ($count)= $sth->fetchrow_array) {
                    warn "Examining Record: $count" if $DEBUG;
    		$nextnum = $count if $count;
		}
		$nextnum++;
		$nextnum = sprintf("%0*d", "4",$nextnum);
		$nextnum = "$year-$nextnum";
                $scr = " 
		for (i=0 ; i<document.f.field_value.length ; i++) {
			if (document.f.tag[i].value == '$tag' && document.f.subfield[i].value == '$subfield') {
				if (document.f.field_value[i].value == '') {
					document.f.field_value[i].value = '$nextnum';
				}
			}
		}";
	}
	elsif ($autoBarcodeType eq 'incremental') {
		# not the best, two catalogers could add the same barcode easily this way :/
		$query = "select max(abs(barcode)) from items";
        my $sth=$dbh->prepare($query);
		$sth->execute();
		while (my ($count)= $sth->fetchrow_array) {
			$nextnum = $count;
		}
		$nextnum++;
                $scr = " 
		for (i=0 ; i<document.f.field_value.length ; i++) {
			if (document.f.tag[i].value == '$tag' && document.f.subfield[i].value == '$subfield') {
				if (document.f.field_value[i].value == '') {
					document.f.field_value[i].value = '$nextnum';
				}
			}
		}";
	}
        elsif ($autoBarcodeType eq 'hbyymmincr') {      # Generates a barcode where hb = home branch Code, yymm = year/month catalogued, incr = incremental number, reset yearly -fbcit
            $year = substr($year, -2);
	    $query = "SELECT MAX(CAST(SUBSTRING(barcode,7,4) AS signed)) FROM items WHERE barcode REGEXP ?";
	    my $sth=$dbh->prepare($query);
	    $sth->execute("^[a-zA-Z]{1,}$year");
	    while (my ($count)= $sth->fetchrow_array) {
    	        $nextnum = $count if $count;
                warn "Existing incremental number = $nextnum" if $DEBUG;
	    }
	    $nextnum++;
            $nextnum = sprintf("%0*d", "4",$nextnum);
            $nextnum = $year . $mon . $nextnum;
            warn "New Barcode = $nextnum" if $DEBUG;
            $scr = " 
		for (i=0 ; i<document.f.field_value.length ; i++) {
			if (document.f.tag[i].value == '$loctag' && document.f.subfield[i].value == '$locsubfield') {
				fnum = i;
			}
		}
		for (i=0 ; i<document.f.field_value.length ; i++) {
			if (document.f.tag[i].value == '$tag' && document.f.subfield[i].value == '$subfield') {
				if (document.f.field_value[i].value == '') {
					document.f.field_value[i].value = document.f.field_value[fnum].value + '$nextnum';
				}
			}
		}";
        }


		my $res  = "
<script type=\"text/javascript\">
//<![CDATA[

//function Blur$function_name(index) {
//need this?
//}

function Focus$function_name(subfield_managed) {";

$res .= $scr;
$res .= "
return 0;
}

function Clic$function_name(subfield_managed) {";

$res .= $scr;
$res .= "
return 0;
}
//]]>
</script>
";
	# don't return a value unless we have the appropriate syspref set
	return ($function_name,$res);
	}
	else {
		return ($function_name,"<script type=\"text/javascript\">function Focus$function_name() { return 0;}</script>");
	}
}

=head1

plugin : the true value_builded. The screen that is open in the popup window.

=cut

sub plugin {
my ($input) = @_;
return "";
}

1;
