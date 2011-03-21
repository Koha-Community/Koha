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
        new YAHOO.widget.Button("newbatch");
    }
    //]]>
</script>
<div id="toolbar">
    <ul class="toolbar">
        <li><a id="newlabel" href="/cgi-bin/koha/labels/label-edit-layout.pl?op=new">New Layout</a></li>
        <li><a id="newtemplate" href="/cgi-bin/koha/labels/label-edit-template.pl?op=new">New Template</a></li>
        <li><a id="newprofile" href="/cgi-bin/koha/labels/label-edit-profile.pl?op=new">New Profile</a></li>
        <li><a id="newbatch" href="/cgi-bin/koha/labels/label-edit-batch.pl?op=new">New Batch</a></li>
    </ul>
</div>
