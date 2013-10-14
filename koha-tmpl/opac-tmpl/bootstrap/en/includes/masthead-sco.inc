<div id="wrap">
    <div class="navbar navbar-inverse navbar-static-top">
        <div class="navbar-inner">
            <div class="container-fluid">
                <a class="brand" href="/cgi-bin/koha/sco/sco-main.pl"><img src="[% interface %]/[% theme %]/images/koha-logo-navbar.png" alt=""></a>
                <div id="checkouthelp">
                    <ul class="nav pull-right">
                        <li><a href="/cgi-bin/koha/sco/help.pl"><i class="icon help"></i> Help</a></li>
                    </ul>
                </div>

                [% IF ( validuser ) %]
                    <div id="members">
                        <ul class="nav pull-right">
                            <li><p class="members navbar-text">Welcome, <a href="/cgi-bin/koha/opac-user.pl"><span class="loggedinusername">[% FOREACH USER_INF IN USER_INFO %][% USER_INF.title %] [% USER_INF.firstname %] [% USER_INF.surname %][% END %]</span></a></p></li>
                            <li class="divider-vertical"></li>
                            <li><p class="navbar-text">[% IF persona %]<a class="logout" id="logout" href="/cgi-bin/koha/opac-main.pl?logout.x=1" onclick='navigator.id.logout();'>[% ELSE %]<a class="logout" id="logout" href="/cgi-bin/koha/opac-main.pl?logout.x=1">[% END %]Log out</a></p></li>
                        </ul>
                    </div> <!-- /members -->
                [% END # / IF validuser %]

            </div> <!-- /container-fluid -->
        </div> <!-- /navbar-inner -->
    </div> <!-- /navbar -->

    [% IF ( opacheader ) %]
        <div class="container-fluid">
            <div class="row-fluid">
                <div id="opacheader">
                    [% opacheader %]
                </div>
            </div>
        </div>
    [% END %]
