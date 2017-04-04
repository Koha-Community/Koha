[% INCLUDE 'blocking_errors.inc' %]
<div id="toolbar" class="btn-toolbar">
    [% IF ( budget_period_id ) %]
        <div class="btn-group">
            <button class="btn btn-default btn-sm dropdown-toggle" data-toggle="dropdown"><i class="fa fa-plus"></i> New <span class="caret"></span></button>
                <ul class="dropdown-menu">
                    <li><a href="/cgi-bin/koha/admin/aqbudgetperiods.pl?op=add_form">New budget</a></li>
                    [% IF ( budget_period_locked || !CAN_user_acquisition_budget_add_del ) %]
                        <li class="disabled">
                    [% ELSE %]
                        <li>
                    [% END %]
                    <a href="/cgi-bin/koha/admin/aqbudgets.pl?op=add_form&amp;budget_period_id=[% budget_period_id %]">New fund for [% budget_period_description %]</a></li>
                </ul>
        </div>

        <div class="btn-group">
            <button class="btn btn-default btn-sm dropdown-toggle" data-toggle="dropdown"><i class="fa fa-pencil"></i> Edit <span class="caret"></span></button>
                <ul class="dropdown-menu">
                    <li><a href="/cgi-bin/koha/admin/aqbudgetperiods.pl?op=add_form&amp;budget_period_id=[% budget_period_id %]">Edit budget [% budget_period_description %]</a></li>
                    <li><a href="/cgi-bin/koha/admin/aqbudgetperiods.pl?op=duplicate_form&amp;budget_period_id=[% budget_period_id %]">Duplicate budget [% budget_period_description %]</a></li>
                </ul>
        </div>

        <div class="btn-group">
            <button class="btn btn-default btn-sm dropdown-toggle" data-toggle="dropdown"><i class="fa fa-pencil"></i> Planning <span class="caret"></span></button>
                <ul class="dropdown-menu">
                    [% IF ( CAN_user_acquisition_planning_manage ) %]
                    <li>
                    [% ELSE %]
                    <li class="disabled">
                    [% END %]
                    <a href="/cgi-bin/koha/admin/aqplan.pl?budget_period_id=[% budget_period_id %]&amp;authcat=MONTHS">Plan by months</a></li>
                    [% IF ( CAN_user_acquisition_planning_manage ) %]
                    <li>
                    [% ELSE %]
                    <li class="disabled">
                    [% END %]
                    <a href="/cgi-bin/koha/admin/aqplan.pl?budget_period_id=[% budget_period_id %]&amp;authcat=BRANCHES">Plan by libraries</a></li>
                    [% IF ( CAN_user_acquisition_planning_manage ) %]
                    <li>
                    [% ELSE %]
                    <li class="disabled">
                    [% END %]
                    <a href="/cgi-bin/koha/admin/aqplan.pl?budget_period_id=[% budget_period_id %]&amp;authcat=ITEMTYPES">Plan by item types</a></li>
                    [% FOREACH auth_cats_loo IN auth_cats_loop %]
                        [% IF ( CAN_user_acquisition_planning_manage ) %]
                        <li>
                        [% ELSE %]
                        <li class="disabled">
                        [% END %]
                        <a href="/cgi-bin/koha/admin/aqplan.pl?budget_period_id=[% budget_period_id %]&amp;authcat=[% auth_cats_loo %]">Plan by [% auth_cats_loo %]</a>
                        </li>
                    [% END %]
                </ul>
        </div>

    [% ELSE %]
        <div class="btn-group"><a class="btn btn-default btn-sm" id="newrootbudget" href="/cgi-bin/koha/admin/aqbudgetperiods.pl?op=add_form"><i class="fa fa-plus"></i> New budget</a></div>
    [% END %]

</div>
