How to build a Koha release -- list of reminders for RMs

Update and document the translations
 ./update.pl will update all translations and you can check for
 failed ones (a copy of the previous version of the po file is
 stored with a ~ (tilda) sign after it, so any that don't have that
 didn't succeed

Install and test the translations
 ./install.pl will install every translation in the po dir

Upload the translations to translate.koha.org
 This is generally done by deleting the database and importing
 the po files using the import tool as part of kartouche

Update the release notes (look at git logs for
major improvements)

Alter the VERSION string in Makefile.PL and comment
out VERSION_FROM. For instance:
 				VERSION     => '3.00.00-stable',
               #VERSION_FROM => 'kohaversion.pl',

run perl Makefile.PL and then make manifest tardist

Sign, MD5 the release, upload:
 put the tarball its own dir
 run the following

 $ md5sum * >koha-3.00.00-alpha.tar.gz.MD5
 $ gpg --clearsign koha-3.00.00-alpha.tar.gz.MD5
 $ cat koha-3.00.00-alpha.tar.gz.MD5.asc
 $ gpg --detach-sign koha-3.00.00-alpha.tar.gz
 $ scp * download.koha.org

Tag the Release:
From a clone of the RM repo, run:

 $ git tag -a -m "version 3.00.00 beta" v3.00.00-beta
 $ git push --tags

From the gitweb repo, issue:

 $ git fetch --tags

 * update the website, trigger the change
 * email the list
