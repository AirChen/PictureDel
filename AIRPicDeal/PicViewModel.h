//
//  PicViewModel.h
//  AIRPicDeal
//
//  Created by Air_chen on 16/6/28.
//  Copyright © 2016年 Air_chen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GlobalHeader.h"

@interface PicViewModel : NSObject<UIPickerViewDelegate,UIPickerViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (strong, nonatomic)  UIImageView *imageView;
@property (strong, nonatomic)  UIBarButtonItem *picBtn;
@property (strong, nonatomic)  UISlider *sliderVal;
@property (strong, nonatomic)  UIButton *dealB;
@property (strong, nonatomic)  UIPickerView *picker;
@property (strong, nonatomic) UIViewController *totalVc;
@property (nonatomic,strong) RACCommand *picCommand;

@end
