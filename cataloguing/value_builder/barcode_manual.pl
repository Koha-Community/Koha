#!/usr/bin/perl

# Converted to new plugin style (Bug 13437)

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

use Modern::Perl;

use C4::Context;
use C4::Barcodes::ValueBuilder;
use C4::Biblio qw( GetMarcFromKohaField );
use Koha::DateUtils qw( dt_from_string output_pref );

my $builder = sub {
    my ( $params ) = @_;
    my $function_name = $params->{id};
    my %args;

    my $dbh = $params->{dbh};
    $args{dbh} = $dbh;

# find today's date
    ($args{year}, $args{mon}, $args{day}) = split('-', output_pref({ dt => dt_from_string, dateformat => 'iso', dateonly => 1 }));
    ($args{tag},$args{subfield})       =  GetMarcFromKohaField( "items.barcode" );

    my $nextnum;
    my $scr;
    my $autoBarcodeType = C4::Context->preference("autoBarcode");
    if ((not $autoBarcodeType) or $autoBarcodeType eq 'OFF') {
# don't return a value unless we have the appropriate syspref set
        return q|<script></script>|;
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
    <script>

    function Click$function_name(event) {
        const id = event.data.id;
        $scr
            return false;
    }
    </script>
END_OF_JS
    return $js;
};

return { builder => $builder };
