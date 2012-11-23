[% BLOCK showhierarchy %]
    [% FOREACH tree IN trees %]
        [% PROCESS showtree tree = tree %]
    [% END %]
[% END %]
[% BLOCK showtree %]
    <ul class="hierarchy">
        [% FOREACH node IN tree %]
            <li id="hier[% node.authid %]" class="[% node.class %] authnode">
            [% IF ( node.current_value ) %]
                <span class='currentauth'>[% node.value | html %]</span>
            [% ELSE %]
                <a href="opac-authoritiesdetail.pl?authid=[% node.authid %]" title="Term">[% node.value | html %]</a>
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
        [% CASE %][% type %]
        [% END %][% END %]</span>
    [% END %]
[% END %]
[% BLOCK otherscript %]
    [% FOREACH heading IN headings %]
        [% IF heading.category == wantcategory %]
            [% IF heading.direction == 'ltr' %]
                <div class="heading otherscript [% heading.category %]">
                <span class="[% heading.category %]">[% heading.term %]</span>
                </div>
            [% ELSIF heading.direction == 'rtl' %]
                <div class="heading otherscript [% heading.category %] rtl">
                <span class="[% heading.category %]">[% heading.term %]</span>
                </div>
            [% END %]
        [% END %]
    [% END %]
[% END %]
[% BLOCK authheadingdisplay %]
    [% IF authid %]<a href="/cgi-bin/koha/opac-authoritiesdetail.pl?authid=[% authid %]">[% heading %]</a>
    [% ELSIF search %]<a href="/cgi-bin/koha/opac-authorities-home.pl?op=do_search&type=opac&operator=contains&marclist=mainentry&and_or=and&orderby=HeadingAsc&value=[% search %]">[% heading %]</a>
    [% ELSE %][% heading %]
    [% END %]
[% END %]
[% BLOCK language %]
  [% SWITCH lang %]
   [% CASE ['en', 'eng'] %]English
   [% CASE ['fr', 'fre'] %]French
   [% CASE ['it', 'ita'] %]Italian
   [% CASE ['de', 'ger', 'deu'] %]German
   [% CASE ['es', 'spa'] %]Spanish
   [% CASE %][% lang %]
  [% END %]
[% END %]
