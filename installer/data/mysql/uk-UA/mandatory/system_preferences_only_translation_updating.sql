
-- Admin - Управління

UPDATE systempreferences SET explanation='Якщо ввімкнуто, то діятиме IP-автентифікація, що блокуватиме доступ до бібліотечного інтерфейсу з несанкціонованої IP-адреси' WHERE variable='AutoLocation';	 
-- If ON, IP authentication is enabled, blocking access to the staff client from unauthorized IP addresses

UPDATE systempreferences SET explanation='Кількість налагоджувальної інформації, що направляються у браузер, коли трапляються помилки (встановити в 0 для виробничого варіанту). 0 = ні, 1 = дещо, 2 = більшість' WHERE variable='DebugLevel';	
-- Define the level of debugging information sent to the browser when errors are encountered (set to 0 in production). 0=none, 1=some, 2=most

UPDATE systempreferences SET explanation='Символ-роздільник по умовчанню для експорту звітів' WHERE variable='delimiter';	
-- Define the default separator character for exporting reports

UPDATE systempreferences SET explanation='Перелік завантажених структур у веб-встановлювачі' WHERE variable='FrameworksLoaded';	
-- Frameworks loaded through webinstaller

UPDATE systempreferences SET explanation='Використання підрозділення привілеїв для працівників' WHERE variable='GranularPermissions';	
-- Use detailed staff user permissions

UPDATE systempreferences SET explanation='Якщо ввімкнуто, то підвищує безпеку між бібліотеками. Використовується, коли бібліотеки використовують одну інсталяцію Коха.' WHERE variable='IndependantBranches';	
-- If ON, increases security between libraries

UPDATE systempreferences SET explanation='Якщо ввімкнуто, то авторизація взагалі непотрібна. Будьте уважні!' WHERE variable='insecure';	
-- If ON, bypasses all authentication. Be careful!

UPDATE systempreferences SET explanation='Тека «includes» може бути корисна для особливого вигляду Коха (наприклад, «includes» чи «includes_npl»)' WHERE variable='intranet_includes';	
-- The includes directory you want for specific look of Koha (includes or includes_npl for example)

UPDATE systempreferences SET explanation='Адреса електронної пошти, на яку приходять запити відвідувачів щодо модифікації їх облікових записів' WHERE variable='KohaAdminEmailAddress';	
-- Define the email address where patron modification requests are sent

UPDATE systempreferences SET explanation='Адреса що використовується при друці квитанцій, прострочень тощо, якщо відрізняється від фізичної адреси' WHERE variable='libraryAddress';	
-- The address to use for printing receipts, overdues, etc. if different than physical address

UPDATE systempreferences SET explanation='Програма за умовчанням для експорту файлів звітів' WHERE variable='MIME';	
-- Define the default application for exporting report data

UPDATE systempreferences SET explanation='Якщо вімкнуто, то будуть відключені зображення типів одиниць' WHERE variable='noItemTypeImages';	
-- If ON, disables item-type images

UPDATE systempreferences SET explanation='Базова URL-адреса для ЕК, наприклад, opac.mylibrary.com, http:// буде додано автоматично за допомогою Коха.' WHERE variable='OPACBaseURL';	
-- Specify the Base URL of the OPAC, e.g., opac.mylibrary.com, the http:// will be added automatically by Koha.

UPDATE systempreferences SET explanation='Якщо ввімкнуто, то будуть включені попередження про обслуговування в ЕК' WHERE variable='OpacMaintenance';	
-- If ON, enables maintenance warning in OPAC

UPDATE systempreferences SET explanation='Використання бази даних чи тимчасового файлу для зберігання даних сесії' WHERE variable='SessionStorage';	
-- Use database or a temporary file for storing session data

UPDATE systempreferences SET explanation='Працювати в режимі одного підрозділу та приховати вибір підрозділів в ЕК' WHERE variable='singleBranchMode';	
-- Operate in Single-branch mode, hide branch selection in the OPAC

UPDATE systempreferences SET explanation='Базова URL-адреса для бібліотечного інтерфейсу' WHERE variable='staffClientBaseURL';	
-- Specify the base URL of the staff client

UPDATE systempreferences SET explanation='Період проміжку часу бездіяльності для аутентифікації (у секундах)' WHERE variable='timeout';	
-- Inactivity timeout for cookies authentication (in seconds)

UPDATE systempreferences SET explanation='Версія бази даних Коха. ЗАСТЕРЕЖЕННЯ: не змінюйте це значення вручну, ним керує веб-встановлювач' WHERE variable='Version';	
-- The Koha database version. WARNING: Do not change this value manually, it is maintained by the webinstaller


-- Acquisitions - Надходження

UPDATE systempreferences SET explanation='Звичайні (normal) придбання на основі статей витрат або ж прості (simple) надходження бібліографічних даних' WHERE variable='acquisitions';
-- Choose Normal, budget-based acquisitions, or Simple bibliographic-data acquisitions

UPDATE systempreferences SET explanation='Якщо ввімкнуто, то висилати пропозиції відвідувачів електронною поштою, а не керувати ними у надходженнях' WHERE variable='emailPurchaseSuggestions';
-- 	If ON, patron suggestions are emailed rather than managed in Acquisitions

UPDATE systempreferences SET explanation='Ставка ПДВ за умовчанням; НЕ в процентах (%), а в числовій формі (0.12 означатиме 12%)' WHERE variable='gist';
-- 	Default Goods and Services tax rate NOT in %, but in numeric form (0.12 for 12%), set to 0 to disable GST


-- EnhancedContent - Розширений вміст

UPDATE systempreferences SET explanation='Див.: http://aws.amazon.com' WHERE variable='AmazonAssocTag';
-- 	 See: http://aws.amazon.com

UPDATE systempreferences SET explanation='Ввімкнути розширений вміст з Amazon — Ви ПОВИННІ встановити AWSAccessKeyID та AmazonAssocTag якщо тут ввімкнено' WHERE variable='AmazonContent';
-- 	Turn ON Amazon Content - You MUST set AWSAccessKeyID and AmazonAssocTag if enabled

UPDATE systempreferences SET explanation='Використовується для встановлення локалі для Ваших веб-сервісів від Amazon.com' WHERE variable='AmazonLocale';
-- 	Use to set the Locale of your Amazon.com Web Services

