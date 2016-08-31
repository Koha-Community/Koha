$DBversion = '16.06.00.XXX';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    {
        print "Attempting upgrade to $DBversion (Bug 17135) ...\n";
        my $maintenance_script = C4::Context->config("intranetdir") . "/misc/maintenance/fix_unclosed_nonaccruing_fines_bug17135.pl";
        system("perl $maintenance_script --confirm");
        print "Upgrade to $DBversion done (Bug 17135 - Fine for the previous overdue may get overwritten by the next one)\n";
        unless ($original_version < TransformToNum("3.23.00.032")) { ## Bug 15675
            print "WARNING: There is a possibility (= just a possibility, it's configuration dependent etc.) that - due to regression introduced by Bug 15675 - some old fine records for overdued items (items which got renewed 1+ time while being overdue) may have been overwritten in your production 16.05+ database. See Bugzilla reports for Bug 14390 and Bug 17135 for more details.\n";
            print "WARNING: Please note that this upgrade does not try to recover such overwitten old fine records (if any) - it's just an follow-up for Bug 14390, it's sole purpose is preventing eventuall further-on overwrites from happening in the future. Optional recovery of the overwritten fines (again, if any) is like, totally outside of the scope of this particular upgrade!\n";
        }
        SetVersion ($DBversion);
    }
}
