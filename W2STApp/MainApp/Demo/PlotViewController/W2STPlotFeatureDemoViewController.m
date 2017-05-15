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

#include <float.h>
#include <libkern/OSAtomic.h>

#import "W2STPlotFeatureDemoViewController.h"
#import "W2STSelectFeatureViewController.h"
#import "BlueMSDemosViewController.h"
#import <BlueSTSDK/BlueSTSDKFeature.h>
#import <BlueSTSDK/BlueSTSDKFeatureField.h>

#import <BlueSTSDK/BlueSTSDKFeatureMagnetometer.h>
#import <BlueSTSDK/BlueSTSDKFeatureCompass.h>
#import <BlueSTSDK/BlueSTSDKFeatureAcceleration.h>
#import <BlueSTSDK/BlueSTSDKFeatureActivity.h>
#import <BlueSTSDK/BlueSTSDKFeatureCarryPosition.h>
#import <BlueSTSDK/BlueSTSDKFeatureBattery.h>
#import <BlueSTSDK/BlueSTSDKFeatureGyroscope.h>
#import <BlueSTSDK/BlueSTSDKFeatureHumidity.h>
#import <BlueSTSDK/BlueSTSDKFeatureLuminosity.h>
#import <BlueSTSDK/BlueSTSDKFeatureMemsSensorFusion.h>
#import <BlueSTSDK/BlueSTSDKFeatureMemsSensorFusionCompact.h>
#import <BlueSTSDK/BlueSTSDKFeatureFreeFall.h>
#import <BlueSTSDK/BlueSTSDKFeatureProximity.h>
#import <BlueSTSDK/BlueSTSDKFeaturePressure.h>
#import <BlueSTSDK/BlueSTSDKFeatureTemperature.h>
#import <BlueSTSDK/BlueSTSDKFeatureAccelerometerEvent.h>
#import <BlueSTSDK/BlueSTSDKFeatureDirectionOfArrival.h>
#import <BlueSTSDK/BlueSTSDKFeatureAudioADPCM.h>
#import <BlueSTSDK/BlueSTSDKFeatureAudioADPCMSync.h>

#define Y_AXIS_BORDER 0.1f
#define X_NAME @"Time (ms)"
#define SELECT_FEATURE_BUTTON_TITLE @"Select Feature"
#define MS_TO_TIMESTAMP_SCALE 10
#define MAX_PLOT_UPDATE_DIFF_MS 500



@interface W2STPlotFeatureDemoViewController () <CPTPlotDataSource,
    BlueSTSDKFeatureDelegate,W2STSelectFeatureDelegate>

@end

@implementation W2STPlotFeatureDemoViewController{
    
    //queue where we schedule a task each MAX_PLOT_UPDATE_DIFF_MS, if the data aren't update
    // the task will insert again the last value
    dispatch_queue_t mForcePlotUpdateQueue;
    //queue used for serialize the access to the ploted data, we move the computation
    //outside the main queue
    dispatch_queue_t mSerializePlotUpdateQueue;
    //time of the last update of the data
    double mLastDataUpdate;
    //time of the last graph plotting, we fix the plot update time to 30fps
    double mLastPlotUpdate;
    //number of fake data insert from the last fresh data, this index is used for compute
    // the fake data timestamp
    uint32_t mNForcedUpdate;
    
    NSUInteger mNFeatureItems;
    
    int64_t mFirstTimeStamp;
    int64_t mLastTimeStamp;
    
    
    BlueSTSDKNode *mNode; // node that export the feature
    BlueSTSDKFeature *mFeature; //feature that we are plotting
    uint32_t mTimestampRange; // range of timestamp to plot
    NSNumber *mTimestampRangeDecimal;
    bool mAutomaticRange; // true if we have to automaticaly update the y
    CPTXYGraph *mGraph; //graph where plot the feature
    NSMutableArray *mPlotDataY; //data plotted Y
    NSMutableArray *mPlotDataX; //data plotted X

    NSArray *mFeatureArray; //array with the available features
    UITapGestureRecognizer *mDoubleTapRecognizer;
    
}


