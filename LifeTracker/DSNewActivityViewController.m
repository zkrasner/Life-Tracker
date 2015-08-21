//
//  DSNewActivityViewController.m
//  LifeTracker
//
//  Created by Daniel Salowe on 4/8/14.
//  Copyright (c) 2014 Danny Salowe. All rights reserved.
//

#import "DSNewActivityViewController.h"
#import "DSAppDelegate.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "DSActivity.h"

@interface DSNewActivityViewController ()<UITextFieldDelegate,CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *titleField;
@property (weak, nonatomic) IBOutlet UITextField *hourField;
@property (weak, nonatomic) IBOutlet UITextField *minuteField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *typeField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *aboveBelowField;
- (IBAction)donePressed:(id)sender;

//keyboard toolbar
@property (nonatomic, strong) UIToolbar *keyboardToolbar;
@property (nonatomic, strong) UIBarButtonItem *previousButton;
@property (nonatomic, strong) UIBarButtonItem *nextButton;
- (void) nextField;
- (void) previousField;
- (void) resignKeyboard;

//application delegate
@property (nonatomic, strong) DSAppDelegate *appDelegate;
@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation DSNewActivityViewController


- (DSAppDelegate *)appDelegate
{
    if (!_appDelegate) {
        _appDelegate = (DSAppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    
    return _appDelegate;
}

- (CLLocationManager *)locationManager
{
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.delegate = self;
    }
    
    return _locationManager;
}

- (UIToolbar *)keyboardToolbar
{
    if (!_keyboardToolbar) {
        _keyboardToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
        self.previousButton = [[UIBarButtonItem alloc] initWithTitle:@"Previous"
                                                               style:UIBarButtonItemStyleBordered
                                                              target:self
                                                              action:@selector(previousField)];
        
        self.nextButton = [[UIBarButtonItem alloc] initWithTitle:@"Next"
                                                           style:UIBarButtonItemStyleBordered
                                                          target:self
                                                          action:@selector(nextField)];
        
        UIBarButtonItem *extraSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                    target:self
                                                                                    action:nil];
        
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                       style:UIBarButtonItemStyleBordered
                                                                      target:self
                                                                      action:@selector(resignKeyboard)];
        
        [_keyboardToolbar setItems:@[self.previousButton, self.nextButton, extraSpace, doneButton]];
    }
    
    return _keyboardToolbar;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleField.inputAccessoryView = self.keyboardToolbar;
    self.hourField.inputAccessoryView = self.keyboardToolbar;
    self.minuteField.inputAccessoryView = self.keyboardToolbar;
    self.titleField.delegate = self;
    self.hourField.delegate = self;
    self.minuteField.delegate = self;
    [self.locationManager startUpdatingLocation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)donePressed:(id)sender {
    
    //logic to actually save
    DSActivity *activityToAdd = [[DSActivity alloc] init];
    activityToAdd.name = self.titleField.text;
    activityToAdd.type = [self.typeField titleForSegmentAtIndex:self.typeField.selectedSegmentIndex];
    activityToAdd.aboveBelow = [self.aboveBelowField titleForSegmentAtIndex:self.aboveBelowField.selectedSegmentIndex];
    
    //convert to minutes
    int time = ([self.hourField.text intValue] * 60) + [self.minuteField.text intValue];
    activityToAdd.time = [NSString stringWithFormat:@"%d", time];
    
    activityToAdd.longitude = [NSString stringWithFormat:@"%f",[self.locationManager location].coordinate.longitude];
    activityToAdd.latitude = [NSString stringWithFormat:@"%f",[self.locationManager location].coordinate.latitude];
    
    //date
    NSDate *localDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"MM/dd/yy/HH:mm:ss.SSS";
    NSString *dateString = [dateFormatter stringFromDate: localDate];
    activityToAdd.date = dateString;
    
    activityToAdd.startTime = @"NO";
    activityToAdd.endTime = @"NO";
    activityToAdd.timeElasped = @"NO";
    activityToAdd.completed = @"NO";
    
    
    int sameName = 0;
    for(int i = 0; i < self.appDelegate.allActivities.count; i++){
        Activity *activity = self.appDelegate.allActivities[i];
        if([activity.name isEqualToString:activityToAdd.name]){
            sameName = 1;
        }
    }
    if(sameName == 1){
        UIAlertView *somethingWrong = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Acitivity already has the same name" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [somethingWrong show];
    }
    else{
        if ([self.appDelegate addActivityFromWrapper:activityToAdd]) {
                [self.navigationController popViewControllerAnimated:YES];
        } else {
            UIAlertView *somethingWrong = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Something was wrong" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [somethingWrong show];
        }
    }

}

#pragma mark - Keyboard Toolbar

- (void) nextField
{
    if ([self.titleField isFirstResponder]) {
        [self.hourField becomeFirstResponder];
    } else if ([self.hourField isFirstResponder]) {
        [self.minuteField becomeFirstResponder];
    }
}

- (void) previousField
{
    //make name field be the one with the cursor
    if ([self.hourField isFirstResponder]) {
        [self.titleField becomeFirstResponder];
    } else if ([self.minuteField isFirstResponder]) {
        [self.hourField becomeFirstResponder];
    }
}

- (void) resignKeyboard
{
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[UITextField class]]) {
            [view resignFirstResponder];
        }
    }
}

#pragma mark - UITextField Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect viewFrame = self.view.frame;
    
    if (textField == self.titleField) {
        self.previousButton.enabled = NO;
    } else {
        self.previousButton.enabled = YES;
    }
    
    if (textField == self.minuteField) {
        self.nextButton.enabled = NO;
    } else {
        self.nextButton.enabled = YES;
    }
    
    if (textField == self.hourField) {
        viewFrame.origin.y = -50;
    } else if (textField == self.minuteField) {
        viewFrame.origin.y = -50;
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3f];
    
    self.view.frame = viewFrame;
    
    [UIView commitAnimations];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y = 0;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3f];
    
    [textField resignFirstResponder];
    self.view.frame = viewFrame;
    
    [UIView commitAnimations];
}


@end
