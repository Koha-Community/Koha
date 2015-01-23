[% BLOCK showhierarchy %]
    [% FOREACH tree IN trees %]
        [% PROCESS showtree tree = tree %]
    [% END %]
[% END %]

[% BLOCK showtree %]
    <ul class="hierarchy">
        [% FOREACH node IN tree %]
            <li id="hier[% node.authid | html %]" class="[% node.class | html %] authnode">
            [% IF ( node.current_value ) %]
                <span class="currentauth">[% node.value | html %]</span>
            [% ELSE %]
                <a href="opac-authoritiesdetail.pl?authid=[% node.authid | html %]" title="Term">[% node.value | html %]</a>
            [% END %]
            [% IF ( node.children && node.children.size > 0 ) %]
                [% PROCESS showtree tree = node.children %]
            [% END %]
            </li>
        [% END %]
    </ul>
[% END %]

[% BLOCK authtypelabel %]
    [% UNLESS ( type=='seefrom' || type=='seealso' || type=='' ) %]
        <span class="type">[% FILTER trim %][% SWITCH type %]
        [% CASE 'earlier' %]Earlier heading
        [% CASE 'later' %]Later heading
        [% CASE 'acronym' %]Acronym
        [% CASE 'musical' %]Musical composition
        [% CASE 'broader' %]Broader heading
        [% CASE 'narrower' %]Narrower heading
        [% CASE %][% type | html %]
        [% END %][% END %]</span>
    [% END %]
[% END %]

[% BLOCK otherscript %]
    [% FOREACH heading IN headings %]
        [% IF heading.category == wantcategory %]
            [% IF heading.direction == 'ltr' %]
                <div class="heading otherscript [% heading.category | html %]">
                <span class="[% heading.category | html %]">[% heading.term | html %]</span>
                </div>
            [% ELSIF heading.direction == 'rtl' %]
                <div class="heading otherscript [% heading.category | html %] rtl">
                <span class="[% heading.category | html %]">[% heading.term | html %]</span>
                </div>
            [% END %]
        [% END %]
    [% END %]
[% END %]

[% BLOCK authheadingdisplay %]
    [% IF authid %]<a href="/cgi-bin/koha/opac-authoritiesdetail.pl?authid=[% authid | html %]">[% heading | html %]</a>
    [% ELSIF search %]<a href="/cgi-bin/koha/opac-authorities-home.pl?op=do_search&amp;type=opac&amp;operator=contains&amp;marclist=mainentry&amp;and_or=and&amp;orderby=HeadingAsc&amp;value=[% search | html %]">[% heading | html %]</a>
    [% ELSE %][% heading | html %]
    [% END %]
[% END %]

[% BLOCK language %]
    [% SWITCH lang %]
        [% CASE ['en', 'eng'] %]English
        [% CASE ['fr', 'fre'] %]French
        [% CASE ['it', 'ita'] %]Italian
        [% CASE ['de', 'ger', 'deu'] %]German
        [% CASE ['es', 'spa'] %]Spanish
        [% CASE %][% lang | html %]
    [% END %]
[% END %]
