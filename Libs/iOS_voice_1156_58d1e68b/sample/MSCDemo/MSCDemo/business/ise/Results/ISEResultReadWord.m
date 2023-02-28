//
//  ISEResultReadWord.m
//  IFlyMSCDemo
//
//  Created by 张剑 on 15/3/7.
//
//

#import "ISEResultReadWord.h"
#import "ISEResultTools.h"

@implementation ISEResultReadWord

-(instancetype)init{
    if(self=[super init]){
        self.category=@"read_word";
    }
    return self;
}

-(NSString*) toString{
    NSString* buffer = [[NSString alloc] init];
    
    if ([@"cn" isEqualToString:self.language]) {
        buffer=[buffer stringByAppendingFormat:@"[总体结果]\n"];
        buffer=[buffer stringByAppendingFormat:@"评测内容：%@\n" ,self.content];
        buffer=[buffer stringByAppendingFormat:@"朗读时长：%d\n",self.time_len];
        buffer=[buffer stringByAppendingFormat:@"总分：%f\n",self.total_score];
        buffer=[buffer stringByAppendingFormat:@"[朗读详情]：%@\n",[ISEResultTools formatDetailsForLanguageCN:self.sentences]];
        
    } else {
        if (self.is_rejected) {
            buffer=[buffer stringByAppendingFormat:@"检测到乱读，"];
            
            //except_info代码说明详见《语音评测参数、结果说明文档》
            buffer=[buffer stringByAppendingFormat:@"except_info:%@\n\n",self.except_info];
        }
        
        buffer=[buffer stringByAppendingFormat:@"[总体结果]\n"];
        buffer=[buffer stringByAppendingFormat:@"评测内容：%@\n",self.content];
//        buffer=[buffer stringByAppendingFormat:@"朗读时长：%d\n",self.time_len];
        buffer=[buffer stringByAppendingFormat:@"总分：%f\n",self.total_score];
        buffer=[buffer stringByAppendingFormat:@"[朗读详情]：%@\n",[ISEResultTools formatDetailsForLanguageEN:self.sentences]];
    }
    
    return buffer;
}

@end
