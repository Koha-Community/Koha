<div id="toolbar">
	<script type="text/javascript">
	//<![CDATA[

	// prepare DOM for YUI Toolbar

	 $(document).ready(function() {
	 	$("#addchild").parent().remove();
		$("#addprofessional").parent().remove();
		$("#addorganisation").parent().remove();
	    $("#newmenuc").empty();
	    yuiToolbar();
	 });

	// YUI Toolbar Functions

	function yuiToolbar() {

		var newmenu = [
			{ text: "Adult Patron",  url: "/cgi-bin/koha/members/memberentry.pl?op=add&amp;category_type=A" },
			{ text: "Child Patron",  url: "/cgi-bin/koha/members/memberentry.pl?op=add&amp;category_type=C" },
			{ text: "Professional Patron",  url: "/cgi-bin/koha/members/memberentry.pl?op=add&amp;category_type=P" },
			{ text: "Organisation",  url: "/cgi-bin/koha/members/memberentry.pl?op=add&amp;category_type=I" },
		] 
	
	    new YAHOO.widget.Button({
	        type: "menu",
	        label: "New",
	        name: "newmenubutton",
	        menu: newmenu,
	        container: "newmenuc"
	    });
	
	}

	//]]>
	</script>
	<ul class="toolbar">
	<li id="newmenuc"><a id="addadult" href="/cgi-bin/koha/members/memberentry.pl?op=add&amp;category_type=A">Adulte</a></li>
<li><a id="addchild" href="/cgi-bin/koha/members/memberentry.pl?op=add&amp;category_type=C">Enfant</a></li>
<li><a id="addprofessional" href="/cgi-bin/koha/members/memberentry.pl?op=add&amp;category_type=P">Professionnel</a></li>
<li><a id="addorganisation" href="/cgi-bin/koha/members/memberentry.pl?op=add&amp;category_type=I">Collectivité</a></li>
</ul></div>
