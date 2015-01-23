[% USE raw %]
<div id="opacnav">[% OpacNav | $raw %]</div>
[% IF IsPatronPage %]
    <div id="usermenu">[% INCLUDE usermenu.inc %]</div>
[% END %]
<div id="opacnavbottom">[% OpacNavBottom | $raw %]</div>
