<script type="text/javascript">
    //<![CDATA[
    // prepare DOM for YUI Toolbar
     $(document).ready(function() {
        yuiToolbar();
     });
    // YUI Toolbar Functions
    function yuiToolbar() {
        new YAHOO.widget.Button("newlabel");
        new YAHOO.widget.Button("newtemplate");
        new YAHOO.widget.Button("newprofile");
        new YAHOO.widget.Button("newlabelbatch");
        new YAHOO.widget.Button("managelabel");
        new YAHOO.widget.Button("managetemplate");
        new YAHOO.widget.Button("manageprofile");
        new YAHOO.widget.Button("managelabelbatch");
    }
//]]>
</script>
<div id="toolbar">
    <ul class="toolbar">
        <li><a id="newlabel" href="/cgi-bin/koha/labels/label-edit-layout.pl">New Layout</a></li>
        <li><a id="newtemplate" href="/cgi-bin/koha/labels/label-create-template.pl?op=blank">New Template</a></li>
        <li><a id="newprofile" href="/cgi-bin/koha/labels/label-create-profile.pl?op=blank">New Profile</a></li>
        <li><a id="newlabelbatch" href="/cgi-bin/koha/labels/label-manager.pl?op=add_batch&amp;type=labels">New Batch</a></li>
    </ul>
</div>
<div id="toolbar">
    <ul class="toolbar">
        <li><a id="managelabel" href="/cgi-bin/koha/labels/label-manage.pl?label_element=layout">Manage Layouts</a></li>
        <li><a id="managetemplate" href="/cgi-bin/koha/labels/label-manage.pl?label_element=template">Manage Templates</a></li>
        <li><a id="manageprofile" href="/cgi-bin/koha/labels/label-manage.pl?label_element=profile">Manage Profiles</a></li>
        <li><a id="managelabelbatch" href="/cgi-bin/koha/labels/label-manage.pl?label_element=batch">Manage Batches</a></li>
    </ul>
</div>
