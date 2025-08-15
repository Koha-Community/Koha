[% FILTER collapse %]
    <span class="dateformat">
        [% IF ( dateformat == "us" ) %]
            [% t("(MM/DD/YYYY)") | html %]
        [% ELSIF ( dateformat == "metric" ) %]
            [% t("(DD/MM/YYYY)") | html %]
        [% ELSE %]
            [% t("(YYYY-MM-DD)") | html %]
        [% END %]
    </span>
[% END %]
