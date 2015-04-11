//
//  ContactPickerViewController.m
//  ContactPicker
//
//  Created by Tristan Himmelman on 11/2/12.
//  Copyright (c) 2012 Tristan Himmelman. All rights reserved.
//

#import "THContactPickerViewController.h"
#import <AddressBook/AddressBook.h>
#import "THContact.h"
#import "LKTestModels.h"

UIBarButtonItem *barButton;

@interface THContactPickerViewController ()

@property (nonatomic, assign) ABAddressBookRef addressBookRef;

@end

//#define kKeyboardHeight 216.0
#define kKeyboardHeight 0.0

@implementation THContactPickerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Select Contacts (0)";
        
        CFErrorRef error;
        _addressBookRef = ABAddressBookCreateWithOptions(NULL, &error);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //    UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonItemStyleBordered target:self action:@selector(removeAllContacts:)];
    
    barButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(done:)];
    barButton.enabled = FALSE;
    
    self.navigationItem.rightBarButtonItem = barButton;
    
    // Initialize and add Contact Picker View
    self.contactPickerView = [[THContactPickerView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
    self.contactPickerView.delegate = self;
    [self.contactPickerView setPlaceholderString:@"Type contact name"];
    [self.view addSubview:self.contactPickerView];
    
    // Fill the rest of the view with the table view
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.contactPickerView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.contactPickerView.frame.size.height - kKeyboardHeight) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"THContactPickerTableViewCell" bundle:nil] forCellReuseIdentifier:@"ContactCell"];
    
    [self.view insertSubview:self.tableView belowSubview:self.contactPickerView];
    
    ABAddressBookRequestAccessWithCompletion(self.addressBookRef, ^(bool granted, CFErrorRef error) {
        if (granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self getContactsFromAddressBook];
            });
        } else {
            // TODO: Show alert
        }
    });
}

-(void)getContactsFromAddressBook
{
    CFErrorRef error = NULL;
    self.contacts = [[NSMutableArray alloc]init];
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    if (addressBook) {
        NSArray *allContacts = (__bridge_transfer NSArray*)ABAddressBookCopyArrayOfAllPeople(addressBook);
        NSMutableArray *mutableContacts = [NSMutableArray arrayWithCapacity:allContacts.count];
        
        NSUInteger i = 0;
        for (i = 0; i<[allContacts count]; i++)
        {
            THContact *contact = [[THContact alloc] init];
            ABRecordRef contactPerson = (__bridge ABRecordRef)allContacts[i];
            contact.recordId = ABRecordGetRecordID(contactPerson);

            // Get first and last names
            NSString *firstName = (__bridge_transfer NSString*)ABRecordCopyValue(contactPerson, kABPersonFirstNameProperty);
            NSString *lastName = (__bridge_transfer NSString*)ABRecordCopyValue(contactPerson, kABPersonLastNameProperty);
            
            // Set Contact properties
            contact.firstName = firstName;
            contact.lastName = lastName;
            
            // Get mobile number
            ABMultiValueRef phonesRef = ABRecordCopyValue(contactPerson, kABPersonPhoneProperty);
            contact.phone = [self getMobilePhoneProperty:phonesRef];
            if(phonesRef) {
                CFRelease(phonesRef);
            }
            
            // Get image if it exists
            NSData  *imgData = (__bridge_transfer NSData *)ABPersonCopyImageData(contactPerson);
            contact.image = [UIImage imageWithData:imgData];
            if (!contact.image) {
                contact.image = [UIImage imageNamed:@"icon-avatar-60x60"];
            }
            
            [mutableContacts addObject:contact];
        }
        
        if(addressBook) {
            CFRelease(addressBook);
        }
        
        self.contacts = [NSArray arrayWithArray:mutableContacts];
        self.selectedContacts = [NSMutableArray array];
        self.filteredContacts = self.contacts;
        
        [self.tableView reloadData];
    }
    else
    {
        NSLog(@"Error");
        
    }
}

- (void) refreshContacts
{
    for (THContact* contact in self.contacts)
    {
        [self refreshContact: contact];
    }
    [self.tableView reloadData];
}

