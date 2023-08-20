[% USE raw %]
[% SET footerjs = 1 %]
[% INCLUDE 'doc-head-open.inc' %]
[% IF ( ! method ) %]
[% method = 'tool'; %]
[% END %]
<title>
    [% IF ( plugin_title ) %][% plugin_title | html %] &rsaquo; [% END %]
    Plugins &rsaquo;
    [% IF ( method == 'tool' ) %]
        Tools
    [% ELSE %]
        Administration
    [% END %]
    &rsaquo; Koha
 </title>
[% INCLUDE 'doc-head-close.inc' %]
</head>

<body id="plugins_run_tool" class="plugins">
[% WRAPPER 'header.inc' %]
    [% INCLUDE 'prefs-admin-search.inc' %]
[% END %]

[% WRAPPER 'sub-header.inc' %]
    [% WRAPPER breadcrumbs %]
        [% WRAPPER breadcrumb_item %]
            [% IF ( method == 'tool' ) %]
                <a href="/cgi-bin/koha/tools/tools-home.pl">Tools</a>
            [% ELSE %]
                <a href="/cgi-bin/koha/admin/admin-home.pl">Administration</a>
            [% END %]
        [% END %]
        [% WRAPPER breadcrumb_item %]
            <a href="/cgi-bin/koha/plugins/plugins-home.pl">Plugins</a>
        [% END %]
        [% WRAPPER breadcrumb_item bc_active= 1 %]
            <span>[% IF ( plugin_title ) %][% plugin_title | html %][% ELSE %]<span>Plugin</span>[% END %]</span>
        [% END %]
    [% END #/ WRAPPER breadcrumbs %]
[% END #/ WRAPPER sub-header.inc %]

<div class="main container-fluid">
    <div class="row">
        <div class="col-sm-10 col-sm-push-2">
            <main>
            [% content | $raw %]
            </main>
        </div> <!-- /.col-sm-10.col-sm-push-2 -->

        <div class="col-sm-2 col-sm-pull-10">
            <aside>
                [% IF ( method == 'tool' ) %]
                    [% INCLUDE 'tools-menu.inc' %]
                [% ELSE %]
                    [% INCLUDE 'admin-menu.inc' %]
                [% END %]
            </aside>
        </div> <!-- /.col-sm-2.col-sm-pull-10 -->
     </div> <!-- /.row -->

[% INCLUDE 'intranet-bottom.inc' %]
