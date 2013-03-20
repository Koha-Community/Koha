

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

INSERT IGNORE INTO systempreferences (variable,explanation,options,type,value)
VALUES('OPACISBD','OPAC ISBD View','90|20', 'Textarea',
'#200|<h2>Заголовок: |{200a}{. 200c}{ : 200e}{200d}{. 200h}{. 200i}|</h2>\r\n#500|<label class="ipt">Уніфікована назва: </label>|{500a}{. 500i}{. 500h}{. 500m}{. 500q}{. 500k}<br/>|\r\n#517|<label class="ipt"> </label>|{517a}{ : 517e}{. 517h}{, 517i}<br/>|\r\n#541|<label class="ipt"> </label>|{541a}{ : 541e}<br/>|\r\n#200||<label class="ipt">Автори: </label><br/>|\r\n#700||<a href="opac-search.pl?op=do_search&marclist=7009&operator==&type=intranet&value={7009}"> <img border="0" src="/opac-tmpl/css/en/images/filefind.png" height="15" title="Пошук за автором"></a>{700c}{ 700b}{ 700a}{ 700d}{ (700f)}{. 7004}<br/>|\r\n#701||<a href="opac-search.pl?op=do_search&marclist=7009&operator==&type=intranet&value={7019}"> <img border="0" src="/opac-tmpl/css/en/images/filefind.png" height="15" title="Пошук за автором"></a>{701c}{ 701b}{ 701a}{ 701d}{ (701f)}{. 7014}<br/>|\r\n#702||<a href="opac-search.pl?op=do_search&marclist=7009&operator==&type=intranet&value={7029}"> <img border="0" src="/opac-tmpl/css/en/images/filefind.png" height="15" title="Пошук за автором"></a>{702c}{ 702b}{ 702a}{ 702d}{ (702f)}{. 7024}<br/>|\r\n#710||<a href="opac-search.pl?op=do_search&marclist=7109&operator==&type=intranet&value={7109}"> <img border="0" src="/opac-tmpl/css/en/images/filefind.png" height="15" title="Пошук за автором"></a>{710a}{ (710c)}{. 710b}{ : 710d}{ ; 710f}{ ; 710e}<br/>|\r\n#711||<a href="opac-search.pl?op=do_search&marclist=7109&operator==&type=intranet&value={7119}"> <img border="0" src="/opac-tmpl/css/en/images/filefind.png" height="15" title="Пошук за автором"></a>{711a}{ (711c)}{. 711b}{ : 711d}{ ; 711f}{ ; 711e}<br/>|\r\n#712||<a href="opac-search.pl?op=do_search&marclist=7109&operator==&type=intranet&value={7129}"> <img border="0" src="/opac-tmpl/css/en/images/filefind.png" height="15" title="Пошук за автором"></a>{712a}{ (712c)}{. 712b}{ : 712d}{ ; 712f}{ ; 712e}<br/>|\r\n#210|<label class="ipt">Уніфікована форма назви: </label>|{ 210a}<br/>|\r\n#210|<label class="ipt">Видавець: </label>|{ 210c}<br/>|\r\n#210|<label class="ipt">Дата публікації: </label>|{ 210d}<br/>|\r\n#215|<label class="ipt">Фізичний опис: </label>|{215a}{ : 215c}{ ; 215d}{ + 215e}|<br/>\r\n#225|<label class="ipt">Серія:</label>|<a href="opac-search.pl?op=do_search&marclist=225a&operator==&type=intranet&value={225a}"> <img border="0" src="/opac-tmpl/css/en/images/filefind.png" height="15" title="Пошук за {225a}"></a>{ (225a}{ = 225d}{ : 225e}{. 225h}{. 225i}{ / 225f}{, 225x}{ ; 225v}|)<br/>\r\n#200||<label class="ipt">Предметні рубрики: </label><br/>|\r\n#600||<a href="opac-search.pl?op=do_search&marclist=6009&operator==&type=intranet&value={6009}"><img border="0" src="/opac-tmpl/css/en/images/filefind.png" height="15" title="Пошук за {6009}"></a>{ 600c}{ 600b}{ 600a}{ 600d}{ (600f)} {-- 600x }{-- 600z }{-- 600y}<br />|\r\n#604||<a href="opac-search.pl?op=do_search&marclist=6049&operator==&type=intranet&value={6049}"><img border="0" src="/opac-tmpl/css/en/images/filefind.png" height="15" title="Пошук за {6049}"></a>{ 604a}{. 604t}<br />|\r\n#601||<a href="opac-search.pl?op=do_search&marclist=6019&operator==&type=intranet&value={6019}"><img border="0" src="/opac-tmpl/css/en/images/filefind.png" height="15" title="Пошук за {6019}"></a>{ 601a}{ (601c)}{. 601b}{ : 601d} { ; 601f}{ ; 601e}{ -- 601x }{-- 601z }{-- 601y}<br />|\r\n#605||<a href="opac-search.pl?op=do_search&marclist=6059&operator==&type=intranet&value={6059}"><img border="0" src="/opac-tmpl/css/en/images/filefind.png" height="15" title="Пошук за {6059}"></a>{ 605a}{. 605i}{. 605h}{. 605k}{. 605m}{. 605q} {-- 605x }{-- 605z }{-- 605y }{-- 605l}<br />|\r\n#606||<a href="opac-search.pl?op=do_search&marclist=6069&operator==&type=intranet&value={6069}"><img border="0" src="/opac-tmpl/css/en/images/filefind.png" height="15" title="Пошук за {6069}">xx</a>{ 606a}{-- 606x }{-- 606z }{606y }<br />|\r\n#607||<a href="opac-search.pl?op=do_search&marclist=6079&operator==&type=intranet&value={6079}"><img border="0" src="/opac-tmpl/css/en/images/filefind.png" height="15" title="Пошук за {6079}"></a>{ 607a}{-- 607x}{-- 607z}{-- 607y}<br />|\r\n#010|<label class="ipt">ISBN: </label>|{010a}|<br/>\r\n#011|<label class="ipt">ISSN: </label>|{011a}|<br/>\r\n#200||<label class="ipt">Нотатки: </label>|<br/>\r\n#300||{300a}|<br/>\r\n#320||{320a}|<br/>\r\n#327||{327a}|<br/>\r\n#328||{328a}|<br/>\r\n#200||<br/><h2>Примірники</h2>|\r\n#200|<table>|<th>Місцезнаходження</th><th>Cote</th>|\r\n#995||<tr><td>{995e}&nbsp;&nbsp;</td><td> {995k}</td></tr>|\r\n#200|||</table>');
