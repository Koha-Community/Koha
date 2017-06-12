package t::lib::TestObjects::Labels::SheetFactory;

# Copyright KohaSuomi 2016
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#

use Modern::Perl;
use Carp;
use JSON::XS;
use Scalar::Util qw(blessed);
use Try::Tiny;

use C4::Labels::SheetManager;
use t::lib::TestObjects::PatronFactory;

use Koha::Exception::BadParameter;

use base qw(t::lib::TestObjects::ObjectFactory);

sub getDefaultHashKey {
    return ['name', 'version'];
}
sub getObjectType {
    return 'C4::Labels::Sheet';
}

=head t::lib::TestObjects::createTestGroup

    my $sheet = t::lib::TestObjects::Labels::SheetFactory->createTestGroup([
                        {'name' => 'Sheetilian',
                         'version'   => '1.1',
                         'author' => '1024' || Koha::Patron,
                         'sheet' => JSON String, #see validateAndPopulateDefaultValues()
                        },
                    ], 'name', $testContext1, $testContext2, $testContext3);
    C4::Labels::SheetManager::putNewSheetToDB($sheet); #Persist the sheet.

@PARAM 'name' String, The name of the Sheet. There are several default sheets
              available and it is recommended that those be used because of the
              complexity of the Sheet-object.
              Available default templates are:
                  'Simplex',       #This is the default if name is omited.
                  'Sheetilian',
@PARAM 'sheet' HASHRef, a complete Hash which is used to generate the sheet and all
               related components. See the example Sheets for inspiration.

No mandatory parameters.

@RETURNS HASHRef of C4::Label::Sheet-objects

See t::lib::TestObjects::ObjectFactory for more documentation
=cut

sub handleTestObject {
    my ($class, $object, $stashes) = @_;

    my $sheet = getSheet($object);
    ##First see if the given Sheet already exists in the DB. If so, there is probably a problem and we delete the existing sheet and make a new one.
    my $oldSheet = C4::Labels::SheetManager::getSheetByName($object->{name}, $object->{version});
    if ($oldSheet) {
        my @cc = caller(0);
        print $cc[3]."():> Sheet ".$oldSheet->getName()." already exists in DB. Deleting it to keep DB clean.";
        C4::Labels::SheetManager::deleteSheet($oldSheet->getId(), $oldSheet->getVersion());
    }

    return $sheet;
}

sub getHashKey {
    my ($class, $object) = @_;

    return $object->getName().'-'.$object->getVersion();
}

=head validateAndPopulateDefaultValues
@OVERLOAD

Validates given Object parameters and makes sure that critical fields are given
and populates defaults for missing values.
=cut

sub validateAndPopulateDefaultValues {
    my ($self, $object, $hashKey, $stashes) = @_;

    $object->{name} = 'Simplex' unless ($object->{name});
    my $borrower;
    try {
        $borrower = Koha::Patrons->cast($object->{author});
        $object->{author}->{borrowernumber} = $borrower->borrowernumber;
    } catch {
        if (blessed($_) && ($_->isa('Koha::Exception::UnknownObject') || $_->isa('Koha::Exception::BadParameter'))) {
            $borrower = t::lib::TestObjects::PatronFactory->createTestGroup(
                                                            {cardnumber => 'sheetAuthor',
                                                             firstname => 'Sheet',
                                                             surname => 'Author'}, undef, @$stashes);
            $object->{author}->{borrowernumber} = $borrower->borrowernumber;
        }
        elsif (blessed($_)) {
            $_->rethrow();
        }
        else {
            die $_;
        }
    };
}

=head deleteTestGroup

    my $records = createTestGroup();
    ##Do funky stuff
    deleteTestGroup($records);

Removes the given test group from the DB.

=cut

