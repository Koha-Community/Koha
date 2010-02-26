
-- Admin - Управление

UPDATE systempreferences SET explanation='Если включено, то задействована IP-аутентификация, которая будет блокировать доступ к библиотечному интерфейсу с несанкционированного IP-адреса' WHERE variable='AutoLocation';	 
-- If ON, IP authentication is enabled, blocking access to the staff client from unauthorized IP addresses 

UPDATE systempreferences SET explanation='Количество отладочной информации, направляемой в браузер, когда встречаются ошибки (установить в 0 в рабочем варианте). 0 = нет, 1 = кое-что, 2 = большинство' WHERE variable='DebugLevel';	
-- Define the level of debugging information sent to the browser when errors are encountered (set to 0 in production). 0=none, 1=some, 2=most

UPDATE systempreferences SET explanation='Символ-разделитель по умолчанию для экспорта отчетов' WHERE variable='delimiter';	
-- Define the default separator character for exporting reports

UPDATE systempreferences SET explanation='Список загруженных структур в веб-инсталляторе' WHERE variable='FrameworksLoaded';	
-- Frameworks loaded through webinstaller

UPDATE systempreferences SET explanation='Использование подразделения привилегий для работников' WHERE variable='GranularPermissions';	
-- Use detailed staff user permissions

UPDATE systempreferences SET explanation='Если включено, то повышает безопасность между библиотеками. Используется, когда библиотеки используют одну инсталляцию Коха.' WHERE variable='IndependantBranches';	
-- If ON, increases security between libraries

UPDATE systempreferences SET explanation='Если включено, то авторизация вообще не нужна. Будьте внимательны!' WHERE variable='insecure';	
-- If ON, bypasses all authentication. Be careful!

UPDATE systempreferences SET explanation='Папка «includes» может быть полезна для особого вида Коха (например, «includes» или «includes_npl»)' WHERE variable='intranet_includes';	
-- The includes directory you want for specific look of Koha (includes or includes_npl for example)

UPDATE systempreferences SET explanation='Адрес электронной почты, на который приходят запросы посетителей касательно модификации их учётных записей' WHERE variable='KohaAdminEmailAddress';	
-- Define the email address where patron modification requests are sent

UPDATE systempreferences SET explanation='Адрес, используемый при печати квитанций, просрочек и т.п., если отличается от физического адреса' WHERE variable='libraryAddress';	
-- The address to use for printing receipts, overdues, etc. if different than physical address

UPDATE systempreferences SET explanation='Программа по умолчанию для экспорта файлов отчётов' WHERE variable='MIME';	
-- Define the default application for exporting report data

UPDATE systempreferences SET explanation='Если включено, то будут отключены изображения типов единиц' WHERE variable='noItemTypeImages';	
-- If ON, disables item-type images

UPDATE systempreferences SET explanation='Базовый URL-адрес для ЭК, например, opac.mylibrary.com, http:// будут добавляться автоматически с помощью Коха' WHERE variable='OPACBaseURL';	
-- Specify the Base URL of the OPAC, e.g., opac.mylibrary.com, the http:// will be added automatically by Koha.

UPDATE systempreferences SET explanation='Если включено, тогда будут включены предупреждения об обслуживании в ЭК' WHERE variable='OpacMaintenance';	
-- If ON, enables maintenance warning in OPAC

UPDATE systempreferences SET explanation='Использование базы данных или временного файла для хранения данных сессии' WHERE variable='SessionStorage';	
-- Use database or a temporary file for storing session data

UPDATE systempreferences SET explanation='Работать в режиме одного подразделения и скрыть выбор подразделений в ЭК' WHERE variable='singleBranchMode';	
-- Operate in Single-branch mode, hide branch selection in the OPAC

UPDATE systempreferences SET explanation='Базовый URL-адрес библиотечного интерфейса' WHERE variable='staffClientBaseURL';	
-- Specify the base URL of the staff client

UPDATE systempreferences SET explanation='Промежуток времени бездействия для аутентификации (в секундах)' WHERE variable='timeout';	
-- Inactivity timeout for cookies authentication (in seconds)

UPDATE systempreferences SET explanation='Версия базы данных Коха. ПРЕДУПРЕЖДЕНИЕ: не изменяйте это значение вручную, им руководит веб-установщик' WHERE variable='Version';	
-- The Koha database version. WARNING: Do not change this value manually, it is maintained by the webinstaller


-- Acquisitions - Поступления

UPDATE systempreferences SET explanation='Обычные (normal) приобретения на основе статей расходов или же простые (simple) поступления библиографических данных' WHERE variable='acquisitions';
-- Choose Normal, budget-based acquisitions, or Simple bibliographic-data acquisitions

UPDATE systempreferences SET explanation='Если включено, то высылать предложения посетителей по электронной почте, а не управлять ими в поступлениях' WHERE variable='emailPurchaseSuggestions';
-- 	If ON, patron suggestions are emailed rather than managed in Acquisitions

UPDATE systempreferences SET explanation='Ставка НДС по умолчанию; НЕ в процентах (%), а в числовой форме (0.12 означает 12%)' WHERE variable='gist';
-- 	Default Goods and Services tax rate NOT in %, but in numeric form (0.12 for 12%), set to 0 to disable GST


-- EnhancedContent - Расширенное содержание

UPDATE systempreferences SET explanation='См.: http://aws.amazon.com' WHERE variable='AmazonAssocTag';
-- 	 See: http://aws.amazon.com

