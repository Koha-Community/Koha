use ExtUtils::MakeMaker;

die "perl >= 5.6.1 required" unless ($] >= 5.006001);

WriteMakefile(
    NAME => 'Koha',
    DISTNAME => 'koha',
    VERSION => '2.3.0',
    PREREQ_PM => {
        'DBI' => 1,
        'Date::Manip' => 1,
        'DBD::MySQL' => 1,
        'HTML::Template' => 1,
        'Digest::MD5' => 1,
        'MARC::Record' => 1,
        'Mail::Sendmail' => 1,
        'PDF::API2' => 1,
        'Net::LDAP' => 1,
        'Event' => 1,
        'Net::Z3950' => 1
        },
   CONFIGURE => sub {
     # Figure out options here
     return {}
     },
   PM => { # srcfile => dest
     },
   PL_FILES => { # generator => target
     }   
);
