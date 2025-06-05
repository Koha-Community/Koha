[% USE raw %]
[% USE Koha %]
[% USE AdditionalContents %]
[% PROCESS 'html_helpers.inc' %]
[% SET OpacLangSelectorMode = Koha.Preference('OpacLangSelectorMode') %]
[% SET OpacHeader = AdditionalContents.get( location => "opacheader", lang => lang, library => logged_in_user.branchcode || default_branch, blocktitle => 0 ) %]

<header id="header-region" class="noprint">
    <nav class="navbar navbar-expand">
        <h1 id="logo">
            <a class="navbar-brand" href="/cgi-bin/koha/sco/sco-main.pl">
                [% IF ( LibraryNameTitle ) %]
                    [% LibraryNameTitle | html %]
                [% ELSE %]
                    Koha online
                [% END %]
            </a>
        </h1>

        <ul class="navbar-nav ml-auto">
            [% IF ( Koha.Preference( 'opaclanguagesdisplay' ) ) %]
                <li class="nav-item"> [% INCLUDE 'langmenu.inc' %] </li>
            [% END # / IF opaclanguagedisplay %]

            <li class="nav-item">
                <ul class="navbar-nav">
                    <li class="nav-item">
                        <a class="nav-link" href="/cgi-bin/koha/sco/help.pl"><i class="fa fa-info-circle fa-icon-black" aria-hidden="true"></i> Help</a>
                    </li>
                </ul>
            </li>
        </ul>
    </nav>
    <!-- /navbar -->

    [% IF ( OpacHeader ) %]
        <div class="container-fluid">
            <div class="row">
                <div class="col"> [% PROCESS koha_news_block news => OpacHeader %] </div>
            </div>
        </div>
    [% END # /IF opacheader %]
</header>
<!-- /navbar -->