- (void) refreshContact:(THContact*)contact
{
    
    ABRecordRef contactPerson = ABAddressBookGetPersonWithRecordID(self.addressBookRef, (ABRecordID)contact.recordId);
    contact.recordId = ABRecordGetRecordID(contactPerson);
    
    // Get first and last names
    NSString *firstName = (__bridge_transfer NSString*)ABRecordCopyValue(contactPerson, kABPersonFirstNameProperty);
    NSString *lastName = (__bridge_transfer NSString*)ABRecordCopyValue(contactPerson, kABPersonLastNameProperty);
    
    // Set Contact properties
    contact.firstName = firstName;
    contact.lastName = lastName;
    
    // Get mobile number
    ABMultiValueRef phonesRef = ABRecordCopyValue(contactPerson, kABPersonPhoneProperty);
    contact.phone = [self getMobilePhoneProperty:phonesRef];
    if(phonesRef) {
        CFRelease(phonesRef);
    }
    
    // Get image if it exists
    NSData  *imgData = (__bridge_transfer NSData *)ABPersonCopyImageData(contactPerson);
    contact.image = [UIImage imageWithData:imgData];
    if (!contact.image) {
        contact.image = [UIImage imageNamed:@"icon-avatar-60x60"];
    }
}

-(LKTest *)refreshFullContacts{
    LKTest *abRecord=[[LKTest alloc]init];
    ABAddressBookRef addressBook = ABAddressBookCreate();
    CFArrayRef results = ABAddressBookCopyArrayOfAllPeople(addressBook);
    for(int i = 0; i < CFArrayGetCount(results); i++)
    {
        ABRecordRef person = CFArrayGetValueAtIndex(results, i);
        //读取firstname
        NSString *personName = (__bridge NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
        if(personName != nil)
            abRecord.firstName=personName;
        //读取lastname
        NSString *lastname = (__bridge NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
        if(lastname != nil)
            abRecord.lastName=lastname;        //读取middlename
        NSString *middlename = (__bridge NSString*)ABRecordCopyValue(person, kABPersonMiddleNameProperty);
        if(middlename != nil)
            abRecord.middleName=middlename;        //读取prefix前缀
        NSString *prefix = (__bridge NSString*)ABRecordCopyValue(person, kABPersonPrefixProperty);
        if(prefix != nil)
            abRecord.prefix=prefix;        //读取suffix后缀
        NSString *suffix = (__bridge NSString*)ABRecordCopyValue(person, kABPersonSuffixProperty);
        if(suffix != nil)
            abRecord.suffix=suffix;        //读取nickname呢称
        NSString *nickname = (__bridge NSString*)ABRecordCopyValue(person, kABPersonNicknameProperty);
        if(nickname != nil)
            abRecord.nickname=nickname;        //读取firstname拼音音标
        NSString *firstnamePhonetic = (__bridge NSString*)ABRecordCopyValue(person, kABPersonFirstNamePhoneticProperty);
        if(firstnamePhonetic != nil)
            abRecord.firstNamePhonetic=firstnamePhonetic;        //读取lastname拼音音标
        NSString *lastnamePhonetic = (__bridge NSString*)ABRecordCopyValue(person, kABPersonLastNamePhoneticProperty);
        if(lastnamePhonetic != nil)
            abRecord.lastNamePhonetic=lastnamePhonetic;        //读取middlename拼音音标
        NSString *middlenamePhonetic = (__bridge NSString*)ABRecordCopyValue(person, kABPersonMiddleNamePhoneticProperty);
        if(middlenamePhonetic != nil)
            abRecord.middleNamePhonetic=middlenamePhonetic;        //读取organization公司
        NSString *organization = (__bridge NSString*)ABRecordCopyValue(person, kABPersonOrganizationProperty);
        if(organization != nil)
            abRecord.organization=organization;        //读取jobtitle工作
        NSString *jobtitle = (__bridge NSString*)ABRecordCopyValue(person, kABPersonJobTitleProperty);
        if(jobtitle != nil)
            abRecord.jobTitle=jobtitle;        //读取department部门
        NSString *department = (__bridge NSString*)ABRecordCopyValue(person, kABPersonDepartmentProperty);
        if(department != nil)
            abRecord.department=department;        //读取birthday生日
        NSDate *birthday = (__bridge NSDate*)ABRecordCopyValue(person, kABPersonBirthdayProperty);
        if(birthday != nil)
            abRecord.birthday=birthday;        //读取note备忘录
        NSString *note = (__bridge NSString*)ABRecordCopyValue(person, kABPersonNoteProperty);
        if(note != nil)
            abRecord.note=note;
        //第一次添加该条记录的时间
        NSString *firstknow = (__bridge NSString*)ABRecordCopyValue(person, kABPersonCreationDateProperty);
        abRecord.created=firstknow;
        //最后一次修改該条记录的时间
        NSString *lastknow = (__bridge NSString*)ABRecordCopyValue(person, kABPersonModificationDateProperty);
        abRecord.modified=lastknow;
        //获取email多值
        ABMultiValueRef email = ABRecordCopyValue(person, kABPersonEmailProperty);
        long emailcount = ABMultiValueGetCount(email);
        for (int x = 0; x < emailcount; x++)
        {
            //获取email Label
            NSString* emailLabel = (__bridge NSString*)ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(email, x));
            //获取email值
            NSString* emailContent = (__bridge NSString*)ABMultiValueCopyValueAtIndex(email, x);
            abRecord.email_test = [NSString stringWithFormat:@"%@:%@",emailLabel,emailContent]; // \n
        }
        //读取地址多值
        ABMultiValueRef address = ABRecordCopyValue(person, kABPersonAddressProperty);
        long count = ABMultiValueGetCount(address);
        
        for(int j = 0; j < count; j++)
        {
            //获取地址Label
            NSString* addressLabel = (__bridge NSString*)ABMultiValueCopyLabelAtIndex(address, j);
            //获取該label下的地址6属性
            abRecord.address_test=addressLabel;
            NSDictionary* personaddress =(__bridge NSDictionary*) ABMultiValueCopyValueAtIndex(address, j);
            NSString* country = [personaddress valueForKey:(NSString *)kABPersonAddressCountryKey];
            if(country != nil)
                abRecord.address_test= [abRecord.address_test stringByAppendingFormat:@"国家：%@\n",country];
            NSString* city = [personaddress valueForKey:(NSString *)kABPersonAddressCityKey];
            if(city != nil)
                abRecord.address_test= [abRecord.address_test stringByAppendingFormat:@"城市：%@\n",city];
            NSString* state = [personaddress valueForKey:(NSString *)kABPersonAddressStateKey];
            if(state != nil)
                abRecord.address_test = [abRecord.address_test stringByAppendingFormat:@"省：%@\n",state];
            NSString* street = [personaddress valueForKey:(NSString *)kABPersonAddressStreetKey];
            if(street != nil)
                abRecord.address_test = [abRecord.address_test stringByAppendingFormat:@"街道：%@\n",street];
            NSString* zip = [personaddress valueForKey:(NSString *)kABPersonAddressZIPKey];
            if(zip != nil)
                abRecord.address_test = [abRecord.address_test stringByAppendingFormat:@"邮编：%@\n",zip];
            NSString* coutntrycode = [personaddress valueForKey:(NSString *)kABPersonAddressCountryCodeKey];
            if(coutntrycode != nil)
                abRecord.address_test = [abRecord.address_test stringByAppendingFormat:@"国家编号：%@\n",coutntrycode];
        }
        
        //获取dates多值
        ABMultiValueRef dates = ABRecordCopyValue(person, kABPersonDateProperty);
        int datescount = ABMultiValueGetCount(dates);
        for (int y = 0; y < datescount; y++)
        {
            //获取dates Label
            NSString* datesLabel = (__bridge NSString*)ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(dates, y));
            abRecord.date_test=datesLabel;
            //获取dates值
            NSString* datesContent = (__bridge NSString*)ABMultiValueCopyValueAtIndex(dates, y);
            abRecord.date_test = [abRecord.date_test stringByAppendingFormat:@"%@:%@\n",datesLabel,datesContent];
        }
        //获取kind值
        CFNumberRef recordType = ABRecordCopyValue(person, kABPersonKindProperty);
        if (recordType == kABPersonKindOrganization) {
            // it's a company
            NSLog(@"it's a company\n");
        } else {
            // it's a person, resource, or room
            NSLog(@"it's a person, resource, or room\n");
        }
        
        
        //获取IM多值
        ABMultiValueRef instantMessage = ABRecordCopyValue(person, kABPersonInstantMessageProperty);
        for (int l = 1; l < ABMultiValueGetCount(instantMessage); l++)
        {
            //获取IM Label
            NSString* instantMessageLabel = (__bridge NSString*)ABMultiValueCopyLabelAtIndex(instantMessage, l);
            abRecord.instantMessageService_test= instantMessageLabel;
            //获取該label下的2属性
            NSDictionary* instantMessageContent =(__bridge NSDictionary*) ABMultiValueCopyValueAtIndex(instantMessage, l);
            NSString* username = [instantMessageContent valueForKey:(NSString *)kABPersonInstantMessageUsernameKey];
            if(username != nil)
                abRecord.instantMessageService_test = [abRecord.instantMessageService_test stringByAppendingFormat:@"username：%@\n",username];
            
            NSString* service = [instantMessageContent valueForKey:(NSString *)kABPersonInstantMessageServiceKey];
            if(service != nil)
                abRecord.instantMessageService_test = [abRecord.instantMessageService_test stringByAppendingFormat:@"service：%@\n",service];
        }
        
        //读取电话多值
        ABMultiValueRef phone = ABRecordCopyValue(person, kABPersonPhoneProperty);
        for (int k = 0; k<ABMultiValueGetCount(phone); k++)
        {
            //获取电话Label
            NSString * personPhoneLabel = (__bridge NSString*)ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(phone, k));
            abRecord.phoneNumber_test=@"";
            //获取該Label下的电话值
            NSString * personPhone = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phone, k);
            abRecord.phoneNumber_test = [abRecord.phoneNumber_test stringByAppendingFormat:@"%@:%@\n",personPhoneLabel,personPhone];
        }

        //获取URL多值
        ABMultiValueRef url = ABRecordCopyValue(person, kABPersonURLProperty);
        for (int m = 0; m < ABMultiValueGetCount(url); m++)
        {
            //获取电话Label
            NSString * urlLabel = (__bridge NSString*)ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(url, m));
            //获取該Label下的电话值
            NSString * urlContent = (__bridge NSString*)ABMultiValueCopyValueAtIndex(url,m);
            abRecord.url_test=@"";
            abRecord.url_test = [abRecord.url_test stringByAppendingFormat:@"%@:%@\n",urlLabel,urlContent];
        }
        
        //读取照片
        NSData *image = (__bridge NSData*)ABPersonCopyImageData(person);
        
        UIImageView *myImage = [[UIImageView alloc] initWithFrame:CGRectMake(200, 0, 50, 50)];
        [myImage setImage:[UIImage imageWithData:image]];
         myImage.opaque = YES;
        abRecord.thumbnail=[UIImage imageWithData:image];
    }
    CFRelease(results);
    CFRelease(addressBook);
    return abRecord;
}






