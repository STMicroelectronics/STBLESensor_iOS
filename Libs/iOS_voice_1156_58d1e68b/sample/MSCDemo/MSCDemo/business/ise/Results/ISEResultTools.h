//
//  ISEResultTools.h
//  IFlyMSCDemo
//
//  Created by 张剑 on 15/3/6.
//
//

#import <Foundation/Foundation.h>


FOUNDATION_EXPORT NSString* const KCIFlyResultNormal;
FOUNDATION_EXPORT NSString* const KCIFlyResultMiss;
FOUNDATION_EXPORT NSString* const KCIFlyResultAdd;
FOUNDATION_EXPORT NSString* const KCIFlyResultRepeat;
FOUNDATION_EXPORT NSString* const KCIFlyResultReplace;

FOUNDATION_EXPORT NSString* const KCIFlyResultNoise;
FOUNDATION_EXPORT NSString* const KCIFlyResultMute;


@interface ISEResultTools : NSObject

/*!
 *  得到key对应的标准音标
 *
 *  @param symbol 音标
 *
 *  @return key对应的标准音标,未有标准音标返回key
 */
+(NSString*) toStdSymbol:(NSString*) symbol;


/*!
 *  将dpMessage映射为输出结果
 *
 *  @param dpMessage dpMessage
 *
 *  @return 转换后的dpMessage
 */
+ (NSString*)translateDpMessageInfo:(int)dpMessage;

/*!
 *  将content映射为输出结果
 *
 *  @param content content
 *
 *  @return 转换后的content
 */
+ (NSString*)translateContentInfo:(NSString*) content;


/**
 * 将汉语评测详情按格式输出
 *
 * @param sentences 句子
 * @return 汉语评测详情
 */
+ (NSString*)formatDetailsForLanguageCN:(NSArray*) sentences ;

/**
 * 将英语评测详情按格式输出
 *
 * @param sentences 句子
 * @return 英语评测详情
 */
+ (NSString*)formatDetailsForLanguageEN:(NSArray*) sentences ;

@end
