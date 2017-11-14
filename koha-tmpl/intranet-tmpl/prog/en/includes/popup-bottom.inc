    [% IF ( footerjs ) %]
        [% INCLUDE js_includes.inc %]
        [% jsinclude # Parse the page template's JavaScript block if necessary %]
    [% END %]
</body>
</html>
