BEGIN { $| = 1; print "1..4\n"; }

my $i = 1;
eval { require Date::Manip; } || print "not "; print "ok ",$i++,"\n";
eval { require DBI; }         || print "not "; print "ok ",$i++,"\n";
eval { require Set::Scalar; } || print "not "; print "ok ",$i++,"\n";
eval { require DBD::mysql; }  || print "not "; print "ok ",$i++,"\n";
