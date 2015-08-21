//
//  DSSelectedActitvityViewController.m
//  LifeTracker
//
//  Created by Daniel Salowe on 4/9/14.
//  Copyright (c) 2014 Danny Salowe. All rights reserved.
//

#import "DSSelectedActitvityViewController.h"
#import "DSAppDelegate.h"
#import <CoreLocation/CoreLocation.h>

@interface DSSelectedActitvityViewController () <UIActionSheetDelegate, CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationBar;
@property (weak, nonatomic) IBOutlet UILabel *todayField;
@property (weak, nonatomic) IBOutlet UILabel *goalField;
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;
@property (nonatomic, strong) DSAppDelegate *appDelegate;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) Activity *selectedActivity;

@property (nonatomic, strong) IBOutlet CPTGraphHostingView *hostView;
@property (nonatomic, strong) CPTBarPlot *aaplPlot;
@property (nonatomic, strong) CPTBarPlot *googPlot;
@property (nonatomic, strong) CPTBarPlot *msftPlot;
@property (nonatomic, strong) CPTPlotSpaceAnnotation *priceAnnotation;

-(void)initPlot;
-(void)configureGraph;
-(void)configurePlots;
-(void)configureAxes;
-(void)hideAnnotation:(CPTGraph *)graph;

@end

@implementation DSSelectedActitvityViewController

CGFloat const CPDBarWidth = 0.25f;
CGFloat const CPDBarInitialX = 0.25f;

@synthesize hostView    = hostView_;
@synthesize aaplPlot    = aaplPlot_;
@synthesize googPlot    = googPlot_;
@synthesize msftPlot    = msftPlot_;
@synthesize priceAnnotation = priceAnnotation_;

BOOL timerRunning;

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
    
    for(int i = 0; i < self.appDelegate.allActivities.count; i++){
        Activity *activity = self.appDelegate.allActivities[i];
        if([activity.name isEqualToString:self.activityTitle]){
            self.selectedActivity = activity;
            break;
        }
    }
    
    self.navigationBar.title = self.selectedActivity.name;
    
    if([self.selectedActivity.type isEqualToString:@"Time"]){
        int hour = [self.selectedActivity.time integerValue]/60;
        int minute = [self.selectedActivity.time integerValue] - (hour * 60);
        NSString* leadZero;
        if (minute < 10) {
            leadZero = @"0";
        } else leadZero = @"";
        self.goalField.text = [NSString stringWithFormat:@"%d:%@%d", hour,leadZero, minute];
        
        if([self.selectedActivity.timeElasped isEqualToString:@"NO"]){
            self.todayField.text = @"00:00";
            self.progressBar.progress = 0.0;
        }
//        else if([self.selectedActivity.endTime isEqualToString:@"NO"]){
//            float totalTime = [self.selectedActivity.time integerValue];
//            
//            float timeElasped = [self.selectedActivity.timeElasped intValue];
//            
//            hour = timeElasped/60;
//            minute = timeElasped - (hour * 60);
//            self.goalField.text = [NSString stringWithFormat:@"%d:%d", hour, minute];
//            
//            self.progressBar.progress = timeElasped/totalTime;
//        }
//        else{
//            self.todayField.text = [NSString stringWithFormat:@"%d:%d", hour, minute];
//            self.progressBar.progress = 1.0;
//        }
        else {
            float timeElasped = [self.selectedActivity.timeElasped intValue];
            int min = timeElasped/60;
            int hour = timeElasped/3600;
            float goalTime = [self.selectedActivity.time integerValue];
            NSString* leadZero;
            if (minute < 10) {
                leadZero = @"0";
            } else leadZero = @"";
            self.todayField.text = [NSString stringWithFormat:@"%d:%@%d",hour, leadZero, min];
            self.progressBar.progress = (timeElasped/60)/goalTime;
        }
    }
    else{
        self.goalField.text = [NSString stringWithFormat:@"Do %@", self.selectedActivity.name];
        if([self.selectedActivity.startTime isEqualToString:@"NO"]){
            self.todayField.text = @"Not Complete";
            self.progressBar.progress = 0.0;
        }
        else{
           self.todayField.text = @"Completed";
            self.progressBar.progress = 1.0;
        }
    }
}

