/*******************************************************************************
 * COPYRIGHT(c) 2015 STMicroelectronics
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *   1. Redistributions of source code must retain the above copyright notice,
 *      this list of conditions and the following disclaimer.
 *   2. Redistributions in binary form must reproduce the above copyright notice,
 *      this list of conditions and the following disclaimer in the documentation
 *      and/or other materials provided with the distribution.
 *   3. Neither the name of STMicroelectronics nor the names of its contributors
 *      may be used to endorse or promote products derived from this software
 *      without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 ******************************************************************************/

#import "BlueSTSDKFeatureField.h"

@implementation BlueSTSDKFeatureField

+(instancetype)createWithName:(NSString *)name
                                  unit:(NSString *)unit
                                  type:(BlueSTSDKFeatureFieldType)type
                                   min:(NSNumber *)min
                                   max:(NSNumber *)max{
    
    return [[BlueSTSDKFeatureField alloc] initWithName:name
                                                unit:unit
                                                type:type
                                                 min:min
                                                 max:max];
}


-(instancetype) initWithName:(NSString *)name
              unit:(NSString*)unit
              type:(BlueSTSDKFeatureFieldType)type
               min:(NSNumber*)min
               max:(NSNumber*)max{
    _name=name;
    _unit=unit;
    _type=type;
    _min=min;
    _max=max;
    return self;
}

-(instancetype) initWithName:(NSString *)name
              unit:(NSString*)unit
              type:(BlueSTSDKFeatureFieldType)type
               min:(NSNumber*)min
               max:(NSNumber*)max
              plotIt:(NSString *)plotIt{
    _name=name;
    _unit=unit;
    _type=type;
    _min=min;
    _max=max;
    _plotIt=plotIt;
    return self;
}


- (BOOL)hasUnit {
    if(_unit!=nil)
        return _unit.length>0;
    return false;
}


@end
