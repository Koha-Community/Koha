[% USE Koha %]
[% USE raw %]
<!-- z3950_search.inc -->
<script nonce="[% Koha.CSPNonce | $raw %]" data-tt-allowed="true">
    var interface = "[% interface | html %]";
    var theme = "[% theme | html %]";
    var total_pages = new Number("[% total_pages | html %]");
</script>
<!-- / z3950_search.inc -->
