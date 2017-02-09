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

#import "STWeSUSettingsDataReadViewController.h"
#define TAG_BASE_SWITCH     10
#define TAG_BASE_BUTTON     20
#define TAG_OK_BUTTON       100
#define TAG_CANCEL_BUTTON   99

@interface STWeSUSettingsDataReadViewController ()

@end

@implementation STWeSUSettingsDataReadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self sync];
    
    UIView *v = self.alertView;
    // border radius
    [v.layer setCornerRadius:15.0f];
    
//    // border
//    [v.layer setBorderColor:[UIColor lightGrayColor].CGColor];
//    [v.layer setBorderWidth:1.5f];
    
//    // drop shadow
//    [v.layer setShadowColor:[UIColor blackColor].CGColor];
//    [v.layer setShadowOpacity:0.8];
//    [v.layer setShadowRadius:3.0];
//    [v.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
    
    //update the buttons
    UIButton *uibutton = nil;
    UISwitch *uiswitch = nil;
    BOOL used = NO;
    assert(self.options);
    for(NSInteger idx = 0; idx < OPTION_MAX; idx++) {
        used = idx < self.options.count;
        uibutton = (UIButton *)[self.alertView viewWithTag:(TAG_BASE_BUTTON + idx)];
        if (uibutton) {
            [uibutton setHidden:!used];
            if (used) { //set the text
                [uibutton setTitle: self.options[idx][OPTION_TEXT_POS] forState: UIControlStateNormal];
            }
        }
        uiswitch = (UISwitch *)[self.alertView viewWithTag:(TAG_BASE_SWITCH + idx)];
        if (uiswitch) {
            [uiswitch setHidden:!used];
        }
    }
    
    if (self.titleValue) {
        self.titleLabel.text = self.titleValue;
    }
    if (self.messageValue) {
        self.messageLabel.text = self.messageValue;
    }
    if (self.backgroundImage) {
        self.backgroundImageView.image = self.backgroundImage;
    }
    self.value = _value;}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

}
- (void)setValue:(NSInteger)value {
    _value = value;
     NSString *str = [NSString stringWithFormat:@"%04X", (int)self.value];
    if ([NSThread isMainThread]) {
        self.valueLabel.text = str;
    }
    else {
        dispatch_async(dispatch_get_main_queue(),^{
            self.valueLabel.text = str;
        });
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)switchAction:(UISwitch *)sender {
    NSLog(@"1:Switch %@ 0x%04X", @(sender.tag), (int)self.value);
    NSInteger idx = sender.tag-TAG_BASE_SWITCH;
    NSInteger mask;
    if (idx >= 0 && idx<=7) {
        mask = [self.options[idx][OPTION_VALUE_POS] integerValue];
        if (sender.on) {
            self.value |= mask;
        }
        else {
            self.value &= ~mask;
        }
    }
    NSLog(@"2:Switch %@ 0x%04X", @(sender.tag), (int)self.value);
}
- (IBAction)buttonAction:(UIButton *)sender {
    NSLog(@"Button %@", @(sender.tag));
    NSInteger idx = sender.tag-TAG_BASE_BUTTON;
    UISwitch *ctrlswitch = [self.alertView viewWithTag:(TAG_BASE_SWITCH+idx)];
    if (ctrlswitch) {
        //perform a toggle
        [ctrlswitch setOn:!ctrlswitch.isOn];
        [self switchAction:ctrlswitch];
    }
}
-(void)sync {
    UISwitch *ctrlswitch = nil;
    NSInteger mask;
    BOOL on;
    for(int idx = 0; idx < MIN(self.options.count, OPTION_MAX); idx++) {
        mask =[self.options[idx][OPTION_VALUE_POS] integerValue];
        on = (self.value & mask) > 0;
        ctrlswitch = (UISwitch *)[self.alertView viewWithTag:(TAG_BASE_SWITCH+idx)];
        if (ctrlswitch) {
            [ctrlswitch setOn:on];
        }
    }
}
- (IBAction)feedbackAction:(UIButton *)sender {
    if (self.delegate) {
        [self.delegate resultDataReadViewController:self button:(sender.tag == TAG_OK_BUTTON) value:self.value];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
