sub appendToYamlSyspref {
  my ($pref) = @_;
  eval {
    require YAML::XS;
    require C4::Context;

    my $val = C4::Context->preference($pref);
    print "$val\n" if $ENV{KOHA_TEST_ATOMICUPDATE};
    my $asYaml = YAML::XS::Load($val);
    $asYaml->{BranchBlock} = 1;
    C4::Context->set_preference($pref, YAML::XS::Dump($asYaml));
  };
  if ($@) {
    warn("Automatically adding 'BranchBlock: 1' to syspref '$pref' failed. To enable the feature, you must manually add the missing clause.\nReason for failure: $@");
  }
}

unless ($ENV{KOHA_TEST_ATOMICUPDATE}) {
$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
  # you can use $dbh here like:

  $dbh->do(q{

--
-- Table structure for table `borrower_ss_blocks`
--

CREATE TABLE `borrower_ss_blocks` ( -- borrower self-service branch-specific blocks. Prevent access to specific self-service libraries, but not to all of them
  `borrower_ss_block_id` int(12) NOT NULL auto_increment,
  `borrowernumber` int(11) NOT NULL,    -- The user that is blocked, if the borrower-row is deleted, this block becomes useless as well
  `branchcode` varchar(10) NOT NULL,    -- FK to branches. Where the block is in effect. Referential integrity enforced on software, because cannot delete the branch and preserve the old value ON DELETE/UPDATE.
  `expirationdate` datetime NOT NULL,   -- When the personal branch-specific block is automatically lifted by the cronjob self_service_block_expiration.pl
  `notes` text,                         -- Non-formal user created notes about the block.
  `created_by` int(11) NOT NULL,        -- The librarian that created the block, referential integrity enforced with Perl, because the librarian can quit, but all the blocks he/she made must remain.
  `created_on` datetime NOT NULL DEFAULT NOW(), -- When was this block created
  PRIMARY KEY  (`borrower_ss_block_id`),
  KEY `branchcode` (`branchcode`),
  KEY `expirationdate` (`expirationdate`),
  KEY `created_by` (`created_by`),
  CONSTRAINT `borrower_ss_blocks_ibfk_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

  });
  $dbh->do(q{

--
-- Set relevant permissions
--

INSERT INTO permissions (module, code, description) VALUES
( 'borrowers',       'ss_blocks_list',    'Allow listing all self-service blocks for a Patron.'),
( 'borrowers',       'ss_blocks_get',     'Allow fetching the data of a single self-service block for a Patron.'),
( 'borrowers',       'ss_blocks_create',  'Allow creating a single self-service block for a Patron.'),
( 'borrowers',       'ss_blocks_edit',    'Allow editing the data of a single self-service block for a Patron.'),
( 'borrowers',       'ss_blocks_delete',  'Allow deleting a single self-service block for a Patron.')
;

  });
  $dbh->do(q{

--
-- Set new sysprefs
--

INSERT INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
('SSBlockCleanOlderThanThis','3650','','Clean expired self-service branch-specific access blocks older than this many days. You must enable access rule "BranchBlock" in syspref "SSRules" for this to have effect.','Integer'),
('SSBlockDefaultDuration','60','','Self-service branch-specific access block default duration. You must enable access rule "BranchBlock" in syspref "SSRules" for this to have effect.','free');


  });

  appendToYamlSyspref('SSRules', {BranchBlock => 1});

  # Always end with this (adjust the bug info)
  SetVersion( $DBversion );
  print "Upgrade to $DBversion done (KD-3698 Self-Service Branch-specific access blocks for Borrowers)\n";
}
} #Atomicupdate defined

#######################################

else { #Tests for the atomicupdate
  require C4::Context;

  my $test = "Syspref is unused";
  C4::Context->set_preference('SSRules', '');
  appendToYamlSyspref('SSRules');
  my $changed = C4::Context->preference('SSRules');
  print "$changed\n" if $ENV{KOHA_TEST_ATOMICUPDATE};
  if($changed =~ /^---\nBranchBlock: 1\n/) {
    print "    ok 1 - $test\n";
  }
  else {
    warn  "    not ok 1 - $test\n";
  }

  $test = "Syspref is bad";
  my $bad = "-\nfasd: 44\ ga: 33\n \"";
  C4::Context->set_preference('SSRules', $bad);
  appendToYamlSyspref('SSRules');
  my $changed = C4::Context->preference('SSRules');
  print "$changed\n" if $ENV{KOHA_TEST_ATOMICUPDATE};
  if($changed =~ /^$bad/) {
    print "    ok 2 - $test\n";
  }
  else {
    warn  "    not ok 2 - $test\n";
  }

  $test = "Syspref is valid";
  C4::Context->set_preference('SSRules', "---\n\nTaC: 1\nPermission: 1\nCardExpired: 1\n");
  appendToYamlSyspref('SSRules');
  my $changed = C4::Context->preference('SSRules');
  print "$changed\n" if $ENV{KOHA_TEST_ATOMICUPDATE};
  if($changed =~ /^---\nBranchBlock: 1\nCardExpired: 1\nPermission: 1\nTaC: 1\n/) {
    print "    ok 3 - $test\n";
  }
  else {
    warn  "    not ok 3 - $test\n";
  }
}
