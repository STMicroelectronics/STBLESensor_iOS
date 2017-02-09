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

#import "STWeSUTools.h"
#import <AudioToolbox/AudioServices.h>
//#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>

#define TAG_NAME_CHAR_NUM 6

@implementation STWeSUTools



+(float)checkBoundsValue:(float)value min:(float)min max:(float)max {
    return value < min ? min : (value > max ? max : value);
}

+(void)alertWithForView:(UIViewController *)viewController title:(NSString *)title message:(NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }];
    [alertController addAction:ok];
    [viewController presentViewController:alertController animated:YES completion:nil];
}


+(void)optionsAlert:(UIViewController *)viewController title:(NSString *)title message:(NSString *)message array:(NSArray *)array simple:(BOOL)simple handler:(void (^ __nullable)(NSString *selection))handler {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    if (simple) {
        for(NSString *str in array) {
            UIAlertAction *item = [UIAlertAction actionWithTitle:str style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                handler(str);
            }];
            [alertController addAction:item];
        }
    }
    else {
        for(NSArray *textValueArray in array) {
            assert(textValueArray && textValueArray.count >= 1);
            
            NSString *text = textValueArray[0];
            NSString *value = textValueArray[textValueArray.count > 1 ? 1 : 0];
            UIAlertAction *item = [UIAlertAction actionWithTitle:text style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                handler(value);
            }];
            [alertController addAction:item];
        }
    }
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        handler(OPTION_CANCEL);
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }];

    [alertController addAction:cancel];
    [viewController presentViewController:alertController animated:YES completion:nil];
}

+(void)playSound:(NSString *)what {
    if ([what isEqualToString:@"vibration"] && UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        AudioServicesPlaySystemSoundWithCompletion(kSystemSoundID_Vibrate, nil);
    }
}

//+(void)torchStatusOn:(BOOL)on {
//    // check if flashlight available
//    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
//    if (captureDeviceClass != nil) {
//        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
//        if ([device hasTorch] && [device hasFlash]){
//            
//            [device lockForConfiguration:nil];
//            if (on) {
//                [device setTorchMode:AVCaptureTorchModeOn];
//                [device setFlashMode:AVCaptureFlashModeOn];
//                //torchIsOn = YES; //define as a variable/property if you need to know status
//            } else {
//                [device setTorchMode:AVCaptureTorchModeOff];
//                [device setFlashMode:AVCaptureFlashModeOff];
//                //torchIsOn = NO;
//            }
//            [device unlockForConfiguration];
//        }
//    }
//}
+(UIImage *)imageWithView:(UIView *)view {
    //Get the size of the screen
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    //Create a bitmap-based graphics context and make
    //it the current context passing in the screen size
    UIGraphicsBeginImageContext(screenRect.size);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [[UIColor blackColor] set];
    CGContextFillRect(ctx, screenRect);
    
    //render the receiver and its sublayers into the specified context
    //choose a view or use the window to get a screenshot of the
    //entire device
    [view.layer renderInContext:ctx];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    //End the bitmap-based graphics context
    UIGraphicsEndImageContext();
    
    //Save UIImage to camera roll
    //UIImageWriteToSavedPhotosAlbum(newImage, nil, nil, nil);
    
    return newImage;
}

@end
