[%~ USE Koha ~%]
[%~ USE raw ~%]
[%~ BLOCK 'display-library-address' ~%]
    [%~ SET line_break = "<br/>" ~%]
    [%~ IF no_line_break %][% SET line_break = " " %][% END ~%]
    [%~ IF Koha.Preference( 'AddressFormat' ) == "us" ~%]
        [%~ PROCESS 'display-library-address-us' ~%]
    [%~ ELSE ~%]
        [%~ PROCESS 'display-library-address-de-fr' ~%]
    [%~ END ~%]
[%~ END ~%]

[%~ BLOCK 'display-library-address-us' ~%]
    [%~ IF ( library.branchaddress1 or library.branchaddress2 ) ~%]
        <span property="streetAddress">
            [%~ IF ( library.branchaddress1 ) ~%]
                <div class="branchaddress1"> [% library.branchaddress1 | html %] </div>
            [%~ END ~%]
            [%~ IF ( library.branchaddress2 ) ~%]
                <div class="branchaddress2"> [%~ library.branchaddress2 |html ~%] </div>
            [%~ END ~%]
            [%~ IF ( library.branchaddress3 ) ~%]
                <span class="branchaddress3"> [%~ library.branchaddress3 | html ~%] </span>
                [% line_break | $raw %]
            [%~ END ~%]
        </span>
    [%~ END ~%]
    [%~ IF ( library.branchcity ) ~%]
        <div class="branchcity">
            <span property="addressLocality">[%~ library.branchcity |html ~%]</span>
            [%~ IF ( library.branchstate ) %]<span property="addressRegion">, [% library.branchstate |html ~%]</span>[%~ END ~%]
            [%~ IF ( library.branchzip ) %]
                <span property="postalCode"> [%~ library.branchzip |html ~%] </span>
            [%~ END ~%]
            [%~ IF ( library.branchcountry ) %]
                <div property="addressCountry"> [% library.branchcountry |html ~%] </div>
            [%~ END ~%]
        </div>
    [%~ END ~%]
[%~ END ~%]

[%~ BLOCK 'display-library-address-de-fr' ~%]
    [%~ IF ( library.branchaddress1 or library.branchaddress2 ) ~%]
        <span property="streetAddress">
            [%~ IF ( library.branchaddress1 ) ~%]
                <span class="branchaddress1"> [%~ library.branchaddress1 | html ~%] </span>
                [% line_break | $raw %]
            [%~ END ~%]
            [%~ IF ( library.branchaddress2 ) ~%]
                <span class="branchaddress2"> [%~ library.branchaddress2 | html ~%] </span>
                [% line_break | $raw %]
            [%~ END ~%]
            [%~ IF ( library.branchaddress3 ) ~%]
                <span class="branchaddress3"> [%~ library.branchaddress3 | html ~%] </span>
                [% line_break | $raw %]
            [%~ END ~%]
        </span>
    [%~ END ~%]
    [%~ IF ( library.branchcity ) ~%]
        <span class="branchcity">
            [%~ IF ( library.branchzip ) ~%]<span property="postalCode">[%~ library.branchzip | html %]</span>[% END ~%]<span property="addressLocality">[%~ library.branchcity | html ~%]</span
            >[%~ IF ( library.branchstate ) ~%][% line_break | $raw %]<span property="addressRegion">[%~ library.branchstate | html ~%]</span>[%~ END ~%]
            [%~ IF ( library.branchcountry ) ~%][% line_break | $raw %]<span property="addressCountry">[%~ library.branchcountry | html ~%]</span>[%~ END ~%]
        </span>
    [%~ END ~%]
[%~ END ~%]