UPDATE systempreferences SET explanation='Включить расширенное содержимое с Amazon — Вы ДОЛЖНЫ установить AWSAccessKeyID и AmazonAssocTag если здесь включено' WHERE variable='AmazonContent';
-- 	Turn ON Amazon Content - You MUST set AWSAccessKeyID and AmazonAssocTag if enabled

UPDATE systempreferences SET explanation='Используется для установки локали для Ваших веб-сервисов от Amazon.com' WHERE variable='AmazonLocale';
-- 	Use to set the Locale of your Amazon.com Web Services

UPDATE systempreferences SET explanation='Включить возможность Amazon для поиска подобных записей - Вы должны установить AWSAccessKeyID и AmazonAssocTag если здесь включено' WHERE variable='AmazonSimilarItems';
-- 	Turn ON Amazon Similar Items feature - You MUST set AWSAccessKeyID and AmazonAssocTag if enabled

UPDATE systempreferences SET explanation='См.: http://aws.amazon.com' WHERE variable='AWSAccessKeyID';
-- 	See: http://aws.amazon.com

UPDATE systempreferences SET explanation='См.: http://aws.amazon.com. Заметьте, что это ключ стал необходим после 15.8.2009 для того, чтобы получать любое расширенное содержимое, кроме обложек книг от Amazon.' WHERE variable='AWSPrivateKey';
-- See:  http://aws.amazon.com.  Note that this is required after 2009/08/15 in order to retrieve any enhanced content other than book covers from Amazon.

UPDATE systempreferences SET explanation='URL-шаблон ссылки для „Мой библиотечный книжный магазин“(МБКМ), для которого значение „ключа“(key) добавляется в конце и „https://“ добавляется впереди. Он должен включать в себя имя Вашего хоста (hostname) и „родительский номер“ (Parent Number). Для отключения МБКМ-ссылки, сделайте это значение пустым. Пример: ocls.mylibrarybookstore.com/MLB/actions/searchHandler.do?nextPage=bookDetails&parentNum=10923&key=' WHERE variable='BakerTaylorBookstoreURL';
-- 	URL template for "My Libary Bookstore" links, to which the "key" value is appended, and "https://" is prepended. It should include your hostname and "Parent Number". Make this variable empty to turn MLB links off. Example: ocls.mylibrarybookstore.com/MLB/actions/searchHandler.do?nextPage=bookDetails&parentNum=10923&key=

UPDATE systempreferences SET explanation='Включить или выключить все функции «BakerTaylor»' WHERE variable='BakerTaylorEnabled';
-- 	Enable or disable all Baker & Taylor features.

UPDATE systempreferences SET explanation='Пароль «BakerTaylor» для «кафе содержания» (внешнее содержание)' WHERE variable='BakerTaylorPassword';
-- 	Baker & Taylor Password for Content Cafe (external content)

UPDATE systempreferences SET explanation='Имя пользователя «BakerTaylor» для «кафе содержания» (внешнее содержание)' WHERE variable='BakerTaylorUsername';
-- 	Baker & Taylor Username for Content Cafe (external content)

UPDATE systempreferences SET explanation='Если включено, Коха будет обращается к одному или нескольким веб-сервисам ISBN относительно объединенных ISBN и отображать их на вкладке «Издания» на страницах с подробностями' WHERE variable='FRBRizeEditions';
-- 	If ON, Koha will query one or more ISBN web services for associated ISBNs and display an Editions tab on the details pages

UPDATE systempreferences SET explanation='Если включено, выводит обложки с помощью API «Поиска книг Google»' WHERE variable='GoogleJackets';
-- 	if ON, displays jacket covers from Google Books API

UPDATE systempreferences SET explanation='Используется с FRBRizeEditions и XISBN. Вы можете подписаться на AffiliateID здесь: http://www.worldcat.org/wcpa/do/AffiliateUserServices?method=initSelfRegister' WHERE variable='OCLCAffiliateID';
-- 	Use with FRBRizeEditions and XISBN. You can sign up for an AffiliateID here: http://www.worldcat.org/wcpa/do/AffiliateUserServices?method=initSelfRegister

UPDATE systempreferences SET explanation='Отображение изображений обложек в ЭК с веб-сервисов Amazon' WHERE variable='OPACAmazonCoverImages';
-- Display cover images on OPAC from Amazon Web Services

UPDATE systempreferences SET explanation='Включить получение данных с Amazon в ЭК — Вы ДОЛЖНЫ настроить AWSAccessKeyID и AmazonAssocTag если здесь включено' WHERE variable='OPACAmazonContent';
-- 	Turn ON Amazon Content in the OPAC - You MUST set AWSAccessKeyID and AmazonAssocTag if enabled

UPDATE systempreferences SET explanation='Включить возможность поиска подобных записей от Amazon — Вы ДОЛЖНЫ настроить AWSAccessKeyID и AmazonAssocTag если здесь включено' WHERE variable='OPACAmazonSimilarItems';
-- 	Turn ON Amazon Similar Items feature - You MUST set AWSAccessKeyID and AmazonAssocTag if enabled

UPDATE systempreferences SET explanation='Если включено, то ЭК будет опрашивать один или несколько веб-сервисов ISBN касательно связанных ISBN и отобразит на вкладке «Издания» на странице с подробностями' WHERE variable='OPACFRBRizeEditions';
-- 	If ON, the OPAC will query one or more ISBN web services for associated ISBNs and display an Editions tab on the details pages

UPDATE systempreferences SET explanation='Используется с FRBRizeEditions. Если включено, Коха использует веб-сервис PINES OISBN для вкладки «Издания» на странице с подробностями.' WHERE variable='PINESISBN';
-- 	Use with FRBRizeEditions. If ON, Koha will use PINES OISBN web service in the Editions tab on the detail pages.

