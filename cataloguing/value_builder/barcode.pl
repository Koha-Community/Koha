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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use C4::Context;
use C4::Barcodes::ValueBuilder;
use C4::Biblio      qw( GetMarcFromKohaField );
use Koha::DateUtils qw( dt_from_string );

use Algorithm::CheckDigits qw( CheckDigits );

use CGI      qw ( -utf8 );
use C4::Auth qw( check_cookie_auth );
my $input = CGI->new;
my ($auth_status) =
    check_cookie_auth( $input->cookie('CGISESSID'), { catalogue => 1 } );
if ( $auth_status ne "ok" ) {
    print $input->header( -type => 'text/plain', -status => '403 Forbidden' );
    exit 0;
}

my $builder = sub {
    my ($params) = @_;
    my $function_name = $params->{id};
    my %args;

    # find today's date
    ( $args{year}, $args{mon}, $args{day} ) = split( '-', dt_from_string()->ymd() );
    ( $args{tag}, $args{subfield} ) = GetMarcFromKohaField("items.barcode");

    my $nextnum;
    my $scr;
    my $autoBarcodeType = C4::Context->preference("autoBarcode");
    if ( ( not $autoBarcodeType ) or $autoBarcodeType eq 'OFF' ) {

        # don't return a value unless we have the appropriate syspref set
        return q|<script></script>|;
    }
    if ( $autoBarcodeType eq 'annual' ) {
        ( $nextnum, $scr ) = C4::Barcodes::ValueBuilder::annual::get_barcode( \%args );
    } elsif ( $autoBarcodeType eq 'incremental' ) {
        ( $nextnum, $scr ) = C4::Barcodes::ValueBuilder::incremental::get_barcode( \%args );
    } elsif ( $autoBarcodeType eq 'hbyymmincr' )
    { # Generates a barcode where hb = home branch Code, yymm = year/month catalogued, incr = incremental number, reset yearly -fbcit
        ( $nextnum, $scr ) = C4::Barcodes::ValueBuilder::hbyymmincr::get_barcode( \%args );
    } elsif ( $autoBarcodeType eq 'EAN13' ) {

        # not the best, two catalogers could add the same barcode easily this way :/
        my $query = "select max(abs(barcode)) from items";
        my $dbh   = $params->{dbh};
        my $sth   = $dbh->prepare($query);
        $sth->execute();
        while ( my ($last) = $sth->fetchrow_array ) {
            $nextnum = $last;
        }
        my $ean = CheckDigits('ean');
        if ( $ean->is_valid($nextnum) ) {
            my $next = $ean->basenumber($nextnum) + 1;
            $nextnum = $ean->complete($next);
            $nextnum = '0' x ( 13 - length($nextnum) ) . $nextnum;    # pad zeros
        } else {
            warn "ERROR: invalid EAN-13 $nextnum, using increment";
            $nextnum++;
        }
    } else {
        warn "ERROR: unknown autoBarcode: $autoBarcodeType";
    }

    # default js body (if not filled by hbyymmincr)
    $scr or $scr = <<END_OF_JS;
if (\$('#' + id).val() == '' || force) {
    if ( autobarcodetype == "annual"){
        const [prefix, numberStr] = '$nextnum'.split('-');
        const incrementedNumber = parseInt(numberStr, 10) + offset;
        const newNumberStr = incrementedNumber.toString().padStart(numberStr.length, '0');
        \$('#' + id).val(prefix + '-' + newNumberStr);
    }
    else if ( autobarcodetype == "EAN13" ) {
        \$('#' + id).val(incrementEAN13($nextnum, offset));
    }
    else if ( incremental_barcode ) {
        \$('#' + id).val($nextnum + offset);
    }
    else {
        \$('#' + id).val('$nextnum');
    }
};
END_OF_JS

    my $js = <<END_OF_JS;
<script>
if(typeof autobarcodetype == 'undefined') {
    var autobarcodetype = "$autoBarcodeType";
    var attempt = -1
    var incrementalBarcodeTypes = ["hbyymmincr", "incremental", "annual", "EAN13"];
    var incremental_barcode = incrementalBarcodeTypes.includes(autobarcodetype);
}

function set_barcode(id, force, offset=0) {
$scr
}

function calculateChecksum(ean12) {
    let sum = 0;
    for (let i = 0; i < ean12.length; i++) {
        const digit = parseInt(ean12[i], 10);
        sum += (i % 2 === 0) ? digit : digit * 3;
    }
    const checksum = (10 - (sum % 10)) % 10;
    return checksum;
}

function incrementEAN13(ean13, offset) {
    // Increment the first 12 digits and recompute the checksum
    let ean12 = String(ean13).slice(0, 12);
    let incrementedNumber = (parseInt(ean12, 10) + offset).toString().padStart(12, '0');
    const newChecksum = calculateChecksum(incrementedNumber);
    return incrementedNumber + newChecksum;
}

function Focus$function_name(event) {
    if (incremental_barcode){
        if (document.getElementById(event.data.id).value == ''){
            attempt += 1
        }
        set_barcode(event.data.id, false, attempt);
    }
    else{
        set_barcode(event.data.id, false);
    }
    return false;
}

function Click$function_name(event) {
    if (incremental_barcode){
        if (document.getElementById(event.data.id).value == ''){
            attempt += 1
        }
        set_barcode(event.data.id, false, attempt);
    }
    else{
        set_barcode(event.data.id, false);
    }
    return false;
}
</script>
END_OF_JS
    return $js;
};

return { builder => $builder };
