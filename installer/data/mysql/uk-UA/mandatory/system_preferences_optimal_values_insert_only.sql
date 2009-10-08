

-- Admin - Управління

UPDATE systempreferences SET value='OPENOFFICE.ORG' WHERE variable='MIME';

-- Acquisitions - Надходження

UPDATE systempreferences SET value='0.20' WHERE variable='gist';

-- EnhancedContent - Розширений вміст

UPDATE systempreferences SET value='lvivsteflibr-20' WHERE variable='AmazonAssocTag';

UPDATE systempreferences SET value='0VQ9R332RKW3AAR6TG82' WHERE variable='AWSAccessKeyID';

-- Authorities - Авторитетні джерела

-- Cataloguing - Каталогізація

UPDATE systempreferences SET value='incremental' WHERE variable='autoBarcode';

UPDATE systempreferences SET value='udc' WHERE variable='DefaultClassificationSource';

UPDATE systempreferences SET value='#942|<code><b>|{942j}|</b></code><br/>
#700|<i>|{700a }{ 700g, }|; </i>
#701|<i>|{701a }{ 701g, }|; </i>
#702|<i>|{702a }{ 702g, }|; </i>
#200||<b>{200a}</b>{ [200b] }{. 200c}{: 200e}{. 200h}{. 200i}{ / 200f}{; 200g}|
#230||{; 230a}|
#205||{; 205a}{, 205b}{ = 205d}{ / 205f}{; 205g}|
#210|<br/>|{; 210a}{ (210b) }{: 210c}{, 210d}|. - 
#210|(|{ 210e}{(210f)}{: 210g}{, 210h}|)
#215|<quantitative>|{; 215a}{: 215c}{; 215d}{ + 215e}|</quantitative>
#225|<br/><description>(|{ 225a}{ = 225d}{: 225e}{. 225h}{. 225i}{ / 225f}{, I225x}{; 225v}|)</description>
#010|<br/>&nbsp;&nbsp;&nbsp;<ISBN>ISBN |{010a}{: 010d}|</ISBN>
#606|<br/>&nbsp;&nbsp;&nbsp;<thematic>|{- 606a }|</thematic>
#686|<br/>&nbsp;&nbsp;&nbsp;ББК |{686a   }|
#675|<br/>&nbsp;&nbsp;&nbsp;УДК |{675a   }|
#676|<br/>&nbsp;&nbsp;&nbsp;ДКД |{676a   }|
#952|<br><block952><div align="right">|{\n952b}{ - 952o}{ [952p]}|</block952></div>
#300|<br/>&nbsp;&nbsp;&nbsp;<i>Примітки:</i><br/> |{300a   }|
#327|<br/>&nbsp;&nbsp;&nbsp;<i>Зміст:</i><br/> |{327a   }|
#330|<br/>&nbsp;&nbsp;&nbsp;<i>Анотація:</i><br/> |{330a   }|' WHERE variable='ISBD';

UPDATE systempreferences SET value='942hv' WHERE variable='itemcallnumber';

UPDATE systempreferences SET value='UNIMARC' WHERE variable='marcflavour';

UPDATE systempreferences SET value="
        'title' => '200a,200c,200d,200e,225a,225d,225e,225f,225h,225i,225v,500*,501*,503*,510*,512*,513*,514*,515*,516*,517*,518*,519*,520*,530*,531*,532*,540*,541*,545*,604t,610t,605a',
        'author' => '200f,600a,601a,604a,700a,700b,700c,700d,700a,701b,701c,701d,702a,702b,702c,702d,710a,710b,710c,710d,711a,711b,711c,711d,712a,712b,712c,712d',
        'se' => '225a',
        'isbn' => '010a',
        'issn' => '011a',
        'biblionumber' => '9999',
        'itemtype' => '200b,942c,952y',
        'language' => '101a',
        'pl' => '210a',
        'publisher' => '210c',
        'date' => '210d',
        'note' => '300a,301a,302a,303a,304a,305a,306az,307a,308a,309a,310a,311a,312a,313a,314a,315a,316a,317a,318a,319a,320a,321a,322a,323a,324a,325a,326a,327a,328a,330a,332a,333a,336a,337a,345a',
        'Koha-Auth-Number' => '6009,6019,6029,6039,6049,6059,6069,6109,7009,7019,7029,7109,7119,7129',
        'subject' => '600*,601*,606*,610*',
        'an' => '6009,6019,6069,6109,6079',
        'su' => '600a,601a,606a,610a,607a,608a',
        'lcn' => '686a,952o',
        'yr' => '210d',
        'mt' => '200b',
        'dewey' => '676a',
        'bc' => '952p',
        'callnum' => '952o',
        'homebranch' => '952a,952c',
        'host-item' => '992b,992c',
        'keyword' => '200*,600*,700*,400*,210*' 
" WHERE variable='NoZebraIndexes';

-- Circulation - Обіг

-- I18N/L10N

UPDATE systempreferences SET value='metric' WHERE variable='dateformat';

UPDATE systempreferences SET value='uk-UA,ru-RU,en,fr-FR,de-DE' WHERE variable='language';

UPDATE systempreferences SET value='uk-UA,ru-RU,en,fr-FR,de-DE' WHERE variable='opaclanguages';

-- Logs - Протоколи

-- OAI-PMH

-- OPAC - Електронний каталог

UPDATE systempreferences SET value='Вітаємо у АБІС Koha...\r\n<hr>' WHERE variable='OpacMainUserBlock';

UPDATE systempreferences SET value='Тут будуть важливі посилання.' WHERE variable='OpacNav';

-- Patrons - Відвідувачі

UPDATE systempreferences SET value='Пане|Пані|Містер|Міссіс|Шановний|Шановна|Товариш|Добродій|Добродійка' WHERE variable='BorrowersTitles';

UPDATE systempreferences SET value='1' WHERE variable='ExtendedPatronAttributes';

UPDATE systempreferences SET value='1' WHERE variable='patronimages';

UPDATE systempreferences SET value='surname|cardnumber' WHERE variable='BorrowerMandatoryField';

-- Searching - Шукання

-- StaffClient - Клієнт для бібліотекарів

-- Local Use - Місцеве використання



