#!/usr/bin/perl
# Copyright 2000-2002 Katipo Communications
# Parts copyright 2008-2010 Foundations Bible College
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use strict;
use warnings;
no warnings 'redefine'; # otherwise loading up multiple plugins fills the log with subroutine redefine warnings

use C4::Context;
require C4::Barcodes::ValueBuilder;
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
    my %args;

    $args{dbh} = $dbh;

# find today's date
    ($args{year}, $args{mon}, $args{day}) = split('-', C4::Dates->today('iso'));
    ($args{tag},$args{subfield})       =  GetMarcFromKohaField("items.barcode", '');
    ($args{loctag},$args{locsubfield}) =  GetMarcFromKohaField("items.homebranch", '');

    my $nextnum;
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
        ($nextnum, $scr) = C4::Barcodes::ValueBuilder::annual::get_barcode(\%args);
    }
    elsif ($autoBarcodeType eq 'incremental') {
        ($nextnum, $scr) = C4::Barcodes::ValueBuilder::incremental::get_barcode(\%args);
    }
    elsif ($autoBarcodeType eq 'hbyymmincr') {      # Generates a barcode where hb = home branch Code, yymm = year/month catalogued, incr = incremental number, reset yearly -fbcit
        ($nextnum, $scr) = C4::Barcodes::ValueBuilder::hbyymmincr::get_barcode(\%args);
    }

# default js body (if not filled by hbyymmincr)
    $scr or $scr = <<END_OF_JS;
    if (\$('#' + id).val() == '') {
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
        return 0;
    }

    function Clic$function_name(id) {
        $scr
            return 0;
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
