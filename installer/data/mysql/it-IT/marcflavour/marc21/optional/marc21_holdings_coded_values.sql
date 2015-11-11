-- Coded values conforming to the Z39.77-2006 Holdings Statements for Bibliographic Items');
-- ISSN: 1041-5653
-- Refer to http://www.niso.org/standards/index.html

-- General Holdings: Type of Unit Designator
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_UT','0','Informazione non disponibile, non applicabile');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_UT','a','Record bibliografico di base');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_UT','c','Record secondario: supplementi, fascicoli speciali, materiale di accompagnamento, altre forme secondarie');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_UT','d','Indici');

-- Physical Form Designators
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','au' ,'Materiale cartografico');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','ad' ,'Materiale cartografico, atlante');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','ag' ,'Materiale cartografico, diagramma');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','aj' ,'Materiale cartografico, carta geografica');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','ak' ,'Materiale cartografico, profilo');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','aq' ,'Materiale cartografico, plastico');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','ar' ,'Materiale cartografico, immagine di rilevamento');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','as' ,'Materiale cartografico, sezione');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','ay' ,'Materiale cartografico, veduta');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','az' ,'CMateriale cartografico, altro');

INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','cu' ,'Risorsa elettronica');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','ca' ,'Risorsa elettronica, cartuccia nastro');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','cb' ,'Risorsa elettronica, cartuccia con chip di memoria');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','cc' ,'Risorsa elettronica, cartuccia disco ottico del computer');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','cf' ,'Risorsa elettronica, cassetta del nastro');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','ch' ,'Risorsa elettronica, bobina del nastro');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','cj' ,'Risorsa elettronica, disco magnetico');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','cm' ,'Risorsa elettronica, disco ottico magnetico');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','co' ,'Risorsa elettronica, disco ottico');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','cr' ,'Risorsa elettronica, remoto');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','cz' ,'Risorsa elettronica, altro');

INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','du' ,'Globo');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','da' ,'Globo, globo celeste');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','db' ,'Globo, globo planetario o lunare');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','dc' ,'Globo, globo terrestre');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','de' ,'Globo, globo della luna del pianeta Terra');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','dz' ,'Globo, altro');

INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','ou' ,'Kit');

INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','hu' ,'Microforma');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','ha' ,'Microforma, scheda a finistra');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','hb' ,'Microforma, microfilm in cartuccia');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','hc' ,'Microforma, microfilm in cassetta');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','hd' ,'Microforma, microfilm in bobina');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','he' ,'Microforma, microfiche');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','hf' ,'Microforma, cassatta di microfiche');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','hg' ,'Microforma, micropaco');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','hz' ,'Microforma, altro');

INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','mu' ,'Film');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','mc' ,'Film, cartuccia di film');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','mf' ,'Film, cassetta di film');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','mr' ,'Film, bobina di film');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','mz' ,'Film, altro');

INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','ku' ,'Grafica non proiettabile');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','kc' ,'Grafica non proiettabile, collage');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','kd' ,'Grafica non proiettabile, disegno');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','ke' ,'Grafica non proiettabile, pittura');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','kf' ,'Grafica non proiettabile, stampa fotomeccanica');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','kg' ,'Grafica non proiettabile, negativo di foto');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','kh' ,'Grafica non proiettabile, stampa di foto');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','ki' ,'Grafica non proiettabile, immagine');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','kj' ,'Grafica non proiettabile, stampa');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','kl' ,'Grafica non proiettabile, disegno tecnico');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','kn' ,'Grafica non proiettabile, diagramma');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','ko' ,'Grafica non proiettabile, scheda didattica');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','kz' ,'Grafica non proiettabile, altro');

INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','qu' ,'Musica notata');

INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','gu' ,'Grafica proiettata');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','gc' ,'Grafica proiettata, cartuccia di filmina');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','gd' ,'Grafica proiettata, spezzone');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','gf' ,'Grafica proiettata, altro tipo di filmina');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','go' ,'Grafica proiettata, rullo di filmina');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','gs' ,'Grafica proiettata, diapositiva');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','gt' ,'Grafica proiettata, transparente');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','gz' ,'Grafica proiettata, altro');

INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','ru' ,'Immagine di telerilevamento');

INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','su' ,'Audioregistrazione');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','sd' ,'Audioregistrazione, disco sonoro');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','se' ,'Audioregistrazione, cilindro');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','sg' ,'Audioregistrazione, audiocartuccia');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','si' ,'Audioregistrazione, colonna sonora film');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','sq' ,'Audioregistrazione, rullo');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','ss' ,'Audioregistrazione, audiocassetta');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','st' ,'Audioregistrazione, audiobobina');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','sw' ,'Audioregistrazione, registrazione su filo');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','sz' ,'Audioregistrazione, altro');

INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','tu' ,'Testo');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','ta' ,'Testo, caratteri normali');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','tb' ,'Testo, grandi caratteri');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','tc' ,'Testo, Braille');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','td' ,'Testo, testo in raccoglitore a fogli mobili');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','tz' ,'Testo, altro');

INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','vu' ,'Videoregistrazione');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','vc' ,'Videoregistrazione, videocartuccia');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','vd' ,'Videoregistrazione, videodisco');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','vf' ,'Videoregistrazione, videocassetta');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','vr' ,'Videoregistrazione, videobobina');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','vz' ,'Videoregistrazione, altro');

INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','zu' ,'La forma fisica non è specificata');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','zm' ,'Multiple forme fisiche');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_PF','zz' ,'Altre forme fisiche');

-- General Holdings: Completeness Designator
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_C','0','Informazione non disponibile o conservazione limitata');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_C','1','Completo (95%-100%)');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_C','2','Incompleto (50%-94%)');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_C','3','Molto incompleta o roviata (meno del 50%)');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_C','4','Non applicabile');

-- General Holdings: Acquisition Status Designator
-- This data element specifies acquisition status for the unit at the time of the holdings report.

INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_AS','0','Informazione non disponibile o conservazione limitata');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_AS','1','Altro');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_AS','2','Ricevuto e completo, o cessato');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_AS','3','Ordinato');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_AS','4','Attualmente ricevuto');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_AS','5','Attualmente non ricevuto');

-- General Holdings: Retention Designator
-- This data element specifies the retention policy for the unit at the time of the holdings report.

INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_RD','0','Informazione non disponibile');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_RD','1','Altro');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_RD','2','Conservato ma sostituito dagli aggiornamenti');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_RD','3','Vieme conservato un fascicolo come esempio');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_RD','4','Conservato fino alla sostituzione con microforma o altro formato di conservazione');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_RD','5','Conservato fino alla sostiuzione di un cumulativo, un volume sostitutivo o revisione');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_RD','6','Conservazione limitata (solo alcune parti vengono tenute)');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_RD','7','Nessuna conservazione(niente viene tenutp)');
INSERT INTO `authorised_values` (category, authorised_value, lib) VALUES ('HINGS_RD','8','Conservazione permanente (tutte le parti tenute a tempo indefinito)');