UPDATE systempreferences SET explanation='Включает или выключает все функции меток. Это основной переключатель для меток.' WHERE variable='TagsEnabled';
-- 	Enables or disables all tagging features. This is the main switch for tags.

UPDATE systempreferences SET explanation='Путь на сервере к локальной исполнительной программе ispell, используется для установления $Lingua::Ispell::path. Этот словарь используется как «белый список» для предварительно разрешенных меток.' WHERE variable='TagsExternalDictionary';
-- 	Path on server to local ispell executable, used to set $Lingua::Ispell::path This dictionary is used as a "whitelist" of pre-allowed tags.

UPDATE systempreferences SET explanation='Разрешить пользователям вводить метки на странице с подробностями.' WHERE variable='TagsInputOnDetail';
-- 	Allow users to input tags from the detail page.

UPDATE systempreferences SET explanation='Разрешить пользователям вводить метки в списке результатов поиска.' WHERE variable='TagsInputOnList';
-- 	Allow users to input tags from the search results list.

UPDATE systempreferences SET explanation='Требовать утверждения меток посетителей перед тем как они станут видимыми.' WHERE variable='TagsModeration';
-- 	Require tags from patrons to be approved before becoming visible.

UPDATE systempreferences SET explanation='Количество меток для показа на странице сведений. 0 — отключено.' WHERE variable='TagsShowOnDetail';
-- 	Number of tags to display on detail page. 0 is off.

UPDATE systempreferences SET explanation='Количество меток, отображаемых в списке результатов поиска. 0 — отключено.' WHERE variable='TagsShowOnList';
-- 	Number of tags to display on search results list. 0 is off.

UPDATE systempreferences SET explanation='Используется с FRBRizeEditions. Если включено, Коха будет использовать веб-сервис ThingISBN для вкладки «Издания» на странице с подробностями.' WHERE variable='ThingISBN';
-- 	Use with FRBRizeEditions. If ON, Koha will use the ThingISBN web service in the Editions tab on the detail pages.

UPDATE systempreferences SET explanation='Используется с FRBRizeEditions. Если включено, Коха будет использовать веб-сервис OCLC xISBN для вкладки «Издания» на странице с подробностями. См.: http://www.worldcat.org/affiliate/webservices/xisbn/app.jsp' WHERE variable='XISBN';
-- 	Use with FRBRizeEditions. If ON, Koha will use the OCLC xISBN web service in the Editions tab on the detail pages. See: http://www.worldcat.org/affiliate/webservices/xisbn/app.jsp

UPDATE systempreferences SET explanation='Веб-сервис xISBN является бесплатным для некоммерческого использования при использовании не более 500 запросов в день' WHERE variable='XISBNDailyLimit';
-- 	The xISBN Web service is free for non-commercial use when usage does not exceed 500 requests per day


-- Authorities — Авторитетные источники

UPDATE systempreferences SET explanation='Показывать иерархии в детализации для авторитетных источников' WHERE variable='AuthDisplayHierarchy';
-- Allow the display of hierarchy in Authority details

UPDATE systempreferences SET explanation='Используется для разделения перечня авторитетных источников на дисплее. Обычно --' WHERE variable='authoritysep';
--  Used to separate a list of authorities in a display. Usually --

UPDATE systempreferences SET explanation='Если включено, при добавлении новой библиотечной записи будет происходить проверка среди существующих авторитетных записей и будут создаваться соответствующие на лету, если таковых не будет существовать' WHERE variable='BiblioAddsAuthorities';
-- If ON, adding a new biblio will check for an existing authority record and create one on the fly if one doesn't exist

UPDATE systempreferences SET explanation='Если включено, изменение авторитетной записи не будет немедленно обновлять все связанные с ней библиографические записи, обратитесь к системному администратору для включения в cron задачу merge_authorities.pl' WHERE variable='dontmerge';
-- If ON, modifying an authority record will not update all associated bibliographic records immediately, ask your system administrator to enable the merge_authorities.pl cron job


-- Cataloguing — Каталогизация

UPDATE systempreferences SET explanation='Если включено, МАРК-редактор не будет показывать описания полей/подполей' WHERE variable='advancedMARCeditor';
-- 	 If ON, the MARC editor won't display field/subfield descriptions

UPDATE systempreferences SET explanation='Используется для авто-создания штрих-кодов: прирост будет иметь форму 1, 2, 3; ежегодник будет иметь вид 2007-0001, 2007-0002; MD08010001 для формы дпггммприрост где дп = домашнее подразделение' WHERE variable='autoBarcode';
-- 	Used to autogenerate a barcode: incremental will be of the form 1, 2, 3; annual of the form 2007-0001, 2007-0002; hbyymmincr of the form HB08010001 where HB=Home Branch

UPDATE systempreferences SET explanation='Система классификации, используемая для собрания по умолчанию. Например, Дьюи, УДК, ББК, КБК и т.п.' WHERE variable='DefaultClassificationSource';
-- 	Default classification scheme used by the collection. E.g., Dewey, LCC, etc.

UPDATE systempreferences SET explanation='Если включено, выключает отображение МАРК-полей, подполей и индикаторов (данные показываются, как и раньше)' WHERE variable='hide_marc';
-- 	If ON, disables display of MARC fields, subfield codes & indicators (still shows data)

UPDATE systempreferences SET explanation='Вид по умолчанию библиотечной записи в внутрибиблиотечном интерфейсе' WHERE variable='IntranetBiblioDefaultView';
-- 	IntranetBiblioDefaultView

