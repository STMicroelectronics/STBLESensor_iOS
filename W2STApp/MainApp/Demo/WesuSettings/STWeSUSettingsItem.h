/*
 * Copyright (c) 2017  STMicroelectronics – All rights reserved
 * The STMicroelectronics corporate logo is a trademark of STMicroelectronics
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, this list of conditions
 *   and the following disclaimer.
 *
 * - Redistributions in binary form must reproduce the above copyright notice, this list of
 *   conditions and the following disclaimer in the documentation and/or other materials provided
 *   with the distribution.
 *
 * - Neither the name nor trademarks of STMicroelectronics International N.V. nor any other
 *   STMicroelectronics company nor the names of its contributors may be used to endorse or
 *   promote products derived from this software without specific prior written permission.
 *
 * - All of the icons, pictures, logos and other images that are provided with the source code
 *   in a directory whose title begins with st_images may only be used for internal purposes and
 *   shall not be redistributed to any third party or modified in any way.
 *
 * - Any redistributions in binary form shall not include the capability to display any of the
 *   icons, pictures, logos and other images that are provided with the source code in a directory
 *   whose title begins with st_images.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER
 * OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY
 * OF SUCH DAMAGE.
 */

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "BlueSTSDK/BlueSTSDKConfigControl.h"
#import "BlueSTSDK/BlueSTSDKWeSURegisterDefines.h"

#define TARGET_P BlueSTSDK_REGISTER_TARGET_PERSISTENT
#define TARGET_S BlueSTSDK_REGISTER_TARGET_SESSION
#define TARGET_DONTCARE BlueSTSDK_REGISTER_TARGET_SESSION

#define MAKE_ITEMN(_ident_,_target_,_regName_,_title_,_details_) [STWeSUSettingsItem itemWithIdent:_ident_ target:_target_ regName:_regName_ title:_title_ details:_details_ type:STWeSUSettingsItemTypeNormal height:0]

#define MAKE_ITEMNH(_ident_,_target_,_regName_,_title_,_details_, _height_) [STWeSUSettingsItem itemWithIdent:_ident_ target:_target_ regName:_regName_ title:_title_ details:_details_ type:STWeSUSettingsItemTypeNormal height:_height_]
#define MAKE_ITEMSH(_ident_,_target_,_regName_,_title_,_details_, _height_) [STWeSUSettingsItem itemWithIdent:_ident_ target:_target_ regName:_regName_ title:_title_ details:_details_ type:STWeSUSettingsItemTypeSpecial height:_height_]

#define MAKE_ITEMF(_ident_,_target_,_title_,_details_) [STWeSUSettingsItem itemWithIdent:_ident_ target:_target_ regName:BlueSTSDK_REGISTER_NAME_NONE title:_title_ details:_details_ type:STWeSUSettingsItemTypeFolder height:0]

#define TAKE_SECTION(_settings_, _section_) ((STWeSUSettingsSection *)_settings_[_section_])
#define TAKE_ITEM(_settings_, _section_, _index_) ((STWeSUSettingsItem *) ((STWeSUSettingsSection *)_settings_[_section_]).items[_index_])

#define HEIGHT_DEFAULT 55

typedef NS_ENUM(NSInteger, STWeSUSettingsItemType){
    STWeSUSettingsItemTypeNormal    =0x01,
    STWeSUSettingsItemTypeSpecial   =0x02,
    STWeSUSettingsItemTypeFolder    =0x03,
};

@interface STWeSUSettingsItem : NSObject

@property (retain, readonly) NSNumber *ident;
@property (assign, readonly) STWeSUSettingsItemType type;
@property (assign, nonatomic, readonly) BlueSTSDKRegisterTarget_e target;
@property (assign, nonatomic, readonly) BlueSTSDKWeSURegisterName_e regName;
@property (retain, readonly) NSString *title;
@property (retain, readonly) NSString *details;
@property (assign, nonatomic) CGFloat height;
@property (retain) NSString *text;
@property (retain) NSString *valueA;
@property (retain) NSIndexPath *indexPath;

+(instancetype)itemWithIdent:(NSNumber *)ident target:(BlueSTSDKRegisterTarget_e)target regName:(BlueSTSDKWeSURegisterName_e)regName title:(NSString *)title details:(NSString *)details type:(STWeSUSettingsItemType)type height:(CGFloat)height;
-(instancetype)initWithIdent:(NSNumber *)ident target:(BlueSTSDKRegisterTarget_e)target regName:(BlueSTSDKWeSURegisterName_e)regName title:(NSString *)title details:(NSString *)details type:(STWeSUSettingsItemType)type height:(CGFloat)height;
@end

@interface STWeSUSettingsSection : NSObject

@property (retain, readonly) NSString *title;
@property (retain) NSMutableArray *items;

+(instancetype)sectionWithTitle:(NSString *)title;
+(instancetype)sectionWithTitle:(NSString *)title items:(NSArray *)items;
-(instancetype)initWithTitle:(NSString *)title items:(NSArray *)items;

@end
