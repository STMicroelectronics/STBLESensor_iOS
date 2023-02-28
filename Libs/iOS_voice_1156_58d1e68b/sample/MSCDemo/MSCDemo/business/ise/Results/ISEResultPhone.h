//
//  ISEResultPhone.h
//  IFlyMSCDemo
//
//  Created by 张剑 on 15/3/6.
//
//

#import <Foundation/Foundation.h>

/**
 *  音素，对应于xml结果中的Phone标签
 */
@interface ISEResultPhone : NSObject

/**
 * 开始帧位置，每帧相当于10ms
 */
@property(nonatomic, assign)int beg_pos;

/**
 * 结束帧位置
 */
@property(nonatomic, assign)int end_pos;

/**
 * 音素内容
 */
@property(nonatomic, strong)NSString* content;

/**
 * 增漏读信息：0（正确），16（漏读），32（增读），64（回读），128（替换）
 */
@property(nonatomic, assign)int dp_message;

/**
 * 时长（单位：帧，每帧相当于10ms）（cn）
 */
@property(nonatomic, assign)int time_len;

/**
 * 得到content对应的标准音标（en）
 */
- (NSString*) getStdSymbol;


@end