UPDATE systempreferences SET explanation='Ввімкнути можливість Amazon для пошуку подібних записів — Ви повинні встановити AWSAccessKeyID та AmazonAssocTag якщо тут ввімкнено' WHERE variable='AmazonSimilarItems';
-- 	Turn ON Amazon Similar Items feature - You MUST set AWSAccessKeyID and AmazonAssocTag if enabled

UPDATE systempreferences SET explanation='Див.: http://aws.amazon.com' WHERE variable='AWSAccessKeyID';
-- 	See: http://aws.amazon.com

UPDATE systempreferences SET explanation='Див: http://aws.amazon.com. Зауважте, що це ключ став необхідний після 15.8.2009 для того, щоб отримувати будь-який розширений вміст, окрім обкладинок книг від Amazon.' WHERE variable='AWSPrivateKey';
-- See:  http://aws.amazon.com.  Note that this is required after 2009/08/15 in order to retrieve any enhanced content other than book covers from Amazon.

UPDATE systempreferences SET explanation='URL-шаблон посилання для „Моя бібліотечна книжкова крамниця“(МБКП), для якого значення „ключа“(key) додається в кінці та „https://“ додається попереду. Він повинен включати в себе ім’я Вашого хосту (hostname) та „батьківський номер“ (Parent Number). Щоб вимкнути МБКП-посилання, зробіть це значення пустим. Приклад: ocls.mylibrarybookstore.com/MLB/actions/searchHandler.do?nextPage=bookDetails&parentNum=10923&key=' WHERE variable='BakerTaylorBookstoreURL';
-- 	URL template for "My Libary Bookstore" links, to which the "key" value is appended, and "https://" is prepended. It should include your hostname and "Parent Number". Make this variable empty to turn MLB links off. Example: ocls.mylibrarybookstore.com/MLB/actions/searchHandler.do?nextPage=bookDetails&parentNum=10923&key=

UPDATE systempreferences SET explanation='Увімкнути або вимкнути усі функції «BakerTaylor»' WHERE variable='BakerTaylorEnabled';
-- 	Enable or disable all Baker & Taylor features.

UPDATE systempreferences SET explanation='Пароль «BakerTaylor» для «кав’ярні вмісту» (зовнішній вміст)' WHERE variable='BakerTaylorPassword';
-- 	Baker & Taylor Password for Content Cafe (external content)

UPDATE systempreferences SET explanation='Ім’я користувача «BakerTaylor» для «кав’ярні вмісту» (зовнішній вміст)' WHERE variable='BakerTaylorUsername';
-- 	Baker & Taylor Username for Content Cafe (external content)

UPDATE systempreferences SET explanation='Якщо увімкнено, Коха буде опитувати один чи більше веб-сервісів ISBN щодо поєднаних ISBN та відображати їх на вкладці «Видання» на сторінках з подробицями' WHERE variable='FRBRizeEditions';
-- 	If ON, Koha will query one or more ISBN web services for associated ISBNs and display an Editions tab on the details pages

UPDATE systempreferences SET explanation='Якщо увімкнуто, виводить обкладинки з допомогою API «Пошуку книг Google»' WHERE variable='GoogleJackets';
-- 	if ON, displays jacket covers from Google Books API

UPDATE systempreferences SET explanation='Використовується з FRBRizeEditions та XISBN. Ви можете підписатися на AffiliateID тут: http://www.worldcat.org/wcpa/do/AffiliateUserServices?method=initSelfRegister' WHERE variable='OCLCAffiliateID';
-- 	Use with FRBRizeEditions and XISBN. You can sign up for an AffiliateID here: http://www.worldcat.org/wcpa/do/AffiliateUserServices?method=initSelfRegister

UPDATE systempreferences SET explanation='Відображення зображень обкладинок в ЕК з веб-сервісів Amazon' WHERE variable='OPACAmazonCoverImages';
-- Display cover images on OPAC from Amazon Web Services

UPDATE systempreferences SET explanation='Включити отримання даних з Amazon в ЕК — Ви ПОВИННІ налаштувати AWSAccessKeyID та AmazonAssocTag якщо тут ввімкнено' WHERE variable='OPACAmazonContent';
-- 	Turn ON Amazon Content in the OPAC - You MUST set AWSAccessKeyID and AmazonAssocTag if enabled

UPDATE systempreferences SET explanation='Включити можливість пошуку подібних записів від Amazon — Ви ПОВИННІ налаштувати AWSAccessKeyID та AmazonAssocTag якщо тут ввімкнено' WHERE variable='OPACAmazonSimilarItems';
-- 	Turn ON Amazon Similar Items feature - You MUST set AWSAccessKeyID and AmazonAssocTag if enabled

UPDATE systempreferences SET explanation='Якщо ввімкнуто, то ЕК буде опитувати один чи більше веб-сервісів ISBN щодо пов’язаних ISBN та відобразить на вкладці «Видання» на сторінці з подробицями' WHERE variable='OPACFRBRizeEditions';
-- 	If ON, the OPAC will query one or more ISBN web services for associated ISBNs and display an Editions tab on the details pages

UPDATE systempreferences SET explanation='Вмикає або вимикає усі функцій міток. Це основний перемикач для міток.' WHERE variable='TagsEnabled';
-- 	Enables or disables all tagging features. This is the main switch for tags.

UPDATE systempreferences SET explanation='Шлях на сервері до локальної виконавчої програми ispell, використовується для встановлення $Lingua::Ispell::path. Цей словник використовується як «білий список» для попередньо дозволених міток.' WHERE variable='TagsExternalDictionary';
-- 	Path on server to local ispell executable, used to set $Lingua::Ispell::path This dictionary is used as a "whitelist" of pre-allowed tags.

UPDATE systempreferences SET explanation='Дозволити користувачам вводити мітки на сторінці з подробицями.' WHERE variable='TagsInputOnDetail';
-- 	Allow users to input tags from the detail page.

UPDATE systempreferences SET explanation='Дозволити користувачам вводити мітки зі списку результатів пошуку.' WHERE variable='TagsInputOnList';
-- 	Allow users to input tags from the search results list.

UPDATE systempreferences SET explanation='Вимагати затвердження міток відвідувачів перед тим як вони стануть видимими.' WHERE variable='TagsModeration';
-- 	Require tags from patrons to be approved before becoming visible.

UPDATE systempreferences SET explanation='Кількість міток для показу на сторінці подробиць. 0 — відключено.' WHERE variable='TagsShowOnDetail';
-- 	Number of tags to display on detail page. 0 is off.

UPDATE systempreferences SET explanation='Кількість міток для відображення у списку результатів пошуку. 0 — відключено.' WHERE variable='TagsShowOnList';
-- 	Number of tags to display on search results list. 0 is off.

