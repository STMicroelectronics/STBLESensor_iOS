//
//  ISEResultXmlParser.h
//  IFlyMSCDemo
//
//  Created by 张剑 on 15/3/6.
//
//

#import <Foundation/Foundation.h>

@class ISEResult;

@protocol ISEResultXmlParserDelegate <NSObject>

-(void)onISEResultXmlParser:(NSXMLParser *)parser Error:(NSError*)error;
-(void)onISEResultXmlParserResult:(ISEResult*)result;

@end

@interface ISEResultXmlParser : NSObject <NSXMLParserDelegate>

@property (nonatomic, weak) id <ISEResultXmlParserDelegate> delegate;

/*!
 *  解析评测xml格式结果
 *
 *  @param xml xml内容
 */
- (void)parserXml:(NSString*) xml;

@end
