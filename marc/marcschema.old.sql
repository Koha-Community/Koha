create table Resource_Table (Resource_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
Date_Added TIMESTAMP, Date_Modified TIMESTAMP, Record_ID INT UNSIGNED NOT NULL,
Statement_ID INT UNSIGNED, Scope_ID INT UNSIGNED,
Container_ID INT UNSIGNED,
primary key(Resource_ID),
key(Record_ID));

create table Schema_Table (Schema_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
Date_Added TIMESTAMP, Date_Modified TIMESTAMP,
Schema_URI CHAR(255) NOT NULL,
Object_ID INT UNSIGNED NOT NULL,
KEY ID_Index(Object_ID),
KEY Schema_Index (Schema_URI(255)),
primary key(Schema_ID));

create table Statement_Table (
Statement_Key INT UNSIGNED NOT NULL AUTO_INCREMENT,
Date_Added TIMESTAMP, 
Date_Modified TIMESTAMP, 
Statement_ID INT UNSIGNED NOT NULL,
Subject CHAR(255) NOT NULL,
Predicate CHAR(255) NOT NULL,
Object CHAR(255) NOT NULL,
Object_ID INT UNSIGNED,
Schema_ID INT UNSIGNED,
Statement_Type INT UNSIGNED,
KEY ID_Index (Statement_ID),
KEY Subject_Index (Subject(255)), 
KEY Pred_Index (Predicate(255)),
KEY Object_Index (Object(255)),
primary key(Statement_Key));  

create table Scope_Table (
Scope_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
Date_Added TIMESTAMP, Date_Modified TIMESTAMP,
Operator_ID INT UNSIGNED,
Location_ID INT UNSIGNED,
Resource_Type_ID ENUM('B','N'),
primary key(Scope_ID));

create table Bib_Table (Bib_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
Record_ID INT UNSIGNED NOT NULL,
Date_Added TIMESTAMP, Date_Modified TIMESTAMP, Control_ID INT UNSIGNED NOT NULL, 
Tag_0XX_ID INT UNSIGNED NOT NULL, Tag_1XX_ID INT UNSIGNED NOT NULL, Tag_2XX_ID INT
UNSIGNED NOT NULL, Tag_3XX_ID INT UNSIGNED NOT NULL, Tag_4XX_ID INT UNSIGNED NOT NULL, Tag_5XX_ID
INT UNSIGNED NOT NULL, Tag_6XX_ID INT UNSIGNED NOT NULL, Tag_7XX_ID INT UNSIGNED NOT NULL,
Tag_8XX_ID INT UNSIGNED NOT NULL, Tag_9XX_ID INT UNSIGNED NOT NULL, Storage_ID INT
UNSIGNED NOT NULL, Holdings_ID INT UNSIGNED NOT NULL,
KEY ID_Index(Record_ID), primary key(Bib_ID),
key (TAG_0XX_ID), key (TAG_1XX_ID), key (TAG_2XX_ID), key (TAG_3XX_ID), key (TAG_4XX_ID), key (TAG_5XX_ID), key (TAG_6XX_ID), key (TAG_7XX_ID), key (TAG_8XX_ID), key (TAG_9XX_ID), key (Storage_ID), key (Holdings_ID));

create table 0XX_Tag_Table (Tag_Key INT UNSIGNED NOT NULL AUTO_INCREMENT,
Tag_ID INT UNSIGNED NOT NULL, Indicator1 CHAR(1) NOT NULL,
Indicator2 CHAR(1) NOT NULL,
Tag CHAR(3) NOT NULL, Subfield_ID INT UNSIGNED NOT NULL, Authority_ID INT UNSIGNED, 
Link_Flag ENUM('Y','N','B'), Storage_ID INT UNSIGNED NOT NULL,
KEY ID_Index(Tag_ID),
key (Subfield_ID),
key (Storage_ID),
KEY Tag_Index (Tag(3)), primary key(Tag_Key));

create table 0XX_Subfield_Table 
(Subfield_Key INT UNSIGNED NOT NULL AUTO_INCREMENT,
Subfield_ID INT UNSIGNED NOT NULL, Subfield_Mark CHAR(1) NOT NULL,
Subfield_Value CHAR(255) NOT NULL, Storage_ID INT UNSIGNED,
KEY ID_Index (Subfield_ID),
KEY Mark_Index (Subfield_Mark(1)),
KEY Subfield_Index (Subfield_Value(255)), primary key(Subfield_Key));

