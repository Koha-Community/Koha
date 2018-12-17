#!/usr/bin/perl
package Koha::Reporting::Import::Abstract;

use Modern::Perl;
use Moose;
use Try::Tiny;
use Data::Dumper;
use C4::Context;
use Koha::Reporting::Table::Fact::Factory;
use Koha::Reporting::Table::Abstract;
use POSIX qw(strftime floor);
use Time::Piece;
use Encode;
use utf8;
use YAML::XS;
use Koha::Exception::BadSystemPreference;
use Koha::ItemTypes;


has 'fact_table' => (
    is => 'rw',
    reader => 'getFactTable',
    writer => 'setFactTable'
);

has 'factTableFactory' => (
    is => 'rw',
    reader => 'getFactTableFactory',
    writer => 'setFactTableFactory'
);

has 'column_transform_method' => (
    is => 'rw',
    isa => 'HashRef',
    default => sub { {} },
    reader => 'getColumnTransformMethods',
    writer => 'setColumnTransformMethods'
);

has 'name' => (
    is => 'rw',
    reader => 'getName',
    writer => 'setName'
);

has 'limit' => (
    is => 'rw',
    reader => 'getLimit',
    writer => 'setLimit'
);

has 'last_allowed_id' => (
    is => 'rw',
    writer => 'setLastAllowedId'
);

has 'last_selected_id' => (
    is => 'rw',
    reader => 'getLastSelectedId',
    writer => 'setLastSelectedId'
);

has 'last_inserted_fact_id' => (
    is => 'rw',
    reader => 'getLastInsertedFactId',
    writer => 'setLastInsertedFactId'
);

has 'last_allowed_id' => (
    is => 'rw',
    writer => 'setLastAllowedId'
);

has 'column_filters' => (
    is => 'rw',
    isa => 'HashRef',
    default => sub { {} },
    reader => 'getColumnFilters',
    writer => 'setColumnFilters'
);

has 'table_abstract' => (
    is => 'rw',
    reader => 'getTableAbstract',
    writer => 'setTableAbstract'
);

has 'retry_count' => (
    is => 'rw',
    default => '0',
    reader => 'getRetryCount',
    writer => 'setRetryCount'
);

has 'insert_on_duplicate_fact' => (
    is => 'rw',
    reader => 'getInsertOnDuplicateFact',
    writer => 'setInsertOnDuplicateFact'
);


sub BUILD {
    my $self = shift;
    my $factTableFactory = new Koha::Reporting::Table::Fact::Factory;
    if($factTableFactory){
        $self->setFactTableFactory($factTableFactory);
    }

    my $tableAbstract = new Koha::Reporting::Table::Abstract;
    if($tableAbstract){
        $self->setTableAbstract($tableAbstract);
    }

    $self->{column_transform_method}->{date}->{date_id} = \&dateDateId;
    $self->{column_transform_method}->{date}->{year} = \&dateYear;
    $self->{column_transform_method}->{date}->{month} = \&dateMonth;
    $self->{column_transform_method}->{date}->{day} = \&dateDay;
    $self->{column_transform_method}->{date}->{hour} = \&dateHour;

    $self->{column_transform_method}->{item}->{is_yle} = \&itemIsYle;
    $self->{column_transform_method}->{item}->{language} = \&itemLanguage;
    $self->{column_transform_method}->{item}->{language_all} = \&itemLanguageAll;

    $self->{column_transform_method}->{item}->{published_year} = \&itemPublishedYear;
    $self->{column_transform_method}->{item}->{itemtype_okm} = \&itemItemTypeOkm;
    $self->{column_transform_method}->{item}->{title} = \&itemTitle;

    $self->{column_transform_method}->{item}->{cn_class} = \&itemCnClass;
    $self->{column_transform_method}->{item}->{cn_class_fict} = \&itemCnClassFict;
    $self->{column_transform_method}->{item}->{cn_class_primary} = \&itemCnClassPrimary;
    $self->{column_transform_method}->{item}->{cn_class_1_dec} = \&itemCnClass1Dec;
    $self->{column_transform_method}->{item}->{cn_class_2_dec} = \&itemCnClass2Dec;
    $self->{column_transform_method}->{item}->{cn_class_3_dec} = \&itemCnClass3Dec;
    $self->{column_transform_method}->{item}->{cn_class_signum} = \&itemCnClassSignum;

    $self->{column_transform_method}->{borrower}->{age_group} = \&borrowerAgeGroup;

    $self->{column_transform_method}->{location}->{branch} = \&locationBranch;
    $self->{column_transform_method}->{location}->{location} = \&locationLocation;

    $self->{column_transform_method}->{location}->{location_type} = \&locationLocationType;
    $self->{column_transform_method}->{location}->{location_age} = \&locationLocationAge;

}

sub initFactTable{
    my $self = shift;
    my $name = $_[0];
    if($self->getFactTableFactory()){
        my $factTable = $self->getFactTableFactory()->create($name);
        if($factTable){
            $self->setFactTable($factTable);
        }
    }
}