UPDATE systempreferences SET explanation='Використовується з FRBRizeEditions. Якщо ввімкнуто, Коха буде використовувати веб-сервіс ThingISBN для вкладки «Видання» на сторінці з подробицями.' WHERE variable='ThingISBN';
-- 	Use with FRBRizeEditions. If ON, Koha will use the ThingISBN web service in the Editions tab on the detail pages.

UPDATE systempreferences SET explanation='Використовується з FRBRizeEditions. Якщо ввімкнуто, Коха буде використовувати веб-сервіс OCLC xISBN для вкладки «Видання» на сторінці з подробицями. Див.: http://www.worldcat.org/affiliate/webservices/xisbn/app.jsp' WHERE variable='XISBN';
-- 	Use with FRBRizeEditions. If ON, Koha will use the OCLC xISBN web service in the Editions tab on the detail pages. See: http://www.worldcat.org/affiliate/webservices/xisbn/app.jsp

UPDATE systempreferences SET explanation='Веб-сервіс xISBN є безкоштовним для некомерційного використання при використанні не більше 500 запитів на день' WHERE variable='XISBNDailyLimit';
-- 	The xISBN Web service is free for non-commercial use when usage does not exceed 500 requests per day


-- Authorities — Авторитетні джерела

UPDATE systempreferences SET explanation='Показувати ієрархії у деталізації для авторитетних джерел' WHERE variable='AuthDisplayHierarchy';
-- Allow the display of hierarchy in Authority details

UPDATE systempreferences SET explanation='Використовується для поділу переліку авторитетних джерел на дисплеї. Зазвичай --' WHERE variable='authoritysep';
--  Used to separate a list of authorities in a display. Usually --

UPDATE systempreferences SET explanation='Якщо ввімкнуто, при додаванні нового бібліотечного запису буде відбуватися перевірка серед існуючих авторитетних записів та будуть створюватися відповідні на льоту, якщо таких не існуватиме' WHERE variable='BiblioAddsAuthorities';
-- If ON, adding a new biblio will check for an existing authority record and create one on the fly if one doesn't exist

UPDATE systempreferences SET explanation='Якщо ввімкнуто, зміна авторитетного запису не буде негайно оновлювати усі пов’язані з ним бібліографічні записи, зверніться до Вашого системного адміністратора для включення в cron завдання merge_authorities.pl' WHERE variable='dontmerge';
-- If ON, modifying an authority record will not update all associated bibliographic records immediately, ask your system administrator to enable the merge_authorities.pl cron job


-- Cataloguing — Каталогізація

UPDATE systempreferences SET explanation='Якщо ввімкнуто, МАРК-редактор не показуватиме описи полів/підполів' WHERE variable='advancedMARCeditor';
-- 	 If ON, the MARC editor won't display field/subfield descriptions

UPDATE systempreferences SET explanation='Використовується для авто-створення штрих-кодів: приріст буде мати форму 1, 2, 3; щорічник матиме вигляд 2007-0001, 2007-0002; MD08010001 для форми дпррммприріст де дп = домашній підрозділ' WHERE variable='autoBarcode';
-- 	Used to autogenerate a barcode: incremental will be of the form 1, 2, 3; annual of the form 2007-0001, 2007-0002; hbyymmincr of the form HB08010001 where HB=Home Branch

UPDATE systempreferences SET explanation='Система класифікації за умовчуванням, що використовується для зібрання. Наприклад, Дьюї, УДК, ББК, КБК тощо' WHERE variable='DefaultClassificationSource';
-- 	Default classification scheme used by the collection. E.g., Dewey, LCC, etc.

UPDATE systempreferences SET explanation='Якщо ввімкнуто, вимикає відображення МАРК-полів, підполів та індикаторів (дані показуються, як і раніше)' WHERE variable='hide_marc';
-- 	If ON, disables display of MARC fields, subfield codes & indicators (still shows data)

UPDATE systempreferences SET explanation='Вид за умовчуванням бібліотечного запису у внутрішньо-бібліотечному інтерфейсі' WHERE variable='IntranetBiblioDefaultView';
-- 	IntranetBiblioDefaultView

UPDATE systempreferences SET explanation='Структура міжнародного стандарту бібліографічного опису ISBD' WHERE variable='ISBD';
-- 	ISBD

UPDATE systempreferences SET explanation='Якщо ввімкнуто, дозволяє мати на рівні примірника типи примірників та правила видачі' WHERE variable='item-level_itypes';
-- 	If ON, enables Item-level Itemtype / Issuing Rules

UPDATE systempreferences SET explanation='МАРК-поле/підполе, яке використовується для розрахунку шифру для замовлення бібліотечної одиниці {itemcallnumber}, для Unimarc/УкрМарк не фіксовано, може бути 942hv чи 852hi із запису примірника (в MARC21 для Дьюі буде 082ab або 092ab; для КБК буде 050ab або 090ab)' WHERE variable='itemcallnumber';
-- 	The MARC field/subfield that is used to calculate the itemcallnumber (Dewey would be 082ab or 092ab; LOC would be 050ab or 090ab) could be 852hi from an item record

UPDATE systempreferences SET explanation='Визначення, як буде відображатися МАРК-запис' WHERE variable='LabelMARCView';
-- 	Define how a MARC record will display

UPDATE systempreferences SET explanation='Увімкнення підтримки МАРК-стандарту' WHERE variable='marc';
-- 	Turn on MARC support

UPDATE systempreferences SET explanation='Визначення глобального МАРК-стандарту (MARC21 чи UNIMARC/Укрмарк), що використовується для кодування символів' WHERE variable='marcflavour';
-- 	Define global MARC flavor (MARC21 or UNIMARC) used for character encoding

UPDATE systempreferences SET explanation='Визначення МАРК-коду для організації — http://www.loc.gov/marc/organizations/orgshome.html' WHERE variable='MARCOrgCode';
-- 	Define MARC Organization Code - http://www.loc.gov/marc/organizations/orgshome.html

UPDATE systempreferences SET explanation='Якщо ввімкнуто, Zebra-індексування відключене (більш просте встановлення але повільніший пошук)' WHERE variable='NoZebra';
-- 	If ON, Zebra indexing is turned off, simpler setup, but slower searches. WARNING: using NoZebra on even modest sized collections is very slow.

