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
                <a href="detail.pl?authid=[% node.authid %]" title="Term">[% node.value | html %]</a>
            [% END %]
            [% IF ( node.children && node.children.size > 0 ) %]
                [% PROCESS showtree tree = node.children %]
            [% END %]
            </li>
        [% END %]
    </ul>
[% END %]
