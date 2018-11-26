// API Implementation



#define KEYCHAIN_ACCESS_GROUP @"43432WKUU5"
#define DOMAIN_DEFAULT        @"https://gitosolutions.com"
// Test
//#define TEST_USERNAME   @"tamchu1403@gmail.com"
//#define TEST_PASSWORD   @"Aa123456?"

#define SERVER_URL              @"/api"

#define URL_INSTALL_APP @"https://itunes.apple.com/us/app/"

// https://itunes.apple.com/us/app/gito-professional-management/id1358563059?ls=1&mt=8
// https://itunes.apple.com/us/app/gito-chat/id1359061744?ls=1&mt=8
// https://itunes.apple.com/us/app/gito-test-case/id1358949931?ls=1&mt=8

#define ID_INSTALL_POSTAPI @"id404249815?mt=8"
#define ID_INSTALL_TESTCASE @"gito-test-case/id1358949931?ls=1&mt=8"
#define ID_INSTALL_CHAT @"gito-chat/id1359061744?ls=1&mt=8"

#define DESKTOP_USER_AGENT @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/66.0.3359.139 Safari/537.36"


#define arrMethods          @[@"GET", @"POST", @"PUT", @"UPDATE", @"DELETE"]

// Number item per page of all list
#define NUMBER_ITEM_PERPAGE 25

// Method Index
#define NUM_METHOD          5

#define METHOD_GET          (0*NUM_METHOD+0)
#define METHOD_GET_2        (1*NUM_METHOD+0)

#define METHOD_POST         (0*NUM_METHOD+1)
#define METHOD_POST_2       (1*NUM_METHOD+1)
#define METHOD_POST_3       (2*NUM_METHOD+1)
#define METHOD_POST_4       (3*NUM_METHOD+1)
#define METHOD_POST_5       (4*NUM_METHOD+1)
#define METHOD_POST_6       (5*NUM_METHOD+1)
#define METHOD_SAVEDATA     (6*NUM_METHOD+1)

#define METHOD_PUT          (0*NUM_METHOD+2)
#define METHOD_PUT_2        (1*NUM_METHOD+2)
#define METHOD_PUT_3        (2*NUM_METHOD+2)
#define METHOD_PUT_4        (3*NUM_METHOD+2)
#define METHOD_PUT_5        (4*NUM_METHOD+2)
#define METHOD_PUT_6        (5*NUM_METHOD+2)
#define METHOD_PUT_7        (6*NUM_METHOD+2)
#define METHOD_PUT_8        (7*NUM_METHOD+2)

//#define METHOD_UPDATE       (0*NUM_METHOD+3)
//#define METHOD_UPDATE_2     (1*NUM_METHOD+3)


#define METHOD_DELETE       (0*NUM_METHOD+4)
#define METHOD_DELETE_2     (1*NUM_METHOD+4)
#define METHOD_DELETE_3     (2*NUM_METHOD+4)
#define METHOD_DELETE_4     (3*NUM_METHOD+4)

// Application Delegate
#define AppShare [UIApplication sharedApplication]
#define App ((AppDelegate*)AppShare.delegate)

// ImagePicker
#define IMAGE_PICKER     [ImagePicker shared]

#define Config  App.config
#define Socket  App.socket

#define CompanyRole Config.user.roleCompany

#define KEY_INFO_DEVICE @"DIC_INFOR_CURRENT_DEVICE"
#define GOOGLE_TRACKING_ID @"UA-110936030-1"

#define SECOND_TK_KEY    @"media-type"
#define SECOND_TK_VALUE  @"application/json"

#define TK_RPREFIX       @"aaaaaaaa"
#define TK_RSUFFIX       @"bbbbbbbb"

#define TK_SPREFIX       @"cccc"
#define TK_SSUFFIX       @"dddd"

#define KEY_BUNDLE_VERSION @"CFBundleVersion"

#define IOS_8_OR_LATER() ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define IOS_9_OR_LATER() ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0)
#define IOS_10_OR_LATER() ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0)

#define IS_IPAD()   (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define IS_IPHONE_4_LANDSCAPE (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)480) < DBL_EPSILON)
#define IS_IPHONE_5_LANDSCAPE (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)568) < DBL_EPSILON)
#define IS_IPHONE_6_LANDSCAPE (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)667) < DBL_EPSILON)
#define IS_IPHONE_6P_LANDSCAPE (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)736) < DBL_EPSILON)
#define IS_IPHONE_X     ((SWIDTH < 380)&&(SHEIGHT > 810))                   //{375, 812}

#define IS_Landscape()            (SWIDTH > SHEIGHT)
#define IS_Portrait()             (SWIDTH < SHEIGHT)

#define IS_IPHONE_4()        (MAX(SWIDTH, SHEIGHT) == 480)
#define IS_IPHONE_5()          (MAX(SWIDTH, SHEIGHT) == 568)
#define IS_IPHONE_6()        (MAX(SWIDTH, SHEIGHT) == 667)
#define IS_IPHONE_6P()        (MAX(SWIDTH, SHEIGHT) == 736)

#define TIME_TRANSITION_LOCK 0.35

#define VCFromSB(VC, SBName) (VC*)[[UIStoryboard storyboardWithName:SBName bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([VC class])];

#define VCFromSBIdentifier(VC, SBName,Identifier) (VC*)[[UIStoryboard storyboardWithName:SBName bundle:nil] instantiateViewControllerWithIdentifier:Identifier];

#define VFromXIB(CLASS_NAME,INDEX) [[[NSBundle mainBundle] loadNibNamed:CLASS_NAME owner:self options:nil] objectAtIndex:INDEX];

#define GET_TABLE_CELL(CellCls) CellCls *cell = [tableView dequeueReusableCellWithIdentifier:@#CellCls forIndexPath:indexPath]

#define OBJ_FROM_NIB(name) [[NSBundle mainBundle] loadNibNamed:@#name owner:nil options:nil].firstObject


//Key save test
#define KEY_TEST(currentSubTest)     SF(@"test%ld",currentSubTest)

// Check Empty
#define isEmpty(A)      ((!A) || [A length] <= 0)
#define E(A)            ((A) ? (A) : @"")
#define isListEmpty(A)       (!A || !A.list || A.list.count <= 0)

#define ESCAPE(A)   [A stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]
#define UNESCAPE(A) [A stringByRemovingPercentEncoding]

//#define CONTENT_FONT(body,font) [NSString stringWithFormat:@"<span style=\"font-family: %@; font-size: %i\">%@</span>",\
 font.fontName,\
 (int) font.pointSize,\
 E(body)]