create table 1XX_Tag_Table (Tag_Key INT UNSIGNED NOT NULL AUTO_INCREMENT,
Tag_ID INT UNSIGNED NOT NULL, Indicator1 CHAR(1) NOT NULL,
Indicator2 CHAR(1) NOT NULL,
Tag CHAR(3) NOT NULL, Subfield_ID INT UNSIGNED NOT NULL, Authority_ID INT UNSIGNED, 
Link_Flag ENUM('Y','N','B'), Storage_ID INT UNSIGNED NOT NULL,
KEY ID_Index(Tag_ID),
key (Subfield_ID), key (Storage_ID),
KEY Tag_Index (Tag(3)), primary key(Tag_Key));

create table 1XX_Subfield_Table 
(Subfield_Key INT UNSIGNED NOT NULL AUTO_INCREMENT,
Subfield_ID INT UNSIGNED NOT NULL, Subfield_Mark CHAR(1) NOT NULL,
Subfield_Value CHAR(255) NOT NULL, Storage_ID INT UNSIGNED,
KEY ID_Index (Subfield_ID),
KEY Mark_Index (Subfield_Mark(1)),
KEY Subfield_Index (Subfield_Value(255)), primary key(Subfield_Key));

create table 2XX_Tag_Table (Tag_Key INT UNSIGNED NOT NULL AUTO_INCREMENT,
Tag_ID INT UNSIGNED NOT NULL, Indicator1 CHAR(1) NOT NULL,
Indicator2 CHAR(1) NOT NULL,
Tag CHAR(3) NOT NULL, Subfield_ID INT UNSIGNED, Authority_ID INT UNSIGNED, 
Link_Flag ENUM('Y','N','B'), Storage_ID INT UNSIGNED,
KEY ID_Index (Tag_ID),
KEY Tag_Index (Tag(3)), primary key(Tag_Key));

create table 2XX_Subfield_Table 
(Subfield_Key INT UNSIGNED NOT NULL AUTO_INCREMENT,
Subfield_ID INT UNSIGNED NOT NULL, Subfield_Mark CHAR(1) NOT NULL,
Subfield_Value CHAR(255) NOT NULL, Storage_ID INT UNSIGNED,
KEY ID_Index (Subfield_ID),
KEY Mark_Index (Subfield_Mark(1)),
KEY Subfield_Index (Subfield_Value(255)), primary key(Subfield_Key));

create table 3XX_Tag_Table (Tag_Key INT UNSIGNED NOT NULL AUTO_INCREMENT,
Tag_ID INT UNSIGNED NOT NULL, Indicator1 CHAR(1) NOT NULL,
Indicator2 CHAR(1) NOT NULL,
Tag CHAR(3) NOT NULL, Subfield_ID INT UNSIGNED, Authority_ID INT UNSIGNED, 
Link_Flag ENUM('Y','N','B'), Storage_ID INT UNSIGNED,
KEY ID_Index (Tag_ID),
KEY Tag_Index (Tag(3)), primary key(Tag_Key));

create table 3XX_Subfield_Table 
(Subfield_Key INT UNSIGNED NOT NULL AUTO_INCREMENT,
Subfield_ID INT UNSIGNED NOT NULL, Subfield_Mark CHAR(1) NOT NULL,
Subfield_Value CHAR(255) NOT NULL, Storage_ID INT UNSIGNED,
KEY ID_Index (Subfield_ID),
KEY Mark_Index (Subfield_Mark(1)),
KEY Subfield_Index (Subfield_Value(255)), primary key(Subfield_Key));

create table 4XX_Tag_Table (Tag_Key INT UNSIGNED NOT NULL AUTO_INCREMENT,
Tag_ID INT UNSIGNED NOT NULL, Indicator1 CHAR(1) NOT NULL,
Indicator2 CHAR(1) NOT NULL,
Tag CHAR(3) NOT NULL, Subfield_ID INT UNSIGNED, Authority_ID INT UNSIGNED, 
Link_Flag ENUM('Y','N','B'), Storage_ID INT UNSIGNED,
KEY ID_Index (Tag_ID),
KEY Tag_Index (Tag(3)), primary key(Tag_Key));

