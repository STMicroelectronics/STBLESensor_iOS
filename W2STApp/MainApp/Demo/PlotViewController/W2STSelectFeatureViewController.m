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

#import "W2STSelectFeatureViewController.h"

@interface W2STSelectFeatureViewController ()<UIPickerViewDataSource,
UIPickerViewDelegate>

@end

@implementation W2STSelectFeatureViewController{

    bool mFeatureSelected;
    NSInteger mSelectedFeature;
    NSInteger mSelectedSample;
    
}

//color used for plot the data lines
static NSArray *sPossibleSamplingStr;
static NSArray *sPossibleSamplingVal;

+(void)initialize{
    if(self == [W2STSelectFeatureViewController class]){
        sPossibleSamplingStr = @[@"1s", @"2s",@"5s",@"10s"];
        sPossibleSamplingVal = @[@(1*1000), @(2*1000),@(5*1000),@(10*1000)];
    }//if
}//initialize


-(void)viewDidLoad{
    [super viewDidLoad];
   // self.view.layer.borderWidth=1.0f;
    self.dataSelector.delegate=self;
    self.dataSelector.dataSource=self;
}

-(void)clearSelection{
    mSelectedSample = -1;
    mFeatureSelected=false;
    [self.dataSelector reloadAllComponents];
    self.titleLabel.text=@"Select the feature to plot";
    mSelectedFeature =0;
    [self.dataSelector selectRow:mSelectedFeature
                     inComponent:0
                        animated:NO];

}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self clearSelection];
}

- (IBAction)cencelAction:(UIButton *)sender {
    [self.delegate selectFeatureAtIndex: [self.delegate getNumberFeature]+1 withNSample:0] ;
    [self clearSelection];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)plotAction:(UIButton *)sender {
    if(mSelectedSample>=0 && mSelectedFeature>=0){
        NSUInteger nSample = [[sPossibleSamplingVal objectAtIndex:mSelectedSample] unsignedIntegerValue];
        [self.delegate selectFeatureAtIndex: mSelectedFeature withNSample:nSample];
        [self clearSelection];
        [self dismissViewControllerAnimated:YES completion:nil];
    }else if(mSelectedFeature>=0){
        mFeatureSelected=true;
        self.titleLabel.text=@"Select the time scale";
        [self.dataSelector reloadAllComponents];
        mSelectedSample =sPossibleSamplingVal.count/2;
        [self.dataSelector selectRow:mSelectedSample
                         inComponent:0
                            animated:NO];
    }//if-else
}

#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component{
    if(!mFeatureSelected)
        return [self.delegate getNumberFeature];
    else
        return sPossibleSamplingStr.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView
                      titleForRow:(NSInteger)row
                     forComponent:(NSInteger)component{
    if(!mFeatureSelected)
        return [self.delegate getNameOfFeatureAtIndex:row];
    else
        return [sPossibleSamplingStr objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component{

    if(!mFeatureSelected){
        mSelectedFeature = row;
    }else{
        mSelectedSample=row;
    }//if-else
    
}


@end