//color used for plot the data lines
static NSArray *sLineColor;
static NSSet *sSkipFeature;
static NSNumber *sZero;
+(void)initialize{
    if(self == [W2STPlotFeatureDemoViewController class]){
        sLineColor = @[ [CPTColor greenColor],
                        [CPTColor blueColor],
                        [CPTColor redColor],
                        [CPTColor yellowColor],
                        [CPTColor purpleColor],
                        [CPTColor purpleColor],
                      ];
        sZero =[NSDecimalNumber zero];
        sSkipFeature = [NSSet setWithObjects:
                          [BlueSTSDKFeatureCarryPosition class],
                          [BlueSTSDKFeatureFreeFall class],
                          [BlueSTSDKFeatureActivity class],
                          [BlueSTSDKFeatureBattery class],
                          [BlueSTSDKFeatureAccelerometerEvent class],
                          [BlueSTSDKFeatureAudioADPCM class],
                          [BlueSTSDKFeatureAudioADPCMSync class],
                        nil];

    }//if
}//initialize


/**
 *  for some know feature fix the plot range
 *
 *  @param f   feature to test
 *  @param min min value of the feature data
 *  @param max max value of the feature data
 *
 *  @return true if the feature have to use a fixed range for the x axis
 * the range is returned with the value of min,max
 */
+(bool)getBoundaryForFeature:(BlueSTSDKFeature*)f min:(float*)min max:(float*)max{
    //keep the min/max declared in the feature class
    if([f isKindOfClass:[BlueSTSDKFeatureMagnetometer class]] ||
       [f isKindOfClass:[BlueSTSDKFeatureAcceleration class]] ||
       [f isKindOfClass:[BlueSTSDKFeatureGyroscope class]] ||
       [f isKindOfClass:[BlueSTSDKFeatureHumidity class]] ||
       [f isKindOfClass:[BlueSTSDKFeatureCompass class]] ||
       [f isKindOfClass:[BlueSTSDKFeatureLuminosity class]] ||
       [f isKindOfClass:[BlueSTSDKFeatureMemsSensorFusion class]] ||
       [f isKindOfClass:[BlueSTSDKFeatureMemsSensorFusionCompact class]] ||
       [f isKindOfClass:[BlueSTSDKFeatureDirectionOfArrival class]] ){
        return true;
    }else if ([f isKindOfClass:[BlueSTSDKFeaturePressure class]]){
        *max = 1110.0f;
        *min = 900.0f;
        return true;
    }else if ([f isKindOfClass:[BlueSTSDKFeatureTemperature class]]){
        *max = 50.0f;
        *min = 0.0f;
        return true;
    }else if ([f isKindOfClass:[BlueSTSDKFeatureActivity class]]){
        *max = 7.0f;
        *min = 0.0f;
        return true;
    }else if ([f isKindOfClass:[BlueSTSDKFeatureFreeFall class]]){
        *max = 2.0f;
        *min = 0.0f;
        return true;
    }//if-else//if-else
    
    return false;
    
}

-(void) viewDidLoad{
    [super viewDidLoad];
    mForcePlotUpdateQueue = dispatch_queue_create("ForcePlotUpdateQueue", DISPATCH_QUEUE_SERIAL);
    mSerializePlotUpdateQueue = dispatch_queue_create("SerializePlotUpdateQueue", DISPATCH_QUEUE_SERIAL);
    mLastPlotUpdate = -1;
    mNForcedUpdate=0;
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //initialize the plot
    
    [self initPlotView];

    //retrive the node and the exported features
    BlueMSDemosViewController *demos = (BlueMSDemosViewController*)[self parentViewController];
    mNode =demos.node;
    
    NSArray *allFeature = [mNode getFeatures];
    mFeatureArray = [allFeature objectsAtIndexes:
                     [allFeature indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        for(Class c in sSkipFeature){
            if([obj isKindOfClass:c])
                return false;
        }//for
        return true;
    }//block
    ]];
    
    //mGraph.affineTransform = CGAffineTransformMakeScale(1.0f,-1.0f);
    self.featureDataLabel.text=@"";
    
    mDoubleTapRecognizer = [[UITapGestureRecognizer alloc]
                                initWithTarget:self
                                        action:@selector(doubleTapEvent:)];
    mDoubleTapRecognizer.numberOfTapsRequired=2;
    [_plotView addGestureRecognizer:mDoubleTapRecognizer];

    //if we return visible after the popupcontroller whent down, start plotting
    if(mFeature!=nil){
        [self startPlotFeature:mFeature withNSample:mTimestampRange ];
    }
    
}

