[% USE raw %]
    [% IF ( footerjs ) %]
        [% INCLUDE js_includes.inc popup=1 %]
        [% jsinclude.raw # Parse the page template's JavaScript block if necessary %]
    [% END %]
</body>
</html>