#pragma mark - UIViewController lifecycle methods
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // The plot is initialized here, since the view bounds have not transformed for landscape until now
    [self initPlot];
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

#pragma mark - Timer stuff
- (IBAction)startStopTouched:(UIButton *)sender
{
    if (timerRunning) {
        [self.timer invalidate];
        self.timer = nil;
        timerRunning = NO;
        self.btnStartStop.titleLabel.text = @"Start";
        
        //Make new wrapper
        DSActivity *activityToAdd = [[DSActivity alloc] init];
        activityToAdd.name = self.selectedActivity.name;
        activityToAdd.type = self.selectedActivity.type;
        activityToAdd.aboveBelow = self.selectedActivity.aboveBelow;
        activityToAdd.longitude =[NSString stringWithFormat:@"%f",[self.locationManager location].coordinate.longitude];
        activityToAdd.latitude = [NSString stringWithFormat:@"%f",[self.locationManager location].coordinate.latitude];
        
        NSDate *localDate = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        dateFormatter.dateFormat = @"MM/dd/yy/HH:mm:ss.SSS";
        NSString *dateString = [dateFormatter stringFromDate: localDate];
        activityToAdd.date = dateString;
        
        activityToAdd.time = self.selectedActivity.time;
        
        activityToAdd.startTime = @"NO";
        activityToAdd.endTime = @"NO";
        int previousTotalTime = self.selectedActivity.timeElasped.intValue;
        int timeElaspedInSeconds = previousTotalTime + self.hr.text.floatValue* 60 *60 + self.min.text.floatValue * 60 + self.sec.text.floatValue;
        activityToAdd.timeElasped = [NSString stringWithFormat:@"%d",timeElaspedInSeconds];;
        activityToAdd.completed = @"NO";
        
        [self.appDelegate deleteActivity:self.selectedActivity];
        [self.appDelegate addActivityFromWrapper:activityToAdd];
    }
    else {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.01
                                                      target:self
                                                    selector:@selector(showTime)
                                                    userInfo:nil
                                                     repeats:YES];
        timerRunning = YES;
        self.btnStartStop.titleLabel.text = @"Stop";
    }
    
}

- (void)showTime
{
    int hours = 0;
    int minutes = 0;
    int seconds = 0;
    int hundredths = 0;
    NSArray *timeArray = [NSArray arrayWithObjects:self.hun.text, self.sec.text, self.min.text, self.hr.text, nil];
    
    for (int i = [timeArray count] - 1; i >= 0; i--)
    {
        int timeComponent = [[timeArray objectAtIndex:i] intValue];
        switch (i) {
            case 3:
                hours = timeComponent;
                break;
            case 2:
                minutes = timeComponent;
                break;
            case 1:
                seconds = timeComponent;
                break;
            case 0:
                hundredths = timeComponent;
                hundredths++;
                break;
                
            default:
                break;
        }
        
    }
    if (hundredths == 100) {
        seconds++;
        hundredths = 0;
    }
    else if (seconds == 60) {
        minutes++;
        seconds = 0;
    }
    else if (minutes == 60) {
        hours++;
        minutes = 0;
    }
    self.hr.text = [NSString stringWithFormat:@"%.2d", hours];
    self.min.text = [NSString stringWithFormat:@"%.2d", minutes];
    self.sec.text = [NSString stringWithFormat:@"%.2d", seconds];
    self.hun.text = [NSString stringWithFormat:@"%.2d", hundredths];
    
}



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - Rotation
//-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
//    //return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
//    return NO;
//}

#pragma mark - Chart behavior
-(void)initPlot {
    //self.hostView.allowPinchScaling = NO;
    [self configureGraph];
    [self configurePlots];
    [self configureAxes];
}

