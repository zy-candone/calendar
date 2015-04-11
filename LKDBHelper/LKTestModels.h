//
//  LKTestModels.h
//  LKDBHelper
//
//  Created by upin on 13-7-12.
//  Copyright (c) 2013年 ljh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LKDBHelper.h"

#import <AddressBook/AddressBook.h>

@interface LKTestForeignSuper : NSObject
@property(copy,nonatomic)NSString* address;
@property int postcode;
@end

@interface LKTestForeign : LKTestForeignSuper
@property NSInteger addid;
@end

@interface LKTest : NSObject
@property(strong,nonatomic)LKTestForeign* address;
@property (nonatomic, readonly, copy) NSArray *linkedPeople;
#if __IPHONE_OS_VERSION_MAX_ALLOWED < 40100
//iOS4.1 added ABPersonImageFormat, however later versions of the headers think it was added in 4.0
//running on 4.0 we will always return the full size image
typedef enum {
    kABPersonImageFormatThumbnail = 0,      // the square thumbnail
    kABPersonImageFormatOriginalSize = 2    // the original image as set by ABPersonSetImageData
} ABPersonImageFormat;
#endif


@property (nonatomic, readonly) BOOL hasImage;
@property (nonatomic,copy) UIImage *thumbnail; //readonly
@property (nonatomic, readonly, copy) UIImage *originalImage;
//-(UIImage*)imageWithFormat:(ABPersonImageFormat)imageFormat;
@property (nonatomic, readonly, copy) NSData *thumbnailData;
@property (nonatomic, readonly, copy) NSData *originalImageData;
//-(NSData*)imageDataWithFormat:(ABPersonImageFormat)imageFormat;
-(BOOL)setImage:(UIImage*)image;
-(BOOL)removeImage;

//personal properties
@property (nonatomic, copy, readonly) NSString *name;       // alias for compositeName
@property (nonatomic, copy) NSString *firstName;            // kABPersonFirstNameProperty
@property (nonatomic, copy) NSString *lastName;             // kABPersonLastNameProperty
@property (nonatomic, copy) NSString *middleName;           // kABPersonMiddleNameProperty
@property (nonatomic, copy) NSString *prefix;               // kABPersonPrefixProperty
@property (nonatomic, copy) NSString *suffix;               // kABPersonSuffixProperty
@property (nonatomic, copy) NSString *nickname;             // kABPersonNicknameProperty

@property (nonatomic, copy) NSString *firstNamePhonetic;    // kABPersonFirstNamePhoneticProperty
@property (nonatomic, copy) NSString *lastNamePhonetic;     // kABPersonLastNamePhoneticProperty
@property (nonatomic, copy) NSString *middleNamePhonetic;   // kABPersonMiddleNamePhoneticProperty

@property (nonatomic, copy) NSString *organization;         // kABPersonOrganizationProperty
@property (nonatomic, copy) NSString *jobTitle;             // kABPersonJobTitleProperty
@property (nonatomic, copy) NSString *department;           // kABPersonDepartmentProperty

@property  ABMultiValueRef *emails;     // kABPersonEmailProperty - (Multi String)
@property (nonatomic,copy) NSString *email_test;
@property (nonatomic, copy) NSDate *birthday;               // kABPersonBirthdayProperty
@property (nonatomic, copy) NSString *note;                 // kABPersonNoteProperty

@property (nonatomic, copy) NSString *created;// readonly NSDate *created;      // kABPersonCreationDateProperty
@property (nonatomic, copy) NSString *modified;//  readonly NSDate *modified;     // kABPersonModificationDateProperty

// (For more info on the keys and values for MultiValue objects check out <AddressBook/ABPerson.h> )
// (Also check out RHPersonLabels.h, it casts a bunch of CF labels into their toll free bridged counterparts for ease of use with this class )

//Addresses
@property  ABMultiValueRef *addresses;        // kABPersonAddressProperty - (Multi Dictionary) dictionary keys are ( kABPersonAddressStreetKey, kABPersonAddressCityKey, kABPersonAddressStateKey, kABPersonAddressZIPKey, kABPersonAddressCountryKey, kABPersonAddressCountryCodeKey )
@property (nonatomic,copy)NSString *address_test;

