function sco_init(valid_session) {
	if (valid_session == 1) {
  		setTimeout("location.href='/cgi-bin/koha/sco/sco-main.pl?op=logout';",120000);
	}
}