-(void)configureGraph {
	// 1 - Create the graph
	CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:self.hostView.bounds];
	graph.plotAreaFrame.masksToBorder = NO;
	self.hostView.hostedGraph = graph;
	// 2 - Configure the graph
	[graph applyTheme:[CPTTheme themeNamed:kCPTPlainBlackTheme]];
	graph.paddingBottom = 30.0f;
	graph.paddingLeft  = 30.0f;
	graph.paddingTop    = -1.0f;
	graph.paddingRight  = -5.0f;
	// 3 - Set up styles
	CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
	titleStyle.color = [CPTColor whiteColor];
	titleStyle.fontName = @"Helvetica-Bold";
	titleStyle.fontSize = 16.0f;
	// 4 - Set up title
	NSString *title = @"Portfolio Prices: April 23 - 27, 2012";
	graph.title = title;
	graph.titleTextStyle = titleStyle;
	graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
	graph.titleDisplacement = CGPointMake(0.0f, -16.0f);
	// 5 - Set up plot space
	CGFloat xMin = 0.0f;
	CGFloat xMax = [[[CPDStockPriceStore sharedInstance] datesInWeek] count];
	CGFloat yMin = 0.0f;
	CGFloat yMax = 800.0f;  // should determine dynamically based on max price
	CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
	plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(xMin) length:CPTDecimalFromFloat(xMax)];
	plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(yMin) length:CPTDecimalFromFloat(yMax)];
}

-(void)configurePlots {
	// 1 - Set up the three plots
	self.aaplPlot = [CPTBarPlot tubularBarPlotWithColor:[CPTColor redColor] horizontalBars:NO];
	self.aaplPlot.identifier = CPDTickerSymbolAAPL;
	self.googPlot = [CPTBarPlot tubularBarPlotWithColor:[CPTColor greenColor] horizontalBars:NO];
	self.googPlot.identifier = CPDTickerSymbolGOOG;
	self.msftPlot = [CPTBarPlot tubularBarPlotWithColor:[CPTColor blueColor] horizontalBars:NO];
	self.msftPlot.identifier = CPDTickerSymbolMSFT;
	// 2 - Set up line style
	CPTMutableLineStyle *barLineStyle = [[CPTMutableLineStyle alloc] init];
	barLineStyle.lineColor = [CPTColor lightGrayColor];
	barLineStyle.lineWidth = 0.5;
	// 3 - Add plots to graph
	CPTGraph *graph = self.hostView.hostedGraph;
	CGFloat barX = CPDBarInitialX;
	NSArray *plots = [NSArray arrayWithObjects:self.aaplPlot, self.googPlot, self.msftPlot, nil];
	for (CPTBarPlot *plot in plots) {
		plot.dataSource = self;
		plot.delegate = self;
		plot.barWidth = CPTDecimalFromDouble(CPDBarWidth);
		plot.barOffset = CPTDecimalFromDouble(barX);
		plot.lineStyle = barLineStyle;
		[graph addPlot:plot toPlotSpace:graph.defaultPlotSpace];
		barX += CPDBarWidth;
	}
}

-(void)configureAxes {
	// 1 - Configure styles
	CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
	axisTitleStyle.color = [CPTColor whiteColor];
	axisTitleStyle.fontName = @"Helvetica-Bold";
	axisTitleStyle.fontSize = 12.0f;
	CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
	axisLineStyle.lineWidth = 2.0f;
	axisLineStyle.lineColor = [[CPTColor whiteColor] colorWithAlphaComponent:1];
	// 2 - Get the graph's axis set
	CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostView.hostedGraph.axisSet;
	// 3 - Configure the x-axis
	axisSet.xAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
	axisSet.xAxis.title = @"Days of Week (Mon - Fri)";
	axisSet.xAxis.titleTextStyle = axisTitleStyle;
	axisSet.xAxis.titleOffset = 10.0f;
	axisSet.xAxis.axisLineStyle = axisLineStyle;
	// 4 - Configure the y-axis
	axisSet.yAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
	axisSet.yAxis.title = @"Price";
	axisSet.yAxis.titleTextStyle = axisTitleStyle;
	axisSet.yAxis.titleOffset = 5.0f;
	axisSet.yAxis.axisLineStyle = axisLineStyle;
}

