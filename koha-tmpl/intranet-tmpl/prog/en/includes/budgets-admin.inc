<div id="toolbar"><script type="text/javascript">
	//<![CDATA[

	// prepare DOM for YUI Toolbar
	 $(document).ready(function() {
            $("#periods_menuc").empty();
            $("#budgets_menuc").empty();



// IF THERE IS NO BUDGETS DEFINED YET, THEN DISPLAY PERIOD BUTTON *ONLY*
<!-- TMPL_UNLESS NAME="period_button_only" -->
            $("#planning_menuc").empty();
<!-- /TMPL_UNLESS  -->


	    yuiToolbar();
	 });

	// YUI Toolbar Functions

	function yuiToolbar() {
                var periods_menu = [
                        { text: _("Display all root budgets"), url: "/cgi-bin/koha/admin/aqbudgetperiods.pl" },
                        { text: _("New root budget"), url: "/cgi-bin/koha/admin/aqbudgetperiods.pl?op=add_form" },
                        <!-- TMPL_IF NAME="budget_period_id" -->
                        { text: _("Edit root budget '<!-- TMPL_VAR NAME="budget_period_description" -->'"), url: "/cgi-bin/koha/admin/aqbudgetperiods.pl?op=add_form&budget_period_id=<!-- TMPL_VAR NAME="budget_period_id" -->" },
                        <!-- /TMPL_IF -->
                        { text: _("Duplicate root budget"),  },
                ]

// IF THERE IS NO BUDGETS DEFINED YET, THEN DISPLAY PERIOD BUTTON *ONLY*
<!-- TMPL_IF NAME="budget_period_id" -->

                var budgets_menu = [
                        { text: _("Display budgets"), url: "/cgi-bin/koha/admin/aqbudgets.pl?budget_period_id=<!-- TMPL_VAR NAME="budget_period_id" -->" },                        
                        { text: _("New budget for '<!-- TMPL_VAR NAME="budget_period_description" -->'"), url: "/cgi-bin/koha/admin/aqbudgets.pl?op=add_form&budget_period_id=<!-- TMPL_VAR NAME="budget_period_id" -->"
                           <!-- TMPL_IF NAME="budget_period_locked" -->,  disabled:true<!-- /TMPL_IF  -->
                           <!-- TMPL_UNLESS NAME="CAN_user_acquisition_budget_add_del" -->,  disabled:true <!-- /TMPL_UNLESS  -->
                          },
                ]

                var planning_menu = [

                        { text: _("Plan by MONTHS"), 
                            url: "/cgi-bin/koha/admin/aqplan.pl?budget_period_id=<!-- TMPL_VAR NAME="budget_period_id" -->&authcat=MONTHS"
                            <!-- TMPL_UNLESS NAME="CAN_user_acquisition_planning_manage" -->,  id:'disabled' <!-- /TMPL_UNLESS  -->
                        },

                        { text: _("Plan by BRANCHES"), 
                            url: "/cgi-bin/koha/admin/aqplan.pl?budget_period_id=<!-- TMPL_VAR NAME="budget_period_id" -->&authcat=BRANCHES" 
                            <!-- TMPL_UNLESS NAME="CAN_user_acquisition_planning_manage" -->,  id:'disabled' <!-- /TMPL_UNLESS  -->
                        },

                        { text: _("Plan by ITEMTYPES"), 
                            url: "/cgi-bin/koha/admin/aqplan.pl?budget_period_id=<!-- TMPL_VAR NAME="budget_period_id" -->&authcat=ITEMTYPES"  
                            <!-- TMPL_UNLESS NAME="CAN_user_acquisition_planning_manage" -->,  id:'disabled' <!-- /TMPL_UNLESS  -->
                        },

                <!-- TMPL_LOOP NAME="auth_cats_loop" -->
                        { text: _("Plan by <!-- TMPL_VAR NAME="authcat" -->    "), 
                            url: "/cgi-bin/koha/admin/aqplan.pl?budget_period_id=<!-- TMPL_VAR NAME="budget_period_id" -->&authcat=<!-- TMPL_VAR NAME="authcat" -->"
                            <!-- TMPL_UNLESS NAME="CAN_user_acquisition_planning_manage" -->,  id:'disabled' <!-- /TMPL_UNLESS  -->
                        },

                <!-- /TMPL_LOOP -->

                ]



<!-- /TMPL_IF  -->

            new YAHOO.widget.Button({
                type: "menu",
                label: _("Root Budgets"),
                name: "periods_button",
                menu: periods_menu,
                container: "periods_menuc"
            });

// IF THERE IS NO BUDGETS DEFINED YET, THEN DISPLAY PERIOD BUTTON *ONLY*
<!-- TMPL_UNLESS NAME="period_button_only" -->

            new YAHOO.widget.Button({
                type: "menu",
                label: _("Budgets"),
                name: "budgets_button",
                menu: budgets_menu,
                container: "budgets_menuc"
            });


            new YAHOO.widget.Button({
                type: "menu",
                label: _("Budget planning"),
                name: "planning_button",
                menu: planning_menu,
                container: "planning_menuc"
            });

<!-- /TMPL_UNLESS -->







	} //yui-toolbar...

	//]]>
	</script>
	<ul class="toolbar">

  <li id="periods_menuc"><a id="periods_menu" href="/cgi-bin/koha/admin/aqbudgetperiods.pl?op=add_form">Root Budgets</a></li>


<!-- TMPL_UNLESS NAME="period_button_only" -->
  <li id="budgets_menuc"><a id="budgets_menu" href="/cgi-bin/koha/cataloguing/addbiblio.pl">Budgets</a></li>
  <li id="planning_menuc"><a id="planning_menu" href="/cgi-bin/koha/admin/aqplan.pl?budget_period_id=<!-- TMPL_VAR NAME="budget_period_id" -->">Budget planning</a></li>
<!-- /TMPL_UNLESS -->


</ul>
</div>
