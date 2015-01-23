[% USE raw %]
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
