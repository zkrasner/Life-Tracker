//
//  DSSelectedActitvityViewController.h
//  LifeTracker
//
//  Created by Daniel Salowe on 4/9/14.
//  Copyright (c) 2014 Danny Salowe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DSSelectedActitvityViewController : UIViewController <CPTBarPlotDataSource, CPTBarPlotDelegate>
@property (strong, nonatomic) NSString *activityTitle;

@property (nonatomic, weak) IBOutlet UILabel *hr;
@property (nonatomic, weak) IBOutlet UILabel *min;
@property (nonatomic, weak) IBOutlet UILabel *sec;
@property (nonatomic, weak) IBOutlet UILabel *hun;
@property (nonatomic, weak) IBOutlet UIButton *btnStartStop;
@property (nonatomic, strong) NSTimer *timer;
- (IBAction)startStopTouched:(UIButton *)sender;

@end
