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
require C4::Dates;
my $DEBUG = 0;

=head1

plugin_parameters : other parameters added when the plugin is called by the dopop function

=cut
sub plugin_parameters {
#   my ($dbh,$record,$tagslib,$i,$tabloop) = @_;
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
	my ($year, $mon, $day) = split('-', C4::Dates->today('iso'));
	my ($tag,$subfield)       =  GetMarcFromKohaField("items.barcode", '');
	my ($loctag,$locsubfield) =  GetMarcFromKohaField("items.homebranch", '');

	my $nextnum;
	my $query;
    my $scr;
	my $autoBarcodeType = C4::Context->preference("autoBarcode");
    warn "Barcode type = $autoBarcodeType" if $DEBUG;
	if ((not $autoBarcodeType) or $autoBarcodeType eq 'OFF') {
        # don't return a value unless we have the appropriate syspref set
		return ($function_name, 
        "<script type=\"text/javascript\">
        // autoBarcodeType OFF (or not defined)
        function Focus$function_name() { return 0;}
        function  Clic$function_name() { return 0;}
        function  Blur$function_name() { return 0;}
        </script>");
    }
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
	}
	elsif ($autoBarcodeType eq 'incremental') {
		# not the best, two catalogers could add the same barcode easily this way :/
		$query = "select max(abs(barcode)) from items";
        my $sth = $dbh->prepare($query);
		$sth->execute();
		while (my ($count)= $sth->fetchrow_array) {
			$nextnum = $count;
		}
		$nextnum++;
    }
    elsif ($autoBarcodeType eq 'hbyymmincr') {      # Generates a barcode where hb = home branch Code, yymm = year/month catalogued, incr = incremental number, reset yearly -fbcit
        $year = substr($year, -2);
        $query = "SELECT MAX(CAST(SUBSTRING(barcode,7,4) AS signed)) FROM items WHERE barcode REGEXP ?";
        my $sth = $dbh->prepare($query);
        $sth->execute("^[a-zA-Z]{1,}$year");
        while (my ($count)= $sth->fetchrow_array) {
            $nextnum = $count if $count;
            warn "Existing incremental number = $nextnum" if $DEBUG;
        }
        $nextnum++;
        $nextnum = sprintf("%0*d", "4",$nextnum);
        $nextnum = $year . $mon . $nextnum;
        warn "New hbyymmincr Barcode = $nextnum" if $DEBUG;
        $scr = " 
        for (i=0 ; i<document.f.field_value.length ; i++) {
            if (document.f.tag[i].value == '$loctag' && document.f.subfield[i].value == '$locsubfield') {
                fnum = i;
            }
        }
        if (\$('#' + id).val() == '' || force) {
            \$('#' + id).val(document.f.field_value[fnum].value + '$nextnum');
        }
        ";
    }

    # default js body (if not filled by hbyymmincr)
    $scr or $scr = <<END_OF_JS;
if (\$('#' + id).val() == '' || force) {
    \$('#' + id).val('$nextnum');
}
END_OF_JS

    my $js  = <<END_OF_JS;
<script type="text/javascript">
//<![CDATA[

function Blur$function_name(index) {
    //barcode validation might go here
}

function Focus$function_name(subfield_managed, id, force) {
$scr
    return 0;
}

function Clic$function_name(id) {
    return Focus$function_name('not_relavent', id, 1);
}
//]]>
</script>
END_OF_JS
    return ($function_name, $js);
}

=head1

plugin: useless here

=cut

sub plugin {
    # my ($input) = @_;
    return "";
}

1;