-(void)hideAnnotation:(CPTGraph *)graph {
	if ((graph.plotAreaFrame.plotArea) && (self.priceAnnotation)) {
		[graph.plotAreaFrame.plotArea removeAnnotation:self.priceAnnotation];
		self.priceAnnotation = nil;
	}
}

#pragma mark - CPTPlotDataSource methods
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
	return [[[CPDStockPriceStore sharedInstance] datesInWeek] count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
	if ((fieldEnum == CPTBarPlotFieldBarTip) && (index < [[[CPDStockPriceStore sharedInstance] datesInWeek] count])) {
		if ([plot.identifier isEqual:CPDTickerSymbolAAPL]) {
			return [[[CPDStockPriceStore sharedInstance] weeklyPrices:CPDTickerSymbolAAPL] objectAtIndex:index];
		} else if ([plot.identifier isEqual:CPDTickerSymbolGOOG]) {
			return [[[CPDStockPriceStore sharedInstance] weeklyPrices:CPDTickerSymbolGOOG] objectAtIndex:index];
		} else if ([plot.identifier isEqual:CPDTickerSymbolMSFT]) {
			return [[[CPDStockPriceStore sharedInstance] weeklyPrices:CPDTickerSymbolMSFT] objectAtIndex:index];
		}
	}
	return [NSDecimalNumber numberWithUnsignedInteger:index];
}

#pragma mark - CPTBarPlotDelegate methods
-(void)barPlot:(CPTBarPlot *)plot barWasSelectedAtRecordIndex:(NSUInteger)index {
	// 1 - Is the plot hidden?
	if (plot.isHidden == YES) {
		return;
	}
	// 2 - Create style, if necessary
	static CPTMutableTextStyle *style = nil;
	if (!style) {
		style = [CPTMutableTextStyle textStyle];
		style.color= [CPTColor yellowColor];
		style.fontSize = 16.0f;
		style.fontName = @"Helvetica-Bold";
	}
	// 3 - Create annotation, if necessary
	NSNumber *price = [self numberForPlot:plot field:CPTBarPlotFieldBarTip recordIndex:index];
	if (!self.priceAnnotation) {
		NSNumber *x = [NSNumber numberWithInt:0];
		NSNumber *y = [NSNumber numberWithInt:0];
		NSArray *anchorPoint = [NSArray arrayWithObjects:x, y, nil];
		self.priceAnnotation = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:plot.plotSpace anchorPlotPoint:anchorPoint];
	}
	// 4 - Create number formatter, if needed
	static NSNumberFormatter *formatter = nil;
	if (!formatter) {
		formatter = [[NSNumberFormatter alloc] init];
		[formatter setMaximumFractionDigits:2];
	}
	// 5 - Create text layer for annotation
	NSString *priceValue = [formatter stringFromNumber:price];
	CPTTextLayer *textLayer = [[CPTTextLayer alloc] initWithText:priceValue style:style];
	self.priceAnnotation.contentLayer = textLayer;
	// 6 - Get plot index based on identifier
	NSInteger plotIndex = 0;
	if ([plot.identifier isEqual:CPDTickerSymbolAAPL] == YES) {
		plotIndex = 0;
	} else if ([plot.identifier isEqual:CPDTickerSymbolGOOG] == YES) {
		plotIndex = 1;
	} else if ([plot.identifier isEqual:CPDTickerSymbolMSFT] == YES) {
		plotIndex = 2;
	}
	// 7 - Get the anchor point for annotation
	CGFloat x = index + CPDBarInitialX + (plotIndex * CPDBarWidth);
	NSNumber *anchorX = [NSNumber numberWithFloat:x];
	CGFloat y = [price floatValue] + 40.0f;
	NSNumber *anchorY = [NSNumber numberWithFloat:y];
	self.priceAnnotation.anchorPlotPoint = [NSArray arrayWithObjects:anchorX, anchorY, nil];
	// 8 - Add the annotation
	[plot.graph.plotAreaFrame.plotArea addAnnotation:self.priceAnnotation];
}

@end
