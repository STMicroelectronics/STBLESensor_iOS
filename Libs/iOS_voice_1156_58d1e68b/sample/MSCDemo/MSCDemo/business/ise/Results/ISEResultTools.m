//
//  ISEResultTools.m
//  IFlyMSCDemo
//
//  Created by 张剑 on 15/3/6.
//
//

#import "ISEResultTools.h"
#import "ISEResultPhone.h"
#import "ISEResultSyll.h"
#import "ISEResultWord.h"
#import "ISEResultSentence.h"

@implementation ISEResultTools


+(NSString*) toStdSymbol:(NSString*) symbol{
    
    if(!symbol){
        return symbol;
    }
    
    /**
     * 讯飞音标-标准音标映射表（en）
     */
    static NSDictionary* _gISEResultPhoneHashDic;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _gISEResultPhoneHashDic=@{
                                  @"aa" : @"ɑ:",
                                  @"oo" : @"ɔ",
                                  @"ae" : @"æ",
                                  @"ah" : @"ʌ",
                                  @"ao" : @"ɔ:",
                                  @"aw" : @"aʊ",
                                  @"ax" : @"ə",
                                  @"ay" : @"aɪ",
                                  @"eh" : @"e",
                                  @"er" : @"ə:",
                                  @"ey" : @"eɪ",
                                  @"ih" : @"ɪ",
                                  @"iy" : @"i:",
                                  @"ow" : @"əʊ",
                                  @"oy" : @"ɔɪ",
                                  @"uh" : @"ʊ",
                                  @"uw" : @"ʊ:",
                                  @"ch" : @"tʃ",
                                  @"dh" : @"ð",
                                  @"hh" : @"h",
                                  @"jh" : @"dʒ",
                                  @"ng" : @"ŋ",
                                  @"sh" : @"ʃ",
                                  @"th" : @"θ",
                                  @"zh" : @"ʒ",
                                  @"y" : @"j",
                                  @"d" : @"d",
                                  @"k" : @"k",
                                  @"l" : @"l",
                                  @"m" : @"m",
                                  @"n" : @"n",
                                  @"b" : @"b",
                                  @"f" : @"f",
                                  @"g" : @"g",
                                  @"p" : @"p",
                                  @"r" : @"r",
                                  @"s" : @"s",
                                  @"t" : @"t",
                                  @"v" : @"v",
                                  @"w" : @"w",
                                  @"z" : @"z",
                                  @"ar" : @"eə",
                                  @"ir" : @"iə",
                                  @"ur" : @"ʊə",
                                  @"tr" : @"tr",
                                  @"dr" : @"dr",
                                  @"ts" : @"ts",
                                  @"dz" : @"dz"
                                  };

    });
    
    NSString* stdsymbol=[_gISEResultPhoneHashDic objectForKey:symbol];
    return stdsymbol?stdsymbol:symbol;
   
}


NSString* const KCIFlyResultNormal=@"正常";
NSString* const KCIFlyResultMiss=@"漏读";
NSString* const KCIFlyResultAdd=@"增读";
NSString* const KCIFlyResultRepeat=@"回读";
NSString* const KCIFlyResultReplace=@"替换";

NSString* const KCIFlyResultNoise=@"噪音";
NSString* const KCIFlyResultMute=@"静音";

+ (NSString*)translateDpMessageInfo:(int)dpMessage {
    
    static NSDictionary* _gISEResultDpMessageHashDic;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _gISEResultDpMessageHashDic=@{
                                      @0 : KCIFlyResultNormal,
                                      @16 : KCIFlyResultMiss,
                                      @32 : KCIFlyResultAdd,
                                      @64 : KCIFlyResultRepeat,
                                      @128 : KCIFlyResultReplace
                                };
    });

    NSString* transDpMessage=[_gISEResultDpMessageHashDic objectForKey:[NSNumber numberWithInt:dpMessage]];
    return transDpMessage;
}

+ (NSString*)translateContentInfo:(NSString*) content {
    
    if(!content){
        return nil;
    }

    static NSDictionary* _gISEResultContentHashDic;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _gISEResultContentHashDic=@{
                                      @"sil"  : KCIFlyResultMute,
                                      @"silv" : KCIFlyResultMute,
                                      @"fil"  : KCIFlyResultNoise
                                      };
    });
    
    NSString* transContent=[_gISEResultContentHashDic objectForKey:content];
    return transContent?transContent:content;
}


