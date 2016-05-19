-- Coded values conforming to the Z39.77-2006 Holdings Statements for Bibliographic Items');
-- ISSN: 1041-5653
-- Refer to http://www.niso.org/standards/index.html

-- General Holdings: Type of Unit Designator
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_UT','0','Information not available; Not applicable');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_UT','a','Basic bibliographic unit');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_UT','c','Secondary bibliographic unit: supplements, special issues, accompanying material, other secondary bibliographic units');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_UT','d','Indexes');

-- Physical Form Designators
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','au','Cartographic material');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','ad','Cartographic material, atlas');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','ag' ,'Cartographic material, diagram');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','aj' ,'Cartographic material, map');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','ak' ,'Cartographic material, profile');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','aq' ,'Cartographic material, model');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','ar' ,'Cartographic material, remote sensing image');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','as' ,'Cartographic material, section');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','ay' ,'Cartographic material, view');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','az' ,'Cartographic material, other');

INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','cu' ,'Computer file');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','ca' ,'Computer file, tape cartridge');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','cb' ,'Computer file, chip cartridge');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','cc' ,'Computer file, computer optical disk cartridge');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','cf' ,'Computer file, tape cassette');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','ch' ,'Computer file, tape reel');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','cj' ,'Computer file, magnetic disk');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','cm' ,'Computer file, magneto-optical disk');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','co' ,'Computer file, optical disk');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','cr' ,'Computer file, remote');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','cz' ,'Computer file, other');

INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','du' ,'Globe');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','da' ,'Globe, celestial');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','db' ,'Globe, planetary or lunar');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','dc' ,'Globe, terrestrial');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','de' ,'Globe, earth moon');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','dz' ,'Globe, other');

INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','ou' ,'Kit');

INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','hu' ,'Microform');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','ha' ,'Microform, aperture card');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','hb',' Microform, microfilm cartridge');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','hc',' Microform, microfilm cassette');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','hd',' Microform, microfilm reel');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','he' ,'Microform, microfiche');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','hf' ,'Microform, microfiche cassette');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','hg' ,'Microform, micro-opaque');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','hz' ,'Microform, other');

INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','mu' ,'Motion picture');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','mc' ,'Motion picture, film cartridge');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','mf' ,'Motion picture, film cassette');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','mr' ,'Motion picture, film reel');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','mz' ,'Motion picture, other');

INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','ku' ,'Nonprojected graphic');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','kc' ,'Nonprojected graphic, collage');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','kd' ,'Nonprojected graphic, drawing');

INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','ke' ,'Nonprojected graphic, painting');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','kf' ,'Nonprojected graphic, photomechanical print');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','kg' ,'Nonprojected graphic, photonegative');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','kh' ,'Nonprojected graphic, photoprint');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','ki' ,'Nonprojected graphic, picture');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','kj' ,'Nonprojected graphic, print');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','kl' ,'Nonprojected graphic, technical drawing');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','kn' ,'Nonprojected graphic, chart');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','ko' ,'Nonprojected graphic, flash card');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','kz' ,'Nonprojected graphic, other');

INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','qu' ,'Notated music');

INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','gu' ,'Projected graphic');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','gc' ,'Projected graphic, filmstrip cartridge');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','gd' ,'Projected graphic, filmstrip');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','gf' ,'Projected graphic, other type of filmstrip');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','go' ,'Projected graphic, filmstrip roll');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','gs' ,'Projected graphic, slide');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','gt' ,'Projected graphic, transparency');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','gz' ,'Projected graphic, other');

INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','ru' ,'Remote-sensing image');

INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','su' ,'Sound recording');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','sd' ,'Sound recording, sound disk');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','se' ,'Sound recording, cylinder');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','sg' ,'Sound recording, sound cartridge');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','si' ,'Sound recording, sound-track film');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','sq' ,'Sound recording, roll');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','ss' ,'Sound recording, sound cassette');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','st' ,'Sound recording, sound-tape reel');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','sw' ,'Sound recording, wire recording');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','sz' ,'Sound recording, other');

INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','tu' ,'Text');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','ta' ,'Text, regular print');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','tb' ,'Text, large print');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','tc' ,'Text, Braille');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','td' ,'Text, loose-leaf');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','tz' ,'Text, other');

INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','vu' ,'Videorecording');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','vc' ,'Videorecording, videocartridge');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','vd' ,'Videorecording, videodisc');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','vf' ,'Videorecording, videocassette');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','vr' ,'Videorecording, videoreel');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','vz' ,'Videorecording, other');

INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','zu' ,'Physical form is unspecified');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','zm' ,'Multiple physical forms');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','zz' ,'Other physical media');

-- General Holdings: Completeness Designator 
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_C','0','Information not available, or Retention is limited');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_C','1','Complete (95%-100% held)');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_C','2','Incomplete (50%-94% held)');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_C','3','Very incomplete or scattered (less than 50% held)');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_C','4','Not applicable');

-- General Holdings: Acquisition Status Designator
-- This data element specifies acquisition status for the unit at the time of the holdings report.

INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_AS','0','Information not available, or Retention is limited');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_AS','1','Other');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_AS','2','Received and complete or Ceased');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_AS','3','On order');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_AS','4','Currently received');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_AS','5','Not currently received');

-- General Holdings: Retention Designator
-- This data element specifies the retention policy for the unit at the time of the holdings report. 

INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_RD','0','Information not available');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_RD','1','Other');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_RD','2','Retained except as replaced by updates');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_RD','3','Sample issue retained');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_RD','4','Retained until replaced by microform, or other preservation format');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_RD','5','Retained until replaced by cumulation, replacement volume, or revision');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_RD','6','Limited retention (only some parts kept)');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_RD','7','No retention (no parts kept)');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_RD','8','Permanent retention (all parts kept permanently)');

