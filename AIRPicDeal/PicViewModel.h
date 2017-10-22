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

@interface PicViewModel : NSObject<UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, readwrite, weak)  UIImageView * _Nullable imageView;
@property (nonatomic, readwrite, weak)  UIBarButtonItem * _Nullable picItem;
@property (nonatomic, readwrite, weak)  UISlider * _Nullable valSlider;
@property (nonatomic, readwrite, weak)  UIPickerView * _Nullable picker;
@property (nonatomic, readwrite, weak) UIViewController * _Nullable totalVc;
@property (nonatomic, readwrite, strong, nonnull) RACCommand *picCommand;

@end