- (NSString *)getMobilePhoneProperty:(ABMultiValueRef)phonesRef
{
    for (int i=0; i < ABMultiValueGetCount(phonesRef); i++) {
        CFStringRef currentPhoneLabel = ABMultiValueCopyLabelAtIndex(phonesRef, i);
        CFStringRef currentPhoneValue = ABMultiValueCopyValueAtIndex(phonesRef, i);
        
        if(currentPhoneLabel) {
            if (CFStringCompare(currentPhoneLabel, kABPersonPhoneMobileLabel, 0) == kCFCompareEqualTo) {
                return (__bridge NSString *)currentPhoneValue;
            }
            
            if (CFStringCompare(currentPhoneLabel, kABHomeLabel, 0) == kCFCompareEqualTo) {
                return (__bridge NSString *)currentPhoneValue;
            }
        }
        if(currentPhoneLabel) {
            CFRelease(currentPhoneLabel);
        }
        if(currentPhoneValue) {
            CFRelease(currentPhoneValue);
        }
    }
    
    return nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self refreshContacts];
    });
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat topOffset = 0;
    if ([self respondsToSelector:@selector(topLayoutGuide)]){
        topOffset = self.topLayoutGuide.length;
    }
    CGRect frame = self.contactPickerView.frame;
    frame.origin.y = topOffset;
    self.contactPickerView.frame = frame;
    [self adjustTableViewFrame:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)adjustTableViewFrame:(BOOL)animated {
    CGRect frame = self.tableView.frame;
    // This places the table view right under the text field
    frame.origin.y = self.contactPickerView.frame.size.height;
    // Calculate the remaining distance
    frame.size.height = self.view.frame.size.height - self.contactPickerView.frame.size.height - kKeyboardHeight;
    
    if(animated) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationDelay:0.1];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        
        self.tableView.frame = frame;
        
        [UIView commitAnimations];
    }
    else{
        self.tableView.frame = frame;
    }
}



