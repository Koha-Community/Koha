</div>
<!-- TMPL_IF NAME="opacuserlogin" -->
<div id="login">
    <!-- TMPL_IF NAME="loggedinusername" -->
        <a href="/cgi-bin/koha/opac-user.pl"><b>User Info</b></a>
        <p>Logged in as: <b> <!-- TMPL_VAR NAME="loggedinusername" --> </b></p>
        <p><a href="/cgi-bin/koha/opac-main.pl?logout.x=1">Log Out</a></p>
    <!-- TMPL_ELSE -->
        <form action="/cgi-bin/koha/opac-user.pl" method="post" name="auth" id="auth">
            <p>Login:</p>
            <input type="text" id="userid" size="10" name="userid" />
            <p>Pass:</p>
            <input type="password" id="password" size="10" name="password" />
            <p>
                <input type="submit" value="Log In" class="submit" />
            </p>
       </form>
    <!-- /TMPL_IF -->
</div>
<!-- /TMPL_IF -->
<!-- TMPL_IF NAME="opaccredits" -->

        <!-- TMPL_VAR NAME="opaccredits" -->
    </div>
<!-- /TMPL_IF -->
</div>
</body>
</html>
