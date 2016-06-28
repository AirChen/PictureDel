//
//  ViewController.m
//  AIRPicDeal
//
//  Created by Air_chen on 16/2/27.
//  Copyright © 2016年 Air_chen. All rights reserved.
//

#import "ViewController.h"
#import "PicViewModel.h"
#import "GlobalHeader.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *picBtn;
@property (weak, nonatomic) IBOutlet UISlider *sliderVal;
@property (weak, nonatomic) IBOutlet UIButton *dealB;
@property (weak, nonatomic) IBOutlet UIPickerView *picker;
@property(nonatomic,strong) PicViewModel *pictureVM;
@end

@implementation ViewController

-(PicViewModel *)pictureVM
{
    if (_pictureVM == nil) {
        _pictureVM = [[PicViewModel alloc] init];
    }
    
    return _pictureVM;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.pictureVM.imageView = self.imageView;
    self.pictureVM.picBtn = self.picBtn;
    self.pictureVM.sliderVal = self.sliderVal;
    self.pictureVM.dealB = self.dealB;
    self.pictureVM.picker = self.picker;
    self.pictureVM.totalVc = self;
    
    RACSignal *sig = [self.pictureVM.picCommand execute:nil];
    
    [sig subscribeNext:^(id x) {
        
    }];
    
}

@end