UPDATE systempreferences SET explanation='Структура международного стандарта библиографического описания ISBD' WHERE variable='ISBD';
-- 	ISBD

UPDATE systempreferences SET explanation='Если включено, позволяет иметь на уровне экземпляра типы экземпляров и правила выдачи' WHERE variable='item-level_itypes';
-- 	If ON, enables Item-level Itemtype / Issuing Rules

UPDATE systempreferences SET explanation='МАРК-поле/подполе, которое используется для расчета шифра для заказа библиотечной единицы {itemcallnumber}, для Unimarc/РусМарк/УкрМарк не фиксированы, может быть 942hv или 852hi из записи экземпляра (в MARC21 для Дьюи будет 082ab или 092ab, для КБК будет 050ab или 090ab)' WHERE variable='itemcallnumber';
-- 	The MARC field/subfield that is used to calculate the itemcallnumber (Dewey would be 082ab or 092ab; LOC would be 050ab or 090ab) could be 852hi from an item record

UPDATE systempreferences SET explanation='Определение, как будет отображаться МАРК-запись' WHERE variable='LabelMARCView';
-- 	Define how a MARC record will display

UPDATE systempreferences SET explanation='Включение поддержки МАРК-стандарта' WHERE variable='marc';
-- 	Turn on MARC support

UPDATE systempreferences SET explanation='Определение глобального МАРК-стандарта (MARC21 или UNIMARC/РусМарк/Укрмарк), который используется для кодирования символов' WHERE variable='marcflavour';
-- 	Define global MARC flavor (MARC21 or UNIMARC) used for character encoding

UPDATE systempreferences SET explanation='Определение МАРК-кода для организации — http://www.loc.gov/marc/organizations/orgshome.html' WHERE variable='MARCOrgCode';
-- 	Define MARC Organization Code - http://www.loc.gov/marc/organizations/orgshome.html

UPDATE systempreferences SET explanation='Если включено, Zebra-индексирование отключено (более простая установка но медленнее поиск)' WHERE variable='NoZebra';
-- 	If ON, Zebra indexing is turned off, simpler setup, but slower searches. WARNING: using NoZebra on even modest sized collections is very slow.

UPDATE systempreferences SET explanation='Запись в особой форме хеша для индексов NoZebra. Записывать подобно следующему: \'indexname\' => \'100a,245a,500*\',\'indexname2\' => \'...\'' WHERE variable='NoZebraIndexes';
-- Enter a specific hash for NoZebra indexes. Enter : \'indexname\' => \'100a,245a,500*\',\'index2\' => \'...\'	

UPDATE systempreferences SET explanation='Включение функции сокрытия в ЭК, требует дальнейшей настройки, обратитесь к системному администратору для получения более детальной информации' WHERE variable='OpacSuppression';
-- 	Turn ON the OPAC Suppression feature, requires further setup, ask your system administrator for details

UPDATE systempreferences SET explanation='Если включена, действует обработка сериальных изданий' WHERE variable='RoutingSerials';
-- 	If ON, serials routing is enabled

UPDATE systempreferences SET explanation='Определение полей библиотечной МАРК-записи для авторитетных записей о личных именах — для заполнения biblio.author' WHERE variable='z3950AuthorAuthFields';
-- 	Define the MARC biblio fields for Personal Name Authorities to fill biblio.author

UPDATE systempreferences SET explanation='Если включено, авторитетные значения о личных именах будут заменять авторов в biblio.author' WHERE variable='z3950NormalizeAuthor';
-- 	If ON, Personal Name Authorities will replace authors in biblio.author


-- Circulation — Оборот

UPDATE systempreferences SET explanation='Разрешить размещать запрос резервирования на поврежденные экземпляры' WHERE variable='AllowHoldsOnDamagedItems';
-- 	 Allow hold requests to be placed on damaged items

UPDATE systempreferences SET explanation='Разрешить размещать запрос резервирования на экземпляры, которые не были выданы' WHERE variable='AllowOnShelfHolds';
-- 	Allow hold requests to be placed on items that are not on loan

UPDATE systempreferences SET explanation='Если включено, позволяет чтобы ограничения на продление были переопределены экраном обращения' WHERE variable='AllowRenewalLimitOverride';
-- 	if ON, allows renewal limits to be overridden on the circulation screen

UPDATE systempreferences SET explanation='Если включено, Коха будет автоматически устанавливать перемещение этого экземпляра к своему домашнему подразделению' WHERE variable='AutomaticItemReturn';
-- 	If ON, Koha will automatically set up a transfer of this item to its homebranch

UPDATE systempreferences SET explanation='С включенными независимыми подразделениями, пользователь с одного библиотечного размещения может резервировать экземпляр в другой библиотеке' WHERE variable='canreservefromotherbranches';
-- 	With Independent branches on, can a user from one library place a hold on an item from another library

UPDATE systempreferences SET explanation='Если включено — задействуется автозавершение для ввода при обороте' WHERE variable='CircAutocompl';
-- 	If ON, autocompletion is enabled for the Circulation input

UPDATE systempreferences SET explanation='Указывается агентство, которое контролирует политики оборота и штрафы' WHERE variable='CircControl';
-- 	Specify the agency that controls the circulation and fines policy

UPDATE systempreferences SET explanation='Если включено, сообщать по электронной почте библиотекаря в тех случаях, когда размещается резервирование (удержание)' WHERE variable='emailLibrarianWhenHoldIsPlaced';
-- 	If ON, emails the librarian whenever a hold is placed

