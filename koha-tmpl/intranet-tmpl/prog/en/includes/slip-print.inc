<script type="text/javascript">
[% IF ( Koha.Preference('IntranetSlipPrinterJS') ) %]
    [% Koha.Preference('IntranetSlipPrinterJS') %]
[% ELSE %]
    function printThenClose() {
        window.print();
        setTimeout('window.close()', 1);
    }
[% END %]
</script>