sub initImportSettings{
    my $self = shift;
    my $result = 0;
    my $dbh = C4::Context->dbh;
    my $lastAllowedId = $self->getLastAllowedId();
    if($lastAllowedId && $self->getName()){
        my $select = $dbh->prepare('select * from reporting_import_settings where name = ?');
        $select->execute($self->getName());
        if($select->rows == 1){
            my $row = $select->fetchrow_hashref();
            my $lastSelected = $row->{last_selected};
            if(defined $row->{last_inserted} && defined $row->{last_selected} && $row->{last_inserted} ne $row->{last_selected}){
                $lastSelected = $row->{last_inserted};
            }
            elsif(!defined $row->{last_inserted}){
                undef $lastSelected;
            }

            if(defined $row->{last_inserted_fact}){
                $self->setLastInsertedFactId($row->{last_inserted_fact});
            }

            if(defined $row->{primary_id}  && $lastAllowedId){
                my $insert = $dbh->prepare('update reporting_import_settings set last_selected = ?, last_allowed_select = ? where primary_id = ?');
                $result = $insert->execute($lastSelected, $lastAllowedId, $row->{primary_id}) or die($DBI::errstr);
                $self->setLastSelectedId($lastSelected);
                $self->setLimit($row->{batch_limit});
            }
        }
    }
    return $result;
}

sub updateLastSelected{
    my $self = shift;
    my $lastSelected = $_[0];
    my $dbh = C4::Context->dbh;
    my $result = 0;
    if($lastSelected && $self->getName()){
        my $insert = $dbh->prepare('update reporting_import_settings set last_selected = ?  where name = ?');
        $result = $insert->execute($lastSelected, $self->getName()) or die($DBI::errstr);
        $self->setLastSelectedId($lastSelected);
    }
    return $result;
}

sub updateLastInserted{
    my $self = shift;
    my $lastInserted = $_[0];
    my $lastInsertedFactId = $_[1];
    my $dbh = C4::Context->dbh;
    my $result = 0;
    if($lastInserted && $self->getName()){
        my $insert = $dbh->prepare('update reporting_import_settings set last_inserted = ?, last_inserted_fact = ?  where name = ?');
        $result = $insert->execute($lastInserted, $lastInsertedFactId, $self->getName()) or die($DBI::errstr);
    }
    return $result;
}


sub getLastAllowedId{
    my $self = shift;
    if(!defined $self->{last_allowed_id}){
       $self->loadLastAllowedId();
    }
    return $self->{last_allowed_id};
}

sub loadLastAllowedId{}


sub massImport{
    my $self = shift;
    my $continue = 1;
    $self->beforeMassImport();
    if($self->initImportSettings()){
        while($continue){
            $continue = $self->importDatas();
        }
    }
}

sub beforeMassImport{}

sub importDatas{
    my $self = shift;
    my $datas = $self->loadDatas();
    my ($fact, $row, $dimension, $tpmRows);
    my $dbh = C4::Context->dbh;
    $self->changeWaitTimeOut();
    my $result = 0;
    if($datas && @$datas){
        $fact = $self->getFactTable();
        $fact->initColumns();
        $fact->initDefaultImportColumns();
        my $dimensions = $fact->getDimensions();
        $dimensions = $self->applyColumnFilters($dimensions);
        $self->applyColumnFilters({'fact' => $fact});
print Dumper 'datas';

        foreach my $data (@$datas){
            $tpmRows = {};
            foreach my $dimensionName (keys %$dimensions){
                $dimension = $dimensions->{$dimensionName};
                if($dimension){
                   $row = $self->transformData($data, $dimensionName, $dimension);
                   if($row){
                       $tpmRows->{$dimensionName} = $row;
                   }
                   else{
                       die Dumper "invalid row";
                       $tpmRows = {};
                       last;
                   }
                }
            }
            if(%{$tpmRows}){
                my $tmpFactRow = {};
                foreach my $dimensionName (keys %$dimensions){
                    $dimension = $dimensions->{$dimensionName};
                    if($dimension && defined $tpmRows->{$dimensionName}){
                        my $tmpRow = $tpmRows->{$dimensionName};
                        my $key = $dimension->addImportRow($tmpRow);
                        $tmpFactRow->{$dimensionName} = $key;
                    }
                }
                if(%{$tmpFactRow}){
                    my $factData = $self->transformData($data, 'fact', $fact);
                    if($factData && @$factData){
                        $tmpFactRow->{'row_data'} = $factData;
                    }
                    if($fact->validateTmpFactRow($tmpFactRow)){
                        $fact->addTmpImportRow($tmpFactRow);
                    }
                    else{
                        die Dumper "invalid tmp fact row";
                    }
                }
            }
        }

print Dumper 'datas done';

        try{
            $result = $self->runAllInserts($dimensions, $fact);
        }
        catch{
            print Dumper "Not retrying. Something went wrong.";
        };
    }
    return $result;
}