UPDATE systempreferences SET explanation='Указывается, использовать ли календарь в расчете сроков и штрафов' WHERE variable='finesCalendar';
-- 	Specify whether to use the Calendar in calculating duedates and fines

UPDATE systempreferences SET explanation='Выберите режим для штрафов, «отключено», «тестовый» (отчеты по электронной почте администратору) или «рабочий» (начисляются штрафы за просрочку). Предполагается выполнения задания «accruefines» для cron.' WHERE variable='finesMode';
-- 	Choose the fines mode, 'off', 'test' (emails admin report) or 'production' (accrue overdue fines). Requires accruefines cronjob.

UPDATE systempreferences SET explanation='Если установлено, разрешается указывать глобальную статическую дату для всех выдач' WHERE variable='globalDueDate';
-- 	If set, allows a global static due date for all checkouts

UPDATE systempreferences SET explanation='Указывается, сколько дней должно пройти до отмены резервирования' WHERE variable='holdCancelLength';
-- 	Specify how many days before a hold is canceled

UPDATE systempreferences SET explanation='Используется в обороте для определения того, какое подразделение экземпляра проверять при включенных независимых подразделениях, и при поиске, чтобы определить, какие подразделения выбирать для наличия' WHERE variable='HomeOrHoldingBranch';
-- 	Used by Circulation to determine which branch of an item to check with independent branches on, and by search to determine which branch to choose for availability

UPDATE systempreferences SET explanation='Если включено, отключаются штрафы, если посетитель сдает экземпляр, который накапливал задолженность' WHERE variable='IssuingInProcess';
-- 	If ON, disables fines if the patron is issuing item that accumulate debt

UPDATE systempreferences SET explanation='Если установлено, указывает входящее фильтрование штрих-кода экземпляра' WHERE variable='itemBarcodeInputFilter';
-- 	If set, allows specification of a item barcode input filter

UPDATE systempreferences SET explanation='Максимальная сумма задолженных просроченных платежей до запрета резервирований' WHERE variable='maxoutstanding';
-- 	maximum amount withstanding to be able make holds

UPDATE systempreferences SET explanation='Максимальное количество резервирований, которое заемщик может сделать' WHERE variable='maxreserves';
-- 	Define maximum number of holds a patron can place

UPDATE systempreferences SET explanation='Определение максимальной суммы задолженных просроченных платежей до запрета выдачи' WHERE variable='noissuescharge';
-- 	Define maximum amount withstanding before check outs are blocked

UPDATE systempreferences SET explanation='Указывается порядок сортировки предыдущих выпусков на странице оборота' WHERE variable='previousIssuesDefaultSortOrder';
-- 	Specify the sort order of Previous Issues on the circulation page

UPDATE systempreferences SET explanation='Если включено, то будут печататься оборотные квитанции' WHERE variable='printcirculationslips';
-- 	If ON, enable printing circulation receipts

UPDATE systempreferences SET explanation='Если включено, то порядок в очереди резервирований в обороте будет генерироваться случайным образом, или же на основе всех кодов расположений, либо через коды расположений, определяемых в StaticHoldsQueueWeight' WHERE variable='RandomizeHoldsQueueWeight';
-- 	if ON, the holds queue in circulation will be randomized, either based on all location codes, or by the location codes specified in StaticHoldsQueueWeight

 UPDATE systempreferences SET explanation='Определение максимального срока хранения экземпляра на резервировании до забора' WHERE variable='ReservesMaxPickUpDelay';
-- 	Define the Maximum delay to pick up an item on hold

 UPDATE systempreferences SET explanation='Если включено, то зарезервированный экземпляр, что есть в этой библиотеке должен быть возвращен, в противном случае конкретный зарезервирован экземпляр, который есть в библиотеке и доступен, считается (автоматически) доступным' WHERE variable='ReservesNeedReturns';
-- 	If ON, a hold placed on an item available in this library must be checked-in, otherwise, a hold on a specific item, that is in the library & available is considered available

UPDATE systempreferences SET explanation='Если установлено, выдача не будет проводиться, если дата возвращения после даты окончания срока действия карточки посетителя' WHERE variable='ReturnBeforeExpiry';
-- 	If ON, checkout will be prevented if returndate is after patron card expiry

-- UPDATE systempreferences SET explanation='' WHERE variable='SpecifyDueDate';
-- 	Define whether to display "Specify Due Date" form in Circulation
-- Определение, показывать ли форму \'Указать срок\' в обороте

-- UPDATE systempreferences SET explanation='' WHERE variable='StaticHoldsQueueWeight';
-- 	Specify a list of library location codes separated by commas -- the list of codes will be traversed and weighted with first values given higher weight for holds fulfillment -- alternatively, if RandomizeHoldsQueueWeight is set, the list will be randomly selective

-- UPDATE systempreferences SET explanation='' WHERE variable='todaysIssuesDefaultSortOrder';
-- 	Specify the sort order of Todays Issues on the circulation page
-- Укажите порядок сортировки сегодняшних выдач на станице оборота

-- UPDATE systempreferences SET explanation='' WHERE variable='TransfersMaxDaysWarning';
-- 	Define the days before a transfer is suspected of having a problem
-- Определение количества дней до которых ожидается перемещение или же подозревается проблема

-- UPDATE systempreferences SET explanation='' WHERE variable='useDaysMode';
-- 	Choose the method for calculating due date: select Calendar to use the holidays module, and Days to ignore the holidays module
-- Выберите метод расчета срока: выберите календарь для использования модуль праздников, и дни если игнорировать модуль праздников

