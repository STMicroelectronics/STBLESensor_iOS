//
//  ISEResult.h
//  IFlyMSCDemo
//
//  Created by 张剑 on 15/3/6.
//
//

#import <Foundation/Foundation.h>

/**
 *  评测结果
 */
@interface ISEResult : NSObject

/**
 * 评测语种：en（英文）、cn（中文）
 */
@property(nonatomic,strong)NSString* language;

/**
 * 评测种类：read_syllable（cn单字）、read_word（词语）、read_sentence（句子）
 */
@property(nonatomic,strong)NSString* category;

/**
 * 开始帧位置，每帧相当于10ms
 */
@property(nonatomic,assign)int beg_pos;

/**
 * 结束帧位置
 */
@property(nonatomic,assign)int end_pos;

/**
 * 评测内容
 */
@property(nonatomic,strong)NSString* content;

/**
 * 总得分
 */
@property(nonatomic,assign)float total_score;

/**
 * 时长（cn）
 */
@property(nonatomic,assign)int time_len;

/**
 * 异常信息（en）
 */
@property(nonatomic,strong)NSString* except_info;

/**
 * 是否乱读（cn）
 */
@property(nonatomic,assign)BOOL is_rejected;

/**
 * xml结果中的sentence标签
 */
@property(nonatomic,strong)NSMutableArray* sentences;

-(NSString*) toString;

@end
