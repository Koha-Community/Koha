BEGIN { $| = 1; print "1..7\n"; }

my $i = 1;
eval { require DBI; }         || print "not "; print "ok ",$i++,"\n";
eval { require Date::Manip; } || print "not "; print "ok ",$i++,"\n";
eval { require DBD::mysql; }  || print "not "; print "ok ",$i++,"\n";
eval { require HTML::Template; }         || print "not "; print "ok ",$i++,"\n";
eval { require Set::Scalar; } || print "not "; print "ok ",$i++,"\n";
eval { require Digest::MD5; }  || print "not "; print "ok ",$i++,"\n";
eval { require Net::Z3950; }  || print "not "; print "ok ",$i++,"\n";
