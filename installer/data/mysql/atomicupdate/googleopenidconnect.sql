INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES
	('GoogleOpenIDConnect', '0', NULL, 'if ON, allows the use of Google OpenID Connect for login', 'YesNo'),
        ('GoogleOAuth2ClientID', '', NULL, 'Client ID for the web app registered with Google', 'Free'),
        ('GoogleOAuth2ClientSecret', '', NULL, 'Client Secret for the web app registered with Google', 'Free'),
        ('GoogleOpenIDConnectDomain', '', NULL, 'Restrict OpenID Connect to this domain (or subdomains of this domain). Leave blank for all Google domains', 'Free');