sub runAllInserts{
    my $self = shift;
    my ($dimensions, $fact) = @_;
    my $result = 0;
    try{
        $self->beginTransaction();
        $self->insertDimensionData($dimensions, $fact);
        my $lastInsertedFactId = $self->insertFactData($dimensions);
        if($lastInsertedFactId){
           $self->extraInserts($lastInsertedFactId);
        }
        $self->updateLastInserted($self->getLastSelectedId(), $lastInsertedFactId);
        $self->commitTransaction();
        $self->initFactTable($self->getFactTable()->getName());
        $self->setLastInsertedFactId($lastInsertedFactId);
        $result = 1;
    }
    catch{
        print Dumper "rollingBack";
        print Dumper $_;
        $self->rollBack();
        if($self->getRetryCount() <= 5){
            print Dumper "Retrying all inserts!";
            $self->setRetryCount($self->getRetryCount() + 1);
            sleep(60);
#            C4::Context->dbh->disconnect();
            #C4::Context->dbh('new');
            $self->initFactTable($self->getFactTable()->getName());
            $result = $self->runAllInserts($dimensions, $fact);
        }
    };
    return $result;
}

sub changeWaitTimeOut{
    my $self = shift;
    my $dbh = C4::Context->dbh;
    my $stmnt = $dbh->prepare('set wait_timeout = 49');
    $stmnt->execute();
}

sub extraInserts{}

sub insertDimensionData{
    my $self = shift;
    my $dbh = C4::Context->dbh;
    my $dimensions = $_[0];
    my $insert;
    foreach my $dimensionName (keys %$dimensions){
        my $dimension = $dimensions->{$dimensionName};
        if($dimension){
            $insert = $dimension->createImportInsert(1);
            if($insert && $insert ne ''){
                $dimension->setRetryCount(0);
                $dimension->execute($insert);
                $dimension->loadKeyMapping();
            }
            else{
                die Dumper "invalid dimesnion insert: " . $dimensionName;
            }
        }
   }
}

sub insertFactData{
    my $self = shift;

print Dumper 'fact';
    my $dbh = C4::Context->dbh;
    my $fact = $self->getFactTable();
    my ($insert, $row, $lastId);
    my $dimensions = $_[0];
    my $primaryIdsByDimensionName = $self->getPrimaryIdsByDimesionName($dimensions);
    my $tmpRows = $fact->getTmpImportRows();
    $self->addFactInsertColumns($dimensions, $fact);
    foreach my $tmpRow (@$tmpRows){
        if(defined $tmpRow->{row_data} && @{$tmpRow->{row_data}}){
            $row = $tmpRow->{row_data};
            delete $tmpRow->{row_data};
        }
        else{
            next;
        }
        foreach my $dimensionName (sort keys $tmpRow){
            my $tmpKeys = $tmpRow->{$dimensionName};
            my $dimension = $dimensions->{$dimensionName};
            my $bussinesKeys = $dimension->getBusinessKey();
            my @bKey;
            foreach my $bussinesKey(@$bussinesKeys){
                if(defined $tmpKeys->{$bussinesKey}){
                    push @bKey, $tmpKeys->{$bussinesKey};
                }
            }
            my $primaryId = $dimension->getPrimaryIdByBusinessKey(\@bKey);
            if($primaryId){
                push $row, $primaryId;
            }
            else{
               print Dumper "invalid dimesnion pkey". $dimensionName;
               print Dumper $tmpRow;
               die Dumper $row;
            }
        }
        if(@$row && $fact->validateImportRow($row)){
            $fact->addImportRow($row);
        }
        else{
            print Dumper "Invalid fact import row";
            die Dumper $tmpRow;
        }
    }
print Dumper 'fact insert';

    if($self->getInsertOnDuplicateFact()){
        $insert = $fact->createImportInsert(1);
    }
    else{
        $insert = $fact->createImportInsert();
    }

    if($insert && $insert ne ''){
        try {
            $fact->setRetryCount(0);
            $fact->execute($insert);
        } catch {
            print Dumper $insert;
            die($_);
        };
        $lastId = $self->getLastInsertedId($fact);
    }
print Dumper 'fact done';

    return $lastId;
}

sub getLastInsertedId{
    my $self = shift;
    my $fact = $_[0];
    my $dbh = C4::Context->dbh;
    my $idQuery = 'select MAX('. $fact->getPrimaryId() .') from ' . $fact->getTableName();
    my $idStmnt = $dbh->prepare($idQuery);
    $idStmnt->execute();
    return $idStmnt->fetch()->[0];
}

sub addFactInsertColumns{
    my $self = shift;
    my $dimensions = $_[0];
    my $fact = $_[1];
    foreach my $dimensionName (sort keys $dimensions){
        my $dimension = $dimensions->{$dimensionName};
        if($dimension && $dimension->getPrimaryId()){
            $fact->addImportColumn($dimension->getPrimaryId());
        }
    }
}

sub getPrimaryIdsByDimesionName{
    my $self = shift;
    my $dimensions = $_[0];
    my $result = {};
    if(%$dimensions){
        foreach my $dimensionName (keys $dimensions){
            my $dimension = $dimensions->{$dimensionName};
            $result->{$dimensionName} = $dimension->getPrimaryId();
        }
    }
    return $result;
}

sub loadDatas{}