-- UPDATE systempreferences SET explanation='' WHERE variable='WebBasedSelfCheck';
-- 	If ON, enables the web-based self-check system
-- Если ON, задействует систему самостоятельной проверки на основе веб


-- I18N/L10N

-- UPDATE systempreferences SET explanation='Формат дати (ММ/ДД/РРРР у США, ДД/ММ/РРРР у метричній системі,  РРРР/ММ/ДД за ISO)' WHERE variable='dateformat';
-- 	 Define global date format (us mm/dd/yyyy, metric dd/mm/yyy, ISO yyyy/mm/dd)

-- UPDATE systempreferences SET explanation='' WHERE variable='language';
-- 	Set the default language in the staff client.

-- UPDATE systempreferences SET explanation='Встановлення Вашої привілейованої мови. Мова зверху списку пробуватиметься спочатку.' WHERE variable='opaclanguages';
-- 	Set the default language in the OPAC.

-- UPDATE systempreferences SET explanation='Включення/виключення можливості зміни мови у ЕК' WHERE variable='opaclanguagesdisplay';
-- 	If ON, enables display of Change Language feature on OPAC

-- Logs - Протоколы

-- UPDATE systempreferences SET explanation='' WHERE variable='BorrowersLog';
-- 	 If ON, log edit/create/delete actions on patron data

-- UPDATE systempreferences SET explanation='' WHERE variable='CataloguingLog';
-- 	If ON, log edit/create/delete actions on bibliographic data. WARNING: this feature is very resource consuming.

-- UPDATE systempreferences SET explanation='' WHERE variable='FinesLog';
-- 	If ON, log fines

-- UPDATE systempreferences SET explanation='' WHERE variable='IssueLog';
-- 	If ON, log checkout activity

-- UPDATE systempreferences SET explanation='' WHERE variable='LetterLog';
-- 	If ON, log all notices sent

-- UPDATE systempreferences SET explanation='' WHERE variable='ReturnLog';
-- 	If ON, enables the circulation (returns) log

-- UPDATE systempreferences SET explanation='' WHERE variable='SubscriptionLog';
-- 	If ON, enables subscriptions log


-- OAI-PMH

-- UPDATE systempreferences SET explanation='' WHERE variable='OAI-PMH';
-- 	 if ON, OAI-PMH server is enabled

-- UPDATE systempreferences SET explanation='' WHERE variable='OAI-PMH:archiveID';
-- 	OAI-PMH archive identification

-- UPDATE systempreferences SET explanation='' WHERE variable='OAI-PMH:MaxCount';
-- 	OAI-PMH maximum number of records by answer to ListRecords and ListIdentifiers queries

-- UPDATE systempreferences SET explanation='' WHERE variable='OAI-PMH:Set';
-- 	OAI-PMH exported set, the set name is followed by a comma and a short description, one set by line

-- UPDATE systempreferences SET explanation='' WHERE variable='OAI-PMH:Subset';
-- 	Restrict answer to matching raws of the biblioitems table EXPERIMENTAL


-- OPAC - Электронный каталог

-- UPDATE systempreferences SET explanation='Вкажіть номер_анонімного_позичальника для дозволу анонімних пропозицій' WHERE variable='AnonSuggestions';
-- 	 Set to anonymous borrowernumber to enable Anonymous suggestions

-- UPDATE systempreferences SET explanation='Вигляд по умовчанню для бібліотечного запису. Може приймати значення normal, marc чи isbd' WHERE variable='BiblioDefaultView';
-- 	Choose the default detail view in the catalog; choose between normal, marc or isbd

-- UPDATE systempreferences SET explanation='Показувати чи приховувати \"втрачені\" одиниці у ЕК.' WHERE variable='hidelostitems';
-- 	If ON, disables display of"lost" items in OPAC.

-- UPDATE systempreferences SET explanation='' WHERE variable='kohaspsuggest';
-- 	Track search queries, turn on by defining host:dbname:user:pass

-- UPDATE systempreferences SET explanation='Електронічний каталог бібліотеки', 'Ім\'я бібліотеки або повідомлення, яке буде показане на головній сторінці електронічнго каталогу' WHERE variable='LibraryName';
-- 	Define the library name as displayed on the OPAC

-- UPDATE systempreferences SET explanation='' WHERE variable='OpacAuthorities';
-- 	If ON, enables the search authorities link on OPAC

-- UPDATE systempreferences SET explanation='Включити чи заблокувати відображення бібліотечного замовлення (полички замовлень)' WHERE variable='opacbookbag';
-- 	If ON, enables display of Cart feature

-- UPDATE systempreferences SET explanation='' WHERE variable='OpacBrowser';
-- 	If ON, enables subject authorities browser on OPAC (needs to set misc/cronjob/sbuild_browser_and_cloud.pl)

-- UPDATE systempreferences SET explanation='' WHERE variable='OpacCloud';
-- 	If ON, enables subject cloud on OPAC

-- UPDATE systempreferences SET explanation='Введіть найменування таблиці стилів кольорів для електронічного каталогу' WHERE variable='opaccolorstylesheet';
-- 	Define the color stylesheet to use in the OPAC

-- UPDATE systempreferences SET explanation='Зазначте будь-які вдячності/заслуги у HTML для низу сторінки ЕК' WHERE variable='opaccredits';
-- 	Define HTML Credits at the bottom of the OPAC page

-- UPDATE systempreferences SET explanation='' WHERE variable='OPACDisplayRequestPriority';
-- 	Show patrons the priority level on holds in the OPAC

