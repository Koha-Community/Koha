[% USE raw %]
<script nonce="[% Koha.CSPNonce | $raw %]" data-tt-allowed="true">
    [% IF ( Koha.Preference('IntranetSlipPrinterJS') ) %]
        [% Koha.Preference('IntranetSlipPrinterJS') | $raw %]
    [% ELSE %]
        $( window ).load(function() {
            window.print();
            window.onafterprint = function () {
                window.close();
            }
            setTimeout('window.close()', 1000); //Hack from Chrome < 63
        });
    [% END %]
</script>