-(void)doubleTapEvent:(UITapGestureRecognizer*)sender{
    if(sender.state == UIGestureRecognizerStateEnded){
        [self showSelectFeature:_selectFeatureButton];
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //if we are ploting something stop it
    if(mFeature!=nil){
        [mFeature removeFeatureDelegate:self];
        [mNode disableNotification:mFeature];
        mFeature=nil;
    }//if
}

-(void)initPlotView{
    _plotView.allowPinchScaling = false;
    _plotView.collapsesLayers=true;
    
    [_selectFeatureButton setTitle:SELECT_FEATURE_BUTTON_TITLE forState:UIControlStateNormal];
    
    // Grid line styles
    CPTMutableLineStyle *majorGridLineStyle = [CPTMutableLineStyle lineStyle];
    majorGridLineStyle.lineWidth = 0.5;
    majorGridLineStyle.lineColor = [[CPTColor blackColor] colorWithAlphaComponent:0.5];
    
    CPTMutableLineStyle *minorGridLineStyle = [CPTMutableLineStyle lineStyle];
    minorGridLineStyle.lineWidth = 0.25;
    minorGridLineStyle.lineColor = [[CPTColor blackColor] colorWithAlphaComponent:0.1];
    
    
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    [textStyle setFontSize:8.0f];
    
    //create the graph
    mGraph =[[CPTXYGraph alloc] initWithFrame: _plotView.bounds];
    
    [mGraph applyTheme:[CPTTheme themeNamed:kCPTPlainWhiteTheme]];
    self.plotView.hostedGraph = mGraph;
   
    //padding of the graph inside the graph view
    mGraph.plotAreaFrame.paddingLeft = 48; //space for the axis value
    mGraph.plotAreaFrame.paddingTop = 8;
    mGraph.plotAreaFrame.paddingRight = 16;
    // more space for the x axis name and the leggend
    mGraph.plotAreaFrame.paddingBottom = 48;
    
    // Axes
    // Y axis
    //show only the major grid, and a title,show only the integer part
    //for other stuff, use the default
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)mGraph.axisSet;
    //Y axis, show only the majout
    CPTXYAxis *y          = axisSet.yAxis;
    y.labelingPolicy              = CPTAxisLabelingPolicyAutomatic;
    y.majorGridLineStyle          = majorGridLineStyle;
    y.title= X_NAME;
    NSNumberFormatter *labelFormatter = [[NSNumberFormatter alloc] init];
    labelFormatter.numberStyle = NSNumberFormatterRoundCeiling;
    labelFormatter.positiveFormat = @"0";
    y.labelFormatter           = labelFormatter;
    y.labelRotation = CPTFloat(-M_PI_2);
    y.titleRotation = CPTFloat(-M_PI_2);
    y.labelTextStyle =textStyle;
    
    // X axis
    //show the grid in both the case, no title
    CPTXYAxis *x = axisSet.xAxis;
    x.labelingPolicy              = CPTAxisLabelingPolicyAutomatic;
    x.majorGridLineStyle          = majorGridLineStyle;
    x.minorGridLineStyle          = minorGridLineStyle;
    //always show the y axis
    x.axisConstraints             = [CPTConstraints constraintWithLowerOffset:0.0];
    x.labelTextStyle = textStyle;
    x.labelRotation = CPTFloat(-M_PI_2);
    

}

