#!/bin/sh
# Enable or disable all the warnings in perl-scripts on Koha (production) server.
# Written by Pasi Korkalo/OUTI-Libraries

# It's a good idea to disable warnings on Koha production server. You should not need them in production
# and they will cause a slight overhead + huge amounts of excessive logging when enabled.

# Be in kohaclone (or kohasuomi). The script will disable all warnings recursively starting from your
# current working directory. Alternatively (with --enable switch) all the warnings previously disabled
# by this script will be re-enabled.

# Watch it! This will mass-change many many Koha-scripts, so be careful!

case $1 in --disable )
  for file in $(grep '^use warnings;$' * -R 2> /dev/null | cut -f 1 -d :); do sed -i 's/^use warnings;$/#use warnings; Warnings disabled by endisWarnings.sh/g' $file; done
;; --enable )
  for file in $(grep '^#use warnings; Warnings disabled by endisWarnings.sh$' * -R 2> /dev/null | cut -f 1 -d :); do sed -i 's/^#use warnings; Warnings disabled by endisWarnings.sh$/use warnings;/g' $file; done
;; * )
   echo "Enable or disable all the warnings in perl-scripts on Koha (production) server."
   echo "Use either --enable or --disable as a parameter."
esac