#pragma mark - UITableView Delegate and Datasource functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredContacts.count;
}

- (CGFloat)tableView: (UITableView*)tableView heightForRowAtIndexPath: (NSIndexPath*) indexPath {
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Get the desired contact from the filteredContacts array
    THContact *contact = [self.filteredContacts objectAtIndex:indexPath.row];
    
    // Initialize the table view cell
    NSString *cellIdentifier = @"ContactCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    // Get the UI elements in the cell;
    UILabel *contactNameLabel = (UILabel *)[cell viewWithTag:101];
    UILabel *mobilePhoneNumberLabel = (UILabel *)[cell viewWithTag:102];
    UIImageView *contactImage = (UIImageView *)[cell viewWithTag:103];
    UIImageView *checkboxImageView = (UIImageView *)[cell viewWithTag:104];
    
    // Assign values to to US elements
    contactNameLabel.text = [contact fullName];
    mobilePhoneNumberLabel.text = contact.phone;
    if(contact.image) {
        contactImage.image = contact.image;
    }
    contactImage.layer.masksToBounds = YES;
    contactImage.layer.cornerRadius = 20;
    
    // Set the checked state for the contact selection checkbox
    UIImage *image;
    if ([self.selectedContacts containsObject:[self.filteredContacts objectAtIndex:indexPath.row]]){
        //cell.accessoryType = UITableViewCellAccessoryCheckmark;
        image = [UIImage imageNamed:@"icon-checkbox-selected-green-25x25"];
    } else {
        //cell.accessoryType = UITableViewCellAccessoryNone;
        image = [UIImage imageNamed:@"icon-checkbox-unselected-25x25"];
    }
    checkboxImageView.image = image;
    
    // Assign a UIButton to the accessoryView cell property
    cell.accessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    // Set a target and selector for the accessoryView UIControlEventTouchUpInside
    [(UIButton *)cell.accessoryView addTarget:self action:@selector(viewContactDetail:) forControlEvents:UIControlEventTouchUpInside];
    cell.accessoryView.tag = contact.recordId; //so we know which ABRecord in the IBAction method
    
    // // For custom accessory view button use this.
    //    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    //    button.frame = CGRectMake(0.0f, 0.0f, 150.0f, 25.0f);
    //
    //    [button setTitle:@"Expand"
    //            forState:UIControlStateNormal];
    //
    //    [button addTarget:self
    //               action:@selector(viewContactDetail:)
    //     forControlEvents:UIControlEventTouchUpInside];
    //
    //    cell.accessoryView = button;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Hide Keyboard
    [self.contactPickerView resignKeyboard];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    // This uses the custom cellView
    // Set the custom imageView
    THContact *user = [self.filteredContacts objectAtIndex:indexPath.row];
    UIImageView *checkboxImageView = (UIImageView *)[cell viewWithTag:104];
    UIImage *image;
    
    if ([self.selectedContacts containsObject:user]){ // contact is already selected so remove it from ContactPickerView
        //cell.accessoryType = UITableViewCellAccessoryNone;
        [self.selectedContacts removeObject:user];
        [self.contactPickerView removeContact:user];
        // Set checkbox to "unselected"
        image = [UIImage imageNamed:@"icon-checkbox-unselected-25x25"];
    } else {
        // Contact has not been selected, add it to THContactPickerView
        //cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.selectedContacts addObject:user];
        [self.contactPickerView addContact:user withName:user.fullName];
        // Set checkbox to "selected"
        image = [UIImage imageNamed:@"icon-checkbox-selected-green-25x25"];
    }
    
    // Enable Done button if total selected contacts > 0
    if(self.selectedContacts.count > 0) {
        barButton.enabled = TRUE;
    }
    else
    {
        barButton.enabled = FALSE;
    }
    
    // Update window title
    self.title = [NSString stringWithFormat:@"Add Members (%lu)", (unsigned long)self.selectedContacts.count];
    
    // Set checkbox image
    checkboxImageView.image = image;
    // Reset the filtered contacts
    self.filteredContacts = self.contacts;
    // Refresh the tableview
    [self.tableView reloadData];
}

