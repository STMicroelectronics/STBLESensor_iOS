//
//  ISEResultSentence.h
//  IFlyMSCDemo
//
//  Created by 张剑 on 15/3/6.
//
//

#import <Foundation/Foundation.h>

/**
 *  句子，对应于xml结果中的sentence标签
 */
@interface ISEResultSentence : NSObject

/**
 * 开始帧位置，每帧相当于10ms
 */
@property(nonatomic, assign)int beg_pos;

/**
 * 结束帧位置
 */
@property(nonatomic, assign)int end_pos;

/**
 * 句子内容
 */
@property(nonatomic, strong)NSString* content;

/**
 * 总得分
 */
@property(nonatomic, assign)float total_score;

/**
 * 时长（单位：帧，每帧相当于10ms）（cn）
 */
@property(nonatomic, assign)int time_len;

/**
 * 句子的索引（en）
 */
@property(nonatomic, assign)int index;

/**
 * 单词数（en）
 */
@property(nonatomic, assign)int word_count;

/**
 * sentence包括的word
 */
@property(nonatomic, strong)NSMutableArray* words;

@end