create table 4XX_Subfield_Table 
(Subfield_Key INT UNSIGNED NOT NULL AUTO_INCREMENT,
Subfield_ID INT UNSIGNED NOT NULL, Subfield_Mark CHAR(1) NOT NULL,
Subfield_Value CHAR(255) NOT NULL, Storage_ID INT UNSIGNED,
KEY ID_Index (Subfield_ID),
KEY Mark_Index (Subfield_Mark(1)),
KEY Subfield_Index (Subfield_Value(255)), primary key(Subfield_Key));

create table 5XX_Tag_Table (Tag_Key INT UNSIGNED NOT NULL AUTO_INCREMENT,
Tag_ID INT UNSIGNED NOT NULL, Indicator1 CHAR(1) NOT NULL,
Indicator2 CHAR(1) NOT NULL,
Tag CHAR(3) NOT NULL, Subfield_ID INT UNSIGNED, Authority_ID INT UNSIGNED, 
Link_Flag ENUM('Y','N','B'), Storage_ID INT UNSIGNED,
KEY ID_Index (Tag_ID),
KEY Tag_Index (Tag(3)), primary key(Tag_Key));

create table 5XX_Subfield_Table 
(Subfield_Key INT UNSIGNED NOT NULL AUTO_INCREMENT,
Subfield_ID INT UNSIGNED NOT NULL, Subfield_Mark CHAR(1) NOT NULL,
Subfield_Value CHAR(255) NOT NULL, Storage_ID INT UNSIGNED,
KEY ID_Index (Subfield_ID),
KEY Mark_Index (Subfield_Mark(1)),
KEY Subfield_Index (Subfield_Value(255)), primary key(Subfield_Key));

create table 6XX_Tag_Table (Tag_Key INT UNSIGNED NOT NULL AUTO_INCREMENT,
Tag_ID INT UNSIGNED NOT NULL, Indicator1 CHAR(1) NOT NULL,
Indicator2 CHAR(1) NOT NULL,
Tag CHAR(3) NOT NULL, Subfield_ID INT UNSIGNED, Authority_ID INT UNSIGNED, 
Link_Flag ENUM('Y','N','B'), Storage_ID INT UNSIGNED,
KEY ID_Index (Tag_ID),
KEY Tag_Index (Tag(3)), primary key(Tag_Key));

create table 6XX_Subfield_Table 
(Subfield_Key INT UNSIGNED NOT NULL AUTO_INCREMENT,
Subfield_ID INT UNSIGNED NOT NULL, Subfield_Mark CHAR(1) NOT NULL,
Subfield_Value CHAR(255) NOT NULL, Storage_ID INT UNSIGNED,
KEY ID_Index (Subfield_ID),
KEY Mark_Index (Subfield_Mark(1)),
KEY Subfield_Index (Subfield_Value(255)), primary key(Subfield_Key));

create table 7XX_Tag_Table (Tag_Key INT UNSIGNED NOT NULL AUTO_INCREMENT,
Tag_ID INT UNSIGNED NOT NULL, Indicator1 CHAR(1) NOT NULL,
Indicator2 CHAR(1) NOT NULL,
Tag CHAR(3) NOT NULL, Subfield_ID INT UNSIGNED, Authority_ID INT UNSIGNED, 
Link_Flag ENUM('Y','N','B'), Storage_ID INT UNSIGNED,
KEY ID_Index (Tag_ID),
KEY Tag_Index (Tag(3)), primary key(Tag_Key));

create table 7XX_Subfield_Table 
(Subfield_Key INT UNSIGNED NOT NULL AUTO_INCREMENT,
Subfield_ID INT UNSIGNED NOT NULL, Subfield_Mark CHAR(1) NOT NULL,
Subfield_Value CHAR(255) NOT NULL, Storage_ID INT UNSIGNED,
KEY ID_Index (Subfield_ID),
KEY Mark_Index (Subfield_Mark(1)),
KEY Subfield_Index (Subfield_Value(255)), primary key(Subfield_Key));

create table 8XX_Tag_Table (Tag_Key INT UNSIGNED NOT NULL AUTO_INCREMENT,
Tag_ID INT UNSIGNED NOT NULL, Indicator1 CHAR(1) NOT NULL,
Indicator2 CHAR(1) NOT NULL,
Tag CHAR(3) NOT NULL, Subfield_ID INT UNSIGNED, Authority_ID INT UNSIGNED, 
Link_Flag ENUM('Y','N','B'), Storage_ID INT UNSIGNED,
KEY ID_Index (Tag_ID),
KEY Tag_Index (Tag(3)), primary key(Tag_Key));