-- UPDATE systempreferences SET explanation='Користувацький HTML-заголовок для ЕК' WHERE variable='opacheader';
-- 	Add HTML to be included as a custom header in the OPAC

-- UPDATE systempreferences SET explanation='' WHERE variable='OpacHighlightedWords';
-- 	If Set, then queried words are higlighted in OPAC

-- UPDATE systempreferences SET explanation='' WHERE variable='OPACItemHolds';
-- 	Allow OPAC users to place hold on specific items. If OFF, users can only request next available copy.

-- UPDATE systempreferences SET explanation='URL-посилання таблиці стилів для компонування сторінок для електронічного каталогу' WHERE variable='opaclayoutstylesheet';
-- 	Enter the name of the layout CSS stylesheet to use in the OPAC

-- UPDATE systempreferences SET explanation='Вітаємо у АБІС Коха...\r\n<hr>' WHERE variable='OpacMainUserBlock';
-- 	A user-defined block of HTML in the main content area of the opac main page

-- UPDATE systempreferences SET explanation='Використовуйте HTML-закладки для додавання посилань до лівостороньої навігаційної смужки у електронічному каталозі' WHERE variable='OpacNav';
-- 	Use HTML tags to add navigational links to the left-hand navigational bar in OPAC

-- UPDATE systempreferences SET explanation='Дозволити/заблокувати зміну паролю у ЕК (заблокуйте, якщо використовуйте LDAP-авторизацію)' WHERE variable='OpacPasswordChange';
-- 	If ON, enables patron-initiated password change in OPAC (disable it when using LDAP auth)

-- UPDATE systempreferences SET explanation='Включення/виключення відображення історії читання відвідувача у ЕК' WHERE variable='opacreadinghistory';
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

-- UPDATE systempreferences SET explanation='' WHERE variable='OpacTopissue';
-- 	If ON, enables the 'most popular items' link on OPAC. Warning, this is an EXPERIMENTAL feature, turning ON may overload your server

-- UPDATE systempreferences SET explanation='' WHERE variable='OPACURLOpenInNewWindow';
-- 	If ON, URLs in the OPAC open in a new window

-- UPDATE systempreferences SET explanation='' WHERE variable='OPACUserCSS';
-- 	Add CSS to be included in the OPAC in an embedded <style> tag.

-- UPDATE systempreferences SET explanation='' WHERE variable='opacuserjs';
-- 	Define custom javascript for inclusion in OPAC

-- UPDATE systempreferences SET explanation='Включити/заблокувати відображення можливості реєстрації користувача' WHERE variable='opacuserlogin';
-- 	Enable or disable display of user login features

-- UPDATE systempreferences SET explanation='' WHERE variable='OPACViewOthersSuggestions';
-- 	If ON, allows all suggestions to be displayed in the OPAC

-- UPDATE systempreferences SET explanation='' WHERE variable='RequestOnOpac';
-- 	If ON, globally enables patron holds on OPAC

-- UPDATE systempreferences SET explanation='' WHERE variable='reviewson';
-- 	If ON, enables patron reviews of bibliographic records in the OPAC

-- UPDATE systempreferences SET explanation='' WHERE variable='SearchMyLibraryFirst';
-- 	If ON, OPAC searches return results limited by the user's library by default if they are logged in

-- UPDATE systempreferences SET explanation='Якщо рівне 1, то пропозиції будуть активовані у ЕК' WHERE variable='suggestion';
-- 	If ON, enables patron suggestions feature in OPAC

-- UPDATE systempreferences SET explanation='' WHERE variable='URLLinkText';
-- 	Text to display as the link anchor in the OPAC

-- UPDATE systempreferences SET explanation='Встановіть управління віртуальними полицями у ON чи OFF' WHERE variable='virtualshelves';
-- 	If ON, enables Lists management

-- UPDATE systempreferences SET explanation='' WHERE variable='XSLTDetailsDisplay';
-- 	Enable XSL stylesheet control over details page display on OPAC exemple : ../koha-tmpl/opac-tmpl/prog/en/xslt/MARC21slim2OPACDetail.xsl

-- UPDATE systempreferences SET explanation='' WHERE variable='XSLTResultsDisplay';
-- 	Enable XSL stylesheet control over results page display on OPAC exemple : ../koha-tmpl/opac-tmpl/prog/en/xslt/MARC21slim2OPACResults.xsl


-- Patrons — Посетители

-- UPDATE systempreferences SET explanation='' WHERE variable='AddPatronLists';
-- 	 Allow user to choose what list to pick up from when adding patrons

-- UPDATE systempreferences SET explanation='' WHERE variable='AutoEmailOpacUser';
-- 	Sends notification emails containing new account details to patrons - when account is created.

-- UPDATE systempreferences SET explanation='' WHERE variable='AutoEmailPrimaryAddress';
-- 	Defines the default email address where 'Account Details' emails are sent.

-- UPDATE systempreferences SET explanation='Чи автоматично призначати номер квитка відвідувача' WHERE variable='autoMemberNum';
-- 	If ON, patron number is auto-calculated

-- UPDATE systempreferences SET explanation='' WHERE variable='BorrowerMandatoryField';
-- 	Choose the mandatory fields for a patron's account

-- UPDATE systempreferences SET explanation='' WHERE variable='borrowerRelationship';
-- 	Define valid relationships between a guarantor & a guarantee (separated by | or ,)

-- UPDATE systempreferences SET explanation='' WHERE variable='BorrowersTitles';
-- 	Define appropriate Titles for patrons