UPDATE systempreferences SET explanation='Запис у особливій формі хешу для індексів NoZebra. Записувати подібно до наступного: \'indexname\' => \'100a,245a,500*\',\'indexname2\' => \'...\'' WHERE variable='NoZebraIndexes';
-- Enter a specific hash for NoZebra indexes. Enter : \'indexname\' => \'100a,245a,500*\',\'index2\' => \'...\'	

UPDATE systempreferences SET explanation='Увімкнення функції приховування в ЕК, вимагає подальшого налаштування, зверніться до системного адміністратора для отримання більш детальної інформації' WHERE variable='OpacSuppression';
-- 	Turn ON the OPAC Suppression feature, requires further setup, ask your system administrator for details

UPDATE systempreferences SET explanation='Якщо ввімкнуто, діє обробка серіальних видань' WHERE variable='RoutingSerials';
-- 	If ON, serials routing is enabled

UPDATE systempreferences SET explanation='Визначення полів бібліотечного МАРК-запису для авторитетних записів про особисті імена — для заповнення biblio.author' WHERE variable='z3950AuthorAuthFields';
-- 	Define the MARC biblio fields for Personal Name Authorities to fill biblio.author

UPDATE systempreferences SET explanation='Якщо увімкнуто, авторитетні значення про особисті імена замінюватимуть авторів у biblio.author' WHERE variable='z3950NormalizeAuthor';
-- 	If ON, Personal Name Authorities will replace authors in biblio.author


-- Circulation — Обіг

UPDATE systempreferences SET explanation='Дозволити розміщувати запит резервування на пошкоджені примірники' WHERE variable='AllowHoldsOnDamagedItems';
-- 	 Allow hold requests to be placed on damaged items

UPDATE systempreferences SET explanation='Дозволити розміщувати запит резервування на примірники, які не були видані' WHERE variable='AllowOnShelfHolds';
-- 	Allow hold requests to be placed on items that are not on loan

UPDATE systempreferences SET explanation='Якщо увімкнуто, дозволяє щоб обмеження на продовження були перевизначені екраном обігу' WHERE variable='AllowRenewalLimitOverride';
-- 	if ON, allows renewal limits to be overridden on the circulation screen

UPDATE systempreferences SET explanation='Якщо увімкнуто, Коха буде автоматично встановлювати переміщення цього примірника до свого домашнього підрозділу' WHERE variable='AutomaticItemReturn';
-- 	If ON, Koha will automatically set up a transfer of this item to its homebranch

UPDATE systempreferences SET explanation='З увімкнутими незалежними підрозділами, користувач з одного бібліотечного розміщення може резервувати примірник з іншої бібліотеки' WHERE variable='canreservefromotherbranches';
-- 	With Independent branches on, can a user from one library place a hold on an item from another library

UPDATE systempreferences SET explanation='Якщо увімкнуто — задіюється автозавершения для вводу при обігу' WHERE variable='CircAutocompl';
-- 	If ON, autocompletion is enabled for the Circulation input

UPDATE systempreferences SET explanation='Вказується агентство, яке контролює політики обігу та штрафи' WHERE variable='CircControl';
-- 	Specify the agency that controls the circulation and fines policy

UPDATE systempreferences SET explanation='Якщо увімкнуто, повідомляти електронною поштою бібліотекаря у тих випадках, коли розміщується резервування (утримання)' WHERE variable='emailLibrarianWhenHoldIsPlaced';
-- 	If ON, emails the librarian whenever a hold is placed

UPDATE systempreferences SET explanation='Вказується, чи використовувати календар у розрахунку термінів та штрафів' WHERE variable='finesCalendar';
-- 	Specify whether to use the Calendar in calculating duedates and fines

UPDATE systempreferences SET explanation='Виберіть режим для штрафів, «відключено», «тестовий» (звіти по електронній пошті адміністратору) або «робочий» (нараховуються штрафи за прострочення). Передбачається виконання завдання «accruefines» для cron.' WHERE variable='finesMode';
-- 	Choose the fines mode, 'off', 'test' (emails admin report) or 'production' (accrue overdue fines). Requires accruefines cronjob.

UPDATE systempreferences SET explanation='Якщо встановлено, дозволяється вказувати загальну статичну дату для усіх видач' WHERE variable='globalDueDate';
-- 	If set, allows a global static due date for all checkouts

UPDATE systempreferences SET explanation='Вказується, скільки днів має пройти до відміни резервування' WHERE variable='holdCancelLength';
-- 	Specify how many days before a hold is canceled

UPDATE systempreferences SET explanation='Використовується в обігу для визначення який підрозділ примірника перевіряти при включених незалежних підрозділах, і при пошуку, щоб визначити, які підрозділи вибирати для наявності' WHERE variable='HomeOrHoldingBranch';
-- 	Used by Circulation to determine which branch of an item to check with independent branches on, and by search to determine which branch to choose for availability

UPDATE systempreferences SET explanation='Якщо увімкнуто, відклються штрафи, якщо відвідувач здає примірник, який накопичував заборгованість' WHERE variable='IssuingInProcess';
-- 	If ON, disables fines if the patron is issuing item that accumulate debt

UPDATE systempreferences SET explanation='Якщо встановлено, зазначає вхідне фільтрування штрих-коду примірника' WHERE variable='itemBarcodeInputFilter';
-- 	If set, allows specification of a item barcode input filter

UPDATE systempreferences SET explanation='Максимальна сума заборгованих сплат до заборони резервувань' WHERE variable='maxoutstanding';
-- 	maximum amount withstanding to be able make holds

UPDATE systempreferences SET explanation='Максимальна кількість резервувань, які позичальник може зробити' WHERE variable='maxreserves';
-- 	Define maximum number of holds a patron can place

UPDATE systempreferences SET explanation='Визначення максимальної суми заборгованих сплат до заборони видачі' WHERE variable='noissuescharge';
-- 	Define maximum amount withstanding before check outs are blocked

UPDATE systempreferences SET explanation='Вказується порядок сортування попередніх випусків на сторінці обігу' WHERE variable='previousIssuesDefaultSortOrder';
-- 	Specify the sort order of Previous Issues on the circulation page

UPDATE systempreferences SET explanation='Якщо увімкнуто, то видруковуватимуться обігові квитанції' WHERE variable='printcirculationslips';
-- 	If ON, enable printing circulation receipts