//Dates
@property   ABMultiValueRef *dates;            // kABPersonDateProperty - (Multi Date) possible predefined labels ( kABPersonAnniversaryLabel )
@property (nonatomic,copy) NSString *date_test;
//Kind
@property (nonatomic, copy) NSNumber *kind;                 // kABPersonKindProperty (Integer) possible values include (kABPersonKindPerson, kABPersonKindOrganization)
-(BOOL)isOrganization;                                      // if person == kABPersonKindOrganization
-(BOOL)isPerson;                                            // if person == kABPersonKindPerson

//Phone numbers
@property   ABMultiValueRef *phoneNumbers;     // kABPersonPhoneProperty (Multi String) possible labels are ( kABPersonPhoneMobileLabel, kABPersonPhoneIPhoneLabel, kABPersonPhoneMainLabel, kABPersonPhoneHomeFAXLabel, kABPersonPhoneWorkFAXLabel, kABPersonPhoneOtherFAXLabel, kABPersonPhonePagerLabel )
@property (nonatomic,copy) NSString *phoneNumber_test;
//IM
@property   ABMultiValueRef *instantMessageServices;   // kABPersonInstantMessageProperty - (Multi Dictionary) dictionary keys are ( kABPersonInstantMessageServiceKey, kABPersonInstantMessageUsernameKey ) possible services are ( kABPersonInstantMessageServiceYahoo, kABPersonInstantMessageServiceJabber, kABPersonInstantMessageServiceMSN, kABPersonInstantMessageServiceICQ, kABPersonInstantMessageServiceAIM, kABPersonInstantMessageServiceQQ, kABPersonInstantMessageServiceGoogleTalk, kABPersonInstantMessageServiceSkype, kABPersonInstantMessageServiceFacebook, kABPersonInstantMessageServiceGaduGadu )
@property (nonatomic,copy) NSString *instantMessageService_test;
//URLs
@property  ABMultiValueRef *urls;             // kABPersonURLProperty - (Multi String)  possible labels are ( kABPersonHomePageLabel )
@property (nonatomic ,copy) NSString *url_test;
//Related Names (Relationships)
@property   ABMultiValueRef *relatedNames;     // kABPersonRelatedNamesProperty - (Multi String) possible labels are ( kABPersonFatherLabel, kABPersonMotherLabel, kABPersonParentLabel, kABPersonBrotherLabel, kABPersonSisterLabel, kABPersonChildLabel, kABPersonFriendLabel, kABPersonSpouseLabel, kABPersonPartnerLabel, kABPersonAssistantLabel, kABPersonManagerLabel )
@property (nonatomic,copy) NSString *relateName_test;
//Social Profile (iOS5 +)
@property   ABMultiValueRef *socialProfiles;   // kABPersonSocialProfileProperty - (Multi Dictionary) possible dictionary keys are ( kABPersonSocialProfileURLKey, kABPersonSocialProfileServiceKey, kABPersonSocialProfileUsernameKey, kABPersonSocialProfileUserIdentifierKey )
// possible kABPersonSocialProfileServiceKey values ( kABPersonSocialProfileServiceTwitter, kABPersonSocialProfileServiceGameCenter, kABPersonSocialProfileService Facebook, kABPersonSocialProfileServiceMyspace, kABPersonSocialProfileServiceLinkedIn, kABPersonSocialProfileServiceFlickr )
@property (nonatomic , copy) NSString *socialProfile_test;
//vCard formatting (iOS5 +)
-(NSData*)vCardRepresentation; //the current persons vCard representation
+(NSData*)vCardRepresentationForPeople:(NSArray*)people; //array of RHPerson Objects.

//geocoding
#if RH_AB_INCLUDE_GEOCODING
-(CLPlacemark*)placemarkForAddressID:(ABMultiValueIdentifier)addressID;
-(CLLocation*)locationForAddressID:(ABMultiValueIdentifier)addressID;
#endif //end Geocoding

@end


@interface NSObject(PrintSQL)
+(NSString*)getCreateTableSQL;
@end