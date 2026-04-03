[% USE raw %]
<!-- slip-print.inc -->
<script nonce="[% Koha.CSPNonce | $raw %]" data-tt-allowed="true">
    [% IF ( Koha.Preference('IntranetSlipPrinterJS') ) %]
        let autoprint = false;
        [% Koha.Preference('IntranetSlipPrinterJS') | $raw %]
    [% ELSE %]
        let autoprint = true;
        window.addEventListener('load', function() {
            window.print();
            window.onafterprint = function () {
                window.close();
            }
        });
    [% END %]
</script>
<!-- / slip-print.inc -->
