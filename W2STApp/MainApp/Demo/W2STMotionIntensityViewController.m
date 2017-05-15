#import <BlueSTSDK/BlueSTSDKFeatureMotionIntensity.h>

#import "W2STMotionIntensityViewController.h"

#define MOTION_INTENSITY_VALUE_FORMAT @"The Motion intensity value is: %d"
#define DEG_TO_RAG(x) ((x)*(M_PI/180.0f))

#define ANIMATION_DURATION_S (0.3f)

static float sNeedleOffset[] = {
        DEG_TO_RAG(-135),
        DEG_TO_RAG(-108),
        DEG_TO_RAG(-81),
        DEG_TO_RAG(-54),
        DEG_TO_RAG(-27),
        DEG_TO_RAG(  0),
        DEG_TO_RAG( 27),
        DEG_TO_RAG( 54),
        DEG_TO_RAG( 81),
        DEG_TO_RAG( 108),
        DEG_TO_RAG( 135),
};

@interface W2STMotionIntensityViewController ()<BlueSTSDKFeatureDelegate>

@property (weak, nonatomic) IBOutlet UILabel *mMotionIntensityValue;
@property (weak, nonatomic) IBOutlet UIImageView *mMotionIntensityNeedle;

@end



@implementation W2STMotionIntensityViewController{
    BlueSTSDKFeature *mFeature;
}

-(CAAnimation*) createRotateAnimationFrom:(CGFloat)from to:(CGFloat)to{
    
    CAKeyframeAnimation * animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation"];
    animation.additive=YES;
    
    [animation setValues:@[@(from),@(to)]];
    
    animation.duration = ANIMATION_DURATION_S;
    return animation;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    //enable the notification
    mFeature =(BlueSTSDKFeatureMotionIntensity*)[self.node getFeatureOfType:BlueSTSDKFeatureMotionIntensity.class];
    if(mFeature!=nil){
        [mFeature addFeatureDelegate:self];
        [self.node enableNotification:mFeature];
    }//if
}//viewDidAppear

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //if we are ploting something stop it
    if(mFeature!=nil){
        [mFeature removeFeatureDelegate:self];
        [self.node disableNotification:mFeature];
        mFeature=nil;
    }//if
}


#pragma mark - BlueSTSDKFeatureDelegate
- (void)didUpdateFeature:(BlueSTSDKFeature *)feature sample:(BlueSTSDKFeatureSample *)sample{
    int8_t status = [BlueSTSDKFeatureMotionIntensity getMotionIntensity:sample];
    if(status<0 || status>=(sizeof(sNeedleOffset)/sizeof(sNeedleOffset[0])))
        return;
    
    
    float rotationAngleRad = sNeedleOffset[status];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        _mMotionIntensityValue.text = [NSString stringWithFormat:MOTION_INTENSITY_VALUE_FORMAT,status ];
        
        [UIView animateWithDuration:ANIMATION_DURATION_S animations:^{
            _mMotionIntensityNeedle.transform = CGAffineTransformMakeRotation(rotationAngleRad);
        }];
        
    });
    
}


@end
