$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    # you can use $dbh here like:
    $dbh->do(q{
ALTER TABLE reserves ADD COLUMN desk_id INT(11) DEFAULT NULL AFTER branchcode,
  ADD KEY desk_id (`desk_id`),
  ADD CONSTRAINT `reserves_ibfk_6` FOREIGN KEY (`desk_id`) REFERENCES `desks` (`desk_id`) ON DELETE CASCADE ON UPDATE CASCADE ;
             });
    $dbh->do(q{
ALTER TABLE old_reserves ADD COLUMN desk_id INT(11) DEFAULT NULL AFTER branchcode,
  ADD KEY `old_desk_id` (`desk_id`);
             });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug XXXXX - Attach waiting reserve to desk)\n";
}
