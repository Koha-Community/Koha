### Commands
# STTY
# CHOWN
# CHMOD
# PERL
# MYSQL
# MYSQLADMIN
# INSTALL		BSD-compatible install tool

### MySQL database administration
# DBA_NAME		Name of MySQL administrator
# DBA_PASSWD		MySQL administrator password

### Koha database
# DB_NAME		Koha database name
# DB_USER		Koha database user
# DB_PASSWD		Koha database user's password

### OPAC site
# OPAC_DOC_URL		Root of tree containing HTML documents
# OPAC_CGI_URL		Root of CGI tree
# OPAC_DOC_DIR		Where to install HTML files
# OPAC_CGI_DIR		Where to install CGI scripts

### OPAC site
# INTRA_DOC_URL		Root of tree containing HTML documents
# INTRA_CGI_URL		Root of CGI tree
# INTRA_DOC_DIR		Where to install HTML files
# INTRA_CGI_DIR		Where to install CGI scripts

# Prefer 'install-sh -d' over 'mkdir', because 'install-sh' will
# create directories recursively if they don't exist. But not all
# Unices support 'mkdir -p'.
MKDIR =	./install-sh -d

# XXX - Add 'clean:' target.

include Make.conf

all:
	@echo "Please use one of the following:"
	@echo "  config	Configuration script"
	@echo "  install-db	Install the database"
	@echo "  install-opac	Install the OPAC web site"
	@echo "  install-intra	Install the intranet web site"

config configure Make.conf koha.conf.new:
	./safe-installer

# XXX - Need to create the Koha user(s) and grant permissions before
# creating the database itself.

# Create the database.
#
# Given the semantics of the MySQL arguments, if $(DBA_PASSWD) isn't
# set, the user will be prompted for them (repeatedly).
#
# First, this runs 'mysqladmin status' to make sure that the current
# user can really connect to the database and do stuff. This really
# isn't a good test, since it really only checks that $(DBA_PASSWD)
# corresponds to $(DBA_USER), and that $(DBA_USER) is authorized to
# read a little bit, but it's better than nothing.
#
# Next, this runs 'mysqldump' on the database we want to create. If
# this exits with a zero status, then everything went well, which
# means that the database already exists. If 'mysqladmin' succeeded
# but 'mysqldump' failed, we figure it must be because the database
# doesn't exist yet, so we need to create it.

create-db:	koha.mysql
	@echo "Checking authorization to connect to MySQL"
	@echo "You may be prompted for the database administrator's password"
	$(MYSQLADMIN) "-u$(DBA_USER)" "-p$(DBA_PASSWD)" status >/dev/null 2>&1
	@echo "Checking whether $(DB_NAME) already exists"
	@echo "$(MYSQLDUMP) -d -u$(DBA_USER) -p$(DBA_PASSWD) $(DB_NAME) >/dev/null"
	@if $(MYSQLDUMP) -d "-u$(DBA_USER)" "-p$(DBA_PASSWD)" $(DB_NAME) >/dev/null 2>&1; then \
		echo "Database $(DB_NAME) already exists"; \
	else \
		echo "Creating database $(DB_NAME)"; \
		echo "$(MYSQLADMIN) -u$(DBA_USER) -p<password> create $(DB_NAME)"; \
		$(MYSQLADMIN) "-u$(DBA_USER)" "-p$(DBA_PASSWD)" create $(DB_NAME); \
		echo "Adding tables to $(DB_NAME)"; \
		$(MYSQL) "-u$(DBA_USER)" "-p$(DBA_PASSWD)" $(DB_NAME) < koha.mysql; \
	fi

# After ensuring that the database exists, bring it up to date.
# XXX - Currently, the sample data set assumes the v1.2 database,
# which is different from what 'updater/updatedatabase' will create.
# Hence, if the user wants to install the sample data, it'll be
# necessary to install it before running 'updater/updatedatabase'.
install-db:	create-db
	@echo "Updating database as necessary"
	KOHA_CONF=koha.conf.new ./updater/updatedatabase

install-opac:	install-opac-html install-opac-cgi

install-opac-html:

install-opac-cgi:

install-intra:	install-intra-html install-intra-cgi

install-intra-html:

install-intra-cgi:
