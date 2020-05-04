[% USE raw %]

[% IF ( OpacNav ) %]
    <div id="opacnav">
        [% PROCESS koha_news_block news => OpacNav %]
    </div>
[% END %]

[% IF IsPatronPage %]
    <div id="usermenu">[% INCLUDE usermenu.inc %]</div>
[% END %]

[% IF ( OpacNavBottom ) %]
    <div id="opacnavbottom">
        [% OpacNavBottom | $raw %]
    </div>
[% END %]