sub transformData{
    my $self = shift;
    my $data = $_[0];
    my $tableAlias = $_[1];
    my $table = $_[2];
    my (@row, $value, $result);
    my $invalid = 0;
    my $lastColumn;
    my $lastValue;

    if($table && $tableAlias){
        my $columns = $table->getImportColumns();
        foreach my $column (@$columns){
           undef $value;
           $lastColumn = $column;
           if(defined $self->{column_transform_method}->{$tableAlias}->{$column}){
               $value = $self->{column_transform_method}->{$tableAlias}->{$column}->($self, $data, $table);
           }
           elsif(exists $data->{$column}){
              $value = $data->{$column};
           }
           $lastValue = $value;

           if($table->validateColumnValue($column, $value)){
               push @row, $value;
           }
           else{
               $invalid = 1;
               last;
           }
        }

         if($invalid){
            print "$tableAlias : $lastColumn was invaid! \n";
            print Dumper $data;
            undef @row;
         }
         else{
            $result = \@row;
         }
    }
    return $result;
}

sub beginTransaction{
    my $self = shift;
    my $dbh = C4::Context->dbh;
 #   $dbh->do('START TRANSACTION');
}


sub commitTransaction{
    my $self = shift;
    my $dbh = C4::Context->dbh;
 #   $dbh->do('COMMIT');
}

sub rollBack{
    my $self = shift;
    my $dbh = C4::Context->dbh;
 #   $dbh->do('ROLLBACK');
}

sub getWhereLogic{
    my $self = shift;
    my $where = $_[0];
    my $logic = '';
    if($where eq ''){
        $logic = 'where'
    }
    else{
        $logic = 'and'
    }
    return $logic;
}

sub applyColumnFilters{
    my $self = shift;
    my $dimensions = $_[0];

    foreach my $dimensionName (keys $dimensions){
        my $dimension = $dimensions->{$dimensionName};
        if(defined $self->{column_filters}->{$dimensionName}){
            my $columnFilters = $self->{column_filters}->{$dimensionName};
            my $importColumns = $dimension->getImportColumns();
            my $filteredColumns = [];
            foreach my $importColumn (@$importColumns){
                if(! defined $columnFilters->{$importColumn}){
                    push $filteredColumns, $importColumn;
                }
            }
            $dimension->setImportColumns($filteredColumns);
        }
    }

    return $dimensions;
}

sub dateDateId{
    my $self = shift;
    my $data = $_[0];
    my $dimension = $_[1];
    my $result;

    if(!defined $data->{date_id} && defined $data->{datetime}){
        $self->initDateData($data);
    }
    if(defined $data->{date_id}){
        $result =  $data->{date_id};
    }
    return $result;
}

sub dateYear{
    my $self = shift;
    my $data = $_[0];
    my $dimension = $_[1];
    my $result;

    if(!defined $data->{year} && defined $data->{datetime}){
        $self->initDateData($data);
    }
    if(defined $data->{year}){
        $result =  $data->{year};
    }
    return $result;
}

sub dateMonth{
    my $self = shift;
    my $data = $_[0];
    my $dimension = $_[1];
    my $result;

    if(!defined $data->{month} && defined $data->{datetime}){
        $self->initDateData($data);
    }
    if(defined $data->{month}){
        $result =  $data->{month};
    }
    return $result;
}

sub dateDay{
    my $self = shift;
    my $data = $_[0];
    my $dimension = $_[1];
    my $result;

    if(!defined $data->{day} && defined $data->{datetime}){
        $self->initDateData($data);
    }
    if(defined $data->{day}){
        $result =  $data->{day};
    }
    return $result;
}

sub dateHour{
    my $self = shift;
    my $data = $_[0];
    my $dimension = $_[1];
    my $result;

    if(!defined $data->{hour} && defined $data->{datetime}){
        $self->initDateData($data);
    }
    if(defined $data->{hour}){
        $result =  $data->{hour};
    }
    return $result;
}

sub initDateData{
    my $self = shift;
    my $data = $_[0];
    if(defined $data->{datetime}){
      my $date;
      eval { $date = Time::Piece->strptime($data->{datetime}, "%Y-%m-%d %R:%S") };
      if($date && defined $date->year ){
           $data->{year} = $date->year;
           $data->{month} = $date->mon;
           $data->{day} = $date->mday;
           $data->{hour} = $date->hour;
           $data->{date_id} = $date->year . sprintf("%02d", $date->mon) . sprintf("%02d", $date->mday)  . sprintf("%02d", $date->hour);
       }
       else{
           $data->{year} = '1001';
           $data->{month} = '1';
           $data->{day} = '1';
           $data->{hour} = '1';
           $data->{date_id} = '1000000000';
       }
    }
}

sub borrowerAgeGroup{
    my $self = shift;
    my $data = $_[0];
    my $dimension = $_[1];
    my ($age, $dateOfBirth, $currentDate);
    if(defined $data->{dateofbirth}){
        $dateOfBirth = $data->{dateofbirth};
        if($dateOfBirth){
            $dateOfBirth = eval{ Time::Piece->strptime($dateOfBirth, "%Y-%m-%d")->epoch() };
            if($dateOfBirth){
                $age = floor( ( time() - $dateOfBirth) / 31536000 );
            }
        }
    }
    my $ageGroup = $self->getAgeGroup($age);
    return $ageGroup;
}