UPDATE systempreferences SET explanation='Якщо увімкнуто, то порядок у черзі резервувань у обігу буде генеруватися випадковим чином, або ж на основі усіх кодів розташування, або через коди розташування, що визначаються у StaticHoldsQueueWeight' WHERE variable='RandomizeHoldsQueueWeight';
-- 	if ON, the holds queue in circulation will be randomized, either based on all location codes, or by the location codes specified in StaticHoldsQueueWeight

UPDATE systempreferences SET explanation='Визначення максимального терміну збереження примірника на резервуванні до забирання' WHERE variable='ReservesMaxPickUpDelay';
-- 	Define the Maximum delay to pick up an item on hold

UPDATE systempreferences SET explanation='Якщо увімкнуто, то зарезервований примірник, що є в цій бібліотеці повинен бути повернений, в іншому випадку конкретний зарезервований примірник, який є в бібліотеці і доступний, вважається (автоматично) доступним' WHERE variable='ReservesNeedReturns';
-- 	If ON, a hold placed on an item available in this library must be checked-in, otherwise, a hold on a specific item, that is in the library & available is considered available

UPDATE systempreferences SET explanation='Якщо встановлено, видача не буде проводиться, якщо дата повернення після дати закінчення терміну дії картки відвідувача' WHERE variable='ReturnBeforeExpiry';
-- 	If ON, checkout will be prevented if returndate is after patron card expiry

-- UPDATE systempreferences SET explanation='Визначення ' WHERE variable='SpecifyDueDate';
-- 	Define whether to display "Specify Due Date" form in Circulation
-- Определение, показывать ли форму \'Указать срок\' в обороте

-- UPDATE systempreferences SET explanation='Вказується ' WHERE variable='StaticHoldsQueueWeight';
-- 	Specify a list of library location codes separated by commas -- the list of codes will be traversed and weighted with first values given higher weight for holds fulfillment -- alternatively, if RandomizeHoldsQueueWeight is set, the list will be randomly selective

-- UPDATE systempreferences SET explanation='Вказується ' WHERE variable='todaysIssuesDefaultSortOrder';
-- 	Specify the sort order of Todays Issues on the circulation page
-- Укажите порядок сортировки сегодняшних выдач на станице оборота

-- UPDATE systempreferences SET explanation='Визначення ' WHERE variable='TransfersMaxDaysWarning';
-- 	Define the days before a transfer is suspected of having a problem
-- Определение количества дней до которых ожидается перемещение или же подозревается проблема

-- UPDATE systempreferences SET explanation='' WHERE variable='useDaysMode';
-- 	Choose the method for calculating due date: select Calendar to use the holidays module, and Days to ignore the holidays module
-- Выберите метод расчета срока: выберите календарь для использования модуль праздников, и дни если игнорировать модуль праздников

-- UPDATE systempreferences SET explanation='Якщо увімкнуто, то ' WHERE variable='WebBasedSelfCheck';
-- 	If ON, enables the web-based self-check system
-- Если ON, задействует систему самостоятельной проверки на основе веб


-- I18N/L10N

-- UPDATE systempreferences SET explanation='Формат дати (ММ/ДД/РРРР у США, ДД/ММ/РРРР у метричній системі,  РРРР/ММ/ДД за ISO)' WHERE variable='dateformat';
-- 	 Define global date format (us mm/dd/yyyy, metric dd/mm/yyy, ISO yyyy/mm/dd)

-- UPDATE systempreferences SET explanation='' WHERE variable='language';
-- 	Set the default language in the staff client.

-- UPDATE systempreferences SET explanation='Встановлення Вашої привілейованої мови. Мова зверху списку пробуватиметься спочатку.' WHERE variable='opaclanguages';
-- 	Set the default language in the OPAC.

-- UPDATE systempreferences SET explanation='Якщо увімкнуто, то Включення/виключення можливості зміни мови у ЕК' WHERE variable='opaclanguagesdisplay';
-- 	If ON, enables display of Change Language feature on OPAC

-- Logs - Протоколи

-- UPDATE systempreferences SET explanation='Якщо увімкнуто, то ' WHERE variable='BorrowersLog';
-- 	 If ON, log edit/create/delete actions on patron data

-- UPDATE systempreferences SET explanation='Якщо увімкнуто, то ' WHERE variable='CataloguingLog';
-- 	If ON, log edit/create/delete actions on bibliographic data. WARNING: this feature is very resource consuming.

-- UPDATE systempreferences SET explanation='Якщо увімкнуто, то ' WHERE variable='FinesLog';
-- 	If ON, log fines

-- UPDATE systempreferences SET explanation='Якщо увімкнуто, то ' WHERE variable='IssueLog';
-- 	If ON, log checkout activity

-- UPDATE systempreferences SET explanation='Якщо увімкнуто, то ' WHERE variable='LetterLog';
-- 	If ON, log all notices sent

-- UPDATE systempreferences SET explanation='Якщо увімкнуто, то ' WHERE variable='ReturnLog';
-- 	If ON, enables the circulation (returns) log

-- UPDATE systempreferences SET explanation='Якщо увімкнуто, то ' WHERE variable='SubscriptionLog';
-- 	If ON, enables subscriptions log


-- OAI-PMH

-- UPDATE systempreferences SET explanation='Якщо увімкнуто, то ' WHERE variable='OAI-PMH';
-- 	 if ON, OAI-PMH server is enabled

-- UPDATE systempreferences SET explanation='' WHERE variable='OAI-PMH:archiveID';
-- 	OAI-PMH archive identification

-- UPDATE systempreferences SET explanation='' WHERE variable='OAI-PMH:MaxCount';
-- 	OAI-PMH maximum number of records by answer to ListRecords and ListIdentifiers queries

-- UPDATE systempreferences SET explanation='' WHERE variable='OAI-PMH:Set';
-- 	OAI-PMH exported set, the set name is followed by a comma and a short description, one set by line

-- UPDATE systempreferences SET explanation='' WHERE variable='OAI-PMH:Subset';
-- 	Restrict answer to matching raws of the biblioitems table EXPERIMENTAL


-- OPAC - Електронний каталог

-- UPDATE systempreferences SET explanation='Вкажіть номер_анонімного_позичальника для дозволу анонімних пропозицій' WHERE variable='AnonSuggestions';
-- 	 Set to anonymous borrowernumber to enable Anonymous suggestions

-- UPDATE systempreferences SET explanation='Вигляд по умовчанню для бібліотечного запису. Може приймати значення normal, marc чи isbd' WHERE variable='BiblioDefaultView';
-- 	Choose the default detail view in the catalog; choose between normal, marc or isbd