#define FONT(Size) [UIFont fontWithName:@"Helvetica" size:Size]
#define FONTBold(Size) [UIFont fontWithName:@"Helvetica-Bold" size:Size]

//Encode, Decode NSUserdefault
#define DEC(A)  _##A = [aDecoder decodeObjectForKey:@#A]
#define DECB(A) _##A = [aDecoder decodeBoolForKey:@#A]
#define DECI(A) _##A = [aDecoder decodeIntegerForKey:@#A]
#define DECD(A) _##A = [aDecoder decodeDoubleForKey:@#A]

#define ENC(A) if(_##A) [aCoder encodeObject:_##A forKey:@#A]
#define ENCB(A) [aCoder encodeBool:_##A forKey:@#A]
#define ENCI(A) [aCoder encodeInteger:_##A forKey:@#A]
#define ENCD(A) [aCoder encodeDouble:_##A forKey:@#A]

// API Parse Server Data
#define MAP(A)      _##A = [dic objectForKey:@#A];
#define MAPB(A)     _##A = [[dic objectForKey:@#A] boolValue];
#define MAPI(A)     _##A = [[dic objectForKey:@#A] integerValue];
#define MAPF(A)     _##A = [[dic objectForKey:@#A] floatValue];
#define MAPD(A)     _##A = [[dic objectForKey:@#A] doubleValue];
#define MAPL(A)     _##A = [[dic objectForKey:@#A] longlongValue];

#define MAPDate(KeyName, DateFormatter)   MAPRDate(KeyName, KeyName, DateFormatter)
#define MAPRDate(AssignedObj, KeyName, DateFormatter)   _##AssignedObj = [DateFormatter dateFromString:[dic objectForKey:@#KeyName]]

