# Tag set for internal Explain-data management
#
# $Id: explain.tag,v 1.1 2002/10/22 12:51:09 adam Exp $

name explain
reference Explain-tagset
type 4
include tagsetm.tag

#
# Explain categories
#
tag 1		categoryList					structured
tag 2		targetInfo					structured
tag 3		databaseInfo					structured
tag 4		schemaInfo					structured
tag 5		tagSetInfo					structured
tag 6		recordSyntaxInfo				structured
tag 7           attributeSetInfo				structured
tag 8		termListInfo					structured
tag 9		extendedServicesInfo				structured
tag 10		attributeDetails				structured
tag 11		termListDetails					structured
tag 12		elementSetDetails				structured
tag 13		retrievalRecordDetails				structured
tag 14		sortDetails					structured
tag 15		processing					structured
tag 16		variants					structured
tag 17		units						structured

#
# TargetInfo
#
tag 102		name						string
tag 103		recentNews					string
tag 104		icon						structured
tag 105		namedResultSets					bool
tag 106		multipleDbSearch				bool
tag 107		maxResultSets					numeric
tag 108		maxResultSize					numeric
tag 109		maxTerms					numeric
tag 110		timeoutInterval					intunit
tag 111		welcomeMessage					string
tag 112		contactInfo					structured
tag 113		description					string
tag 114		nicknames					structured
tag 115		usageRest					string
tag 116		paymentAddr					string
tag 117		hours						string
tag 118		dbCombinations					structured
tag 119		addresses					structured
tag 120		internetAddress					structured
tag 121		host						string
tag 122		port						numeric
tag 123		otherAddress					structured
tag 124		addressType					string
tag 125		languages					structured
tag 126		language					string
tag 127		address						string
tag 128		email						string
tag 129		phone						string

#
# DatabaseInfo
#
tag 201		userFee						bool
tag 202		available					bool
tag 203		titleString					string
tag 205		associatedDbs					structured
tag 206		subDbs						structured
tag 207		disclaimers					string
tag 209		recordCount					structured
tag 210		recordCountActual				numeric
tag 211		recordCountApprox				numeric
tag 212		defaultOrder					string
tag 213		avRecordSize					numeric
tag 214		maxRecordSize					numeric
tag 215		hours						string
tag 216		bestTime					string
tag 217		lastUpdate					generalizedtime
tag 218		updateInterval					intunit
tag 219		coverage					string
tag 220		proprietary					bool
tag 221		copyrightText					string
tag 222		copyrightNotice					string
tag 223		producerContactInfo				structured
tag 224		supplierContactInfo				structured
tag 225		submissionContactInfo				structured
tag 226		explainDatabase					null
tag 227		keywords					string

# CategoryList
tag 300		categories					structured
tag 301		category					structured
tag 302		originalName					string
tag 303		asn1Module					string
#
# AccessInfo
#
tag 500		accessinfo					structured
tag 501		queryTypesSupported				structured
tag 503		diagnosticSets					structured
tag 505		attributeSetIds					structured
tag 507		schemas						structured
tag 509		recordSyntaxes					structured
tag 511		resourceChallenges				structured
tag 513		restrictedAccess				structured
tag 514		costInfo					structured
tag 515		variantSets					structured
tag 516		elementSetNames					structured
tag 517		unitSystems					structured
tag 518         queryTypeDetails				structured
tag 519		rpnCapabilities					structured
tag 520		Iso8777Capabilities				structured
tag 521         privateCapabilities				structured

tag 550		rpnOperators					structured
tag 551		rpnOperator					numeric
tag 552		resultSetAsOperandSupported			bool
tag 553		restrictionOperandSupported			bool
tag 554		proximitySupport				structured
tag 555		anySupport					bool
tag 556 	proximityUnitsSupported				structured
tag 557		proximityUnitSupported				structured
tag 558		proximityUnitVal				numeric
tag 559		proximityUnitPrivate				structured
tag 560		proximityUnitDescription			string

# CommonInfo

tag 600		commonInfo					structured
tag 601		dateAdded					generalizedtime
tag 602		dateChanged					generalizedtime
tag 603		expiry						generalizedtime
tag 604		languageCode					string
tag 605 	databaseList					structured

# AttributeDetails, AttributeSetDetails

tag 700		attributesBySet					structured
tag 701		attributeSetDetails				structured
tag 702		attributesByType				structured
tag 703		attributeTypeDetails				structured
tag 704		type						numeric
tag 705		defaultIfOmitted				structured
tag 706		defaultValue					structured
tag 708		attributeValues					structured
tag 709		attributeValue					structured
tag 710		value						structured
tag 711		partialSupport					string
tag 712		subAttributes					structured
tag 713		subAttribute					structured
tag 714		superAttributes					structured
tag 715		superAttribute					structured
tag 716		attributeCombinations				structured
tag 717		legalAttributeCombinations			structured
tag 718		attributeCombination				structured
tag 719		attributeOccurrence				structured
tag 720		mustBeSupplied					bool
tag 721		anyOrNone					string
tag 722		specific					structured

#
# AttributeSetInfo
#
tag 750		attributes					structured
tag 751		attributeType					structured
tag 752		equivalentAttribute				structured
#
# General tags for list members, etc.
#
tag 1000	oid						oid
tag 1001	string						string
tag 1002	numeric						numeric

