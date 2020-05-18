$DBversion = 'XXX';    # will be replaced by the RM
  if ( CheckVersion($DBversion) ) {
   
      $dbh->do(qq{
          INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) VALUES
          ('UseIssueDesks','0','','Use issue desks with circulation.','YesNo')
      });
   
      SetVersion($DBversion);
      print "Upgrade to $DBversion done (Bug 13881 - Add cash register system preference)\n";
  }