create table 8XX_Subfield_Table 
(Subfield_Key INT UNSIGNED NOT NULL AUTO_INCREMENT,
Subfield_ID INT UNSIGNED NOT NULL, Subfield_Mark CHAR(1) NOT NULL,
Subfield_Value CHAR(255) NOT NULL, Storage_ID INT UNSIGNED,
KEY ID_Index (Subfield_ID),
KEY Mark_Index (Subfield_Mark(1)),
KEY Subfield_Index (Subfield_Value(255)), primary key(Subfield_Key));

create table 9XX_Tag_Table (Tag_Key INT UNSIGNED NOT NULL AUTO_INCREMENT,
Tag_ID INT UNSIGNED NOT NULL, Indicator1 CHAR(1) NOT NULL,
Indicator2 CHAR(1) NOT NULL,
Tag CHAR(3) NOT NULL, Subfield_ID INT UNSIGNED, Authority_ID INT UNSIGNED, 
Link_Flag ENUM('Y','N','B'), Storage_ID INT UNSIGNED,
KEY ID_Index (Tag_ID),
KEY Tag_Index (Tag(3)), primary key(Tag_Key));

create table 9XX_Subfield_Table 
(Subfield_Key INT UNSIGNED NOT NULL AUTO_INCREMENT,
Subfield_ID INT UNSIGNED NOT NULL, Subfield_Mark CHAR(1) NOT NULL,
Subfield_Value CHAR(255) NOT NULL, Storage_ID INT UNSIGNED,
KEY ID_Index (Subfield_ID),
KEY Mark_Index (Subfield_Mark(1)),
KEY Subfield_Index (Subfield_Value(255)), primary key(Subfield_Key));

create table Control_Table
(Control_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
Record_Status CHAR(1) NOT NULL,
Record_Type CHAR(1) NOT NULL,
Encoding_Level CHAR(1) NOT NULL,
Des_Cat_Form CHAR(1) NOT NULL,
Type_Date CHAR(1) NOT NULL,
Beg_Pub_Date CHAR(4) NOT NULL,
End_Pub_Date CHAR(4) NOT NULL,
Pub_Place CHAR(3) NOT NULL,
Ill_Code CHAR(4) NOT NULL,
Target_Aud CHAR(1) NOT NULL,
Item_Form CHAR(1) NOT NULL,
Cont_Nature CHAR(4) NOT NULL,
Gov_Code CHAR(1) NOT NULL,
Conf_Code CHAR(1) NOT NULL,
Festschrift CHAR(1) NOT NULL,
Own_Index CHAR(1) NOT NULL,
Fiction CHAR(1) NOT NULL,
Biography CHAR(1) NOT NULL,
Lan_Code CHAR(3) NOT NULL,
Storage_ID INT UNSIGNED,
primary key (Control_ID));

create table Auth_Table
(Auth_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
Auth_Control_ID INT UNSIGNED NOT NULL, Date_Added TIMESTAMP, 
Date_Modified TIMESTAMP,
Auth_1XX_ID INT UNSIGNED, Auth_260_ID INT UNSIGNED, Auth_360_ID INT UNSIGNED,
Auth_4XX_ID INT UNSIGNED, Auth_663_ID INT UNSIGNED, Auth_664_ID INT UNSIGNED,
Auth_665_ID INT UNSIGNED, Auth_667_ID INT UNSIGNED, Storage_ID INT UNSIGNED,
KEY ID_Index (Auth_Control_ID),
primary key(Auth_ID));

create table Auth_1XX_Tag_Table 
(Tag_Key INT UNSIGNED NOT NULL AUTO_INCREMENT, Tag_ID INT UNSIGNED NOT NULL ,
Indicator1 CHAR(1) NOT NULL,
Indicator2 CHAR(1) NOT NULL,
Tag CHAR(3) NOT NULL,
Subfield_ID INT UNSIGNED, Storage_ID INT UNSIGNED,
KEY ID_Index (Tag_ID),
KEY Tag_Index (Tag(3)), primary key(Tag_Key));

