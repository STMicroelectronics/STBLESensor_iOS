//
//  W2STViewController.m
//  W2STApp
//
//  Created by Antonino Raucea on 12/03/14.
//  Copyright (c) 2014 STMicroelectronics. All rights reserved.
//

#import "W2STViewController.h"
//#import "W2ST3DCubeDebugViewController.h"
#import "W2STDeviceControlViewController.h"
#import "W2STDeviceControlDebugViewController.h"
#import "W2STDeviceConfigurationTableViewController.h"
#import "ToastView.h"

//#import "LeMotionService.h"

@interface W2STViewController ()
@property (retain, nonatomic) IBOutlet UITextView *infoText;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *waiting;
@end

@implementation W2STViewController

@synthesize infoText;

W2STSDKManager *manager123 = nil;
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    manager123 = [W2STSDKManager sharedInstance];
    [manager123 discoveryStart];
}

- (IBAction)dbg001Action:(id)sender {
    W2STDeviceControlViewController *viewcmd = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"debug node control"];
    [self.navigationController pushViewController:viewcmd animated:YES];
}
- (IBAction)dbg002Action:(id)sender {
    /*
    W2STDeviceConfigurationTableViewController *viewcmd = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"node config"];
    viewctrl.node = nil;
    [self.navigationController viewcmd animated:YES];
     */
    W2STDeviceControlDebugViewController *viewcmd = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"debug node frame"];
    viewcmd.node = [manager123 nodes];
    [viewcmd.node connectAndReading];
    [self.navigationController pushViewController:viewcmd animated:YES];
}
- (IBAction)dbg003Action:(id)sender {
    /*
    W2STCube3DViewController *viewcmd = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"cube3D"];
    W2STSDKManager * manager = [W2STSDKManager sharedInstance];
    [manager addLocalNode];
    viewcmd.node = manager.nodes[0];
    [viewcmd.node connectAndReading];
    [self.navigationController pushViewController:viewcmd animated:YES];
     */
    //W2ST3DCubeDebugViewController *viewcmd = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"3D object demo"];
    //W2STSDKManager * manager = [W2STSDKManager sharedInstance];
    //[manager addLocalNode];
    //viewcmd.node = manager.nodes[0];
    //[viewcmd.node connectAndReading];
    //[self.navigationController pushViewController:viewcmd animated:YES];
}
- (IBAction)dbg004Action:(id)sender {
     W2STDeviceConfigurationTableViewController *viewcmd = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"node config"];
     viewcmd.node = nil;
     [self.navigationController pushViewController:viewcmd animated:YES];
    //[ToastView showToastInParentView:self.view withText:@"test ... " withDuaration:2.0];
}
@end
