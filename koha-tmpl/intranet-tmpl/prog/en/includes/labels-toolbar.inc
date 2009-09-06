<script type="text/javascript">
    //<![CDATA[
    // prepare DOM for YUI Toolbar
    $(document).ready(function() {
        $("#layoutsc").empty();
        $("#templatesc").empty();
        $("#profilesc").empty();
        $("#batches").empty();
        yuiToolbar();
     });

    // YUI Toolbar Functions
    function yuiToolbar() {
        var layouts = [
                {text: _("Manage Layouts"), url: "/cgi-bin/koha/labels/label-manage.pl?label_element=layout" },
                {text: _("New Layout"), url: "/cgi-bin/koha/labels/label-edit-layout.pl?op=new" }
        ];

        var templates = [
                {text: _("Manage Templates"), url: "/cgi-bin/koha/labels/label-manage.pl?label_element=template" },
                {text: _("New Template"), url: "/cgi-bin/koha/labels/label-edit-template.pl?op=new" }
        ];

        var profiles = [
                {text: _("Manage Profiles"), url: "/cgi-bin/koha/labels/label-manage.pl?label_element=profile" },
                {text: _("New Profile"), url: "/cgi-bin/koha/labels/label-edit-profile.pl?op=new" }
        ];

        var batches = [
                {text: _("Manage Batches"), url: "/cgi-bin/koha/labels/label-manage.pl?label_element=batch" },
                {text: _("New Batch"), url: "/cgi-bin/koha/labels/label-edit-batch.pl?op=new" }
        ];

        new YAHOO.widget.Button({
            type: "menu",
            label: _("Layouts"),
            name: "layouts",
            menu: layouts,
            container: "layoutsc"
        });

        new YAHOO.widget.Button({
            type: "menu",
            label: _("Templates"),
            name: "templates",
            menu: templates,
            container: "templatesc"
        });

        new YAHOO.widget.Button({
            type: "menu",
            label: _("Profiles"),
            name: "profiles",
            menu: profiles,
            container: "profilesc"
        });

        new YAHOO.widget.Button({
            type: "menu",
            label: _("Batches"),
            name: "batches",
            menu: batches,
            container: "batchesc"
        });
    }
//]]>
</script>
<div id="toolbar">
    <ul class="toolbar">
        <li id="layoutsc"><a id="layouts" href="#">Layouts</a></li>
        <li id="templatesc"><a id="templates" href="#">Templates</a></li>
        <li id="profilesc"><a id="profiles" href="#">Profiles</a></li>
        <li id="batchesc"><a id="batches" href="#">Batches</a></li>
    </ul>
</div>