create table Auth_1XX_Subfield_Table 
(Subfield_Key INT UNSIGNED NOT NULL AUTO_INCREMENT,
Subfield_ID INT UNSIGNED NOT NULL, Subfield_Mark CHAR(1) NOT NULL,
Subfield_Value CHAR(255) NOT NULL, Storage_ID INT UNSIGNED,
KEY ID_Index (Subfield_ID),
KEY Mark_Index (Subfield_Mark(1)),
KEY Subfield_Index (Subfield_Value(255)), primary key(Subfield_Key));

create table Auth_260_Tag_Table 
(Tag_Key INT UNSIGNED NOT NULL AUTO_INCREMENT, Tag_ID INT UNSIGNED NOT NULL,  
Indicator1 CHAR(1) NOT NULL,
Indicator2 CHAR(1) NOT NULL,
Tag CHAR(3) NOT NULL,
Subfield_ID INT UNSIGNED, Storage_ID INT UNSIGNED,
KEY ID_Index (Tag_ID),
KEY Tag_Index (Tag(3)), primary key(Tag_Key));

create table Auth_260_Subfield_Table 
(Subfield_Key INT UNSIGNED NOT NULL AUTO_INCREMENT,
Subfield_ID INT UNSIGNED NOT NULL, Subfield_Mark CHAR(1) NOT NULL,
Subfield_Value CHAR(255) NOT NULL, Storage_ID INT UNSIGNED,
KEY ID_Index (Subfield_ID),
KEY Mark_Index (Subfield_Mark(1)),
KEY Subfield_Index (Subfield_Value(255)), primary key(Subfield_Key));

create table Auth_360_Tag_Table 
(Tag_Key INT UNSIGNED NOT NULL AUTO_INCREMENT, Tag_ID INT UNSIGNED NOT NULL, 
Indicator1 CHAR(1) NOT NULL,
Indicator2 CHAR(1) NOT NULL,
Tag CHAR(3) NOT NULL,
Subfield_ID INT UNSIGNED, Storage_ID INT UNSIGNED,
KEY ID_Index (Tag_ID),
KEY Tag_Index (Tag(3)), primary key(Tag_Key));

create table Auth_360_Subfield_Table 
(Subfield_Key INT UNSIGNED NOT NULL AUTO_INCREMENT,
Subfield_ID INT UNSIGNED NOT NULL, Subfield_Mark CHAR(1) NOT NULL,
Subfield_Value CHAR(255) NOT NULL, Storage_ID INT UNSIGNED,
KEY ID_Index (Subfield_ID),
KEY Mark_Index (Subfield_Mark(1)),
KEY Subfield_Index (Subfield_Value(255)), primary key(Subfield_Key));

create table Auth_4XX_Tag_Table 
(Tag_Key INT UNSIGNED NOT NULL AUTO_INCREMENT, Tag_ID INT UNSIGNED NOT NULL, 
Indicator1 CHAR(1) NOT NULL,
Indicator2 CHAR(1) NOT NULL,
Tag CHAR(3) NOT NULL,
Subfield_ID INT UNSIGNED, Storage_ID INT UNSIGNED,
KEY ID_Index(Tag_ID),
KEY Tag_Index (Tag(3)), primary key(Tag_Key));

create table Auth_4XX_Subfield_Table 
(Subfield_Key INT UNSIGNED NOT NULL AUTO_INCREMENT,
Subfield_ID INT UNSIGNED NOT NULL, Subfield_Mark CHAR(1) NOT NULL,
Subfield_Value CHAR(255) NOT NULL, Storage_ID INT UNSIGNED,
KEY ID_Index(Subfield_ID),
KEY Mark_Index (Subfield_Mark(1)),
KEY Subfield_Index (Subfield_Value(255)), primary key(Subfield_Key));

create table Auth_663_Tag_Table 
(Tag_Key INT UNSIGNED NOT NULL AUTO_INCREMENT, Tag_ID INT UNSIGNED NOT NULL, 
Indicator1 CHAR(1) NOT NULL,
Indicator2 CHAR(1) NOT NULL,
Tag CHAR(3) NOT NULL,
Subfield_ID INT UNSIGNED, Storage_ID INT UNSIGNED,
KEY ID_Index (Tag_ID),
KEY Tag_Index (Tag(3)), primary key(Tag_Key));

