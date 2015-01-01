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
  
  [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kCellIdentifier];
  const NSInteger numberOfColors = 100;
  self.colorArray = [NSMutableArray arrayWithCapacity:numberOfColors];
  RACSignal *arrayChanged = RACObserve(self, itemCount);
  [[arrayChanged distinctUntilChanged] subscribeNext:^(NSNumber*number) {
    NSLog(@"added object collection view now has %li", number.integerValue);
  }];
  for (NSInteger i = 0; i < numberOfColors; i++)
  {
      CGFloat redValue = (arc4random() % 255) / 255.0f;
      CGFloat blueValue = (arc4random() % 255) / 255.0f;
      CGFloat greenValue = (arc4random() % 255) / 255.0f;
      [self addColor:[UIColor colorWithRed:redValue green:greenValue blue:blueValue alpha:1.0f]];
  }
  
  RACSignal *messageChanged = RACObserve(self, message);
  [[messageChanged distinctUntilChanged] subscribeNext:^(NSString *string){
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:string message:@"" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
    [alert show];
    NSLog(@"Message changed to: %@", string);
    CGFloat redValue = (arc4random() % 255) / 255.0f;
    CGFloat blueValue = (arc4random() % 255) / 255.0f;
    CGFloat greenValue = (arc4random() % 255) / 255.0f;
    [self addColor:[UIColor colorWithRed:redValue green:greenValue blue:blueValue alpha:1.0f]];
  }];
  
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
  
  [self.addCell rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
    [self ]
  }
}

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
