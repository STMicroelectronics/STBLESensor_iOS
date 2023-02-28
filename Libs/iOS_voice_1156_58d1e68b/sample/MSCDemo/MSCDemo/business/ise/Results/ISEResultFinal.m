//
//  ISEResultFinal.m
//  IFlyMSCDemo
//
//  Created by 张剑 on 15/3/7.
//
//

#import "ISEResultFinal.h"

@implementation ISEResultFinal

-(NSString*) toString{
    NSString* resultString=[NSString stringWithFormat:@"返回值：%d，总分：%f",self.ret,self.total_score];
    return resultString;
}

@end