#define MAPO(A, CLASS)      _##A = [[CLASS alloc] initWithData:[dic objectForKey:@#A]]
#define MAPA(A, CLASS)      _##A = [[NSMutableArray alloc] init]; \
NSArray *a##A = [dic objectForKey:@#A]; \
if(a##A && [a##A isKindOfClass:[NSArray class]]) { \
NSInteger count = a##A.count; \
for(NSInteger i=0; i<count; i++) { \
id item = a##A[i]; \
if([item isKindOfClass:[NSDictionary class]]) { \
[_##A addObject:[[CLASS alloc] initWithData:item]]; \
} \
} \
}

#define MAPAO_ARR(A, CLASS)      if (_##A == nil) { \
_##A = [NSMutableArray array]; \
} \
if (dic && [dic isKindOfClass:[NSArray class]]) { \
for (id obj in dic) { \
CLASS *dic = [[CLASS alloc] init]; \
[dic mapDataFromServer:obj]; \
[_##A addObject:dic]; \
} \
}else{\
NSString *str = VarName(_##A);\
NSLog(@"Please get dic for key %@",str);\
}\

#define MAPAO_DIC(A, CLASS)      if ([dic objectForKey:@#A]) {\
NSDictionary *dicB = [dic objectForKey:@#A];\
if (_##A == nil) {\
_##A = [NSMutableArray array];\
}\
if (dicB && [dicB isKindOfClass:[NSArray class]]) {\
for (id obj in dicB) {\
CLASS *aa = [[CLASS alloc] init];\
[aa mapDataFromServer:obj];\
[_##A addObject:aa];\
}\
}\
}\

// Merge
#define M(A)        _##A = obj.A;
#define MX(A)       [_##A mergeFrom:obj.A];

//Get Variable Name
#define VarName(arg) (@""#arg)

//fast dictionary
#define KEYVALO(KEY) KEYVALMO(KEY, self.KEY)
#define KEYVALN(KEY) KEYVALMN(KEY, self.KEY)

#define KEYVALMO(KEY, VAL) @#KEY: E(VAL)
#define KEYVALMN(KEY, VAL) @#KEY: @(VAL)


// Screen size
#define SRECT [UIScreen mainScreen].bounds
#define SWIDTH SRECT.size.width
#define SHEIGHT SRECT.size.height

#pragma mark - Alert
//Alert
#define ALERT(CONTENT_FORMAT, ...) MSG_NEW(nil, CONTENT_FORMAT, ##__VA_ARGS__);

#define MSG(TITLE, CONTENT_FORMAT, ...)    \
[[[UIAlertView alloc] initWithTitle:TITLE message:[NSString stringWithFormat:CONTENT_FORMAT, ##__VA_ARGS__] delegate:nil cancelButtonTitle:L(@"OK") otherButtonTitles:nil] show];

#define MSG_NEW(TITLE, CONTENT_FORMAT, ...) \
UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:L(@"OK") style:UIAlertActionStyleDefault handler:nil];\
UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:[NSString stringWithFormat:CONTENT_FORMAT, ##__VA_ARGS__] preferredStyle:UIAlertControllerStyleAlert];\
[alert addAction:cancelAction];\
if ([self isKindOfClass:[UIViewController class]]) {\
UIViewController *vc = (UIViewController*)self;\
[vc presentViewController:alert animated:YES completion:nil];\
}else{\
[App.mainVC.contentNV presentViewController:alert animated:YES completion:nil];\
}\


//Get Color Function
#define rgba(R, G, B, A) [UIColor colorWithRed:(R)/255.0 green:(G)/255.0 blue:(B)/255.0 alpha:(A)]
#define RGBA(ColorLongValue, AlphaValue) [UIColor colorWithRed:((ColorLongValue>>16)&0xFF)/255.0 green:((ColorLongValue>>8)&0xFF)/255.0 blue:(ColorLongValue&0xFF)/255.0 alpha:AlphaValue]
#define RGB(ColorLongValue) RGBA(ColorLongValue, 1.0)

//Color
#define GREEN_COLOR RGB(0x69D554)
#define BLUE_COLOR RGB(0x0962A6)
#define RED_COLOR RGB(0xFC4837)
#define RED_COLOR_ALPHA RGB(0xFF7256)
#define RED_BOOKING_COLOR RGB(0xD0021B)
#define GRAY_TAB_COLOR RGB(0xF9F9F9)
#define GRAY_TEXT_COLOR RGB(0x2A2D34)
#define GRAY_LIGHT_COLOR RGB(0xCCD6DD)
#define GRAY_VIEW_COLOR RGB(0xF2F2F2)
#define GRAY_LIGHT_PLACEHOLDER_COLOR RGB(0xCCD6DD)
#define GRAY_DARK_COLOR RGB(0xCFCFCF)
#define GRAY_COLOR RGB(0xCDCDCD)
#define ORANGE_COLOR RGB(0xFF724B)
#define PURPLE_COLOR RGB(0x9885E2)
#define BLUE_BUTTON RGB(0x009DF7)
#define SHADOW_COLOR RGB(0X4C4C4C)
#define PASSED_COLOR RGB(0x00C79B)
#define LOGGED_HOUR_COLOR RGB(0XF79318)
#define LOGGED_COST_COLOR RGB(0X2F630A)

#define TEXT_COLOR RGB(0x000000)
#define TEXT_MENU_COLOR RGB(0x002C45)
#define PLACEHOLDER_COLOR RGBA(0x000000,0.5)

#define NAV_BG_COLOR RGB(0x2A2D34)
#define BORDER_COLOR RGB(0x979797)
#define COLOR_CHART_HIGHlIGHT RGB(0xB3B4B9)
#define COLOR_CHART RGB(0x69D554)
#define GRAY_BUTTON_COLOR RGB(0xE6E6E6)
#define GRAY_DARK_TEXT_COLOR RGB(0x4A4A4A)
#define GRAY_HEADER_COLOR RGB(0xEFEFF4)
#define GRAYANPLA_VIEW_COLOR RGB(0xE2E1E1)
#define WHITE_COLOR [UIColor whiteColor]
#define GRAY_LINE_COLOR RGB(0xF2F2F2)
#define KEYBOARD_BG_COLOR RGB(0xD1D5DB)

//color random on scrum
#define SCRUM_RED RGB(0xFF1E22)
#define SCRUM_ORANGE RGB(0xFF9F00)
#define SCRUM_GREEN RGB(0x417505)
#define SCRUM_GREEN_NEON RGB(0x7ED321)
#define SCRUM_GRAY RGB(0x4A4A4A)
#define SCRUM_GRAY_LIGHT RGB(0x9B9B9B)
#define SCRUM_BLUE RGB(0x1E34FF)
#define SCRUM_NEON RGB(0xF6E400)
#define SCRUM_BLUE_LIGHT RGB(0x009DF7)
#define SCRUM_GREEN_LIGHT RGB(0x00C89B)
#define SCRUM_PINK RGB(0XBD0FE1)
#define SCRUM_PURPLE RGB(0X9012FE)

#pragma mark - CHECK Version IOS
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#define STATUS_BAR_HEIGHT [[UIApplication sharedApplication]statusBarFrame].size.height

#define VALRANGE(VAL, MINVAL, MAXVAL) MAX(MINVAL, MIN(VAL, MAXVAL))
#define VALINRANGE(VALUE, MINVAL, MAXVAL) (((VALUE > MAXVAL) || (VALUE < MINVAL)) ? NO : YES)

#define IP6PLUS (SHEIGHT == 736.000000)
#define IP6 (SHEIGHT == 667.000000)
#define IP5 (SHEIGHT == 568.000000)
#define IP4S (SHEIGHT == 480.000000)
#define isLandscape() (SWIDTH > SHEIGHT)
#define isPortrait()  (SWIDTH < SHEIGHT)
#define IS_IPHONEX (([[UIScreen mainScreen] bounds].size.height-812)?NO:YES)


#define VALCond(Condition, TrueValue, FalseValue)  ((Condition) ? (TrueValue) : (FalseValue))
#define VA(Value, AltValue)  ((Value) ? (Value) : (AltValue))

#define APPEND_LINE [[NSAttributedString alloc] initWithString:@"\n\n"]

// String preprocess
#define SF(A, ...) [NSString stringWithFormat:A, __VA_ARGS__]
#define SF_ATT(A, ...) [NSMutableAttributedString stringWithFormat:A, __VA_ARGS__]
#define SFCurrency(A) [Utilities getStringFromNumber:[NSNumber numberWithDouble:A]]
#define SFCurrencyHasCurrency(A) [Utilities getStringFromNumberHasCurrency:[NSNumber numberWithDouble:A]]


#define GET_COLLECTION_CELL(CellCls) CellCls *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@#CellCls forIndexPath:indexPath]
#define NSLOG_DELEGATE NSLog(@"%s:\nPlease implement delegate",__PRETTY_FUNCTION__);
#define NSLOG_DEBUG_FUNCTION(msg, ...) NSLog((@"%s [Line %d] " msg), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

#define ALERT_DEBUG if (data) {\
ALERT(@"ErrorMessage: %@, \nMessage: %@ \nAlert debug, will remove later", data.errorMessage, data.Message);\
}\

#define VID(A)  [Utilities validID:A]
#define GID(A)  [Utilities getValidID:A]
#define VID_NUM(A)  [Utilities validNumber:A]

#define ValidID(A)  [Utilities validID:A]
#define GetID(A)  [Utilities getValidID:A]
#define GetACronym(A)  [Utilities getValidACronym:A]


#define MId(A) [[A lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@"-"]
#define MId_Id(A) [[A lowercaseString] stringByReplacingOccurrencesOfString:@"\n" withString:@"-"]

// App Key
#define CF_UserData                 @"CF_UserData"
#define CF_SaveFilter               @"CF_SaveFilter"
#define CF_ProjectData              @"CF_ProjectData"
#define CF_HasShownTermPrivacy      @"CF_HasShownTermPrivacy"
#define CF_CalendarFillter          @"CF_CalendarFillter"
#define CF_CalendarFillterProject   @"CF_CalendarFillterProject"

#define CF_UserIDNotification       @"CF_UserIDNotification"


// Date
#define DATE_IS_FUTURE  1
#define DATE_IS_TODAY   0
#define DATE_IS_PAST    -1


// DTO Preprocess
// Parse
#define IO(Obj)                 id z##Obj = dic[@#Obj]; if(z##Obj && ![z##Obj isKindOfClass:[NSNull class]]) _##Obj = z##Obj
#define IOK(Obj,key)            id z##Obj = dic[key]; if(z##Obj && ![z##Obj isKindOfClass:[NSNull class]]) _##Obj = z##Obj
#define IB(Obj)                 id z##Obj = dic[@#Obj]; if(z##Obj && ![z##Obj isKindOfClass:[NSNull class]]) _##Obj = [z##Obj boolValue]

#define IC(Obj, ClassName)      id z##Obj = dic[@#Obj]; if(z##Obj && ![z##Obj isKindOfClass:[NSNull class]]) _##Obj = [[ClassName alloc] initWithData:z##Obj]

#define IDate(Obj)              IDateF(Obj, [NSDateFormatter serverDateFormatter])
#define IDateF(Obj, DateFormat) id z##Obj = dic[@#Obj]; _##Obj = [DateFormat dateFromString:z##Obj]

#define IN(Obj)                 id z##Obj = dic[@#Obj]; _##Obj = (z##Obj && ![z##Obj isKindOfClass:[NSNull class]]) ? [z##Obj integerValue] : 0
#define IL(Obj)                 id z##Obj = dic[@#Obj]; _##Obj = (z##Obj && ![z##Obj isKindOfClass:[NSNull class]]) ? [z##Obj longLongValue] : 0
#define ID(Obj)                 id z##Obj = dic[@#Obj]; _##Obj = (z##Obj && ![z##Obj isKindOfClass:[NSNull class]]) ? [z##Obj doubleValue] : 0.0
#define IF(Obj)                 id z##Obj = dic[@#Obj]; _##Obj = (z##Obj && ![z##Obj isKindOfClass:[NSNull class]]) ? [z##Obj floatValue] : 0.0
#define INK(Obj, Key)           id z##Obj = dic[Key]; _##Obj = (z##Obj && ![z##Obj isKindOfClass:[NSNull class]]) ? [z##Obj integerValue] : 0

#define IA(Obj, ClassName) \
{ \
_##Obj = [[NSMutableArray alloc] init]; \
id items = dic[@#Obj]; \
if(items && ![items isKindOfClass:[NSNull class]]) { \
for(NSDictionary *item in items) { \
[_##Obj addObject:[[ClassName alloc] initWithData:item]]; \
} \
} \
}

#define IAK(Obj, ClassName, SubKey) \
{ \
_##Obj = [[NSMutableArray alloc] init]; \
id items = dic[@#Obj]; \
if(items && ![items isKindOfClass:[NSNull class]]) { \
for(NSDictionary *item in items) { \
[_##Obj addObject:[[ClassName alloc] initWithData:item[SubKey]]]; \
} \
} \
}


#define IAObj(Obj, Array, ClassName) \
{ \
_##Obj = [[NSMutableArray alloc] init]; \
if(Array && ![Array isKindOfClass:[NSNull class]]) { \
for(NSDictionary *item in Array) { \
[_##Obj addObject:[[ClassName alloc] initWithData:item]]; \
} \
} \
}

#define IAS(Obj) \
{ \
_##Obj = [[NSMutableArray alloc] init]; \
id items = dic[@#Obj]; \
if(items && ![items isKindOfClass:[NSNull class]]) { \
for(NSString *item in items) { \
[_##Obj addObject:item]; \
} \
} \
}



// JSON MAP
#define JP(A) \
if(_##A) { \
NSString *pwd = PK(_##A); \
[dic setObject:pwd forKey:@#A]; \
}
#define JNN(Obj) JBKey(Obj, @#Obj)
#define JN(Obj)  JBNKey(Obj, @#Obj)
#define JB(Obj)  JBNKey(Obj, @#Obj)
#define JBN(Obj) JBKey(Obj, @#Obj)
#define JD(Obj)  JBKey(Obj, @#Obj)
#define JBKey(Obj, Key) \
if(_##Obj) { \
[dic setObject:@(_##Obj) forKey:Key]; \
}

#define JBNKey(Obj, Key) [dic setObject:@(_##Obj) forKey:Key]; \

#define JC(Obj) JCKey(Obj, @#Obj)
#define JCKey(Obj, Key) \
if(_##Obj) { \
[dic setObject:[_##Obj getJSONObject] forKey:Key]; \
}

#define JDate(Obj) JDateF(Obj, [NSDateFormatter serverDateFormatter])
#define JDateF(Obj, DateFormatter) if(_##Obj) [dic setObject:[DateFormatter stringFromDate:_##Obj] forKey:@#Obj]

#define JO(Obj) JOKey(Obj, @#Obj)
#define JOKey(Obj, Key) \
if(_##Obj) { \
[dic setObject:_##Obj forKey:Key]; \
}

#define JCI(Obj) JCIKey(Obj, @#Obj)
#define JCIKey(Obj, Key) \
if(_##Obj._id) { \
[dic setObject:_##Obj._id forKey:Key]; \
}

#define JAM(Obj, method) \
if(_##Obj) { \
NSMutableArray *arr = [[NSMutableArray alloc] init]; \
for(BaseDto *item in _##Obj) { \
[arr addObject:[item getJSONObjectWithMethod:method]]; \
} \
[dic setObject:arr forKey:@#Obj]; \
}

#define JA(Obj) \
if(_##Obj) { \
NSMutableArray *arr = [[NSMutableArray alloc] init]; \
for(BaseDto *item in _##Obj) { \
[arr addObject:[item getJSONObject]]; \
} \
[dic setObject:arr forKey:@#Obj]; \
}

#define JAK(A, Class, SubPath) \
NSMutableArray *arr##A = [[NSMutableArray alloc] init]; \
for(int i=0; i<_##A.count; i++) { \
Class *dto = _##A[i]; \
[arr##A addObject:dto.SubPath]; \
} \
[dic setObject:arr##A forKey:@#A];

#define JAC(A, Class, SubPath) \
NSMutableArray *arr##A = [[NSMutableArray alloc] init]; \
for(int i=0; i<_##A.list.count; i++) { \
Class *dto = _##A.list[i]; \
[arr##A addObject:dto.SubPath]; \
} \
[dic setObject:arr##A forKey:@#A];


// image
#define IM(A) [UIImage imageNamed:@#A]

// Clone
#define CO(Key) dto.Key = _##Key
#define COSelf(Key) dto.Key = self.Key
#define CA(Key) \
if(_##Key.count > 0) { \
dto.Key = [[NSMutableArray alloc] init]; \
for (NSInteger i = 0; i< _##Key.count; i++) { \
[dto.Key addObject:_##Key[i]];\
}\
}

#define CClass(Key,Class) dto.Key = (Class*)[_##Key cloneToNewObject]

#define CAO(Key,Class) \
if(_##Key.count > 0) { \
dto.Key = [[NSMutableArray alloc] init]; \
for (NSInteger i = 0; i< _##Key.count; i++) { \
Class *object = (Class*)([_##Key[i] cloneToNewObject]);\
[dto.Key addObject:object];\
}\
}

// Merge
#define MO(Key) _##Key = object.Key


#define PK(A) [Utilities getPassword:A]


// Term Privacy
#define Term_Mode_TermService   0
#define Term_Mode_Privacy       1
#define TermArray               @[@"Term", @"Privacy"]


// Storyboard
#define SB_TaskDetail       @"TaskDetail"
#define SB_Common           @"Common"
#define SB_Main             @"Main"
#define SB_Login            @"Login"
#define SB_Project          @"Project"
#define SB_Task             @"Task"
#define SB_Gantt            @"Gantt"
#define SB_Calendar         @"Calendar"
#define SB_Document         @"Document"
#define SB_SpaceStorage     @"SpaceStorage"
#define SB_Version          @"Version"
#define SB_SourceCode       @"SourceCode"
#define SB_Wiki             @"Wiki"
#define SB_Chat             @"Chat"
#define SB_Note             @"Note"
#define SB_Todo             @"Todo"
#define SB_LogTime          @"LogTime"
#define SB_Survey           @"Survey"
#define SB_Report           @"Report"
#define SB_Meeting          @"Meeting"
#define SB_Estate           @"Estate"
#define SB_ChangeLog        @"ChangeLog"
#define SB_Checkin          @"Checkin"
#define SB_Leaving          @"Leaving"
#define SB_Contact          @"Contact"
#define SB_RoomBooking      @"RoomBooking"
#define SB_Accounting       @"Accounting"
#define SB_Prepayment       @"Prepayment"
#define SB_SalaryDetail     @"SalaryDetail"
#define SB_SalaryPayslip    @"SalaryPayslip"
#define SB_Salary         	@"Salary"
#define SB_Bonus            @"Bonus"

#define SB_WareHouse        @"WareHouse"
#define SB_Email            @"Email"
#define SB_CaseStudy        @"CaseStudy"
#define SB_User             @"User"
#define SB_Notification     @"Announcement"
#define SB_Company          @"Company"
#define SB_Group            @"Group"
#define SB_Recruit          @"Recruit"
#define SB_TestCase         @"TestCase"
#define SB_PickerTypeList   @"PickerTypeList"
#define SB_Candidate        @"Candidate"
#define SB_MyPage           @"MyPage"
#define SB_Performance      @"Performance"
#define SB_Cost             @"Cost"
#define SB_Contract         @"Contract"
#define SB_Request          @"RequestResolution"
#define SB_Profit           @"Profit"
#define SB_KPI              @"KPI"
#define SB_Scrum            @"Scrum"
#define SB_RoleInfor        @"RoleInfor"

#define SB_MailCampaign     @"MailCampaign"
#define SB_SMSCampaign      @"SMSCampaign"
#define SB_Customer         @"Customer"
#define SB_CustomerCare     @"CustomerCare"
#define SB_ShowRoom         @"ShowRoom"
#define SB_Feedback         @"Feedback"

#define SB_Producing        @"Producing"
#define SB_Invoice          @"Invoice"
#define SB_Tax              @"Tax"
#define SB_Purchase         @"Purchase"

#define SB_Event            @"Event"
#define SB_Sale             @"Sale"

//Storyboard ChatApp
#define SB_CLogin          @"CLogin"

#define Identify_EstateNoti  @"Asset"

// Company Feature
typedef enum : NSUInteger {
    
    HFMenu_MyPage = 0,
    HFMenu_Project,
    
    HFMenu_Sumary,
    HFMenu_Scrum,
    HFMenu_Task,
    HFMenu_Gantt,
    HFMenu_Document,
    HFMenu_SpaceStorage,
    HFMenu_SourceCode,
    HFMenu_Wiki,
    HFMenu_Version,
    HFMenu_TestCase,
    HFMenu_ChangeLog,
    HFMenu_Setting,
    
    HFMenu_Calendar,
    HFMenu_Event,
    HFMenu_LogTime,
    HFMenu_Note,
    HFMenu_Meeting,
    HFMenu_Chat,
    HFMenu_API,
    HFMenu_Performance,
    HFMenu_Cost,
    
    
    HFMenu_Report,
    HFMenu_Announcement,
    
    
    HFMenu_Todo,
    
    HFMenu_CheckIn,
    HFMenu_LeavingRegister,
    HFMenu_BookingRoom,
    HFMenu_Accounting,
    HFMenu_Prepayment,
    HFMenu_Salary,
    HFMenu_Bonus,
    
    HFMenu_Survey,
    HFMenu_Estate,
    HFMenu_CaseStudy,
    
    HFMenu_Email,
    HFMenu_User,
    HFMenu_Group,
    HFMenu_UserNGroup,
    HFMenu_Recruit,
    
    HFMenu_KPI,
    HFMenu_ContactList,
    HFMenu_Contract,
    HFMenu_Profit,
    HFMenu_RequestAndResolution,
    
    HFMenu_Customer,
    HFMenu_CustomerCare,
    HFMenu_Feedback,
    HFMenu_SMSCampaign,
    HFMenu_ShowRoom,
    HFMenu_Purchase,
    HFMenu_Producing,
    HFMenu_Tax,
    HFMenu_Invoice,

    HFMenu_MailCampaign
    
} HFMenu_;

typedef enum : NSUInteger {
    DisplayMode_View = 0,
    DisplayMode_New,
    DisplayMode_Edit,
    DisplayMode_Lock,
    DisplayMode_Archive
} DisplayMode;

typedef enum : NSUInteger {
    StatusMode_View = 0,
    StatusMode_Unapprove,
    StatusMode_Approved
} StatusMode;

typedef enum : NSInteger {
    DisplayMode_SingleUser = 50,
    DisplayMode_MultiUser
}DisplayMode_User;

//Edir task
#define TASK_TITLE          0
#define TASK_STATUS         2
#define TASK_CONTENT        1
#define TASK_PRIORITY       3
#define TASK_ASSIGN         4
#define TASK_FROMDAY        20
#define TASK_TODAY          21

#define PJR_STATUS_ACTIVE   0
#define PJR_STATUS_LOCKED   1
//#define PJR_STATUS_CLOSED   2
#define PJR_STATUS_ARCHIVED 3

#define PJR_COLOR_ACTIVE    RGB(0xF5A623)
#define PJR_COLOR_CLOSED    RGB(0x4A4A4A)
#define PJR_COLOR_LOCKED    RGB(0xFF1E22)
#define PJR_COLOR_ARCHIVED  RGB(0x00C79B)

#define TAG_NOITEM 99999

#pragma mark - VersionColor Accepted 3: Rejected

#define PVERSION_COLOR_NEW        RGB(0xF5A623)
#define PVERSION_COLOR_SUBMITTED  RGB(0x417505)
#define PVERSION_COLOR_APPROVED   RGB(0x00C096)
#define PVERSION_COLOR_REJECTED   RGB(0xFF1E22)


#pragma mark - STATUS NOTIFY
#define STATUS_NEW       0
#define STATUS_APPROVED  1
#define STATUS_REJECTED  2
#define STATUS_SUBMITED  3
#define STATUS_SENT   4

//COLOR STATUS
#define COLOR_NEW        RGB(0xF5A623)
#define COLOR_APPROVED   RGB(0x00C096)
#define COLOR_SUBMITED   RGB(0x417505)
#define COLOR_REJECTED   RGB(0xFF1E22)
#define COLOR_SENT       RGB(0x00C096)

// ONLY FOR REPORT TIMELINE
#define COLOR_BORDER_REPORT RGB(0xD3D3D3)

#define OT_COLOR RGB(0x8770E4)


#pragma mark - TaskColor

typedef enum : NSInteger {
    TaskStatusUndefine = -1,
    TaskStatusOpen = 0,
    TaskStatusDoing,
    TaskStatusDone,
    TaskStatusClosed,
    TaskStatusPending,
    TaskStatusRejected,
} TaskStatus;

#define TASK_COLOR_OPEN     RGB(0xF5A623)
#define TASK_COLOR_DOING    RGB(0x417505)
#define TASK_COLOR_DONE     RGB(0x00C79B)
#define TASK_COLOR_CLOSED   RGB(0x4A4A4A)
#define TASK_COLOR_PENDING  RGB(0x9B9B9B)
#define TASK_COLOR_REJECTED RGB(0xFF1E22)

#pragma mark - Case Study Color

#define CS_COLOR_NEW           RGB(0xF5A623)
#define CS_COLOR_APPROVED      RGB(0x00C89B)
#define CS_COLOR_REJECTED      RGB(0xFF1E22)
#define CS_COLOR_SUBMMITED     RGB(0x417505)
#define CS_COLOR_COLOR_DONE    RGB(0x009DF7)
#define CS_COLOR_CLOSED        RGB(0x000000)

#define TASK_PRIORITY_IMMEDIATE   5
#define TASK_PRIORITY_URGENT      4
#define TASK_PRIORITY_HIGH        3
#define TASK_PRIORITY_NORMAL      2
#define TASK_PRIORITY_LOW         1
#define TASK_PRIORITY_NEXTPHASE   0

#define TASK_PRIORITY_COLOR_IMMEDIATE   RGB(0xFF1E22)
#define TASK_PRIORITY_COLOR_URGENT      RGB(0xF5A623)
#define TASK_PRIORITY_COLOR_HIGH        RGB(0x417505)
#define TASK_PRIORITY_COLOR_NORMAL      RGB(0x7ED321)
#define TASK_PRIORITY_COLOR_LOW         RGB(0x4A4A4A)
#define TASK_PRIORITY_COLOR_NEXTPHASE   RGB(0x9B9B9B)

#define SURVEY_COLOR_CROSS     RGBA(0x000000, 0.5)
#define SURVEY_COLOR_NORMAL    RGBA(0x000000, 0.5)
#define SURVEY_COLOR_DIRECTLY    RGBA(0x000000, 0.5)

#pragma mark - TestCase Color

#define TCS_COLOR_APPROVED      RGB(0x00C79B)
#define TCS_COLOR_UNAPPROVED    RGB(0x787878)

#define TASK_PRIORITY_COLOR_IMMEDIATE   RGB(0xFF1E22)
#define TASK_PRIORITY_COLOR_URGENT      RGB(0xF5A623)
#define TASK_PRIORITY_COLOR_HIGH        RGB(0x417505)
#define TASK_PRIORITY_COLOR_NORMAL      RGB(0x7ED321)
#define TASK_PRIORITY_COLOR_LOW         RGB(0x4A4A4A)
#define TASK_PRIORITY_COLOR_NEXTPHASE   RGB(0x9B9B9B)

// color Summary
#define GRAY_COLOR_SUMMARY RGB(0xEFEFEF)
#define BLUE_COLOR_SUMMARY RGB(0x009DF7)
#define MAIN_COLOR_ALPHA RGBA(0x009DF7, 0.5)
#define RED_COLOR_SUMMARY RGB(0xFF1E22)
#define GRAY_COLOR_SUMMARY_A RGB(0xf7f7f7)
#define BLUE_COLOR_SUMMARY_A RGB(0x80cefb)

#define RED_COLOR_SUMMARY_A RGB(0xff8e90)

#define GRAY_COLOR_SUMMARY_BG RGB(0xEFEFEF)
#define GRAY_COLOR_SUMMARY_A_BG RGB(0xf7f7f7)

#define MAINCOLOR RGB(0x009DF7)
#define MAIN_ANPLA RGB(0xB2E1FD)
#define MAINCOLOR_ANPLA RGB(0x52B7F1)

// color status RequestResolution
#define RR_COLOR_NEW        RGB(0xF5A623)
#define RR_COLOR_SUBMIT     RGB(0x417505)
#define RR_COLOR_REJECTED   RGB(0xFF1E22)
#define RR_COLOR_DOING      RGB(0x00C096)
#define RR_COLOR_RESOLVED   RGB(0x9885E2)
#define RR_COLOR_CLOSED     RGB(0x4A4A4A)


// Color for Status of Product
#define AP_Active       RGB(0xF6AE36)
#define AP_Borrowing    RGB(0x417505)
#define AP_Repairing    RGB(0x00C79B)
#define AP_Broken       RGB(0x4A4A4A)
#define AP_Deleted      RGB(0xFF1E22)

// Color of Leaving Bar Chart
#define LEAVING_CompanyPermit   RGB(0x008000)
#define LEAVING_UserPermit      RGB(0x7ed321)
#define LEAVING_UserTotal       RGB(0x009df7)
#define LEAVING_WithSalary      RGB(0x000000)
#define LEAVING_WithoutSalary   RGB(0x808080)



// Menu

#define COMPANY_PLACEHODER_ICON @"CompanyLogo"
#define USER_PLACEHOLDER_ICON @"avatarCandidate"
#define ITEM_PLACEHOLDER_ICON @"avatarCandidate"
#define DOCUMENT_FILE_ICON @"Document.doc"

#define ModeDateTime UIDatePickerModeDateAndTime
#define ModeDate UIDatePickerModeDate
#define ModeTime UIDatePickerModeTime

#define DDF(A) ((A) ? [[NSDateFormatter displayDateFormatter] stringFromDate:A] : @"")


// Form-Data Formmater
#define StartForm() NSMutableData *data = [[NSMutableData alloc] init];
#define EndForm() [data appendData:[SF(@"--%@--\r\n", __boundary) dataUsingEncoding:NSUTF8StringEncoding]]

#define FormKV(Obj) FormKVKey(Obj, @#Obj, __boundary)
#define FormKVKey(Value, Key, Boundary) \
[data appendData:[[NSString stringWithFormat:@"--%@\r\n", Boundary] dataUsingEncoding:NSUTF8StringEncoding]]; \
[data appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", Key] dataUsingEncoding:NSUTF8StringEncoding]]; \
[data appendData:[[NSString stringWithFormat:@"%@\r\n", _##Value] dataUsingEncoding:NSUTF8StringEncoding]];

#define FormKVI(Obj) FormKVIKey(Obj, @#Obj, __boundary)
#define FormKVIKey(Value, Key, Boundary) \
[data appendData:[[NSString stringWithFormat:@"--%@\r\n", Boundary] dataUsingEncoding:NSUTF8StringEncoding]]; \
[data appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", Key] dataUsingEncoding:NSUTF8StringEncoding]]; \
[data appendData:[[NSString stringWithFormat:@"%ld\r\n", _##Value] dataUsingEncoding:NSUTF8StringEncoding]];

#define FormKVB(Obj) FormKVBKey(Obj, @#Obj, __boundary)
#define FormKVBKey(Value, Key, Boundary) \
[data appendData:[[NSString stringWithFormat:@"--%@\r\n", Boundary] dataUsingEncoding:NSUTF8StringEncoding]]; \
[data appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", Key] dataUsingEncoding:NSUTF8StringEncoding]]; \
[data appendData:[[NSString stringWithFormat:@"%d\r\n", _##Value] dataUsingEncoding:NSUTF8StringEncoding]];


#define FormFile(FileName, MineType, FileContent) \
[data appendData:[[NSString stringWithFormat:@"--%@\r\n", __boundary] dataUsingEncoding:NSUTF8StringEncoding]]; \
[data appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", @"file", _##FileName] dataUsingEncoding:NSUTF8StringEncoding]]; \
[data appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", MineType] dataUsingEncoding:NSUTF8StringEncoding]]; \
[data appendData:_##FileContent]; \
[data appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];

#define DATE_DEFAULT_START [[NSDateFormatter companyDateFormatter] dateFromString:@"01/01/2000"]
#define DATE_DEFAULT_END [[NSDateFormatter companyDateFormatter] dateFromString:@"01/01/2100"]

#define RootFrame(ViewA) [App.window.rootViewController.view convertRect:ViewA.frame fromView:ViewA]

#define TimeAnimation 0.3

//init

typedef enum : NSUInteger {
    AccFilterCellTypeTitle = 0,
    AccFilterCellTypeAmount,
    AccFilterCellTypeCreatedBy,
    AccFilterCellTypeDate,
    AccFilterCellTypeProject
} AccFilterCellType;

typedef enum : NSUInteger {
    MeetingCellTypeEdit = 0,
    MeetingCellTypeCalendar,
    MeetingCellTypeAddRoom,
    MeetingCellTypeHeaderAdd,
    MeetingCellTypeUser,
    MeetingCellTypeAttach
} MeetingCellType;


typedef enum : NSUInteger {
    
    CS_STATUS_NEW = 0,
    CS_STATUS_APRROVED,
    CS_STATUS_REJECTED,
    CS_STATUS_SUBMITTED,
    CS_STATUS_PUBLISH
} CSStatus;

typedef enum : NSUInteger {
    E_STATUS_NEW = 0,
    E_STATUS_APPROVED,
    E_STATUS_SUBMITTED,
    E_STATUS_REJECTED
} EStatus;

typedef enum : NSUInteger {
    
    BS_STATUS_NEW = 0,
    BS_STATUS_APRROVED,
    BS_STATUS_REJECTED,
    BS_STATUS_SUBMITTED,
} BSStatus;

typedef enum : NSUInteger {
    RR_STATUS_NEW = 0,
    RR_STATUS_SUBMIT,
    RR_STATUS_REJECT,
    RR_STATUS_DOING,
    RR_STATUS_RESOLVE,
    RR_STATUS_CLOSE
} RRStatus;

typedef enum : NSUInteger {
    
    TYPE_CURRENCY_USD = 0,
    TYPE_CURRENCY_VND
} TYPE_CURENCY;

typedef enum : NSUInteger {
    
    TYPE_ACCOUNTING_CASH = 0,
    TYPE_ACCOUNTING_BANK,
    TYPE_ACCOUNTING_CHEQUE
} TYPE_ACCOUNTING;
typedef enum : NSUInteger {
    
    ACC_STATUS_NEW = 0,
    ACC_STATUS_APPROVED,
    ACC_STATUS_REJECTED,
    ACC_STATUS_SUBMITTED,
    ACC_STATUS_CLOSE
} ACCOUNTING_STATUS;

typedef enum : NSUInteger {
    
    VER_STATUS_ACTIVE = 0,
    VER_STATUS_RELEASED,
    VER_STATUS_ACCEPTED,
    VER_STATUS_REJECTED,
} VERSION_STATUS;

typedef enum : NSUInteger {
    CALENDAR_DAY = 0,
    CALENDAR_WEEK,
    CALENDAR_MONTH,
} CALENDAR_MOD;

typedef enum : NSUInteger {
    CSTypeTitle = 0,
    CSTypeCont,
    CSTypeTag,
    CSTypeAttachFile,
    CSTypeCreator,
    CSTypeReason
} CSType;

typedef enum : NSUInteger {
    ETitle = 0,
    EDesc,
    EPlace,
    EAddress,
    ELat,
    ELog,
    EAddInvitee,
    EEmail,
    ETime,
    EAttachFile,
    EImage,
    EAttachTodo,
    EAttachNote,
    EInvitees
} EType;

typedef enum : NSInteger{
    FilterModeDate = 0,
    FilterModeContent
}FilterMode;


typedef enum : NSUInteger{
    TypeShortcutGitoIconMyPage = 0,
    TypeShortcutGitoIconAllProject,
    TypeShortcutGitoIconCalendar,
    TypeShortcutGitoIconLogTime,
    TypeShortcutGitoIconNote,
    TypeShortcutGitoIconTodo,
    TypeShortcutGitoIconMeeting,
    TypeShortcutGitoIconReport,
    TypeShortcutGitoIconChat,
    TypeShortcutGitoIconEstate,
    TypeShortcutGitoIconCaseStudy,
    TypeShortcutGitoIconRecruitment,
    TypeShortcutGitoIconNotification,
    TypeShortcutGitoIconChecking,
    TypeShortcutGitoIconLeavingRegister,
    TypeShortcutGitoIconRoombooking,
    TypeShortcutGitoIconSurey,
    TypeShortcutGitoIconAccounting,
    TypeShortcutGitoIconSalary
}TypeShortcutGitoIcon;

typedef enum : NSUInteger {
    LogtimeStatus_New = 0,
    LogtimeStatus_Approved,
    LogtimeStatus_Rejected,
    LogtimeStatus_All
} LogtimeStatus;

typedef enum : NSUInteger {
    
    SHOW_BY_USER_LOGIN = 100,
    SHOW_BY_USER_SINGLE,
    SHOW_BY_ALL_USER,
    SHOW_BY_USER_LIST_IN_PROJECT
} USER_LIST;

// For Local Notification

typedef NS_ENUM(NSInteger, LNotificationType) {
    LNotificationTypeNone = 0,
    LNotificationTypeMeeting,
    LNotificationTypeTodo,
    LNotificationTypeRecruit
    
};

typedef enum : NSUInteger{
    StatusSalaryNew = 0,
    StatusSalaryApproved,
    StatusSalaryReject,
    StatusSalarySummited,
    StatusSalarySent,
}StatusSalary;

typedef enum : NSUInteger {
    StatusContractChangeNew = 0,
    StatusContractChangeApproved,
    StatusContractChangeReject,
    StatusContractChangeSubmited,
}StatusContractChange;

//Status for new, edit, readonly
typedef NS_ENUM(NSInteger, TypeViewControl){
    TypeViewControlNew = 0,
    TypeViewControlEdit,
    TypeViewControlReadOnly
};

// STATUS CANDIDATE
#define STATUS_NEW    0
#define STATUS_FAIL   1
#define STATUS_PASS   2
#define STATUS_ABSENT 3


//Todo + Note
typedef enum: NSInteger{
    FILTER_TYPE_ALL,
    FILTER_TYPE_MEETING,
    
}FILTER;

//TestCase

typedef enum : NSInteger {
    TCModeType = 0,
    TCModeComponent,
    TCModeScreen
} TCMode;


// For Header Add button
#define HeaderAdd(POS, IMG, TagId) \
    [self.vHeader.vTopBar.btn##POS setImage:[UIImage imageNamed:IMG]]; \
    [self.vHeader.vTopBar.btn##POS setTag:TagId];


#define MD(Val, Font, Clickable, ProjectId) [Utilities getMarkdownAttributedStringHTMLString:Val withFont:Font clickable:Clickable projectId:ProjectId]
#define MDAtt(Val, Font, Clickable, ProjectId) [Utilities getMarkdownAttributedString:Val withFont:Font clickable:Clickable projectId:ProjectId]
#define WrapHtml(Text, Font) [Utilities wrapHtmlText:Text withFont:Font]

#define ATT(Text, Dic) [[NSAttributedString alloc] initWithString:Text attributes:Dic]
#define CheckLastestVersion() [self performSelector:@selector(checkLastVersion) withObject:nil afterDelay:1]

#define L(A) [HLocalization textForKey:A]

#define RMsgW(Title, Txt) [RMessage showNotificationWithTitle:Title subtitle:Txt type:(RMessageTypeWarning) customTypeName:nil duration:10 callback:nil]
#define RMsgE(Title, Txt) [RMessage showNotificationWithTitle:Title subtitle:Txt type:(RMessageTypeError) customTypeName:nil duration:10 callback:nil]
#define RMsgS(Title, Txt) [RMessage showNotificationWithTitle:Title subtitle:Txt type:(RMessageTypeSuccess) customTypeName:nil duration:10 callback:nil]
#define RMsgC(Title, Txt) [RMessage showNotificationWithTitle:Title subtitle:Txt type:(RMessageTypeCustom) customTypeName:nil duration:10 callback:nil]
#define RMsg(Title, Txt) [RMessage showNotificationWithTitle:Title subtitle:Txt type:(RMessageTypeNormal) customTypeName:nil duration:10 callback:nil]


#define LoadingMoreView() [Utilities loadingMoreView]
#define LoadingMoreCell() [Utilities loadingMoreCell]

#define Pro_List_Fields \
@property (nonatomic, assign) NSInteger all; \
@property (nonatomic, assign) NSInteger open; \
@property (nonatomic, assign) NSInteger doing; \
@property (nonatomic, assign) NSInteger done; \
@property (nonatomic, assign) NSInteger closed; \
@property (nonatomic, assign) NSInteger pending; \
@property (nonatomic, assign) NSInteger rejected; \

#define Pro_List_Implement \
IN(all); \
IN(open); \
IN(doing); \
IN(done); \
IN(pending); \
IN(closed); \
IN(rejected);

#define Pro_List_Merge(intoA, fromB) \
intoA.all = fromB.all; \
intoA.open = fromB.open; \
intoA.doing = fromB.doing; \
intoA.done = fromB.done; \
intoA.pending = fromB.pending; \
intoA.closed = fromB.closed; \
intoA.rejected = fromB.rejected;

#define Pro_List_New_Fields \
@property (nonatomic, assign) NSInteger all; \
@property (nonatomic, assign) NSInteger newCount; \
@property (nonatomic, assign) NSInteger submitted; \
@property (nonatomic, assign) NSInteger approved; \
@property (nonatomic, assign) NSInteger closed; \
@property (nonatomic, assign) NSInteger rejected;

#define Pro_List_New_Implement \
IN(all); \
INK(newCount, @"new"); \
IN(submitted); \
IN(approved); \
IN(closed); \
IN(rejected);

#define Pro_List_New_Merge(intoA, fromB) \
intoA.all = fromB.all; \
intoA.newCount = fromB.newCount; \
intoA.submitted = fromB.submitted; \
intoA.approved = fromB.approved; \
intoA.closed = fromB.closed; \
intoA.rejected = fromB.rejected;


#define Pro_List_Money_Fields \
@property (nonatomic, assign) NSInteger total; \
@property (nonatomic, assign) NSInteger totalSubmit;

#define Pro_List_Money_Implement \
IN(total); \
IN(totalSubmit);

#define Pro_List_Money_Merge(intoA, fromB) \
intoA.total = fromB.total; \
intoA.totalSubmit = fromB.totalSubmit;

#define PerformAction(Object, Sel, Data) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
[Object performSelector:Sel withObject:Data]; \
_Pragma("clang diagnostic pop") \
} while (0)


#define PerformWithoutWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)
