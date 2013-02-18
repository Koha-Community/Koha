[% UNLESS ( no_add ) %]
<div id="toolbar" class="btn-toolbar">
    <div class="btn-group">
        <button class="btn btn-small dropdown-toggle" data-toggle="dropdown"><i class="icon-plus"></i> New patron <span class="caret"></span></button>
            <ul class="dropdown-menu">
                [% IF ( AddPatronLists_categorycode ) %]
                    [% FOREACH categorie IN categories %]<li><a href="/cgi-bin/koha/members/memberentry.pl?op=add&amp;categorycode=[% categorie.categorycode %]">[% categorie.description %]</a></li>[% END %]
                [% ELSE %]
                    <li><a href="/cgi-bin/koha/members/memberentry.pl?op=add&amp;category_type=A">Adult patron</a></li>
                    <li><a href="/cgi-bin/koha/members/memberentry.pl?op=add&amp;category_type=C">Child patron</a></li>
                    <li><a href="/cgi-bin/koha/members/memberentry.pl?op=add&amp;category_type=P">Professional patron</a></li>
                    <li><a href="/cgi-bin/koha/members/memberentry.pl?op=add&amp;category_type=I">Organization</a></li>
                    <li><a href="/cgi-bin/koha/members/memberentry.pl?op=add&amp;category_type=S">Staff patron</a></li>
                    <li><a href="/cgi-bin/koha/members/memberentry.pl?op=add&amp;category_type=X">Statistical patron</a></li>
                [% END %]
            </ul>
    </div>
</div>
[% END %]