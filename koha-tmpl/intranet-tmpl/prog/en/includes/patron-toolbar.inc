<div id="toolbar">
	<script type="text/javascript">
	//<![CDATA[

	// prepare DOM for YUI Toolbar

	 $(document).ready(function() {
<!--TMPL_IF Name="AddPatronLists_categorycode"-->
<!--TMPL_ELSE-->
	 	$("#addchild").parent().remove();
		$("#addprofessional").parent().remove();
		$("#addorganisation").parent().remove();
		$("#addstaff").parent().remove();
		$("#addstatistical").parent().remove();
<!--/TMPL_IF-->
	    $("#newmenuc").empty();
	    yuiToolbar();
	 });

	// YUI Toolbar Functions

	function yuiToolbar() {

		var newmenu = [
<!--TMPL_IF Name="AddPatronLists_categorycode"-->
<!--TMPL_LOOP Name="categories"-->{ text: "<!--TMPL_VAR Name="description"-->",  url: "/cgi-bin/koha/members/memberentry.pl?op=add&amp;categorycode=<!--TMPL_VAR Name="categorycode"-->" },<!--/TMPL_LOOP-->
<!--TMPL_ELSE-->
			{ text: _("Adult Patron"),  url: "/cgi-bin/koha/members/memberentry.pl?op=add&amp;category_type=A" },
			{ text: _("Child Patron"),  url: "/cgi-bin/koha/members/memberentry.pl?op=add&amp;category_type=C" },
			{ text: _("Professional Patron"),  url: "/cgi-bin/koha/members/memberentry.pl?op=add&amp;category_type=P" },
			{ text: _("Organisation"),  url: "/cgi-bin/koha/members/memberentry.pl?op=add&amp;category_type=I" },
			{ text: _("Staff"),  url: "/cgi-bin/koha/members/memberentry.pl?op=add&amp;category_type=S" },
			{ text: _("Statistical"),  url: "/cgi-bin/koha/members/memberentry.pl?op=add&amp;category_type=X" },
<!--/TMPL_IF-->
		] 
	
	    new YAHOO.widget.Button({
	        type: "menu",
	        label: _("New"),
	        name: "newmenubutton",
	        menu: newmenu,
	        container: "newmenuc"
	    });
	
	}

	//]]>
	</script>
	<ul class="toolbar">
	<li id="newmenuc"></li>
</ul>
</div>
