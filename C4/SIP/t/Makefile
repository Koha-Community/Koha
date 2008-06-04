# 
# 
# 

TESTS = 000_sc_config_auth.t \
	00sc_status.t 01patron_status.t 02patron_info.t 03checkout.t \
	04patron_status.t 05block_patron.t 06patron_enable.t 07hold.t \
	08checkin.t 09renew.t 10renew_all.t 11item_info.t

OILS_TESTS = 00sc_status.t 01patron_status.t 02patron_info.t 03checkout.t \
	08checkin.t 09renew.t 11item_info.t 05block_patron.t

test-openils:
	prove -I.. $(OILS_TESTS)

test:
	prove -I../ -I./ $(TESTS)
