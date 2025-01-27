[% USE raw %]
[% PROCESS 'i18n.inc' %]
[% SET footerjs = 1 %]
[% INCLUDE 'doc-head-open.inc' %]
[% IF ( ! method ) %]
    [% method = 'tool'; %]
[% END %]
<title
    >[% FILTER collapse %]
        [% IF ( plugin_title ) %]
            [% plugin_title | html %]
            &rsaquo;
        [% END %]
        [% t("Plugins") | html %]
        &rsaquo;
        [% IF ( method == 'tool' ) %]
            [% t("Tools") | html %]
        [% ELSE %]
            [% t("Administration") | html %]
        [% END %]
        &rsaquo; [% t("Koha") | html %]
    [% END %]</title
>
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
            [% IF ( plugin_title ) %][% plugin_title | html %][% ELSE %]<span>Plugin</span>[% END %]
        [% END %]
    [% END #/ WRAPPER breadcrumbs %]
[% END #/ WRAPPER sub-header.inc %]

<div class="main container-fluid">
    <div class="row">
        <div class="col-md-10 order-md-2 order-sm-1">
            <main> [% content | $raw %] </main>
        </div>
        <!-- /.col-md-10.order-md-2 -->

        <div class="col-md-2 order-sm-2 order-md-1">
            <aside>
                [% IF ( method == 'tool' ) %]
                    [% INCLUDE 'tools-menu.inc' %]
                [% ELSE %]
                    [% INCLUDE 'admin-menu.inc' %]
                [% END %]
            </aside>
        </div>
        <!-- /.col-md-2.order-md-1 -->
    </div>
    <!-- /.row -->

    [% INCLUDE 'intranet-bottom.inc' %]
</div>
