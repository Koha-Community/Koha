-- Coded values conforming to the Z39.77-2006 Holdings Statements for Bibliographic Items');
-- ISSN: 1041-5653
-- Refer to http://www.niso.org/standards/index.html

-- General Holdings: Type of Unit Designator
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('UNIT_TYPE','0','Information not available; Not applicable');INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('UNIT_TYPE','a','Basic bibliographic unit');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('UNIT_TYPE','c','Secondary bibliographic unit: supplements, special issues, accompanying material, other secondary bibliographic units');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('UNIT_TYPE','d','Indexes');

-- Physical Form Designators
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','au','Cartographic material');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','ad','Cartographic material, atlas');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','ag' ,'Cartographic material, diagram');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','aj' ,'Cartographic material, map');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','ak' ,'Cartographic material, profile');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','aq' ,'Cartographic material, model');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','ar' ,'Cartographic material, remote sensing image');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','as' ,'Cartographic material, section');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','ay' ,'Cartographic material, view');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','az' ,'Cartographic material, other');

INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','cu' ,'Computer file');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','ca' ,'Computer file, tape cartridge');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','cb' ,'Computer file, chip cartridge');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','cc' ,'Computer file, computer optical disk cartridge');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','cf' ,'Computer file, tape cassette');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','ch' ,'Computer file, tape reel');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','cj' ,'Computer file, magnetic disk');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','cm' ,'Computer file, magneto-optical disk');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','co' ,'Computer file, optical disk');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','cr' ,'Computer file, remote');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','cz' ,'Computer file, other');

INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','du' ,'Globe');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','da' ,'Globe, celestial');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','db' ,'Globe, planetary or lunar');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','dc' ,'Globe, terrestrial');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','de' ,'Globe, earth moon');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','dz' ,'Globe, other');

INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','ou' ,'Kit');

INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','hu' ,'Microform');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','ha' ,'Microform, aperture card');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','hb',' Microform, microfilm cartridge');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','hc',' Microform, microfilm cassette');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','hd',' Microform, microfilm reel');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','he' ,'Microform, microfiche');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','hf' ,'Microform, microfiche cassette');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','hg' ,'Microform, micro-opaque');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','hz' ,'Microform, other');

INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','mu' ,'Motion picture');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','mc' ,'Motion picture, film cartridge');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','mf' ,'Motion picture, film cassette');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','mr' ,'Motion picture, film reel');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','mz' ,'Motion picture, other');

INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','ku' ,'Nonprojected graphic');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','kc' ,'Nonprojected graphic, collage');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','kd' ,'Nonprojected graphic, drawing');

INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','ke' ,'Nonprojected graphic, painting');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','kf' ,'Nonprojected graphic, photomechanical print');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','kg' ,'Nonprojected graphic, photonegative');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','kh' ,'Nonprojected graphic, photoprint');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','ki' ,'Nonprojected graphic, picture');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','kj' ,'Nonprojected graphic, print');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','kl' ,'Nonprojected graphic, technical drawing');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','kn' ,'Nonprojected graphic, chart');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','ko' ,'Nonprojected graphic, flash card');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','kz' ,'Nonprojected graphic, other');

INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','qu' ,'Notated music');

INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','gu' ,'Projected graphic');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','gc' ,'Projected graphic, filmstrip cartridge');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','gd' ,'Projected graphic, filmstrip');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','gf' ,'Projected graphic, other type of filmstrip');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','go' ,'Projected graphic, filmstrip roll');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','gs' ,'Projected graphic, slide');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','gt' ,'Projected graphic, transparency');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','gz' ,'Projected graphic, other');

INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','ru' ,'Remote-sensing image');

INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','su' ,'Sound recording');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','sd' ,'Sound recording, sound disk');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','se' ,'Sound recording, cylinder');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','sg' ,'Sound recording, sound cartridge');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','si' ,'Sound recording, sound-track film');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','sq' ,'Sound recording, roll');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','ss' ,'Sound recording, sound cassette');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','st' ,'Sound recording, sound-tape reel');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','sw' ,'Sound recording, wire recording');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','sz' ,'Sound recording, other');

INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','tu' ,'Text');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','ta' ,'Text, regular print');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','tb' ,'Text, large print');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','tc' ,'Text, Braille');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','td' ,'Text, loose-leaf');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','tz' ,'Text, other');

INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','vu' ,'Videorecording');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','vc' ,'Videorecording, videocartridge');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','vd' ,'Videorecording, videodisc');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','vf' ,'Videorecording, videocassette');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','vr' ,'Videorecording, videoreel');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','vz' ,'Videorecording, other');

INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','zu' ,'Physical form is unspecified');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','zm' ,'Multiple physical forms');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('PHYS_FORMS','zz' ,'Other physical media');

-- General Holdings: Completeness Designator 
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('COMPLETENESS','0','Information not available, or Retention is limited');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('COMPLETENESS','1','Complete (95%-100% held)');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('COMPLETENESS','2','Incomplete (50%-94% held)');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('COMPLETENESS','3','Very incomplete or scattered (less than 50% held)');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('COMPLETENESS','4','Not applicable');

-- General Holdings: Acquisition Status Designator
-- This data element specifies acquisition status for the unit at the time of the holdings report.

INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('ACQUI_STAT','0','Information not available, or Retention is limited');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('ACQUI_STAT','1','Other');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('ACQUI_STAT','2','Received and complete or Ceased');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('ACQUI_STAT','3','On order');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('ACQUI_STAT','4','Currently received');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('ACQUI_STAT','5','Not currently received');

-- General Holdings: Retention Designator
-- This data element specifies the retention policy for the unit at the time of the holdings report. 

INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('RET_DESIG','0','Information not available');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('RET_DESIG','1','Other');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('RET_DESIG','2','Retained except as replaced by updates');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('RET_DESIG','3','Sample issue retained');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('RET_DESIG','4','Retained until replaced by microform, or other preservation format');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('RET_DESIG','5','Retained until replaced by cumulation, replacement volume, or revision');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('RET_DESIG','6','Limited retention (only some parts kept)');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('RET_DESIG','7','No retention (no parts kept)');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('RET_DESIG','8','Permanent retention (all parts kept permanently)');

