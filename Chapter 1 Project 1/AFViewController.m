//
//  AFViewController.m
//  Chapter 1 Project 1
//
//

#import "AFViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACDelegateProxy.h>

/*** Very simple example of reactive programming example in conjunction with a collection view.
 This example does three things. 
 
 1.) Displays a collection view with random colors.
 2.) Displays a UIAlertView when a message string is changed.
 3.) NSLogs a message when an item is added.
 
 Number 1 is pretty basic collection view. It's non reactive meaning it's not really using
 Reactive Cocoa. The collection view example code is taken from the sourcecode for the book
 
 RACObserve()
 ---------------------------
 Number 2.) Is Reactive Cocoa code. Here I want to display a UIAlertView whenever an NSString value
 is changed. In order to do this I observe the self.message NSString object using RACObserve.
 This creates a signal that receives the new value and displays a UIAlertView with the new string value.
 
 UIButton:rac_signalForControlEvents:
 ---------------------------------------------------
 Number 3.) Is also Reactive Cocoa where I bind a RAC signal to a touch up inside control event. When the 
 button receives the touch up inside event a signal is sent to create a new color cell add it to the collection view datasource
 and call reload data on the collection view.
 
 
 RACDelegateProxy
 ----------------------
 I am also using RACDelegateProxy to bind to the collection view's didSelectItemAtIndex selector.
 
 
 
 **/
@interface AFViewController()
@property (nonatomic, strong) id collectionViewDelegate;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSMutableArray *colorArray;
@property (nonatomic, strong) NSNumber *itemCount;
@property (nonatomic, strong) IBOutlet UIButton *addCell;
@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;
@end
static NSString *kCellIdentifier = @"Cell Identifier";

@implementation AFViewController
{
  
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  // basic objective-c
  [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kCellIdentifier];
  const NSInteger numberOfColors = 100;
  self.colorArray = [NSMutableArray arrayWithCapacity:numberOfColors];
  
  // rac signal when itemCount changes, reloads data and logs message.
  RACSignal *arrayChanged = RACObserve(self, itemCount);
  [[arrayChanged distinctUntilChanged] subscribeNext:^(NSNumber*number) {
    [self.collectionView reloadData];
    NSLog(@"added object collection view now has %li", number.integerValue);
  }];
  
  // load UIColors in colorArray
  for (NSInteger i = 0; i < numberOfColors; i++)
  {
      CGFloat redValue = (arc4random() % 255) / 255.0f;
      CGFloat blueValue = (arc4random() % 255) / 255.0f;
      CGFloat greenValue = (arc4random() % 255) / 255.0f;
      [self addColor:[UIColor colorWithRed:redValue green:greenValue blue:blueValue alpha:1.0f]];
  }
  
  // RAC signal to display new message in UIAlertView
  RACSignal *messageChanged = [RACObserve(self, message) skip:1];
  [[messageChanged distinctUntilChanged] subscribeNext:^(NSString *string){
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:string message:@"" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
    [alert show];
    NSLog(@"Message changed to: %@", string);  
  }];
  
  // Hook into collection view delegate method didSelectItemAtIndexPath
  self.collectionViewDelegate =
  [[RACDelegateProxy alloc] initWithProtocol:@protocol(UICollectionViewDelegate)];
  [[self.collectionViewDelegate
   rac_signalForSelector:@selector(collectionView:didDeselectItemAtIndexPath:)
            fromProtocol:@protocol(UICollectionViewDelegate)]
  subscribeNext:^(RACTuple *arguments) {
    NSIndexPath *path = arguments.second;
    self.message = [NSString stringWithFormat:@"Cell: %li in section %li.", (long)path.row, (NSInteger)path.section];
  }];
  
  self.collectionView.delegate = self.collectionViewDelegate;
  
  // RAC signal sent for control event touch up inside.
  [[self.addCell rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
    CGFloat redValue = (arc4random() % 255) / 255.0f;
    CGFloat blueValue = (arc4random() % 255) / 255.0f;
    CGFloat greenValue = (arc4random() % 255) / 255.0f;
    [self addColor:[UIColor colorWithRed:redValue green:greenValue blue:blueValue alpha:1.0f]];
  }];

}

// adds a color to collection view
- (void)addColor:(UIColor*)color {
  [self.colorArray addObject:color];
  self.itemCount = @(self.colorArray.count);
}

#pragma mark - UICollectionViewDataSource Methods

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
  return self.itemCount.integerValue;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier forIndexPath:indexPath];
    cell.backgroundColor = self.colorArray[indexPath.item];
    return cell;
}

@end
