[% USE raw %]
<!-- slip-print.inc -->
<script>
[% IF ( Koha.Preference('IntranetSlipPrinterJS') ) %]
    [% Koha.Preference('IntranetSlipPrinterJS') | $raw %]
[% ELSE %]
    $( window ).load(function() {
        window.print();
        setTimeout('window.close()', 1);
    });
[% END %]
</script>
<!-- / slip-print.inc -->
