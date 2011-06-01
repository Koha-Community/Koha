<div id="toolbar">
<script type="text/javascript">
	//<![CDATA[

	// prepare DOM for YUI Toolbar

	 $(document).ready(function() {
	    $("#newmenuc").empty();
	    $("#delAuthc").empty();
	    yuiToolbar();
	 });

	// YUI Toolbar Functions

	function yuiToolbar() {   
	
		var newmenu = [
			[% FOREACH authtypesloo IN authtypesloop %]{ text: "[% authtypesloo.authtypetext %]", url: "/cgi-bin/koha/authorities/authorities.pl?authtypecode=[% authtypesloo.value %]"},
[% END %]
		]

	    new YAHOO.widget.Button({
	        type: "menu",
	        label: _("New Authority"),
	        name: "newmenubutton",
	        menu: newmenu,
	        container: "newmenuc"
	    });  
		
		var editButton = new YAHOO.widget.Button("editAuth");
		
		var delAuthButton = new YAHOO.widget.Button({
          id: "delAuth", 
          type: "button", 
          label: _("Delete"), 
          container: "delAuthc",
		  onclick: {fn: confirm_deletion }
      });
	}

	//]]>
	</script>
  <form name="f2" method="post" action="authorities.pl">	
  
[% IF ( authid ) %]  <a id="editAuth" href="authorities.pl?authid=[% authid %]">Edit</a>
    
    [% UNLESS ( count ) %]
    <span id="delAuthc"><a id="delAuth" href="javascript:confirm_deletion()">Delete</a></span>
    [% END %][% ELSE %]&nbsp;[% END %]
  
  <span id="newmenuc">
	<label for="add_authtypecode">New: </label>
        <select id="add_authtypecode" name="authtypecode">
[% FOREACH authtypesloo IN authtypesloop %]
  [% IF ( authtypesloo.selected ) %]
        <option value="[% authtypesloo.value %]" selected="selected">[% authtypesloo.authtypetext %]</option>
  [% ELSE %]
        <option value="[% authtypesloo.value %]">[% authtypesloo.authtypetext %]</option>
  [% END %]
[% END %]
        </select>
      <input type="submit" value="Add" class="button" />
  </span></form>
</div>
