[% USE raw %]
[% USE Asset %]
[% USE Koha %]
[% PROCESS 'i18n.inc' %]
[% SET footerjs = 1 %]
[% INCLUDE 'doc-head-open.inc' %]
[% IF ( ! method ) %]
    [% method = 'tool'; %]
[% END #/ method check %]
<title>
    [% FILTER collapse %]
        [% IF ( plugin_title ) %]
            [% plugin_title | html %]
            &rsaquo;
        [% END %]
        [% t("Plugins") | html %]
        &rsaquo;
        [% IF ( method == 'tool' ) %]
            [% t("Tools") | html %]
        [% ELSIF (method == 'report' ) %]
            [% t("Reports") | html %]
        [% ELSE %]
            [% t("Administration") | html %]
        [% END %]
        &rsaquo; [% t("Koha") | html %]
    [% END %]
</title>
[% INCLUDE 'doc-head-close.inc' %]
</head>

<body id="plugins_run_tool" class="plugins">
[% WRAPPER 'header.inc' %]
    [% INCLUDE 'prefs-admin-search.inc' %]
[% END #/ WRAPPER header.inc %]

[% WRAPPER 'sub-header.inc' %]
    [% WRAPPER breadcrumbs %]
        [% WRAPPER breadcrumb_item %]
            [% IF ( method == 'tool' ) %]
                <a href="/cgi-bin/koha/tools/tools-home.pl">Tools</a>
            [% ELSIF (method == 'report' ) %]
                <a href="/cgi-bin/koha/reports/reports-home.pl">Reports</a>
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
[% IF ( method == 'tool' ) %]
    [% SET 'dynamicaside' = 'tools-menu' %]
[% ELSIF (method == 'report' ) %]
    [% SET 'dynamicaside' = 'reports-menu' %]
[% ELSE %]
    [% SET 'dynamicaside' = 'admin-menu' %]
[% END %]
[% WRAPPER 'main-container.inc' aside=dynamicaside %]
    <main> [% content | $raw %] </main>
    <!-- /.row -->
    [% SET islands = Asset.js("js/vue/dist/islands.esm.js").match('(src="([^"]+)")').1 %]
 <script src="[% islands | $raw %]" type="module">
</script>
    <script nonce="[% Koha.CSPNonce | $raw %]" type="module">
        import { hydrate } from "[% islands | $raw %]";
        hydrate();
    </script>
    [% MACRO jsinclude BLOCK %]
        [% Asset.js("js/admin-menu.js") | $raw %]
    [% END %]
[% END %]
[% INCLUDE 'intranet-bottom.inc' %]