sub getAgeGroup{
    my $self = shift;
    my $age = $_[0];
    my $ageGroup;

if(defined $age){
    if($age >= 0 && $age <= 6){
        $ageGroup = '0-6';
    }
    elsif($age >= 7 && $age <= 12){
        $ageGroup = '07-12';
    }
    elsif($age >= 13 && $age <= 15){
        $ageGroup = '13-15';
    }
    elsif($age >= 16 && $age <= 18){
        $ageGroup = '16-18';
    }
    elsif($age >= 19 && $age <= 24){
        $ageGroup = '19-24';
    }
    elsif($age >= 25 && $age <= 44){
        $ageGroup = '25-44';
    }
    elsif($age >= 45 && $age <= 64){
        $ageGroup = '45-64';
    }
    elsif($age >= 65 && $age <= 74){
        $ageGroup = '65-74';
    }
    elsif($age >= 75 && $age <= 84){
        $ageGroup = '75-84';
    }
    elsif($age >= 85){
        $ageGroup = '85-';
    }
}
    return $ageGroup;
}

sub itemItemTypeOkm{
    my $self = shift;
    my $data = $_[0];
    my $dimension = $_[1];
    my $config = $self->loadConfiguration();
    my $result;

    if(defined $data->{itemtype}){
        my $type = $data->{itemtype};
        my $cnPrimary = $self->itemCnClassPrimary($data, $dimension);

        my $category = $config->{itemTypeToStatisticalCategory}->{$type};

        if($category && $category eq 'Books'){
            $result = 'Kirjat';
        }
        elsif($category && $category eq 'SheetMusicAndScores'){
            $result = 'Nuotit ja partituurit';
        }
        elsif( $cnPrimary && $cnPrimary eq '78' && $category && $category eq 'Recordings' ){
            $result = 'Musiikkiäänitteet';
        }
        elsif( $cnPrimary && $cnPrimary ne '78' && $category && $category eq 'Recordings' ){
            $result = 'Muut äänitteet';
        }
        elsif($category && $category eq 'Videos'){
            $result = 'Videot';
        }
        elsif($category && $category eq 'CDROMs'){
            $result = 'CD-ROM-levyt';
        }
        elsif($category && $category eq 'Other'){
            $result = 'Muut aineistot';
        }
        elsif($category && $category eq 'DVDsAndBluRays'){
            $result = 'DVD ja Blu-ray -levyt';
        }
        elsif($category && $category eq 'Celia'){
            $result = 'Celian cd-levy';
        }
        elsif($category && $category eq 'Electronic'){
            $result = 'E-kirja';
        }
        elsif($category && $category eq 'Online'){
            $result = 'Verkkoaineisto';
        }
    }

    return $result;
}

sub itemIsYle{
    my $self = shift;
    my $data = $_[0];
    my $dimension = $_[1];
    my $result = 0;

    if($dimension){
        my $marc = $self->initMarc($data, $dimension);
        if($marc){
            my $value = $marc->subfield('260','b');
            if(defined $value){
               $_ = $value;
               if( /^YLE/ || /^Yle/){
                  $result = 1;
               }
            }
        }
    }
    return $result;
}

sub itemLanguage{
    my $self = shift;
    my $data = $_[0];
    my $dimension = $_[1];
    my $result;

    if(!defined $data->{language}){
        $self->initLanguageData($data);
    }
    if(defined $data->{language}){
        $result =  $data->{language};
    }
    return $result;


    return $result;
}

sub itemLanguageAll{
    my $self = shift;
    my $data = $_[0];
    my $dimension = $_[1];
    my $result;

    if(!defined $data->{language_al}){
        $self->initLanguageData($data);
    }
    if(defined $data->{language_all}){
        $result =  $data->{language_all};
    }
    return $result;


    return $result;
}

sub initLanguageData{
    my $self = shift;
    my $data = $_[0];
    my $dimension = $_[1];
    my $language;

    my $marc = $self->initMarc($data, $dimension);
    if($marc){
        my $value = $marc->subfield('041','a');
        if(defined $value){
            $value =~ s/^\s+|\s+$//g
        }

        if(!defined $value || $value eq ''){
            $value = $marc->subfield('041','d');
        }

        if($value && ($value ne 'fin' && $value ne 'swe')){
            $language = 'other';
        }
        elsif($value){
            $language = $value;
        }

        if(defined $language){
            $data->{'language'} = $language;
        }
        if(defined $value){
            $data->{'language_all'} = $value;
        }
    }
}

sub itemPublishedYear{
    my $self = shift;
    my $data = $_[0];
    my $dimension = $_[1];
    my ($result, $year);

    if($data && defined $data->{published_year} ){
        $result = $data->{published_year};
    }
    if(!$result || $result ne ''){
        if($dimension){
            my $marc = $self->initMarc($data, $dimension);
            if($marc){
                $year = $marc->subfield('260','c');
                if($year){ #remove non digit characters.
                    $year =~ s/\D//g;
                }
                if($year){
                    $_ = $year;
                    if(m/^\d{4}$/){ #check if digit is 4 numbers
                        $result = $year;
                    }
                }
            }
        }
    }
    return $result;
}

sub itemTitle{
    my $self = shift;
    my $data = $_[0];
    my $dimension = $_[1];
    my ($result, $mainTitle, $additionalTitle, $respTitle);

    if($data && defined $data->{title} ){
        $result = $data->{title};
    }
    if(!$result || $result ne ''){
        if($dimension){
            my $marc = $self->initMarc($data, $dimension);
            if($marc){
                $mainTitle = $marc->subfield('245','a');
                $additionalTitle = $marc->subfield('245','b');
                $respTitle = $marc->subfield('245','c');
                if($mainTitle){
                    $result = $mainTitle;
                    if($additionalTitle){
                        $result .= $additionalTitle;
                    }
                    if($respTitle){
                        $result .= $respTitle;
                    }
                }

            }
        }
    }
    return $result;
}

