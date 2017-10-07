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
@property (weak, nonatomic) IBOutlet UIBarButtonItem *picItem;
@property (weak, nonatomic) IBOutlet UISlider *valSlider;
@property (weak, nonatomic) IBOutlet UIButton *dealBtn;
@property (weak, nonatomic) IBOutlet UIPickerView *picker;
@property (nonatomic, readwrite, strong) PicViewModel *pictureVM;
@end

@implementation ViewController

- (PicViewModel *)pictureVM
{
    if (_pictureVM == nil) {
        _pictureVM = [[PicViewModel alloc] init];
        
        _pictureVM.imageView = self.imageView;
        _pictureVM.picItem = self.picItem;
        _pictureVM.valSlider = self.valSlider;
        _pictureVM.dealBtn = self.dealBtn;
        _pictureVM.picker = self.picker;
        _pictureVM.totalVc = self;
    }
    
    return _pictureVM;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    RACSignal *sig = [self.pictureVM.picCommand execute:nil];
    
    [sig subscribeNext:^(id x) {
        
    }];
    
}


@end