#pragma mark - THContactPickerTextViewDelegate

- (void)contactPickerTextViewDidChange:(NSString *)textViewText {
    if ([textViewText isEqualToString:@""]){
        self.filteredContacts = self.contacts;
    } else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.%@ contains[cd] %@ OR self.%@ contains[cd] %@", @"firstName", textViewText, @"lastName", textViewText];
        self.filteredContacts = [self.contacts filteredArrayUsingPredicate:predicate];
    }
    [self.tableView reloadData];
}

- (void)contactPickerDidResize:(THContactPickerView *)contactPickerView {
    [self adjustTableViewFrame:YES];
}

- (void)contactPickerDidRemoveContact:(id)contact {
    [self.selectedContacts removeObject:contact];
    
    NSUInteger index = [self.contacts indexOfObject:contact];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    //cell.accessoryType = UITableViewCellAccessoryNone;
    
    // Enable Done button if total selected contacts > 0
    if(self.selectedContacts.count > 0) {
        barButton.enabled = TRUE;
    }
    else
    {
        barButton.enabled = FALSE;
    }
    
    // Set unchecked image
    UIImageView *checkboxImageView = (UIImageView *)[cell viewWithTag:104];
    UIImage *image;
    image = [UIImage imageNamed:@"icon-checkbox-unselected-25x25"];
    checkboxImageView.image = image;
    
    // Update window title
    self.title = [NSString stringWithFormat:@"Add Members (%lu)", (unsigned long)self.selectedContacts.count];
}

