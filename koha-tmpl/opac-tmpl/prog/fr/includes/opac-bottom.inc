</div>
<!-- TMPL_IF NAME="opacuserlogin" -->
<div id="login">
    <!-- TMPL_IF NAME="loggedinusername" -->
        <a href="/cgi-bin/koha/opac-user.pl"><b>Info utilisateur</b></a>
        <p>Connecté en tant que <b> <!-- TMPL_VAR NAME="loggedinusername" --> </b></p>
        <p><a href="/cgi-bin/koha/opac-logout.pl?logout=Log Out">Déconnexion</a></p>
    <!-- TMPL_ELSE -->
        <form action="/cgi-bin/koha/opac-user.pl" method="post" name="auth" id="auth">
            <p>Utilisateur</p>
            <input type="text" id="userid" size="10" name="userid" />
            <p>Mot de passe</p>
            <input type="password" id="password" size="10" name="password" />
            <p>
                <input type="submit" value="Se connecter" class="submit">
            </p>
       </form>
    <!-- /TMPL_IF -->
</div>
<!-- /TMPL_IF -->
<!-- TMPL_IF NAME="opaccredits" -->
    <div id="footer">
        <!-- TMPL_VAR NAME="opaccredits" -->
    </div>
<!-- /TMPL_IF -->

</body>
</html>