create table Auth_663_Subfield_Table 
(Subfield_Key INT UNSIGNED NOT NULL AUTO_INCREMENT,
Subfield_ID INT UNSIGNED NOT NULL, Subfield_Mark CHAR(1) NOT NULL,
Subfield_Value CHAR(255) NOT NULL, Storage_ID INT UNSIGNED,
KEY ID_Index (Subfield_ID),
KEY Mark_Index (Subfield_Mark(1)),
KEY Subfield_Index (Subfield_Value(255)), primary key(Subfield_Key));

create table Auth_664_Tag_Table 
(Tag_Key INT UNSIGNED NOT NULL AUTO_INCREMENT, Tag_ID INT UNSIGNED NOT NULL, 
Indicator1 CHAR(1) NOT NULL,
Indicator2 CHAR(1) NOT NULL,
Tag CHAR(3) NOT NULL,
Subfield_ID INT UNSIGNED, Storage_ID INT UNSIGNED,
KEY ID_Index (Tag_ID),
KEY Tag_Index (Tag(3)), primary key(Tag_Key));

create table Auth_664_Subfield_Table 
(Subfield_Key INT UNSIGNED NOT NULL AUTO_INCREMENT,
Subfield_ID INT UNSIGNED NOT NULL, Subfield_Mark CHAR(1) NOT NULL,
Subfield_Value CHAR(255) NOT NULL, Storage_ID INT UNSIGNED,
KEY ID_Index (Subfield_ID),
KEY Mark_Index (Subfield_Mark(1)),
KEY Subfield_Index (Subfield_Value(255)), primary key(Subfield_Key));

create table Auth_665_Tag_Table 
(Tag_Key INT UNSIGNED NOT NULL AUTO_INCREMENT, Tag_ID INT UNSIGNED NOT NULL, 
Indicator1 CHAR(1) NOT NULL,
Indicator2 CHAR(1) NOT NULL,
Tag CHAR(3) NOT NULL,
Subfield_ID INT UNSIGNED, Storage_ID INT UNSIGNED,
KEY ID_Index (Tag_ID),
KEY Tag_Index (Tag(3)), primary key(Tag_Key));

create table Auth_665_Subfield_Table 
(Subfield_Key INT UNSIGNED NOT NULL AUTO_INCREMENT,
Subfield_ID INT UNSIGNED NOT NULL, Subfield_Mark CHAR(1) NOT NULL,
Subfield_Value CHAR(255) NOT NULL, Storage_ID INT UNSIGNED,
KEY ID_Index (Subfield_ID),
KEY Mark_Index (Subfield_Mark(1)),
KEY Subfield_Index (Subfield_Value(255)), primary key(Subfield_Key));

create table Auth_667_Tag_Table 
(Tag_Key INT UNSIGNED NOT NULL AUTO_INCREMENT, Tag_ID INT UNSIGNED NOT NULL, 
Indicator1 CHAR(1) NOT NULL,
Indicator2 CHAR(1) NOT NULL,
Tag CHAR(3) NOT NULL,
Subfield_ID INT UNSIGNED, Storage_ID INT UNSIGNED,
KEY ID_Index (Tag_ID),
KEY Tag_Index (Tag(3)), primary key(Tag_Key));

create table Auth_667_Subfield_Table 
(Subfield_Key INT UNSIGNED NOT NULL AUTO_INCREMENT,
Subfield_ID INT UNSIGNED NOT NULL, Subfield_Mark CHAR(1) NOT NULL,
Subfield_Value CHAR(255) NOT NULL, Storage_ID INT UNSIGNED,
KEY ID_Index (Subfield_ID),
KEY Mark_Index (Subfield_Mark(1)),
KEY Subfield_Index (Subfield_Value(255)), primary key(Subfield_Key));

create table Auth_Link_Table
(Link_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
Date_Added TIMESTAMP, Date_Modified TIMESTAMP,
Auth_ID INT UNSIGNED, Record_ID INT UNSIGNED,
Link_Type ENUM('a','b','c','d','e','f','g'),
Tag_ID INT UNSIGNED, Tag CHAR(3) NOT NULL,
KEY Tag_Index (Tag(3)), primary key (Link_ID));

