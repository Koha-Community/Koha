[% UNLESS ( no_add ) %]
<div id="toolbar" class="btn-toolbar">
    <div class="btn-group">
        <button class="btn btn-small dropdown-toggle" data-toggle="dropdown"><i class="icon-plus"></i> New patron <span class="caret"></span></button>
            <ul class="dropdown-menu">
                [% FOREACH categorie IN categories %]<li><a href="/cgi-bin/koha/members/memberentry.pl?op=add&amp;categorycode=[% categorie.categorycode %]">[% categorie.description %]</a></li>[% END %]
            </ul>
    </div>
</div>
[% END %]
