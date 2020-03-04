[% IF renew_results && renew_results.size > 0 %]
    <div class="alert">
        The fines on the following items were paid off, renewal results are displayed below:
        [% FOREACH result IN renew_results %]
            [% IF result.success %]
                <p>[% INCLUDE 'biblio-title.inc' biblio=result.item.biblio %] ( [% result.item.barcode | html %] ): Renewed - due [% result.info | html %]</p>
            [% ELSE %]
                <p>[% INCLUDE 'biblio-title.inc' biblio=result.item.biblio %] ( [% result.item.barcode | html %] ): Not renewed - [% INCLUDE 'renew_strings.inc' error=result.info %]</p>
            [% END %]
        [% END %]
    </div>
[% END %]
