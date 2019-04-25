$DBversion = 'XXX';    # will be replaced by the RM
if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        INSERT IGNORE INTO `systempreferences` (`variable`, `value`, `explanation`, `options`, `type`) VALUES
          ('OpenURLResolverURL', '', 'URL of OpenURL Resolver', NULL, 'Free'),
          ('OpenURLText', '', 'Text of OpenURL links (or image title if OpenURLImageLocation is defined)', NULL, 'Free'),
          ('OpenURLImageLocation', '', 'Location of image for OpenURL links', NULL, 'Free'),
          ('OPACShowOpenURL', '', 'Enable display of OpenURL links in OPAC search results and detail page', NULL, 'YesNo'),
          ('OPACOpenURLItemTypes', '', 'Show the OpenURL link only for these item types', NULL, 'Free');
    });

    SetVersion($DBversion);
    print
"Upgrade to $DBversion done (Bug 8995 - Add new preferences for OpenURLResolvers)\n";
}
