[% UNLESS ( no_add ) %]
<div id="toolbar">
	<script type="text/javascript">
	//<![CDATA[

	// prepare DOM for YUI Toolbar

	 $(document).ready(function() {
[% IF ( AddPatronLists_categorycode ) %]
[% ELSE %]
	 	$("#addchild").parent().remove();
		$("#addprofessional").parent().remove();
		$("#addorganisation").parent().remove();
		$("#addstaff").parent().remove();
		$("#addstatistical").parent().remove();
[% END %]
	    $("#newmenuc").empty();
	    yuiToolbar();
	 });

	// YUI Toolbar Functions

	function yuiToolbar() {

		var newmenu = [
[% IF ( AddPatronLists_categorycode ) %]
[% FOREACH categorie IN categories %]
{ text: "[% categorie.description %]",  url: "/cgi-bin/koha/members/memberentry.pl?op=add&amp;categorycode=[% categorie.categorycode %]" },
[% END %]
[% ELSE %]
			{ text: _("Adult Patron"),  url: "/cgi-bin/koha/members/memberentry.pl?op=add&amp;category_type=A" },
			{ text: _("Child Patron"),  url: "/cgi-bin/koha/members/memberentry.pl?op=add&amp;category_type=C" },
			{ text: _("Professional Patron"),  url: "/cgi-bin/koha/members/memberentry.pl?op=add&amp;category_type=P" },
			{ text: _("Organization"),  url: "/cgi-bin/koha/members/memberentry.pl?op=add&amp;category_type=I" },
			{ text: _("Staff"),  url: "/cgi-bin/koha/members/memberentry.pl?op=add&amp;category_type=S" },
			{ text: _("Statistical"),  url: "/cgi-bin/koha/members/memberentry.pl?op=add&amp;category_type=X" },
[% END %]
		]

	    new YAHOO.widget.Button({
	        type: "menu",
	        label: _("New patron"),
	        name: "newmenubutton",
	        menu: newmenu,
	        container: "newmenuc"
	    });

	}

	//]]>
	</script>
	<ul class="toolbar">
	<li id="newmenuc">
		<form action="/cgi-bin/koha/members/memberentry.pl" method="get">
			<input type="hidden" name="op" value="add" />
			<label for="newcategorycode">New Patron: </label><select name="categorycode" id="newcategorycode">
			[% IF ( AddPatronLists_categorycode ) %]
				[% FOREACH categorie IN categories %]<option value="[% categorie.categorycode %]">[% categorie.description %]</option>[% END %]
			[% ELSE %]
				<option value="A">Adult Patron</option>
				<option value="C">Child Patron</option>
				<option value="P">Professional Patron</option>
				<option value="I">Organization</option>
				<option value="S">Staff</option>
				<option value="X">Statistical</option>
			[% END %]
			</select>
			<input type="submit" class="submit" value="Go" />
		</form>
	</li>
</ul>
</div>
[% END %]