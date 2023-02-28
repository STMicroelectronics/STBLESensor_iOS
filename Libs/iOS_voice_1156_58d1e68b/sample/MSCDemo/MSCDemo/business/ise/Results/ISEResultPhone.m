//
//  ISEResultPhone.m
//  IFlyMSCDemo
//
//  Created by 张剑 on 15/3/6.
//
//

#import "ISEResultPhone.h"
#import "ISEResultTools.h"

@implementation ISEResultPhone

/**
 * 得到content对应的标准音标（en）
 */
- (NSString*) getStdSymbol{
    
    if(self.content){
        NSString* stdSymbol=[ISEResultTools toStdSymbol:self.content];
        return stdSymbol?stdSymbol:self.content;
    }
    
    return self.content;
}

@end
