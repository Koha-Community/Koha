[% UNLESS ( no_add ) %]
<div id="toolbar">
	<script type="text/javascript">
	//<![CDATA[
	 $(document).ready(function() {
		$("#newmenuc").empty();
		$("#newsql").remove();
		yuiToolbar();
	 });

	// YUI Toolbar Functions
	function yuiToolbar() {
	[% IF ( CAN_user_reports_create_reports ) %]
		var newmenu = [
			{ text: _("Guided report"),  url: "/cgi-bin/koha/reports/guided_reports.pl?phase=Build%20new" },
			{ text: _("SQL report"),  url: "/cgi-bin/koha/reports/guided_reports.pl?phase=Create%20report%20from%20SQL" }
		]
	    new YAHOO.widget.Button({
	        type: "menu",
	        label: _("New"),
	        name: "newmenubutton",
	        menu: newmenu,
	        container: "newmenuc"
	    });
	    new YAHOO.widget.Button("editreport");[% END %]
	    new YAHOO.widget.Button("runreport");
	}
	//]]>
	</script>

	<ul class="toolbar">
		[% IF ( CAN_user_reports_create_reports ) %]<li id="newmenuc"><a href="/cgi-bin/koha/reports/guided_reports.pl?phase=Build%20new">New guided report</a> </li>[% END %]
		<li id="newsql"><a href="/cgi-bin/koha/reports/guided_reports.pl?phase=Create%20report%20from%20SQL">New SQL report</a> </li>
		[% IF ( showsql || execute || editsql || save_successful ) %]
			[% UNLESS ( errors ) %][%# Unless there are errors saving a report %]
				[% UNLESS ( editsql ) %][%# Do not show edit button on edit page %]
					[% IF ( CAN_user_reports_create_reports ) %]<li><a id="editreport" href="/cgi-bin/koha/reports/guided_reports.pl?reports=[% id %]&amp;phase=Edit%20SQL">Edit</a></li>[% END %]
				[% END %]
				<li><a id="runreport" href="/cgi-bin/koha/reports/guided_reports.pl?reports=[% id %]&amp;phase=Run%20this%20report">Run report</a></li>
			[% END %]
		[% END %]
	</ul>
</div>
[% END %]