sub initMarc{
    my $self = shift;
    my $data = $_[0];
    my $dimension = $_[1];
    my $marc;

    if(defined $data->{'marcxml'}){
        my $marcXml = $data->{'marcxml'};
        if($marcXml && $marcXml->isa('MARC::Record')){
            $marc = $marcXml;
        }
        elsif($marcXml){
            $marc = $dimension->initMarcXml($marcXml);
            $data->{'marcxml'} = $marc;
        }
    }
    return $marc;
}

sub itemCnClassFict{
    my $self = shift;
    my $data = $_[0];
    my $dimension = $_[1];
    my $result;
    if($dimension){
        my $marc = $self->initMarc($data, $dimension);
        if($marc){
            my @fields = $marc->field('084');
            foreach my $field (@fields){
                if($field->subfield('a') && $field->indicator(1) eq '9'){
                     my $tmpResult = $field->subfield('a');
                     $_ = $tmpResult;
                     if(/([[:alpha:]]+)/){
                         $result = $tmpResult;
                     }
                }
            }
        }
    }
    return $result;
}


sub itemCnClass{
    my $self = shift;
    my $data = $_[0];
    my $dimension = $_[1];
    my $result;

    if(!defined $data->{cn_class}){
        $self->initCnClassData($data, $dimension);
    }
    if(defined $data->{cn_class}){
        $result =  $data->{cn_class};
    }
    return $result;
}

sub itemCnClassPrimary{
    my $self = shift;
    my $data = $_[0];
    my $dimension = $_[1];
    my $result;

    if(!defined $data->{cn_class_primary}){
        $self->initCnClassData($data, $dimension);
    }
    if(defined $data->{cn_class_primary}){
        $result =  $data->{cn_class_primary};
    }
    return $result;
}

sub itemCnClass1Dec{
    my $self = shift;
    my $data = $_[0];
    my $dimension = $_[1];
    my $result;

    if(!defined $data->{cn_class_1_dec}){
        $self->initCnClassData($data, $dimension);
    }
    if(defined $data->{cn_class_1_dec}){
        $result =  $data->{cn_class_1_dec};
    }
    return $result;
}

sub itemCnClass2Dec{
    my $self = shift;
    my $data = $_[0];
    my $dimension = $_[1];
    my $result;

    if(!defined $data->{cn_class_2_dec}){
        $self->initCnClassData($data, $dimension);
    }
    if(defined $data->{cn_class_2_dec}){
        $result =  $data->{cn_class_2_dec};
    }
    return $result;
}

sub itemCnClass3Dec{
    my $self = shift;
    my $data = $_[0];
    my $dimension = $_[1];
    my $result;

    if(!defined $data->{cn_class_3_dec}){
        $self->initCnClassData($data, $dimension);
    }
    if(defined $data->{cn_class_3_dec}){
        $result =  $data->{cn_class_3_dec};
    }
    return $result;
}

sub itemCnClassSignum{
    my $self = shift;
    my $data = $_[0];
    my $dimension = $_[1];
    my $result;

    if(!defined $data->{cn_class_signum}){
        $self->initCnClassData($data, $dimension);
    }
    if(defined $data->{cn_class_signum}){
        $result =  $data->{cn_class_signum};
    }
    return $result;
}

sub initCnClassData{
    my $self = shift;
    my $data = $_[0];
    my $dimension = $_[1];
    my $result;
    my $cnSort;
    my $cnClass;
    my $signum;

    if(defined $data->{cn_sort}){
        $_ = $data->{cn_sort};
        if(/.([[:alpha:]]+)/){
            $signum = $1;
            if(defined $signum && $signum ne ''){
                $signum = encode('UTF-8', $signum, Encode::FB_CROAK);
                $data->{'cn_class_signum'} = $signum;
            }
        }
    }

    if($dimension){
        my $marc = $self->initMarc($data, $dimension);
        if($marc){
            $cnSort = $marc->subfield('084','a');
            $_ = $cnSort;
            if(defined $cnSort && /([0-9]*[.][0-9]*)/){
                $cnClass =  $1;
                if($cnClass){
                    $self->setCnData($data, $cnClass);
                    $result = 1;
                }
            }
            elsif(defined $cnSort && /([0-9]*)/){
                $cnClass =  $1;
                if($cnClass){
                    $self->setCnData($data, $cnClass);
                    $result = 1;
                }
            }
        }
    }

    if(!defined $result){
        undef $cnSort;
        if(defined $data->{cn_sort}){
            $cnSort = $data->{cn_sort};
        }

        if(defined $cnSort){
            $_ = $cnSort;
            if(/([0-9]*[.][0-9]*)/){
                $cnClass =  $1;
                if($cnClass){
                     $self->setCnData($data, $cnClass);
                     $result = 1;
                }
            }
            elsif(/([0-9]*)/){
                $cnClass =  $1;
                if($cnClass){
                    $self->setCnData($data, $cnClass);
                    $result = 1;
                }
            }
        }
    }
}

