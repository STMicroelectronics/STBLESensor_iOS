//
//  ISEResultWord.h
//  IFlyMSCDemo
//
//  Created by 张剑 on 15/3/6.
//
//

#import <Foundation/Foundation.h>

/**
 *  单词，对应于结果xml中的word标签
 */
@interface ISEResultWord : NSObject

/**
 * 开始帧位置，每帧相当于10ms
 */
@property(nonatomic, assign)int beg_pos;

/**
 * 结束帧位置
 */
@property(nonatomic, assign)int end_pos;

/**
 * 单词内容
 */
@property(nonatomic, strong)NSString* content;

/**
 * 增漏读信息：0（正确），16（漏读），32（增读），64（回读），128（替换）
 */
@property(nonatomic, assign)int dp_message;

/**
 * 单词在全篇索引（en）
 */
@property(nonatomic, assign)int global_index;

/**
 * 单词在句子中的索引（en）
 */
@property(nonatomic, assign)int index;

/**
 * 拼音（cn），数字代表声调，5表示轻声，如fen1
 */
@property(nonatomic, strong)NSString* symbol;

/**
 * 时长（单位：帧，每帧相当于10ms）（cn）
 */
@property(nonatomic, assign)int time_len;

/**
 * 单词得分（en）
 */
@property(nonatomic, assign)float total_score;

/**
 * Word包含的Syll
 */
@property(nonatomic, strong)NSMutableArray* sylls;

@end
