[% INCLUDE 'blocking_errors.inc' %]
[% USE Categories %]
[% USE Koha %]
[% SET categories = Categories.all %]

[% UNLESS ( no_add ) %]
<div id="toolbar" class="btn-toolbar">
    <div class="btn-group">
        <button class="btn btn-default btn-sm dropdown-toggle" data-toggle="dropdown"><i class="fa fa-plus"></i> New patron <span class="caret"></span></button>
            <ul class="dropdown-menu">
                [% FOREACH category IN categories %]<li><a href="/cgi-bin/koha/members/memberentry.pl?op=add&amp;categorycode=[% category.categorycode %]">[% category.description |html %]</a></li>[% END %]
            </ul>
    </div>
    [% IF Koha.Preference('PatronQuickAddFields') || Koha.Preference('BorrowerMandatoryField') %]
    <div class="btn-group">
        <button class="btn btn-default btn-sm dropdown-toggle" data-toggle="dropdown"><i class="fa fa-plus"></i> Quick add new patron <span class="caret"></span></button>
            <ul class="dropdown-menu">
                [% FOREACH category IN categories %]<li><a href="/cgi-bin/koha/members/memberentry.pl?op=add&amp;categorycode=[% category.categorycode %]&amp;quickadd=true">[% category.description |html %]</a></li>[% END %]
            </ul>
    </div>
    [% END %]
    [% IF CAN_user_tools_manage_patron_lists %]
        <a class="btn btn-default btn-sm" href="/cgi-bin/koha/patron_lists/lists.pl"><i class="fa fa-edit"></i> Patron lists</a>
    [% END %]

</div>
[% END %]