sub initCnClassDataOld{
    my $self = shift;
    my $data = $_[0];
    my $dimension = $_[1];
    my $result;
    my $cnSort;
    my $cnClass;
    if(defined $data->{cn_sort}){
        $cnSort = $data->{cn_sort};
    }

    if(defined $cnSort){
        $_ = $cnSort;
        if(/([0-9]*[.][0-9]*)/){
            $cnClass =  $1;
            if($cnClass){
                 $self->setCnData($data, $cnClass);
                 $result = 1;
            }
        }
        elsif(/([0-9]*)/){
            $cnClass =  $1;
            if($cnClass){
                 $self->setCnData($data, $cnClass);
                 $result = 1;
            }
        }
    }

    if(!defined $result){
        if($dimension){
            my $marc = $self->initMarc($data, $dimension);
            if($marc){
                $cnSort = $marc->subfield('084','a');
                $_ = $cnSort;
                if(defined $cnSort && /([0-9]*[.][0-9]*)/){
                    $cnClass =  $1;
                    if($cnClass){
                        $self->setCnData($data, $cnClass);
                        $result = 1;
                    }
                }
                elsif(defined $cnSort && /([0-9]*)/){
                    $cnClass =  $1;
                    if($cnClass){
                        $self->setCnData($data, $cnClass);
                        $result = 1;
                    }
                }
            }
        }
    }
}


sub setCnData{
    my $self = shift;
    my $data = $_[0];
    my $cnClass = $_[1];
    my ($cnFirstDec, $cnSecondDec, $cnThirdDec);

    if(defined $cnClass){
        my ($cnPrimary, $cnDecimal) = split /\./, $cnClass;

        if(defined $cnDecimal){
            ($cnFirstDec, $cnSecondDec, $cnThirdDec) = split //, $cnDecimal;
        }

        if(defined $cnClass && $cnClass ne ''){
            $data->{cn_class} = $cnClass;
        }
        if(defined $cnPrimary && $cnPrimary ne ''){
            $data->{cn_class_primary} = $cnPrimary;
        }
        if(defined $cnFirstDec && $cnFirstDec ne ''){
            $data->{cn_class_1_dec} = $cnFirstDec;
        }
        if(defined $cnSecondDec && $cnSecondDec ne ''){
            $data->{cn_class_2_dec} = $cnSecondDec;
        }
        if(defined $cnThirdDec && $cnThirdDec ne ''){
            $data->{cn_class_3_dec} = $cnThirdDec;
        }
    }
    return $data;
}

sub locationLocationType{
    my $self = shift;
    my $data = $_[0];
    my $dimension = $_[1];
    my $result;

    if(!defined $data->{location_type}){
        $self->initLocationTypeData($data, $dimension);
    }

    if(defined $data->{location_type}){
        $result = $data->{location_type};
    }

    return $result;
}

sub locationLocationAge{
    my $self = shift;
    my $data = $_[0];
    my $dimension = $_[1];
    my $result;

    if(!defined $data->{location_age}){
        $self->initLocationTypeData($data, $dimension);
    }

    if(defined $data->{location_age}){
        $result = $data->{location_age};
    }

    return $result;
}

sub initLocationTypeData{
    my $self = shift;
    my $data = $_[0];
    my $dimension = $_[1];
    my ($location, $cnClassPrimary);
    my $config = $self->getSearchableConfig();
    my $adultLocations = $config->{adultShelvingLocations};
    my $childLocations = $config->{juvenileShelvingLocations};

    if(defined $data->{location}){
        $location = $data->{location};
    }

    if(defined $location && defined $adultLocations->{$location}){
        $data->{location_age} = 'aikuiset';
    }
    elsif(defined $location && defined $childLocations->{$location}){
        $data->{location_age} = 'lapset';
    }
    else{
        $data->{location_age} = 'muu';
    }

    $cnClassPrimary = $self->itemCnClassPrimary($data, $dimension);
    if(defined $cnClassPrimary && ($cnClassPrimary >= 80 && $cnClassPrimary <= 85) ){
        $data->{location_type} = 'kauno';
    }
    elsif(defined $cnClassPrimary && ( ($cnClassPrimary >= 0 && $cnClassPrimary <= 79) || ($cnClassPrimary >= 86 && $cnClassPrimary <= 99)) ){
        $data->{location_type} = 'tieto';
    }
    else{
        $data->{location_type} = 'muu';
    }
}

sub locationBranch{
    my $self = shift;
    my $data = $_[0];
    my $dimension = $_[1];

    if(!defined $data->{branch}){
        $data->{branch} = 'null';
    }
    return $data->{branch};
}

sub locationLocation{
    my $self = shift;
    my $data = $_[0];
    my $dimension = $_[1];

    if(!defined $data->{location}){
        $data->{location} = 'null';
    }
    return $data->{location};
}

=head loadConfiguration

    my $config = $self->loadConfiguration();

Loads the configuration YAML from sysprefs and parses it to a Hash.
=cut

sub loadConfiguration {
    my $self = shift;
    my $data = $_[0];

    my $yaml = C4::Context->preference('OKM');
    $yaml = Encode::encode('UTF-8', $yaml, Encode::FB_CROAK);
    $data->{conf} = YAML::XS::Load($yaml);

    $self->validateConfiguration($data->{conf});

    return $data->{conf};
    
}