-- UPDATE systempreferences SET explanation='Якщо увімкнуто, то Показувати чи приховувати „втрачені“ одиниці у ЕК.' WHERE variable='hidelostitems';
-- 	If ON, disables display of"lost" items in OPAC.

-- UPDATE systempreferences SET explanation='' WHERE variable='kohaspsuggest';
-- 	Track search queries, turn on by defining host:dbname:user:pass

-- UPDATE systempreferences SET explanation='Електронічний каталог бібліотеки', 'Ім’я бібліотеки або повідомлення, яке буде показане на головній сторінці електронічнго каталогу' WHERE variable='LibraryName';
-- 	Define the library name as displayed on the OPAC

-- UPDATE systempreferences SET explanation='Якщо увімкнуто, то ' WHERE variable='OpacAuthorities';
-- 	If ON, enables the search authorities link on OPAC

-- UPDATE systempreferences SET explanation='Якщо увімкнуто, то Включити чи заблокувати відображення бібліотечного замовлення (полички замовлень)' WHERE variable='opacbookbag';
-- 	If ON, enables display of Cart feature

-- UPDATE systempreferences SET explanation='Якщо увімкнуто, то ' WHERE variable='OpacBrowser';
-- 	If ON, enables subject authorities browser on OPAC (needs to set misc/cronjob/sbuild_browser_and_cloud.pl)

-- UPDATE systempreferences SET explanation='Якщо увімкнуто, то ' WHERE variable='OpacCloud';
-- 	If ON, enables subject cloud on OPAC

-- UPDATE systempreferences SET explanation='Введіть найменування таблиці стилів кольорів для електронічного каталогу' WHERE variable='opaccolorstylesheet';
-- 	Define the color stylesheet to use in the OPAC

-- UPDATE systempreferences SET explanation='Зазначте будь-які вдячності/заслуги у HTML для низу сторінки ЕК' WHERE variable='opaccredits';
-- 	Define HTML Credits at the bottom of the OPAC page

-- UPDATE systempreferences SET explanation='' WHERE variable='OPACDisplayRequestPriority';
-- 	Show patrons the priority level on holds in the OPAC	 

-- UPDATE systempreferences SET explanation='Користувацький HTML-заголовок для ЕК' WHERE variable='opacheader';
-- 	Add HTML to be included as a custom header in the OPAC

-- UPDATE systempreferences SET explanation='Якщо увімкнуто, то ' WHERE variable='OpacHighlightedWords';
-- 	If Set, then queried words are higlighted in OPAC

-- UPDATE systempreferences SET explanation='' WHERE variable='OPACItemHolds';
-- 	Allow OPAC users to place hold on specific items. If OFF, users can only request next available copy.

-- UPDATE systempreferences SET explanation='URL-посилання таблиці стилів для компонування сторінок для електронічного каталогу' WHERE variable='opaclayoutstylesheet';
-- 	Enter the name of the layout CSS stylesheet to use in the OPAC

-- UPDATE systempreferences SET explanation='Вітаємо у АБІС Коха...\r\n<hr>' WHERE variable='OpacMainUserBlock';
-- 	A user-defined block of HTML in the main content area of the opac main page

-- UPDATE systempreferences SET explanation='Використовуйте HTML-закладки для додавання посилань до лівостороньої навігаційної смужки у електронічному каталозі' WHERE variable='OpacNav';
-- 	Use HTML tags to add navigational links to the left-hand navigational bar in OPAC

-- UPDATE systempreferences SET explanation='Якщо увімкнуто, то Дозволити/заблокувати зміну паролю у ЕК (заблокуйте, якщо використовуйте LDAP-авторизацію)' WHERE variable='OpacPasswordChange';
-- 	If ON, enables patron-initiated password change in OPAC (disable it when using LDAP auth)

-- UPDATE systempreferences SET explanation='Якщо увімкнуто, то Включення/виключення відображення історії читання відвідувача у ЕК' WHERE variable='opacreadinghistory';
-- 	If ON, enables display of Patron Circulation History in OPAC

-- UPDATE systempreferences SET explanation='' WHERE variable='OpacRenewalAllowed';
-- 	If ON, users can renew their issues directly from their OPAC account

-- UPDATE systempreferences SET explanation='' WHERE variable='OPACShelfBrowser';
-- 	Enable/disable Shelf Browser on item details page. WARNING: this feature is very resource consuming on collections with large numbers of items.

-- UPDATE systempreferences SET explanation='URL-посилання зображення, що розміщується зверху/зліва замість логотипу Koha' WHERE variable='opacsmallimage';
-- 	Enter a complete URL to an image to replace the default Koha logo

-- UPDATE systempreferences SET explanation='URL-посилання альтернативної таблиці стилів для електронічного каталогу' WHERE variable='opacstylesheet';
-- 	Enter a complete URL to use an alternate layout stylesheet in OPAC

-- UPDATE systempreferences SET explanation='Встановлення переважного порядку для тем. Спочатку пробуватиметься вища тема.' WHERE variable='opacthemes';
-- 	Define the current theme for the OPAC interface.

-- UPDATE systempreferences SET explanation='Якщо увімкнуто, то ' WHERE variable='OpacTopissue';
-- 	If ON, enables the 'most popular items' link on OPAC. Warning, this is an EXPERIMENTAL feature, turning ON may overload your server

-- UPDATE systempreferences SET explanation='' WHERE variable='OPACURLOpenInNewWindow';
-- 	If ON, URLs in the OPAC open in a new window

-- UPDATE systempreferences SET explanation='' WHERE variable='OPACUserCSS';
-- 	Add CSS to be included in the OPAC in an embedded <style> tag.

-- UPDATE systempreferences SET explanation='' WHERE variable='opacuserjs';
-- 	Define custom javascript for inclusion in OPAC

-- UPDATE systempreferences SET explanation='Включити/заблокувати відображення можливості реєстрації користувача' WHERE variable='opacuserlogin';
-- 	Enable or disable display of user login features

-- UPDATE systempreferences SET explanation='Якщо увімкнуто, то ' WHERE variable='OPACViewOthersSuggestions';
-- 	If ON, allows all suggestions to be displayed in the OPAC

-- UPDATE systempreferences SET explanation='Якщо увімкнуто, то ' WHERE variable='RequestOnOpac';
-- 	If ON, globally enables patron holds on OPAC

-- UPDATE systempreferences SET explanation='Якщо увімкнуто, то ' WHERE variable='reviewson';
-- 	If ON, enables patron reviews of bibliographic records in the OPAC

