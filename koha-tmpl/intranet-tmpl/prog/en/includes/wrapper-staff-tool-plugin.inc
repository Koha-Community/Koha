[% USE raw %]
[% SET footerjs = 1 %]
[% INCLUDE 'doc-head-open.inc' %]
<title>[% IF ( plugin_title ) %][% plugin_title | html %] &rsaquo; [% END %]Plugins &rsaquo; Tools &rsaquo; Koha </title>
[% INCLUDE 'doc-head-close.inc' %]
</head>
<body id="plugins_run_tool" class="plugins">

[% INCLUDE 'header.inc' %]
[% INCLUDE 'prefs-admin-search.inc' %]

<nav id="breadcrumbs" aria-label="Breadcrumb" class="breadcrumb">
    <ol>
        <li>
            <a href="/cgi-bin/koha/mainpage.pl">Home</a>
        </li>
        <li>
            <a href="/cgi-bin/koha/tools/tools-home.pl">Tools</a>
        </li>
        <li>
            <a href="/cgi-bin/koha/plugins/plugins-home.pl">Plugins</a>
        </li>
        <li>
            <a href="#" aria-current="page">
                [% IF ( plugin_title ) %][% plugin_title | html %][% ELSE %]Plugin[% END %]
            </a>
        </li>
    </ol>
</nav>

<div class="main container-fluid">
    <div class="row">
        <div class="col-sm-10 col-sm-push-2">
            <main>
            [% content | $raw %]
            </main>
        </div> <!-- /.col-sm-10.col-sm-push-2 -->

        <div class="col-sm-2 col-sm-pull-10">
            <aside>
                [% INCLUDE 'tools-menu.inc' %]
            </aside>
        </div> <!-- /.col-sm-2.col-sm-pull-10 -->
     </div> <!-- /.row -->

[% INCLUDE 'intranet-bottom.inc' %]
