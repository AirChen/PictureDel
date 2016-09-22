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

typedef NS_ENUM(NSInteger, FilterState){
    filter_1,filter_2,filter_3,filter_4
};
@interface PicViewModel : NSObject<UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, readwrite, weak)  UIImageView *imageView;
@property (nonatomic, readwrite, weak)  UIBarButtonItem *picBtn;
@property (nonatomic, readwrite, weak)  UISlider *sliderVal;
@property (nonatomic, readwrite, weak)  UIButton *dealB;
@property (nonatomic, readwrite, weak)  UIPickerView *picker;
@property (nonatomic, readwrite, weak) UIViewController *totalVc;
@property (nonatomic, readwrite, strong, nonnull) RACCommand *picCommand;

@end
