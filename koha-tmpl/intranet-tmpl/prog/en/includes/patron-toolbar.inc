[% USE Categories %]
[% SET categories = Categories.all %]

[% UNLESS ( no_add ) %]
<div id="toolbar" class="btn-toolbar">
    <div class="btn-group">
        <button class="btn btn-small dropdown-toggle" data-toggle="dropdown"><i class="fa fa-plus"></i> New patron <span class="caret"></span></button>
            <ul class="dropdown-menu">
                [% FOREACH category IN categories %]<li><a href="/cgi-bin/koha/members/memberentry.pl?op=add&amp;categorycode=[% category.categorycode %]">[% category.description %]</a></li>[% END %]
            </ul>
    </div>
    [% IF CAN_user_tools_manage_patron_lists %]
        <a class="btn btn-small" href="/cgi-bin/koha/patron_lists/lists.pl"><i class="fa fa-edit"></i>Patron lists</a>
    [% END %]
</div>
[% END %]