create table Auth_Control_Table
(Auth_Cont_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
Record_Status CHAR(1) NOT NULL,
Record_Type CHAR(1) NOT NULL,
Geo_Sub_Code CHAR(1) NOT NULL,
Record_Kind CHAR(1) NOT NULL,
Main_or_Added CHAR(1) NOT NULL,
Subj_Added CHAR(1) NOT NULL,
Ser_Added CHAR(1) NOT NULL,
Storage_ID INT UNSIGNED,
primary key (Auth_Cont_ID));

create table Holdings_Table
(Hold_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
Hold_Control_ID INT UNSIGNED NOT NULL, Date_Added TIMESTAMP, 
Date_Modified TIMESTAMP,
Notes_Tag_ID INT UNSIGNED, Hold_852_ID INT UNSIGNED, Caps_Pat_ID INT UNSIGNED,
Enum_Chron_ID INT UNSIGNED, Text_Hold_ID INT UNSIGNED,
Storage_ID INT UNSIGNED, 
KEY ID_Index (Hold_Control_ID),
primary key(Hold_ID));

create table Hold_Notes_Tag_Table
(Tag_Key INT UNSIGNED NOT NULL AUTO_INCREMENT,
Tag_ID INT UNSIGNED NOT NULL, Indicator1 CHAR(1) NOT NULL,
Indicator2 CHAR(1) NOT NULL, Tag CHAR(3) NOT NULL,
Subfield_ID INT UNSIGNED, Storage_ID INT UNSIGNED,
KEY ID_Index (Tag_ID),
KEY Tag_Index (Tag(3)), primary key(Tag_Key));

create table Hold_Notes_Tag_Subfield_Table 
(Subfield_Key INT UNSIGNED NOT NULL AUTO_INCREMENT,
Subfield_ID INT UNSIGNED NOT NULL, Subfield_Mark CHAR(1) NOT NULL,
Subfield_Value CHAR(255) NOT NULL, Storage_ID INT UNSIGNED,
KEY ID_Index (Subfield_ID),
KEY Mark_Index (Subfield_Mark(1)),
KEY Subfield_Index (Subfield_Value(255)), primary key(Subfield_Key));

create table Hold_852_Table
(Tag_Key INT UNSIGNED NOT NULL AUTO_INCREMENT,
Tag_ID INT UNSIGNED NOT NULL, Indicator1 CHAR(1) NOT NULL,
Indicator2 CHAR(1) NOT NULL, Tag CHAR(3) NOT NULL,
Subfield_ID INT UNSIGNED, Storage_ID INT UNSIGNED,
KEY ID_Index (Tag_ID),
KEY Tag_Index (Tag(3)), primary key(Tag_Key));

create table Hold_852_Subfield_Table 
(Subfield_Key INT UNSIGNED NOT NULL AUTO_INCREMENT,
Subfield_ID INT UNSIGNED NOT NULL, Subfield_Mark CHAR(1) NOT NULL,
Subfield_Value CHAR(255) NOT NULL, Storage_ID INT UNSIGNED,
KEY ID_Index (Subfield_ID),
KEY Mark_Index (Subfield_Mark(1)),
KEY Subfield_Index (Subfield_Value(255)), primary key(Subfield_Key));

create table Hold_Caps_Pat_Table
(Tag_Key INT UNSIGNED NOT NULL AUTO_INCREMENT,
Tag_ID INT UNSIGNED NOT NULL, Indicator1 CHAR(1) NOT NULL,
Indicator2 CHAR(1) NOT NULL, Tag CHAR(3) NOT NULL,
Subfield_ID INT UNSIGNED, Storage_ID INT UNSIGNED,
KEY ID_Index (Tag_ID),
KEY Tag_Index (Tag(3)), primary key(Tag_Key));

create table Hold_Caps_Pat_Subfield_Table 
(Subfield_Key INT UNSIGNED NOT NULL AUTO_INCREMENT,
Subfield_ID INT UNSIGNED NOT NULL, Subfield_Mark CHAR(1) NOT NULL,
Subfield_Value CHAR(255) NOT NULL, Storage_ID INT UNSIGNED,
KEY ID_Index (Subfield_ID),
KEY Mark_Index (Subfield_Mark(1)),
KEY Subfield_Index (Subfield_Value(255)), primary key(Subfield_Key));

