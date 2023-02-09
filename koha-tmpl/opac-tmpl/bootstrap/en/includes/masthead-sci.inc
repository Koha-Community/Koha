[% USE raw %]
[% USE Koha %]
[% USE AdditionalContents %]
[% PROCESS 'html_helpers.inc' %]
[% SET OpacLangSelectorMode = Koha.Preference('OpacLangSelectorMode') %]
[% SET OpacHeader = AdditionalContents.get( location => "opacheader", lang => lang, library => logged_in_user.branchcode || default_branch, blocktitle => 0 ) %]

<div id="wrapper">
    <div id="header-region" class="noprint">
        <nav class="navbar navbar-expand">
            <h1 id="logo">
                <a class="navbar-brand" href="/cgi-bin/koha/sci/sci-main.pl">
                    [% IF ( LibraryNameTitle ) %]
                        [% LibraryNameTitle | html %]
                    [% ELSE %]
                        Koha online
                    [% END %]
                </a>
            </h1>

            <ul class="navbar-nav ml-auto">
                [% IF ( Koha.Preference( 'opaclanguagesdisplay' ) ) %]
                    <li class="nav-item">
                        [% INCLUDE 'masthead-langmenu.inc' %]
                    </li>
                [% END # / IF opaclanguagedisplay %]

                <li class="nav-item">
                    <ul class="navbar-nav">
                        <li class="nav-item">
                            <a href="/cgi-bin/koha/sci/sci-main.pl" class="nav-link helpModal-trigger" role="button" data-toggle="modal"><i class="fa fa-info-circle fa-icon-black" aria-hidden="true"></i> Help</a></li>
                        </li>
                    </ul>
                </li>
                <li class="nav-item">
                    <a id="sci_logout" href="/cgi-bin/koha/sci/sci-main.pl?logout.x=1" class="nav-link logout">
                        <i class="fa-solid fa-right-from-bracket" aria-hidden="true"></i> Log out
                    </a>
                </li>
            </ul>
        </nav> <!-- /navbar -->

        [% IF ( OpacHeader ) %]
            <div class="container-fluid">
                <div class="row">
                    <div class="col">
                        [% PROCESS koha_news_block news => OpacHeader %]
                    </div>
                </div>
            </div>
        [% END # /IF opacheader %]

    </div> <!-- /navbar -->