/**
 * 将汉语评测详情按格式输出
 *
 * @param sentences 句子
 * @return 汉语评测详情
 */
+ (NSString*)formatDetailsForLanguageCN:(NSArray*) sentences {
    NSString* buffer =[[NSString alloc] init];
    if (!sentences) {
        return nil;
    }
    
    for (ISEResultSentence* sentence in sentences ) {
        
        if (nil == sentence.words) {
            continue;
        }
        
        for (ISEResultWord* word in sentence.words) {
            NSString* wContent=[ISEResultTools translateContentInfo:word.content];
            if ([KCIFlyResultNoise isEqualToString:wContent] || [KCIFlyResultMute isEqualToString:wContent]){
                continue;
            }
            buffer=[buffer stringByAppendingFormat:@"\n词语[%@] %@  时长：%d",wContent,word.symbol,word.time_len];
            
            if (!word.sylls) {
                continue;
            }
            
            for (ISEResultSyll* syll in word.sylls) {
                NSString* syContent=[ISEResultTools translateContentInfo:[syll content]];
                if ([KCIFlyResultNoise isEqualToString:syContent] || [KCIFlyResultMute isEqualToString:syContent]){
                    continue;
                }
                
                buffer=[buffer stringByAppendingFormat:@"\n└音节[%@] %@  时长：%d",syContent,syll.symbol,syll.time_len];
                if (!syll.phones) {
                    continue;
                }
                
                for (ISEResultPhone* phone in syll.phones) {
                    NSString* pContent=[ISEResultTools translateContentInfo:[phone content]];
                    NSString* pDpMessage=[ISEResultTools translateDpMessageInfo:phone.dp_message];
                    buffer=[buffer stringByAppendingFormat:@"\n\t└音素[%@] 时长：%d 朗读：%@",pContent,phone.time_len,pDpMessage];
                }
                
            }
            buffer=[buffer stringByAppendingString:@"\n"];
        }
    }
    return buffer;
    
}

/**
 * 将英语评测详情按格式输出
 *
 * @param sentences 句子
 * @return 英语评测详情
 */
+ (NSString*)formatDetailsForLanguageEN:(NSArray*) sentences {
    NSString* buffer =[[NSString alloc] init];
    if (!sentences) {
        return nil;
    }
    
    for (ISEResultSentence* sentence in sentences ) {
        NSString* sContent=[ISEResultTools translateContentInfo:sentence.content];
        if ([KCIFlyResultNoise isEqualToString:sContent] || [KCIFlyResultMute isEqualToString:sContent]){
            continue;
        }
        
        if (nil == sentence.words) {
            continue;
        }
        for (ISEResultWord* word in sentence.words) {
            NSString* wContent=[ISEResultTools translateContentInfo:word.content];
            NSString* wDpMessage=[ISEResultTools translateDpMessageInfo:word.dp_message];
            if ([KCIFlyResultNoise isEqualToString:wContent] || [KCIFlyResultMute isEqualToString:wContent]){
                continue;
            }
            buffer=[buffer stringByAppendingFormat:@"\n单词[%@] 朗读：%@  得分：%f",wContent,wDpMessage,word.total_score];
            
            if (!word.sylls) {
                buffer=[buffer stringByAppendingString:@"\n"];
                continue;
            }
            
            for (ISEResultSyll* syll in word.sylls) {
                NSString* syContent=[ISEResultTools translateContentInfo:[syll getStdSymbol]];
                buffer=[buffer stringByAppendingFormat:@"\n└音节[%@] ",syContent];
                if (!syll.phones) {
                    continue;
                }
                
                for (ISEResultPhone* phone in syll.phones) {
                    NSString* pContent=[ISEResultTools translateContentInfo:[phone getStdSymbol]];
                    NSString* pDpMessage=[ISEResultTools translateDpMessageInfo:phone.dp_message];
                    buffer=[buffer stringByAppendingFormat:@"\n\t└音素[%@] 朗读：%@",pContent,pDpMessage];
                }
                
            }
            buffer=[buffer stringByAppendingString:@"\n"];
        }
    }
    return buffer;
}

@end
