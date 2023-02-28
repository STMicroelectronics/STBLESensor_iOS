//
//  ISEResultReadSyllable.m
//  IFlyMSCDemo
//
//  Created by 张剑 on 15/3/7.
//
//

#import "ISEResultReadSyllable.h"
#import "ISEResultTools.h"

@implementation ISEResultReadSyllable


-(instancetype)init{
    if(self=[super init]){
        self.category = @"read_syllable";
        self.language = @"cn";
    }
    return self;
}

-(NSString*) toString{
    NSString* buffer = [[NSString alloc] init];

    buffer=[buffer stringByAppendingFormat:@"[总体结果]\n"];
    buffer=[buffer stringByAppendingFormat:@"评测内容：%@\n" ,self.content];
    buffer=[buffer stringByAppendingFormat:@"朗读时长：%d\n",self.time_len];
    buffer=[buffer stringByAppendingFormat:@"总分：%f\n",self.total_score];
    buffer=[buffer stringByAppendingFormat:@"[朗读详情]：%@\n",[ISEResultTools formatDetailsForLanguageCN:self.sentences]];

    return buffer;
}

@end
