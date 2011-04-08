<div id="toolbar"><script type="text/javascript">
	//<![CDATA[

	// prepare DOM for YUI Toolbar
	 $(document).ready(function() {
            $("#periods_menuc").empty();
            $("#budgets_menuc").empty();
            $("#newrootbudgetc").empty();

// IF THERE IS NO BUDGETS DEFINED YET, THEN DISPLAY PERIOD BUTTON *ONLY*
<!-- TMPL_UNLESS NAME="period_button_only" -->
            $("#planning_menuc").empty();
<!-- /TMPL_UNLESS  -->

	    yuiToolbar();
	 });

	// YUI Toolbar Functions

	function yuiToolbar() {
<!-- TMPL_IF NAME="budget_period_id" -->
		                var budgets_menu = [
						{ text: _("New budget"), url: "/cgi-bin/koha/admin/aqbudgetperiods.pl?op=add_form" },
                        { text: _("New fund for") + " '<!-- TMPL_VAR NAME="budget_period_description" -->'", url: "/cgi-bin/koha/admin/aqbudgets.pl?op=add_form&budget_period_id=<!-- TMPL_VAR NAME="budget_period_id" -->"
                           <!-- TMPL_IF NAME="budget_period_locked" -->,  disabled:true<!-- /TMPL_IF  -->
                           <!-- TMPL_UNLESS NAME="CAN_user_acquisition_budget_add_del" -->,  disabled:true <!-- /TMPL_UNLESS  -->
                          }
                ]
		<!-- TMPL_ELSE -->
        var newrootbudgetButton = new YAHOO.widget.Button("newrootbudget");
		<!-- /TMPL_IF -->

        <!-- TMPL_IF NAME="budget_period_id" -->
                var periods_menu = [
                        { text: _("Edit budget") + " '<!-- TMPL_VAR NAME="budget_period_description" -->'", url: "/cgi-bin/koha/admin/aqbudgetperiods.pl?op=add_form&budget_period_id=<!-- TMPL_VAR NAME="budget_period_id" -->" },
                        <!-- { text: _("Duplicate budget") + " '<!-- TMPL_VAR NAME="budget_period_description" -->'" } -->
                ]
        <!-- /TMPL_IF -->

// IF THERE IS NO BUDGETS DEFINED YET, THEN DISPLAY PERIOD BUTTON *ONLY*
<!-- TMPL_IF NAME="budget_period_id" -->

               var planning_menu = [

                        { text: _("Plan by Months"),
                            url: "/cgi-bin/koha/admin/aqplan.pl?budget_period_id=<!-- TMPL_VAR NAME="budget_period_id" -->&authcat=MONTHS"
                            <!-- TMPL_UNLESS NAME="CAN_user_acquisition_planning_manage" -->,  id:'disabled' <!-- /TMPL_UNLESS  -->
                        },

                        { text: _("Plan by Branches"),
                            url: "/cgi-bin/koha/admin/aqplan.pl?budget_period_id=<!-- TMPL_VAR NAME="budget_period_id" -->&authcat=BRANCHES"
                            <!-- TMPL_UNLESS NAME="CAN_user_acquisition_planning_manage" -->,  id:'disabled' <!-- /TMPL_UNLESS  -->
                        },

                        { text: _("Plan by Item Types"),
                            url: "/cgi-bin/koha/admin/aqplan.pl?budget_period_id=<!-- TMPL_VAR NAME="budget_period_id" -->&authcat=ITEMTYPES"
                            <!-- TMPL_UNLESS NAME="CAN_user_acquisition_planning_manage" -->,  id:'disabled' <!-- /TMPL_UNLESS  -->
                        },
           <!-- TMPL_IF NAME="authcat" -->
                <!-- TMPL_LOOP NAME="auth_cats_loop" -->
                        { text: _("Plan by <!-- TMPL_VAR NAME="authcat" -->    "),
                            url: "/cgi-bin/koha/admin/aqplan.pl?budget_period_id=<!-- TMPL_VAR NAME="budget_period_id" -->&authcat=<!-- TMPL_VAR NAME="authcat" -->"
                            <!-- TMPL_UNLESS NAME="CAN_user_acquisition_planning_manage" -->,  id:'disabled' <!-- /TMPL_UNLESS  -->
                        },
                <!-- /TMPL_LOOP -->
           <!-- /TMPL_IF -->
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

<!-- /TMPL_IF  -->

// IF THERE IS NO BUDGETS DEFINED YET, THEN DISPLAY PERIOD BUTTON *ONLY*
<!-- TMPL_UNLESS NAME="period_button_only" -->


<!-- /TMPL_UNLESS -->

	} //yui-toolbar...

	//]]>
</script>
	<ul class="toolbar">
        <!-- TMPL_UNLESS NAME="budget_period_id" --><li><a id="newrootbudget" href="/cgi-bin/koha/admin/aqbudgetperiods.pl?op=add_form">New Budget</a></li><!-- /TMPL_UNLESS -->
		<!-- TMPL_UNLESS NAME="period_button_only" --><li id="budgets_menuc"><a id="budgets_menu" href="/cgi-bin/koha/cataloguing/addbiblio.pl">New</a></li><!-- /TMPL_UNLESS -->
        <li id="periods_menuc"><a id="periods_menu" href="/cgi-bin/koha/admin/aqbudgetperiods.pl?op=add_form">Budgets</a></li>
		<!-- TMPL_UNLESS NAME="period_button_only" --><li id="planning_menuc"><a id="planning_menu" href="/cgi-bin/koha/admin/aqplan.pl?budget_period_id=<!-- TMPL_VAR NAME="budget_period_id" -->">Budget planning</a></li>
	<!-- /TMPL_UNLESS -->
	</ul>
</div>