-(void)setUpPlotViewForFeature:(BlueSTSDKFeature*)feature{
    NSString *newButtonTitle = [NSString stringWithFormat:@"Stop plotting %@",feature.name];
    [self.selectFeatureButton setTitle:newButtonTitle forState:UIControlStateNormal];
    //before add new plot, remove the old one
    NSArray *oldPlots = [mGraph allPlots];
    for(CPTPlot *plot in oldPlots){
        [mGraph removePlot:plot];
    }
    
    //reset the plot data
    mPlotDataY = [NSMutableArray arrayWithCapacity:mTimestampRange];
    mPlotDataX = [NSMutableArray arrayWithCapacity:mTimestampRange];
    
    //create a plot for each data exported by the feature
    NSArray *dataDesc = [feature getFieldsDesc];
    mNFeatureItems = dataDesc.count;
    BlueSTSDKFeatureField *field = dataDesc[0];
    
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)mGraph.defaultPlotSpace;

    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@0.0
                                                    length:mTimestampRangeDecimal];
    
    float min = field.min.floatValue;
    float max = field.max.floatValue;
    if([W2STPlotFeatureDemoViewController getBoundaryForFeature:feature
                                                            min:&min
                                                            max:&max]){
        plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@(min)
                                                        length:@(max - min)];
        if(max-min > 100){
            NSNumberFormatter *labelFormatter = [[NSNumberFormatter alloc] init];
            labelFormatter.numberStyle = NSNumberFormatterRoundCeiling;
            labelFormatter.positiveFormat = @"0";
            ((CPTXYAxisSet *)mGraph.axisSet).xAxis.labelFormatter = labelFormatter;
        }else{
            NSNumberFormatter *labelFormatter = [[NSNumberFormatter alloc] init];
            labelFormatter.numberStyle = NSNumberFormatterRoundCeiling;
            labelFormatter.positiveFormat = @"0.0";
            ((CPTXYAxisSet *)mGraph.axisSet).xAxis.labelFormatter = labelFormatter;
        }
        mAutomaticRange =false;
    }else
        mAutomaticRange =true;
    //if-else
    
    
    //fix the x axis on the bottom of the plot
    ((CPTXYAxisSet*)mGraph.axisSet).yAxis.axisConstraints = [CPTConstraints constraintWithLowerOffset:0];
    uint32_t identifier = 0;
    for(BlueSTSDKFeatureField *field in dataDesc){
        // Create the plot
        CPTScatterPlot *dataSourceLinePlot = [[CPTScatterPlot alloc] init];
        dataSourceLinePlot.identifier     = @(identifier);
        dataSourceLinePlot.cachePrecision = CPTPlotCachePrecisionDouble;
        
        CPTMutableLineStyle *lineStyle = [dataSourceLinePlot.dataLineStyle mutableCopy];
        lineStyle.lineWidth              = 1.0;
        lineStyle.lineColor              = sLineColor[identifier % sLineColor.count];
        dataSourceLinePlot.dataLineStyle = lineStyle;
        dataSourceLinePlot.title = field.name;
        dataSourceLinePlot.dataSource = self;
        dataSourceLinePlot.showLabels=false;

        [mGraph addPlot: dataSourceLinePlot];
        identifier++;
    }//for
    
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)mGraph.axisSet;
    if(dataDesc.count!=1){
        // Add legend
        mGraph.legend                 = [CPTLegend legendWithGraph:mGraph];
        mGraph.legend.hidden=false;
        mGraph.legend.fill            = [CPTFill fillWithColor:[CPTColor clearColor]];
        mGraph.legend.cornerRadius    = 5.0;
        mGraph.legend.numberOfRows    = 1;
        mGraph.legendAnchor           = CPTRectAnchorBottom;
        mGraph.legendDisplacement     = CGPointMake( 0.0, 16 * CPTFloat(1.25) );
        axisSet.xAxis.title=@"";
    }else{
        BlueSTSDKFeatureField *field = ((BlueSTSDKFeatureField*) dataDesc[0]);
        if([field hasUnit])
            axisSet.xAxis.title = [NSString stringWithFormat:@"%@ (%@)",field.name,field.unit ];
        else
            axisSet.xAxis.title = [NSString stringWithFormat:@"%@",field.name ];
        mGraph.legend.hidden=true;
    }//dataDesc
    
    //[plotSpace scaleToFitPlots:plots];
}

#pragma mark - CPTPlotDataSource methods
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    return mPlotDataY.count;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum
               recordIndex:(NSUInteger)index {
    //NSLog(@"NumberOfPlot: Index:%d",index);
    NSArray *datas;
    switch (fieldEnum){
        case CPTScatterPlotFieldY:
            return mPlotDataX[index];
        case CPTScatterPlotFieldX:
            datas = mPlotDataY[index];
            NSNumber *idx = (NSNumber*)plot.identifier;
            return datas[[idx unsignedIntValue]];
    }
    return sZero;
}

/**
 * find the max and min value that we will plot in the graph
 */