-- UPDATE systempreferences SET explanation='Перевірка достовірності картки відвідувача: немає перевірки або "Katipo"-перевірка' WHERE variable='checkdigit';
-- 	If ON, enable checks on patron cardnumber: none or "Katipo" style checks

-- UPDATE systempreferences SET explanation='' WHERE variable='EnhancedMessagingPreferences';
-- 	If ON, allows patrons to select to receive additional messages about items due or nearly due.

-- UPDATE systempreferences SET explanation='' WHERE variable='ExtendedPatronAttributes';
-- 	Use extended patron IDs and attributes

-- UPDATE systempreferences SET explanation='' WHERE variable='intranetreadinghistory';
-- 	If ON, Reading History is enabled for all patrons

-- UPDATE systempreferences SET explanation='' WHERE variable='MaxFine';
-- 	Maximum fine a patron can have for a single late return

-- UPDATE systempreferences SET explanation='' WHERE variable='memberofinstitution';
-- 	If ON, patrons can be linked to institutions

-- UPDATE systempreferences SET explanation='' WHERE variable='minPasswordLength';
-- 	Specify the minimum length of a patron/staff password

-- UPDATE systempreferences SET explanation='За скільки днів до завершення дії квитка подавати повідомлення при видачах' WHERE variable='NotifyBorrowerDeparture';
-- 	Define number of days before expiry where circulation is warned about patron account expiry

-- UPDATE systempreferences SET explanation='Включення/виключення відображення зображень відвідувачів в Інтернеті та зазначення розширення файлу для зображень' WHERE variable='patronimages';
-- 	Enable patron images for the Staff Client

-- UPDATE systempreferences SET explanation='' WHERE variable='PatronsPerPage';
-- 	Number of Patrons Per Page displayed by default

-- UPDATE systempreferences SET explanation='' WHERE variable='SMSSendDriver';
-- 	Sets which SMS::Send driver is used to send SMS messages.

-- UPDATE systempreferences SET explanation='' WHERE variable='uppercasesurnames';
-- 	If ON, surnames are converted to upper case in patron entry form


-- Searching — Искание

-- UPDATE systempreferences SET explanation='' WHERE variable='AdvancedSearchTypes';
-- 	 Select which set of fields comprise the Type limit in the advanced search

-- UPDATE systempreferences SET explanation='' WHERE variable='defaultSortField';
-- 	Specify the default field used for sorting

-- UPDATE systempreferences SET explanation='' WHERE variable='defaultSortOrder';
-- 	Specify the default sort order

-- UPDATE systempreferences SET explanation='' WHERE variable='expandedSearchOption';
-- 	If ON, set advanced search to be expanded by default

-- UPDATE systempreferences SET explanation='' WHERE variable='numSearchResults';
-- 	Specify the maximum number of results to display on a page of results

-- UPDATE systempreferences SET explanation='' WHERE variable='OPACdefaultSortField';
-- 	Specify the default field used for sorting

-- UPDATE systempreferences SET explanation='' WHERE variable='OPACdefaultSortOrder';
-- 	Specify the default sort order

-- UPDATE systempreferences SET explanation='' WHERE variable='OPACItemsResultsDisplay';
-- 	statuses : show only the status of items in result list. itemdisplay : show full location of items (branch+location+callnumber) as in staff interface

-- UPDATE systempreferences SET explanation='' WHERE variable='OPACnumSearchResults';
-- 	Specify the maximum number of results to display on a page of results

-- UPDATE systempreferences SET explanation='' WHERE variable='QueryAutoTruncate';
-- 	If ON, query truncation is enabled by default

-- UPDATE systempreferences SET explanation='' WHERE variable='QueryFuzzy';
-- 	If ON, enables fuzzy option for searches

-- UPDATE systempreferences SET explanation='' WHERE variable='QueryRemoveStopwords';
-- 	If ON, stopwords listed in the Administration area will be removed from queries

-- UPDATE systempreferences SET explanation='' WHERE variable='QueryStemming';
-- 	If ON, enables query stemming

-- UPDATE systempreferences SET explanation='' WHERE variable='QueryWeightFields';
-- 	If ON, enables field weighting

-- UPDATE systempreferences SET explanation='Сортувати результати пошуку за необліковуваними МАРК-символами' WHERE variable='sortbynonfiling';
-- 	Sort search results by MARC nonfiling characters (deprecated)


-- StaffClient - Клиент для библиотекарей

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


-- Local Use - Местное использование

-- UPDATE systempreferences SET explanation='Якщо увімкнуто, то ' WHERE variable='AllowHoldPolicyOverride';
-- Allow staff to override hold policies when placing holds

-- UPDATE systempreferences SET explanation='' WHERE variable='AllowNotForLoanOverride';
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

-- UPDATE systempreferences SET explanation='' WHERE variable='MergeAuthoritiesOnUpdate';
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

-- UPDATE systempreferences SET explanation='' WHERE variable='OPACDisplayExtendedSubInfo';
-- 	If ON, extended subscription information is displayed in the OPAC

-- UPDATE systempreferences SET explanation='' WHERE variable='OPACSubscriptionDisplay';
-- 	Specify how to display subscription information in the OPAC

UPDATE systempreferences SET explanation='Если включено, добавляет новое предложение при восстановлении подписки серийного издания' WHERE variable='RenewSerialAddsSuggestion';
-- 	If ON, adds a new suggestion at serial subscription renewal 

-- UPDATE systempreferences SET explanation='Рівень інформативності для хронології періодичних видань у електронічному каталозі' WHERE variable='SubscriptionHistory';
-- 	Define the display preference for serials issue history in OPAC

