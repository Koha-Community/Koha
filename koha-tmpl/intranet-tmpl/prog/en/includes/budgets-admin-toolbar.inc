<div id="toolbar"><script type="text/javascript">
	//<![CDATA[

	// prepare DOM for YUI Toolbar
	 $(document).ready(function() {
            $("#periods_menuc").empty();
            $("#budgets_menuc").empty();
            $("#newrootbudgetc").empty();

// IF THERE IS NO BUDGETS DEFINED YET, THEN DISPLAY PERIOD BUTTON *ONLY*
[% UNLESS ( period_button_only ) %]
            $("#planning_menuc").empty();
[% END %]

	    yuiToolbar();
	 });

	// YUI Toolbar Functions

	function yuiToolbar() {
[% IF ( budget_period_id ) %]
		                var budgets_menu = [
						{ text: _("New budget"), url: "/cgi-bin/koha/admin/aqbudgetperiods.pl?op=add_form" },
                        { text: _("New fund for") + " '[% budget_period_description %]'", url: "/cgi-bin/koha/admin/aqbudgets.pl?op=add_form&budget_period_id=[% budget_period_id %]"
                           [% IF ( budget_period_locked ) %],  disabled:true[% END %]
                           [% UNLESS ( CAN_user_acquisition_budget_add_del ) %],  disabled:true [% END %]
                          }
                ]
		[% ELSE %]
        var newrootbudgetButton = new YAHOO.widget.Button("newrootbudget");
		[% END %]

        [% IF ( budget_period_id ) %]
                var periods_menu = [
                        { text: _("Edit budget") + " '[% budget_period_description %]'", url: "/cgi-bin/koha/admin/aqbudgetperiods.pl?op=add_form&budget_period_id=[% budget_period_id %]" },
                        { text: _("Duplicate budget") + " '[% budget_period_description %]'", url: "/cgi-bin/koha/admin/aqbudgetperiods.pl?op=duplicate_form&budget_period_id=[% budget_period_id %]" },
                ]
        [% END %]

// IF THERE IS NO BUDGETS DEFINED YET, THEN DISPLAY PERIOD BUTTON *ONLY*
[% IF ( budget_period_id ) %]

               var planning_menu = [

                        { text: _("Plan by months"),
                            url: "/cgi-bin/koha/admin/aqplan.pl?budget_period_id=[% budget_period_id %]&authcat=MONTHS"
                            [% UNLESS ( CAN_user_acquisition_planning_manage ) %],  id:'disabled' [% END %]
                        },

                        { text: _("Plan by libraries"),
                            url: "/cgi-bin/koha/admin/aqplan.pl?budget_period_id=[% budget_period_id %]&authcat=BRANCHES"
                            [% UNLESS ( CAN_user_acquisition_planning_manage ) %],  id:'disabled' [% END %]
                        },

                        { text: _("Plan by item types"),
                            url: "/cgi-bin/koha/admin/aqplan.pl?budget_period_id=[% budget_period_id %]&authcat=ITEMTYPES"
                            [% UNLESS ( CAN_user_acquisition_planning_manage ) %],  id:'disabled' [% END %]
                        },
           [% IF ( authcat ) %]
                [% FOREACH auth_cats_loo IN auth_cats_loop %]
                        { text: _("Plan by [% auth_cats_loo.authcat %]    "),
                            url: "/cgi-bin/koha/admin/aqplan.pl?budget_period_id=[% auth_cats_loo.budget_period_id %]&authcat=[% auth_cats_loo.authcat %]"
                            [% UNLESS ( CAN_user_acquisition_planning_manage ) %],  id:'disabled' [% END %]
                        },
                [% END %]
           [% END %]
                ]

	            new YAHOO.widget.Button({
                type: "menu",
                label: _("Edit"),
                name: "periods_button",
                menu: periods_menu,
                container: "periods_menuc"
            });

            new YAHOO.widget.Button({
                type: "menu",
                label: _("New"),
                name: "budgets_button",
                menu: budgets_menu,
                container: "budgets_menuc"
            });

            new YAHOO.widget.Button({
                type: "menu",
                label: _("Planning"),
                name: "planning_button",
                menu: planning_menu,
                container: "planning_menuc"
            });

[% END %]

// IF THERE IS NO BUDGETS DEFINED YET, THEN DISPLAY PERIOD BUTTON *ONLY*
[% UNLESS ( period_button_only ) %]


[% END %]

	} //yui-toolbar...

	//]]>
</script>
	<ul class="toolbar">
        [% UNLESS ( budget_period_id ) %]<li><a id="newrootbudget" href="/cgi-bin/koha/admin/aqbudgetperiods.pl?op=add_form">New budget</a></li>[% END %]
		[% UNLESS ( period_button_only ) %]<li id="budgets_menuc"><a id="budgets_menu" href="/cgi-bin/koha/cataloguing/addbiblio.pl">New</a></li>[% END %]
        <li id="periods_menuc"><a id="periods_menu" href="/cgi-bin/koha/admin/aqbudgetperiods.pl?op=add_form">Budgets</a></li>
		[% UNLESS ( period_button_only ) %]<li id="planning_menuc"><a id="planning_menu" href="/cgi-bin/koha/admin/aqplan.pl?budget_period_id=[% budget_period_id %]">Budget planning</a></li>
	[% END %]
	</ul>
</div>