-(void) extractMaxMinFromData:(NSArray*)data min:(float*)outMin max:(float*)outMax{

    float min = FLT_MAX;
    float max = FLT_MIN;
    
    for (NSArray *arr in data){
        for(NSNumber *n in arr){
            float temp = n.floatValue;
            if(temp<min)
                min=temp;
            else if (temp>max)
                max = temp;
        }//for n
    }//for arr
    
    *outMin=min;
    *outMax=max;
}


-(void)insertPlotItem:(bool)forceUpdate{
    static bool isPlotting=false;
    if(mFeature==nil)
        return;
    if(isPlotting)
        return;
    isPlotting=true;
    BlueSTSDKFeatureSample *sample = mFeature.lastSample;
    NSString *dataString=nil;
    if(forceUpdate) //generate the string only if we have to render it
        dataString= [mFeature description];
    
    dispatch_async(mSerializePlotUpdateQueue,^{
        //check that in the mean time the used didn't select a new feature
        if(mFeature==nil){ //plot stop
            isPlotting=false;
            return;
        }
        
        double currentTime = CACurrentMediaTime();
        double diffLastDataUpdate = currentTime-mLastDataUpdate;
        if(mFirstTimeStamp<0){
            mFirstTimeStamp=sample.timestamp;
            mLastTimeStamp=0;
        }

        if(sample.timestamp<mLastTimeStamp){ // the data are old, avoid to plot it
            isPlotting=false;
            return;
        }
        
        mLastTimeStamp=sample.timestamp;

        uint64_t xValue=sample.timestamp;
        
        if(forceUpdate){
            mLastDataUpdate=currentTime;
            mNForcedUpdate=0;
            //update the text label
            
        }else{
           // NSLog(@"Force update: %f < %f\n",diffLastDataUpdate,MAX_PLOT_UPDATE_DIFF_MS*0.001);

            //the last update is recent -> we can skip this one
            if(diffLastDataUpdate< MAX_PLOT_UPDATE_DIFF_MS*0.001){
                isPlotting=false;
                return;
            }else{
                //increase the timestamp for duplicate the last received data
                xValue += (++mNForcedUpdate)*(MAX_PLOT_UPDATE_DIFF_MS/MS_TO_TIMESTAMP_SCALE);
            }//if-else
        }//if
        
        //convert from timestamp to time
        xValue =(uint32_t)(xValue-mFirstTimeStamp)*MS_TO_TIMESTAMP_SCALE;
        
        //the system clock is faster than the board one, so we run too much -> remove the sample that are in the future
        if(((NSNumber*)mPlotDataX.lastObject).unsignedIntValue > xValue){
            
            uint32_t nRemove =0;
            while (mPlotDataX.count>0 && ((NSNumber*)mPlotDataX.lastObject).unsignedIntValue > xValue) {
                [mPlotDataX removeLastObject];
                [mPlotDataY removeLastObject];
                nRemove++;
            }//while
                       
            
        }//if
        
        //if is a proximity out of range value we add a 0 instad of the big value
        if([mFeature isKindOfClass:BlueSTSDKFeatureProximity.class] &&
            [BlueSTSDKFeatureProximity isOutOfRangeSample:sample]){
                [mPlotDataY addObject:@[@(0)]];
        }else{
            [mPlotDataY addObject:sample.data];
        }

        NSNumber *lastXValue = @(xValue);
        [mPlotDataX addObject:lastXValue];
        
        unsigned int nRemove=0;
        // NSLog(@"Oldest: %@ newer:%@",((NSNumber*)mPlotDataX.firstObject),((NSNumber*)mPlotDataX.lastObject));
//        const uint32_t lastTs =(((NSNumber*)mPlotDataX.lastObject).unsignedIntValue);
        while(( xValue-
               (((NSNumber*) mPlotDataX[nRemove]).unsignedIntValue))
              > mTimestampRange ){
            
            nRemove++;
        }//while
        
        if(nRemove!=0){
            [mPlotDataX removeObjectsInRange:NSMakeRange(0, nRemove)];
            [mPlotDataY removeObjectsInRange:NSMakeRange(0, nRemove)];
        }
        
        float minY=0,maxY=0;
        if(mAutomaticRange){
            //update the y range
            [self extractMaxMinFromData:mPlotDataY min:&minY max:&maxY];
            float delta = maxY-minY;
            minY = minY - (delta)*Y_AXIS_BORDER;
            maxY = maxY + delta*Y_AXIS_BORDER;
        }//if automaticRange
        
     //   if(currentTime-mLastPlotUpdate>0.016) // refresh at 60fps
       // if(currentTime-mLastPlotUpdate>0.1) // refresh at 30fps
            dispatch_sync(dispatch_get_main_queue(), ^{
                    if(mFeature==nil){ //plot stop
                        isPlotting=false;
                        return;
                    }//if
                
                    mLastPlotUpdate = currentTime;
                    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)mGraph.defaultPlotSpace;
                
                    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:lastXValue
                                                                length:mTimestampRangeDecimal];
                 
                    if(mAutomaticRange){
                        plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@(minY)
                                                                        length:@(maxY - minY)];

                    }//if automaticRange
                
                    [mGraph reloadData];
   
                    if(forceUpdate)
                        self.featureDataLabel.text=dataString;
                
            });
        isPlotting=false;
        dispatch_time_t nextUpdate = dispatch_time(DISPATCH_TIME_NOW, MAX_PLOT_UPDATE_DIFF_MS*1000000L);
        dispatch_after(nextUpdate,mForcePlotUpdateQueue, ^{
            [self insertPlotItem:false];
        });

    });

}