create table Hold_Enum_Chron_Table
(Tag_Key INT UNSIGNED NOT NULL AUTO_INCREMENT,
Tag_ID INT UNSIGNED NOT NULL, Indicator1 CHAR(1) NOT NULL,
Indicator2 CHAR(1) NOT NULL, Tag CHAR(3) NOT NULL,
Subfield_ID INT UNSIGNED, Storage_ID INT UNSIGNED,
KEY ID_Index (Tag_ID),
KEY Tag_Index (Tag(3)), primary key(Tag_Key));

create table Hold_Enum_Chron_Subfield_Table 
(Subfield_Key INT UNSIGNED NOT NULL AUTO_INCREMENT,
Subfield_ID INT UNSIGNED NOT NULL, Subfield_Mark CHAR(1) NOT NULL,
Subfield_Value CHAR(255) NOT NULL, Storage_ID INT UNSIGNED,
KEY ID_Index (Subfield_ID),
KEY Mark_Index (Subfield_Mark(1)),
KEY Subfield_Index (Subfield_Value(255)), primary key(Subfield_Key));

create table Hold_Text_Hold_Table
(Tag_Key INT UNSIGNED NOT NULL AUTO_INCREMENT,
Tag_ID INT UNSIGNED NOT NULL, Indicator1 CHAR(1) NOT NULL,
Indicator2 CHAR(1) NOT NULL, Tag CHAR(3) NOT NULL,
Subfield_ID INT UNSIGNED, Storage_ID INT UNSIGNED,
KEY ID_Index (Tag_ID),
KEY Tag_Index (Tag(3)), primary key(Tag_Key));

create table Hold_Text_Hold_Subfield_Table 
(Subfield_Key INT UNSIGNED NOT NULL AUTO_INCREMENT,
Subfield_ID INT UNSIGNED NOT NULL, Subfield_Mark CHAR(1) NOT NULL,
Subfield_Value CHAR(255) NOT NULL, Storage_ID INT UNSIGNED,
KEY ID_Index (Subfield_ID),
KEY Mark_Index (Subfield_Mark(1)),
KEY Subfield_Index (Subfield_Value(255)), primary key(Subfield_Key));

create table Hold_Control_Table
(Hold_Cont_ID INT UNSIGNED NOT NULL AUTO_INCREMENT,
Record_Status CHAR(1) NOT NULL,
Record_Type CHAR(1) NOT NULL, 
Meth_Acq CHAR(1) NOT NULL, 
Cancel_Date CHAR(4) NOT NULL, 
Gen_Retention CHAR(1) NOT NULL, 
Spe_Retention CHAR(3) NOT NULL, 
Cmplt CHAR(4) NOT NULL, 
Lend_Pol CHAR(1) NOT NULL,
Re_Pol CHAR(1) NOT NULL,
Lan_Code CHAR(3) NOT NULL,
Storage_ID INT UNSIGNED,
primary key(Hold_Cont_ID));

create table Storage_Table
(Storage_Key INT UNSIGNED NOT NULL AUTO_INCREMENT,
Storage_ID INT UNSIGNED NOT NULL, Blob_ID INT UNSIGNED, Text_ID INT UNSIGNED,
Med_Blob_ID INT UNSIGNED, Med_Text_ID INT UNSIGNED, Long_Blob_ID INT UNSIGNED,
Long_Text_ID INT UNSIGNED, URI CHAR(255),
Storage_Type ENUM('B','MB','LB','U'),
KEY ID_Index (Storage_ID),
primary key(Storage_Key));

create table Blob_Table
(Blob_Key INT UNSIGNED NOT NULL AUTO_INCREMENT,
Blob_ID INT UNSIGNED NOT NULL, Blob_Data BLOB,
Seq_No  INT UNSIGNED,
KEY ID_Index (Blob_ID),
primary key(Blob_Key));

create table Med_Blob_Table
(Med_Blob_Key INT UNSIGNED NOT NULL AUTO_INCREMENT,
Med_Blob_ID INT UNSIGNED NOT NULL, Blob_Data MEDIUMBLOB,
Seq_No  INT UNSIGNED,
KEY ID_Index (Med_Blob_ID),
primary key(Med_Blob_Key));

create table Long_Blob_Table
(Long_Blob_Key INT UNSIGNED NOT NULL AUTO_INCREMENT,
Long_Blob_ID INT UNSIGNED NOT NULL, Long_Blob_Data LONGBLOB,
Seq_No  INT UNSIGNED,
KEY ID_Index (Long_Blob_ID),
primary key(Long_Blob_Key));