sub getSearchableConfig {
    my $self = shift;
    my $data = $_[0];
    my $config = $self->loadConfiguration();
    
    $data->{conf} = parseListConfig($config, "adultShelvingLocations");
    $data->{conf} = parseListConfig($config, "juvenileShelvingLocations");
    $data->{conf} = parseListConfig($config, "patronCategories");
    $data->{conf} = parseListConfig($config, "notForLoanStatuses");

    return $data->{conf};
}

sub getConditionValues {
    my $self = shift;
    my $name = shift;
    my $config = $self->getSearchableConfig();

    my @keys = keys($config->{$name});
    my $values = '(';
    foreach my $key (@keys) {
        if (\$key == \$keys[-1]) {
            $values .= '"'.$key.'"';
        } else {
            $values .= '"'.$key.'",';
        }
    }
    $values .= ')';

    $values = Encode::encode('UTF-8', $values, Encode::FB_CROAK);

    return $values;
}


sub parseListConfig {
    my $config = shift;
    my $listname = shift;

    my $list = $config->{$listname};
    $config->{$listname} = {};
    foreach my $loc (@{$list}) {
        $config->{$listname}->{$loc} = 1;
    }

    return $config;
}

sub validateConfiguration {
    my $self = shift;
    my $config = shift;

    ##Make sanity checks for the config and throw an error to tell the user that the config needs fixing.
    my @statCatKeys = ();
    my @categoryKeys = ();
    my @notForLoanKeys = ();
    my @adultShelLocKeys = ();
    my @juvenileShelLocKeys = ();
    if (ref $config->{itemTypeToStatisticalCategory} eq 'HASH') {
        @statCatKeys = keys($config->{itemTypeToStatisticalCategory});
    }
    if (ref $config->{patronCategories} eq 'ARRAY') {
        @categoryKeys = $config->{patronCategories};
    }
    if (ref $config->{notForLoanStatuses} eq 'ARRAY') {
        @notForLoanKeys = $config->{notForLoanStatuses};
    }
    if (ref $config->{adultShelvingLocations} eq 'ARRAY') {
        @adultShelLocKeys = $config->{adultShelvingLocations};
    }
    if (ref $config->{juvenileShelvingLocations} eq 'ARRAY') {
        @juvenileShelLocKeys = $config->{juvenileShelvingLocations};
    }
    unless (scalar(@statCatKeys)) {
        my @cc = caller(0);
        Koha::Exception::BadSystemPreference->throw(
            error => $cc[3]."():> System preference 'OKM' is missing YAML-parameter 'itemTypeToStatisticalCategory'.\n".
                     "It should look something like this: \n".
                     "itemTypeToStatisticalCategory: \n".
                     "  BK: Books \n".
                     "  MU: Recordings \n");
    }
    unless (scalar(@categoryKeys)) {
        my @cc = caller(0);
        Koha::Exception::BadSystemPreference->throw(
            error => $cc[3]."():> System preference 'OKM' is missing YAML-parameter 'patronCategories'.\n".
                     "It should look something like this: \n".
                     "patronCategories: \n".
                     "  - ADULTS \n".
                     "  - STAFF \n");
    }
    unless (scalar(@notForLoanKeys)) {
        my @cc = caller(0);
        Koha::Exception::BadSystemPreference->throw(
            error => $cc[3]."():> System preference 'OKM' is missing YAML-parameter 'notForLoanStatuses'.\n".
                     "It should look something like this: \n".
                     "patronCategories: \n".
                     "  - -1 \n".
                     "  - 5 \n");
    }
    unless (scalar(@adultShelLocKeys)) {
        my @cc = caller(0);
        Koha::Exception::BadSystemPreference->throw(
            error => $cc[3]."():> System preference 'OKM' is missing YAML-parameter 'adultShelvingLocations'.\n".
                     "It should look something like this: \n".
                     "patronCategories: \n".
                     "  - ADULT \n".
                     "  - AIK \n");
    }
    unless (scalar(@juvenileShelLocKeys)) {
        my @cc = caller(0);
        Koha::Exception::BadSystemPreference->throw(
            error => $cc[3]."():> System preference 'OKM' is missing YAML-parameter 'juvenileShelvingLocations'.\n".
                     "It should look something like this: \n".
                     "juvenileShelvingLocations: \n".
                     "  - CHILD \n".
                     "  - AV \n");
    }

    # my @itypes = Koha::ItemTypes->search;

    # ##Check that we haven't accidentally mapped any itemtypes that don't actually exist in our database
    # my %mappedItypes = map {$_ => 1} @statCatKeys; #Copy the itemtypes-as-keys
    # foreach my $itype (@itypes) {
    #     my $it = $itype->itemtype;
    #     my $mapping = $config->{itemTypeToStatisticalCategory}->{$it};
    #     unless ($mapping) { #Is itemtype mapped?
    #         my @cc = caller(0);
    #         Koha::Exception::BadSystemPreference->throw(error => $cc[3]."():> System preference 'OKM' has an unmapped itemtype '".$itype->itemtype."'. Put it under 'itemTypeToStatisticalCategory'.");
    #     }
    # }
}

1;
