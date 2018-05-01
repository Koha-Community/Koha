<script>
[% IF ( Koha.Preference('IntranetSlipPrinterJS') ) %]
    [% Koha.Preference('IntranetSlipPrinterJS') %]
[% ELSE %]
    $( window ).load(function() {
        window.print();
        setTimeout('window.close()', 1);
    });
[% END %]
</script>