- (void)removeAllContacts:(id)sender
{
    [self.contactPickerView removeAllContacts];
    [self.selectedContacts removeAllObjects];
    self.filteredContacts = self.contacts;
    [self.tableView reloadData];
}
#pragma mark ABPersonViewControllerDelegate

- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    return YES;
}


// This opens the apple contact details view: ABPersonViewController
//TODO: make a THContactPickerDetailViewController
- (IBAction)viewContactDetail:(UIButton*)sender {
    ABRecordID personId = (ABRecordID)sender.tag;
    ABPersonViewController *view = [[ABPersonViewController alloc] init];
    view.addressBook = self.addressBookRef;
    view.personViewDelegate = self;
    view.displayedPerson = ABAddressBookGetPersonWithRecordID(self.addressBookRef, personId);

    
    [self.navigationController pushViewController:view animated:YES];
}

// TODO: send contact object
- (void)done:(id)sender
{
    [self asynInsert: [self refreshFullContacts]];
}

-(void)asynInsert:(LKTest *)insertObj{
    LKDBHelper* globalHelper = [LKTest getUsingLKDBHelper];
   // [globalHelper dropAllTable];
    [insertObj saveToDB];
    [globalHelper insertToDB:insertObj callback:^(BOOL isInsert) {
        NSLog(@"asynchronization insert complete: %@",isInsert>0?@"YES":@"NO");
    }];
}

@end
