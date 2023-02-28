//
//  ISEParams.h
//  MSCDemo_UI
//
//  Created by 张剑 on 15/2/5.
//
//

#import <Foundation/Foundation.h>

#pragma mark - const values

FOUNDATION_EXPORT NSString* const KCLanguageTitle;
FOUNDATION_EXPORT NSString* const KCLanguageShowZHCN;
FOUNDATION_EXPORT NSString* const KCLanguageShowENUS;
FOUNDATION_EXPORT NSString* const KCLanguageZHCN;
FOUNDATION_EXPORT NSString* const KCLanguageENUS;

FOUNDATION_EXPORT NSString* const KCCategoryTitle;
FOUNDATION_EXPORT NSString* const KCCategoryShowSentence;
FOUNDATION_EXPORT NSString* const KCCategoryShowWord;
FOUNDATION_EXPORT NSString* const KCCategoryShowSyllable;
FOUNDATION_EXPORT NSString* const KCCategorySentence;
FOUNDATION_EXPORT NSString* const KCCategoryWord;
FOUNDATION_EXPORT NSString* const KCCategorySyllable;

FOUNDATION_EXPORT NSString* const KCRstLevelTitle;
FOUNDATION_EXPORT NSString* const KCRstLevelPlain;
FOUNDATION_EXPORT NSString* const KCRstLevelComplete;

FOUNDATION_EXPORT NSString* const KCBOSTitle;
FOUNDATION_EXPORT NSString* const KCBOSDefault;
FOUNDATION_EXPORT NSString* const KCEOSTitle;
FOUNDATION_EXPORT NSString* const KCEOSDefault;
FOUNDATION_EXPORT NSString* const KCTimeoutTitle;
FOUNDATION_EXPORT NSString* const KCTimeoutDefault;

FOUNDATION_EXPORT NSString* const KCSourceMIC;
FOUNDATION_EXPORT NSString* const KCSourceSTREAM;
FOUNDATION_EXPORT NSString* const KCSourceTitle;

#pragma mark -

@interface ISEParams : NSObject

@property (nonatomic, strong) NSString *language;
@property (nonatomic, strong) NSString *languageShow;
@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) NSString *categoryShow;
@property (nonatomic, strong) NSString *rstLevel;
@property (nonatomic, strong) NSString *bos;
@property (nonatomic, strong) NSString *eos;
@property (nonatomic, strong) NSString *timeout;
@property (nonatomic, strong) NSString *audioSource;

- (NSString *)toString;
- (void)setDefaultParams;
- (void)toUserDefaults;
+ (ISEParams *)fromUserDefaults;

@end
