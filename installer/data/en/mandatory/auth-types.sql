-- *******************************************************
-- KOHA 3.0 MARC 21 STANDARD DEFAULT AUTHORITY FRAMEWORKS 
--                     AUTHORITY TYPES                    
--                                                        
--                  PRETEST VERSION 0.0.4                 
--                       2007-08-21                       
--                                                        
--                         edited                         
--                   by thd for LibLime                   
--                                                        
--                       BASED UPON                       
--                                                        
--   KOHA MARC 21 STANDARD DEFAULT AUTHORITY FRAMEWORKS   
--                                                        
--                  PRETEST VERSION 0.0.4                 
--                       2007-08-21                       
--                                                        
--  original default requiring greater user customisation 
--               created by a few Koha Hands              
--                 guided by Paul POULAIN                 
--                                                        
--       revised and greatly enlarged to completion,      
--            well not quite complete yet today           
--        but close enough for someone to have use,       
--                   by thd for LibLime                   
-- *******************************************************


SET FOREIGN_KEY_CHECKS = 0;


-- ******************************************************
-- KOHA DEFAULT MARC 21 AUTHORITY TYPE. 
-- ******************************************************

-- This authority type includes all fields and subfieds used by any 
-- authority type. 

INSERT INTO `auth_types` VALUES ('', 'Default', '', '');


-- ******************************************************
-- KOHA SUPPORTED STANDARD MARC 21 AUTHORITY TYPES. 
-- ******************************************************

-- These authority types are supported for for guiding the cataloguer to 
-- fill authorised values in Koha MARC bibliographic editor.


INSERT INTO `auth_types` VALUES ('PERSO_NAME', 'Personal Name', '100', 'Personal Names');
INSERT INTO `auth_types` VALUES ('CORPO_NAME', 'Corporate Name', '110', 'Corporate Names');
INSERT INTO `auth_types` VALUES ('MEETI_NAME', 'Meeting Name', '111', 'Meeting Name');
INSERT INTO `auth_types` VALUES ('UNIF_TITLE', 'Uniform Title', '130', 'Uniform Title');
INSERT INTO `auth_types` VALUES ('CHRON_TERM', 'Chronological Term', '148', 'Chronological Term');
INSERT INTO `auth_types` VALUES ('TOPIC_TERM', 'Topical Term', '150', 'Topical Term');
INSERT INTO `auth_types` VALUES ('GEOGR_NAME', 'Geographic Name', '151', 'Geographic Name');
INSERT INTO `auth_types` VALUES ('GENRE/FORM', 'Genre/Form Term', '155', 'Genre/Form Term');


-- ******************************************************
-- KOHA UNSUPPORTED STANDARD MARC 21 AUTHORITY TYPES. 
-- ******************************************************

-- These authority types are only supported for guiding the cataloguer to 
-- fill authorised values in the Koha MARC bibliographic editor to the 
-- extent that they have already been included in a primary authority type, 
-- therefore, they have not yet been specified.
--
-- Minimal primary authorities including subdivisions may currently be 
-- built by a script which uses the values in bibliographic records but 
-- include no tracings and references which are necessarily not present 
-- in bibliographic records.


-- INSERT INTO `auth_types` VALUES ('TOPIC_SUBD', 'General Topical Term Subdivision', '180', 'General Topical Term Subdivision');
-- INSERT INTO `auth_types` VALUES ('GEOGR_SUBD', 'Geographic Subdivision', '181', 'Geographic Subdivision');
-- INSERT INTO `auth_types` VALUES ('CHRON_SUBD', 'Chronological Subdivision', '182', 'Chronological Subdivision');
-- INSERT INTO `auth_types` VALUES ('FORM_SUBDI', 'Form Subdivision', '185', 'Form Subdivision');