-- UPDATE systempreferences SET explanation='Якщо увімкнуто, то ' WHERE variable='SearchMyLibraryFirst';
-- 	If ON, OPAC searches return results limited by the user's library by default if they are logged in

-- UPDATE systempreferences SET explanation='Якщо увімкнуто, то Якщо рівне 1, то пропозиції будуть активовані у ЕК' WHERE variable='suggestion';
-- 	If ON, enables patron suggestions feature in OPAC

-- UPDATE systempreferences SET explanation='' WHERE variable='URLLinkText';
-- 	Text to display as the link anchor in the OPAC

-- UPDATE systempreferences SET explanation='Якщо увімкнуто, то Встановіть управління віртуальними полицями у ON чи OFF' WHERE variable='virtualshelves';
-- 	If ON, enables Lists management

-- UPDATE systempreferences SET explanation='' WHERE variable='XSLTDetailsDisplay';
-- 	Enable XSL stylesheet control over details page display on OPAC exemple : ../koha-tmpl/opac-tmpl/prog/en/xslt/MARC21slim2OPACDetail.xsl

-- UPDATE systempreferences SET explanation='' WHERE variable='XSLTResultsDisplay';
-- 	Enable XSL stylesheet control over results page display on OPAC exemple : ../koha-tmpl/opac-tmpl/prog/en/xslt/MARC21slim2OPACResults.xsl


-- Patrons - Відвідувачі

-- UPDATE systempreferences SET explanation='' WHERE variable='AddPatronLists';
-- 	 Allow user to choose what list to pick up from when adding patrons

-- UPDATE systempreferences SET explanation='' WHERE variable='AutoEmailOpacUser';
-- 	Sends notification emails containing new account details to patrons - when account is created.

-- UPDATE systempreferences SET explanation='Визначає' WHERE variable='AutoEmailPrimaryAddress';
-- 	Defines the default email address where 'Account Details' emails are sent.

-- UPDATE systempreferences SET explanation='Якщо увімкнуто, то Чи автоматично призначати номер квитка відвідувача' WHERE variable='autoMemberNum';
-- 	If ON, patron number is auto-calculated

-- UPDATE systempreferences SET explanation='' WHERE variable='BorrowerMandatoryField';
-- 	Choose the mandatory fields for a patron's account

-- UPDATE systempreferences SET explanation='Визначення ' WHERE variable='borrowerRelationship';
-- 	Define valid relationships between a guarantor & a guarantee (separated by | or ,)

-- UPDATE systempreferences SET explanation='' WHERE variable='BorrowersTitles';
-- 	Define appropriate Titles for patrons

-- UPDATE systempreferences SET explanation='Якщо увімкнуто, то Перевірка достовірності картки відвідувача: немає перевірки або "Katipo"-перевірка' WHERE variable='checkdigit';
-- 	If ON, enable checks on patron cardnumber: none or "Katipo" style checks

-- UPDATE systempreferences SET explanation='Якщо увімкнуто, то ' WHERE variable='EnhancedMessagingPreferences';
-- 	If ON, allows patrons to select to receive additional messages about items due or nearly due.

-- UPDATE systempreferences SET explanation='' WHERE variable='ExtendedPatronAttributes';
-- 	Use extended patron IDs and attributes

-- UPDATE systempreferences SET explanation='Якщо увімкнуто, то ' WHERE variable='intranetreadinghistory';
-- 	If ON, Reading History is enabled for all patrons

-- UPDATE systempreferences SET explanation='' WHERE variable='MaxFine';
-- 	Maximum fine a patron can have for a single late return

-- UPDATE systempreferences SET explanation='Якщо увімкнуто, то ' WHERE variable='memberofinstitution';
-- 	If ON, patrons can be linked to institutions

-- UPDATE systempreferences SET explanation='Вказується ' WHERE variable='minPasswordLength';
-- 	Specify the minimum length of a patron/staff password

-- UPDATE systempreferences SET explanation='За скільки днів до завершення дії квитка подавати повідомлення при видачах' WHERE variable='NotifyBorrowerDeparture';
-- 	Define number of days before expiry where circulation is warned about patron account expiry

-- UPDATE systempreferences SET explanation='Включення/виключення відображення зображень відвідувачів в Інтернеті та зазначення розширення файлу для зображень' WHERE variable='patronimages';
-- 	Enable patron images for the Staff Client

-- UPDATE systempreferences SET explanation='' WHERE variable='PatronsPerPage';
-- 	Number of Patrons Per Page displayed by default

-- UPDATE systempreferences SET explanation='' WHERE variable='SMSSendDriver';
-- 	Sets which SMS::Send driver is used to send SMS messages.

-- UPDATE systempreferences SET explanation='Якщо увімкнуто, то ' WHERE variable='uppercasesurnames';
-- 	If ON, surnames are converted to upper case in patron entry form


-- Searching - Шукання

-- UPDATE systempreferences SET explanation='' WHERE variable='AdvancedSearchTypes';
-- 	 Select which set of fields comprise the Type limit in the advanced search

-- UPDATE systempreferences SET explanation='Вказується ' WHERE variable='defaultSortField';
-- 	Specify the default field used for sorting

-- UPDATE systempreferences SET explanation='Вказується ' WHERE variable='defaultSortOrder';
-- 	Specify the default sort order

-- UPDATE systempreferences SET explanation='Якщо увімкнуто, то ' WHERE variable='expandedSearchOption';
-- 	If ON, set advanced search to be expanded by default

-- UPDATE systempreferences SET explanation='Вказується ' WHERE variable='numSearchResults';
-- 	Specify the maximum number of results to display on a page of results

-- UPDATE systempreferences SET explanation='Вказується ' WHERE variable='OPACdefaultSortField';
-- 	Specify the default field used for sorting

-- UPDATE systempreferences SET explanation='Вказується ' WHERE variable='OPACdefaultSortOrder';
-- 	Specify the default sort order

-- UPDATE systempreferences SET explanation='' WHERE variable='OPACItemsResultsDisplay';
-- 	statuses : show only the status of items in result list. itemdisplay : show full location of items (branch+location+callnumber) as in staff interface

-- UPDATE systempreferences SET explanation='Вказується ' WHERE variable='OPACnumSearchResults';
-- 	Specify the maximum number of results to display on a page of results

-- UPDATE systempreferences SET explanation='Якщо увімкнуто, то ' WHERE variable='QueryAutoTruncate';
-- 	If ON, query truncation is enabled by default

