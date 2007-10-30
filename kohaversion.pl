# the next koha public release version number;
# the kohaversion is divided in 4 parts :
# - #1 : the major number. 3 atm
# - #2 : the functionnal release. 00 atm
# - #3 : the subnumber, moves only on a public release
# - #4 : the developper version. The 4th number is the database subversion. 
#        used by developpers when the database changes. updatedatabase take care of the changes itself
#        and is automatically called by Auth.pm when needed.

sub kohaversion {
    return "3.00.00.016";
}

1;
