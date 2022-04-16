//
//  TopbarViewController.m
//  XKVODemo
//
//  Created by yangcy on 2022/4/6.
//

#import "TopbarViewController.h"

@interface TopbarViewController ()

@property (nonatomic, strong) UIButton * goButton;
@property (nonatomic, strong) UITextField * urlTextField;

@end

@implementation TopbarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.jumpUrlSignal = [XSignal new];
    
    CGRect bounds = self.view.bounds;
    
    self.goButton = [[UIButton alloc] initWithFrame:CGRectMake(bounds.size.width - 20 - 80, 0, 80, 36)];
    [self.goButton setTitle:@"GO" forState:(UIControlStateNormal)];
    [self.goButton setTitleColor:[UIColor blackColor] forState:(UIControlStateNormal)];
    [self.view addSubview:self.goButton];
    
    [self.goButton addTarget:self action:@selector(goClicked) forControlEvents:(UIControlEventTouchUpInside)];

    self.urlTextField = [[UITextField alloc] initWithFrame:(CGRectMake(20, 0, bounds.size.width - 20 - 80, 36))];
    [self.view addSubview:self.urlTextField];
    [self.urlTextField setBackgroundColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5]];
    [self.urlTextField setText:@"Input URL"];

}

- (void)goClicked
{
    self.goBtnClickCount ++;
    
    NSString * url = self.urlTextField.text;
    NSLog(@"goClicked url:%@", url);
    
    self.jumpUrlSignal.emit(url);
}

@end
