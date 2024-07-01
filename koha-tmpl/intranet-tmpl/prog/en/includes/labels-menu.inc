<div id="labels-menu" class="sidebar_menu">
    <ul>
        [% IF ( label_element_title == "Batches" ) %]
            <li><a class="current" href="/cgi-bin/koha/labels/label-manage.pl?label_element=batch">Label batches</a></li>
        [% ELSE -%]
            <li><a href="/cgi-bin/koha/labels/label-manage.pl?label_element=batch">Label batches</a></li>
        [% END %]

        [% IF ( label_element_title == "Layouts" ) %]
            <li><a class="current" href="/cgi-bin/koha/labels/label-manage.pl?label_element=layout">Label layouts</a></li>
        [% ELSE -%]
            <li><a href="/cgi-bin/koha/labels/label-manage.pl?label_element=layout">Label layouts</a></li>
        [% END %]

        [% IF ( label_element_title == "Templates" ) %]
            <li><a class="current" href="/cgi-bin/koha/labels/label-manage.pl?label_element=template">Label templates</a></li>
        [% ELSE -%]
            <li><a href="/cgi-bin/koha/labels/label-manage.pl?label_element=template">Label templates</a></li>
        [% END %]

        [% IF ( label_element_title == "Profiles" ) %]
            <li><a class="current" href="/cgi-bin/koha/labels/label-manage.pl?label_element=profile">Printer profiles</a></li>
        [% ELSE -%]
            <li><a href="/cgi-bin/koha/labels/label-manage.pl?label_element=profile">Printer profiles</a></li>
        [% END %]
    </ul>
</div>
<!-- /.sidebar_menu -->