#pragma mark - BlueSTSDKFeatureDelegate methods
- (void)didUpdateFeature:(BlueSTSDKFeature *)feature sample:(BlueSTSDKFeatureSample *)sample{
   // static volatile int32_t nCall =0;
    if(feature!=mFeature)
        return;
    //if the feature change the number of items we rebuild the plot
    if(mNFeatureItems!= [feature getFieldsDesc].count)
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self setUpPlotViewForFeature:feature];
        });
    [self insertPlotItem:true];
    
}

-(void) startPlotFeature: (BlueSTSDKFeature*)newFeature withNSample:(NSUInteger)nSample{
    //if present stop the current feature
    if(mFeature!=nil){
        [self stopPlotCurrentFeature];
    }
    
    mFeature = newFeature;
    mTimestampRange = (uint32_t)nSample;
    mTimestampRangeDecimal = @(-(int32_t) mTimestampRange);
    mFirstTimeStamp=-1;
    //update the graph for plot the new feature
    [self setUpPlotViewForFeature:mFeature];
    
    //start receve data from the new feature
    [mFeature addFeatureDelegate:self];
    [mNode enableNotification:mFeature];
}

-(void) stopPlotCurrentFeature{
    [mFeature removeFeatureDelegate:self];
    [mNode disableNotification:mFeature];
    mFeature=nil;
    
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.destinationViewController isKindOfClass:W2STSelectFeatureViewController.class]){
        
        W2STSelectFeatureViewController *temp = (W2STSelectFeatureViewController *)segue.destinationViewController;
        temp.delegate=self;
        
        //needed for center the ancor in the center bottom instead of the top left corner..
        UIPopoverPresentationController* possiblePopOver =temp.popoverPresentationController;
        possiblePopOver.sourceRect = possiblePopOver.sourceView.bounds;
    }
}



- (IBAction)showSelectFeature:(UIButton *)sender {    
    if(mFeature!=nil){//is plotting something
        [self stopPlotCurrentFeature];
        [sender setTitle:SELECT_FEATURE_BUTTON_TITLE forState:UIControlStateNormal];
    }else
        [self performSegueWithIdentifier:@"SelectFeaturePlotPopover" sender:sender];
}

#pragma mark - W2STSelectFeatureDelegate

-(NSUInteger) getNumberFeature{
    return mFeatureArray.count;
}

-(NSString*) getNameOfFeatureAtIndex:(NSUInteger)idx{
    BlueSTSDKFeature *f = [mFeatureArray objectAtIndex:idx];
    return f.name;
}

-(void) selectFeatureAtIndex:(NSUInteger)idx withNSample:(NSUInteger)nSample{
    if(idx<mFeatureArray.count){
        BlueSTSDKFeature *f = [mFeatureArray objectAtIndex:idx];
        [self startPlotFeature:f withNSample: nSample];
    }
}

@end