-- UPDATE systempreferences SET explanation='Якщо увімкнуто, то ' WHERE variable='QueryFuzzy';
-- 	If ON, enables fuzzy option for searches

-- UPDATE systempreferences SET explanation='Якщо увімкнуто, то ' WHERE variable='QueryRemoveStopwords';
-- 	If ON, stopwords listed in the Administration area will be removed from queries

-- UPDATE systempreferences SET explanation='Якщо увімкнуто, то ' WHERE variable='QueryStemming';
-- 	If ON, enables query stemming

-- UPDATE systempreferences SET explanation='Якщо увімкнуто, то ' WHERE variable='QueryWeightFields';
-- 	If ON, enables field weighting

-- UPDATE systempreferences SET explanation='Сортувати результати пошуку за необліковуваними МАРК-символами' WHERE variable='sortbynonfiling';
-- 	Sort search results by MARC nonfiling characters (deprecated)


-- StaffClient - Клієнт для бібліотекарів

-- UPDATE systempreferences SET explanation='Введіть назву таблиці стилів кольорів для внутрішньобібліотечного інтерфейсу' WHERE variable='intranetcolorstylesheet';
-- 	 Define the color stylesheet to use in the Staff Client

-- UPDATE systempreferences SET explanation='' WHERE variable='IntranetmainUserblock';
-- 	Add a block of HTML that will display on the intranet home page

-- UPDATE systempreferences SET explanation='Використовуйте HTML-закладки для додавання посилань до лівостороньої навігаційної смужки у внутрішньобібліотечному інтерфейсі' WHERE variable='IntranetNav';
-- 	Use HTML tabs to add navigational links to the left-hand navigational bar in the Staff Client

-- UPDATE systempreferences SET explanation='Назва альтернативної таблиці стилів для компонування сторінок внутрішньобібліотечного інтерфейсу' WHERE variable='intranetstylesheet';
-- 	Enter a complete URL to use an alternate layout stylesheet in Intranet

-- UPDATE systempreferences SET explanation='' WHERE variable='intranetuserjs';
-- 	Custom javascript for inclusion in Intranet

-- UPDATE systempreferences SET explanation='Вибір варіанту шаблону для внутрішньобібліотечного інтерфейсу' WHERE variable='template';
-- 	Define the preferred staff interface template

-- UPDATE systempreferences SET explanation='Зазначення кодування шаблонів' WHERE variable='TemplateEncoding';
-- 	Globally define the default character encoding

-- UPDATE systempreferences SET explanation='' WHERE variable='yuipath';
-- 	Insert the path to YUI libraries, choose local if you use koha offline


-- Local Use - Місцеве використання

-- UPDATE systempreferences SET explanation='Якщо увімкнуто, то ' WHERE variable='AllowHoldPolicyOverride';
-- Allow staff to override hold policies when placing holds

-- UPDATE systempreferences SET explanation='Якщо увімкнуто, то ' WHERE variable='AllowNotForLoanOverride';
-- 	 If ON, Koha will allow the librarian to loan a not for loan item.

-- UPDATE systempreferences SET explanation='' WHERE variable='AmazonCoverImages';
-- Display Cover Images in Staff Client from Amazon Web Services

-- UPDATE systempreferences SET explanation='' WHERE variable='AmazonEnabled';
-- 	 Turn ON Amazon Content - You MUST set AWSAccessKeyID, AWSPrivateKey, and AmazonAssocTag if enabled

-- UPDATE systempreferences SET explanation='' WHERE variable='AmazonReviews';
-- 	 Display Amazon review on staff interface - You MUST set AWSAccessKeyID, AWSPrivateKey, and AmazonAssocTag if enabled

-- UPDATE systempreferences SET explanation='' WHERE variable='HomeOrHoldingBranchReturn';
-- Used by Circulation to determine which branch of an item to check checking-in items

-- UPDATE systempreferences SET explanation='' WHERE variable='IndependentBranchPatron';
-- If ON, librarian patron search can only be done on patron of same library as librarian

-- UPDATE systempreferences SET explanation='Якщо увімкнуто, то ' WHERE variable='MergeAuthoritiesOnUpdate';
-- 	if ON, Updating authorities will automatically updates biblios

-- UPDATE systempreferences SET explanation='' WHERE variable='OPACAmazonEnabled';
--  Turn ON Amazon Content in the OPAC - You MUST set AWSAccessKeyID, AWSPrivateKey, and AmazonAssocTag if enabled

-- UPDATE systempreferences SET explanation='' WHERE variable='OPACISBD';
-- OPAC ISBD View

-- UPDATE systempreferences SET explanation='' WHERE variable='OPACviewISBD';
-- Allow display of ISBD view of bibiographic records in OPAC

-- UPDATE systempreferences SET explanation='' WHERE variable='OPACviewMARC';
-- Allow display of MARC view of bibiographic records in OPAC

-- UPDATE systempreferences SET explanation='' WHERE variable='ReceiveBackIssues';
-- Number of Previous journals to display when on subscription detail

-- UPDATE systempreferences SET explanation='' WHERE variable='RenewalPeriodBase';
--	Set whether the renewal date should be counted from the date_due or from the moment the Patron asks for renewal

-- UPDATE systempreferences SET explanation='' WHERE variable='viewISBD';
-- 	Allow display of ISBD view of bibiographic records

-- UPDATE systempreferences SET explanation='' WHERE variable='viewLabeledMARC';
-- 	Allow display of labeled MARC view of bibiographic records

-- UPDATE systempreferences SET explanation='' WHERE variable='viewMARC';
-- 	Allow display of MARC view of bibiographic records


-- Serials --------------------------------------------------------------------------------------------------------------------------------

-- UPDATE systempreferences SET explanation='Якщо увімкнуто, то ' WHERE variable='OPACDisplayExtendedSubInfo';
-- 	If ON, extended subscription information is displayed in the OPAC

-- UPDATE systempreferences SET explanation='Вказується ' WHERE variable='OPACSubscriptionDisplay';
-- 	Specify how to display subscription information in the OPAC

UPDATE systempreferences SET explanation='Якщо ввімкнуто, додає нову пропозицію при відновленні передплати серійного видання' WHERE variable='RenewSerialAddsSuggestion';
-- 	If ON, adds a new suggestion at serial subscription renewal 

-- UPDATE systempreferences SET explanation='Рівень інформативності для хронології періодичних видань у електронічному каталозі' WHERE variable='SubscriptionHistory';
-- 	Define the display preference for serials issue history in OPAC