sub deleteTestGroup {
    my ($class, $sheets) = @_;

    while( my ($key, $sheet) = each %$sheets) {
        try {
            C4::Labels::SheetManager::deleteSheet($sheet->getId(), $sheet->getVersion());
        }
        catch {
            if (blessed($_) && $_->isa('Koha::Exception::UnknownObject')) {
                ##Silently trap this exception
            }
            elsif (blessed($_)) {
                $_->rethrow();
            }
            else {
                die $_;
            }
        };
    }
}

sub getSheet {
    my ($object) = @_;

    my $asText = {
    Simplex => '
{
	"name": "Simplex",
	"id": 8,
    "dpi": 100,
	"dimensions": {
		"width": 464,
		"height": 403
	},
	"version": "0.3",
	"author": {
		"userid": "admin123",
		"borrowernumber": "10963465"
	},
	"timestamp": "2016-01-15T20:09:01.824Z",
	"boundingBox": true,
	"items": [{
		"index": 1,
		"regions": [{
			"dimensions": {
				"width": 391,
				"height": 204
			},
			"position": {
				"left": 24,
				"top": 14
			},
			"boundingBox": true,
			"elements": [{
				"dimensions": {
					"width": 366,
					"height": 30
				},
				"position": {
					"left": 11,
					"top": 17
				},
				"boundingBox": false,
				"dataSource": "title()",
				"dataFormat": "oneLinerShrinkText",
				"fontSize": "15",
				"font": "H",
				"colour": {
					"r": 230,
					"g": 24,
					"b": 24,
					"a": 1
				}
			}, {
				"dimensions": {
					"width": 365,
					"height": 32
				},
				"position": {
					"left": 11,
					"top": 54
				},
				"boundingBox": false,
				"dataSource": "biblio.issn || 245$a and biblio.author",
				"dataFormat": "oneLinerShrinkText",
				"fontSize": 12,
				"font": "H",
				"colour": {
					"r": 0,
					"g": 0,
					"b": 0,
					"a": 1
				}
			}]
		}]
	}]
}
    ',
    Sheetilian => '
{
	"name": "Sheetilian",
	"id": 9,
    "dpi": 100,
	"dimensions": {
		"width": 551,
		"height": 580
	},
	"version": "1.2",
	"author": {
		"borrowernumber": "10963465"
	},
	"timestamp": "2016-01-16T05:03:35.857Z",
	"boundingBox": false,
	"items": [{
		"index": 1,
		"regions": [{
			"dimensions": {
				"width": 193,
				"height": 168
			},
			"position": {
				"left": 9,
				"top": 7
			},
			"boundingBox": true,
			"elements": [{
				"dimensions": {
					"width": 172,
					"height": 55
				},
				"position": {
					"left": 12,
					"top": 12
				},
				"boundingBox": false,
				"dataSource": "245$a || biblio.title && biblio.author",
				"dataFormat": "oneLinerShrinkText",
				"fontSize": "16",
				"font": "H",
				"colour": {
					"r": 214,
					"g": 48,
					"b": 48,
					"a": 1
				}
			}, {
				"dimensions": {
					"width": 171,
					"height": 78
				},
				"position": {
					"left": 13,
					"top": 78
				},
				"boundingBox": false,
				"dataSource": "homebranch.branchname",
				"dataFormat": "oneLinerShrinkText",
				"fontSize": "12",
				"font": "H",
				"colour": {
					"r": 128,
					"g": 196,
					"b": 0,
					"a": 1
				}
			}, {
				"dimensions": {
					"width": 172,
					"height": 55
				},
				"position": {
					"left": 12,
					"top": 12
				},
				"boundingBox": false,
				"dataSource": "item.barcode",
				"dataFormat": "barcode39",
				"fontSize": "16",
				"font": "H",
				"colour": {
					"r": 214,
					"g": 48,
					"b": 48,
					"a": 1
				},
                "customAttr": "yScale=1.0, xScale=0.75"
			}]
		}, {
			"dimensions": {
				"width": 98,
				"height": 81
			},
			"position": {
				"left": 467,
				"top": 4
			},
			"boundingBox": false,
			"elements": [{
				"dimensions": {
					"width": 91,
					"height": 29
				},
				"position": {
					"left": 3,
					"top": 4
				},
				"boundingBox": false,
				"dataSource": "signum()",
				"dataFormat": "oneLinerShrinkText",
				"fontSize": "12",
				"font": "H",
				"colour": {
					"r": 0,
					"g": 0,
					"b": 0,
					"a": 1
				}
			}, {
				"dimensions": {
					"width": 89,
					"height": 32
				},
				"position": {
					"left": 5,
					"top": 40
				},
				"boundingBox": false,
				"dataSource": "item.itemcallnumber",
				"dataFormat": "oneLinerShrinkText",
				"fontSize": "12",
				"font": "H",
				"colour": {
					"r": 0,
					"g": 0,
					"b": 0,
					"a": 1
				}
			}]
		}]
	}, {
		"index": 3,
		"regions": [{
			"dimensions": {
				"width": 255,
				"height": 172
			},
			"position": {
				"left": 207,
				"top": 4
			},
			"boundingBox": false,
			"elements": [{
				"dimensions": {
					"width": 236,
					"height": 64
				},
				"position": {
					"left": 9,
					"top": 5
				},
				"boundingBox": false,
				"dataSource": "contentDescription()",
				"dataFormat": "oneLinerShrinkText",
				"fontSize": "16",
				"font": "H",
				"colour": {
					"r": 201,
					"g": 45,
					"b": 45,
					"a": 1
				}
			}, {
				"dimensions": {
					"width": 238,
					"height": 81
				},
				"position": {
					"left": 4,
					"top": 80
				},
				"boundingBox": false,
				"dataSource": "homebranch.branchcode",
				"dataFormat": "oneLinerShrinkText",
				"fontSize": "12",
				"font": "H",
				"colour": {
					"r": 0,
					"g": 0,
					"b": 0,
					"a": 1
				}
			}, {
				"dimensions": {
					"width": 172,
					"height": 55
				},
				"position": {
					"left": 12,
					"top": 12
				},
				"boundingBox": false,
				"dataSource": "item.barcode",
				"dataFormat": "barcode39",
				"fontSize": "16",
				"font": "H",
				"colour": {
					"r": 214,
					"g": 48,
					"b": 48,
					"a": 1
				},
                "customAttr": "yScale=1.0, xScale=0.75"
			}]
		}, {
			"dimensions": {
				"width": 95,
				"height": 84
			},
			"position": {
				"left": 468,
				"top": 92
			},
			"boundingBox": false,
			"elements": [{
				"dimensions": {
					"width": 81,
					"height": 36
				},
				"position": {
					"left": 7,
					"top": 3
				},
				"boundingBox": false,
				"dataSource": "signum()",
				"dataFormat": "oneLinerShrinkText",
				"fontSize": "12",
				"font": "H",
				"colour": {
					"r": 0,
					"g": 0,
					"b": 0,
					"a": 1
				}
			}, {
				"dimensions": {
					"width": 84,
					"height": 33
				},
				"position": {
					"left": 6,
					"top": 45
				},
				"boundingBox": false,
				"dataSource": "item.itemcallnumber",
				"dataFormat": "oneLinerShrinkText",
				"fontSize": "12",
				"font": "H",
				"colour": {
					"r": 0,
					"g": 0,
					"b": 0,
					"a": 1
				}
			}]
		}]
	}]
}
    ',
    };
    my $sheetJsonTxt = $object->{sheet};
    $sheetJsonTxt = $asText->{$object->{name}} unless $sheetJsonTxt;
    unless ($sheetJsonTxt) {
        return undef;
    }
    my $hash = JSON::XS->new()->decode($sheetJsonTxt);

    #Set default values before initing the Sheet
    $hash->{author} = $object->{author};
    my $sheet = C4::Labels::Sheet->new($hash);
    return $sheet;
}

1;
