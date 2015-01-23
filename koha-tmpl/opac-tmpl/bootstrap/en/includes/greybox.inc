[% USE raw %]
[% USE Asset %]
<script>
    var GB_ROOT_DIR = "[% interface | html %]/[% theme | html %]/lib/greybox/";
</script>
[% Asset.js("lib/greybox/AJS.js") | $raw %]
[% Asset.js("lib/greybox/AJS_fx.js") | $raw %]
[% Asset.js("lib/greybox/gb_scripts.js") | $raw %]
[% Asset.css("lib/greybox/gb_styles.css") | $raw %]
