//
//  ISEResultSyll.h
//  IFlyMSCDemo
//
//  Created by 张剑 on 15/3/6.
//
//

#import <Foundation/Foundation.h>

/**
 *  音节，对应于结果xml中的Syll标签
 */
@interface ISEResultSyll : NSObject

/**
 * 开始帧位置，每帧相当于10ms
 */
@property(nonatomic, assign)int beg_pos;

/**
 * 结束帧位置
 */
@property(nonatomic, assign)int end_pos;

/**
 * 音节内容
 */
@property(nonatomic, strong)NSString* content;

/**
 * 拼音（cn），数字代表声调，5表示轻声，如fen1
 */
@property(nonatomic, strong)NSString* symbol;

/**
 * 增漏读信息：0（正确），16（漏读），32（增读），64（回读），128（替换）
 */
@property(nonatomic, assign)int dp_message;

/**
 * 时长（单位：帧，每帧相当于10ms）（cn）
 */
@property(nonatomic, assign)int time_len;

/**
 * Syll包含的音节
 */
@property(nonatomic, strong)NSMutableArray* phones;

/**
 * 获取音节的标准音标（en）
 *
 * @return 标准音标
 */
- (NSString*) getStdSymbol;

@end
