[% USE raw %]

[% IF ( OpacNav ) %]
    [% PROCESS koha_news_block news => OpacNav %]
[% END %]

[% IF IsPatronPage %]
    <div id="usermenu">[% INCLUDE usermenu.inc %]</div>
[% END %]

[% IF ( OpacNavBottom ) %]
    [% PROCESS koha_news_block news => OpacNavBottom %]
[% END %]
