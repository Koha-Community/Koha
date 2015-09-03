update borrowers set debarred = NULL where debarred = '0000-00-00';
update borrowers set dateexpiry = NULL where dateexpiry = '0000-00-00';
update borrowers set dateofbirth = NULL where dateofbirth = '0000-00-00';
update borrowers set dateenrolled = NULL where dateenrolled = '0000-00-00';
