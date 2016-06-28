//
//  PicViewModel.m
//  AIRPicDeal
//
//  Created by Air_chen on 16/6/28.
//  Copyright © 2016年 Air_chen. All rights reserved.
//

#import "PicViewModel.h"

@interface PicViewModel(){
    UIImagePickerController *imagePicker;
    CIContext* ctx;
    CIImage* tmpImage;
    UIImage* tmpUImage;
    CIFilter* filter1;
    CIFilter* filter2;
    CIFilter* filter3;
    CIFilter* filter4;
    NSArray *characterNames;
}

@end

@implementation PicViewModel

enum filterStatus{
    filter_1,filter_2,filter_3,filter_4
} filterState;

-(instancetype)init
{
    if (self = [super init]) {
        
        [self bindEvents];
        
    }
    
    return self;
}

-(void)bindEvents
{
    _picCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        
        [self viewWillAppear];
        
            RACSignal *sig = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
               
                
                return nil;
            }];
            
            
            return sig;
        }];
}

-(void)viewWillAppear
{
    imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    
    ctx = [CIContext contextWithOptions: nil];
    
    filter1 = [CIFilter filterWithName:@"CIGaussianBlur"];
    filter2 = [CIFilter filterWithName:@"CIBumpDistortion"];
    filter3 = [CIFilter filterWithName:@"CIHueAdjust"];
    filter4 = [CIFilter filterWithName:@"CIPixellate"];
    
    [self showSome:false];
    [self showPicker:false];
    
    characterNames = [[NSArray alloc] initWithObjects:@"模糊",@"鱼眼",@"颜色",@"像素", nil];
    
    self.picker.delegate = self;
    self.picker.dataSource = self;
    
    //    添加手势
    self.imageView.userInteractionEnabled = YES;
    self.imageView.multipleTouchEnabled = YES;
    
    UISwipeGestureRecognizer*gesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftGesture:)];
    gesture.numberOfTouchesRequired = 1;
    gesture.direction = 1 << 0;//right
    [self.imageView addGestureRecognizer:gesture];

    self.picBtn = [self.picBtn initWithTitle:@"图片" style:UIBarButtonItemStylePlain target:self action:@selector(docPicture)];
    
    [[self.dealB rac_signalForControlEvents:UIControlEventTouchDown]subscribeNext:^(id x) {
        switch (filterState) {
            case filter_1:
                tmpImage = [filter1 outputImage];
                self.sliderVal.value = 0.5;
                break;
            case filter_2:
                tmpImage = [filter2 outputImage];
                self.sliderVal.value = 0.5;
                break;
            case filter_3:
                tmpImage = [filter3 outputImage];
                self.sliderVal.value = 0.5;
                break;
            case filter_4:
                tmpImage = [filter4 outputImage];
                self.sliderVal.value = 0.5;
                break;
            default:
                break;
        }
        
        [self showSome:false];
        [self showPicker:false];
    }];
    
    [[self.sliderVal rac_newValueChannelWithNilValue:nil] subscribeNext:^(NSNumber* x) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            CGFloat slideValue = x.floatValue;
            CIImage* outImage;
            
            switch (filterState) {
                case filter_1:
                    [filter1 setValue:tmpImage forKey:@"inputImage"];
                    [filter1 setValue:[NSNumber numberWithFloat:slideValue] forKey:@"inputRadius"];
                    outImage = [filter1 outputImage];
                    break;
                case filter_2:
                    [filter2 setValue:tmpImage forKey:@"inputImage"];
                    [filter2 setValue:[CIVector vectorWithX:150 Y:240]forKey:@"inputCenter"];
                    [filter2 setValue:[NSNumber numberWithFloat:150]forKey:@"inputRadius"];
                    [filter2 setValue:[NSNumber numberWithFloat:slideValue]forKey:@"inputScale"];
                    outImage = [filter2 outputImage];
                    break;
                case filter_3:
                    [filter3 setValue:tmpImage forKey:@"inputImage"];
                    [filter3 setValue:[NSNumber numberWithFloat:slideValue] forKey:@"inputAngle"];
                    outImage = [filter3 outputImage];
                    break;
                case filter_4:
                    [filter4 setValue:tmpImage forKey:@"inputImage"];
                    [filter4 setValue:[CIVector vectorWithX:150 Y:240]forKey:@"inputCenter"];
                    [filter4 setValue:[NSNumber numberWithFloat:slideValue]forKey:@"inputScale"];
                    outImage = [filter4 outputImage];
                    break;
                default:
                    break;
            }
            
            CGImageRef tmp = [ctx createCGImage:outImage fromRect:[outImage extent]];
            tmpUImage = [UIImage imageWithCGImage:tmp];
            CGImageRelease(tmp);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.imageView setImage:tmpUImage];
                
            });
         });
    }];
}

- (void)leftGesture:(UISwipeGestureRecognizer *)ges
{
    [self showPicker:YES];
}

//显示和隐藏slider和确定
- (void)showSome:(BOOL) decide
{
    if (decide) {
        self.sliderVal.enabled = true;
        self.sliderVal.alpha = 1;
        self.dealB.enabled = true;
        self.dealB.alpha = 1;
    }else{
        self.sliderVal.enabled = false;
        self.sliderVal.alpha = 0;
        self.dealB.enabled = false;
        self.dealB.alpha = 0;
    }
}

//picker的显示与隐藏
- (void)showPicker:(BOOL) decide
{
    self.picker.hidden = !decide;
}

//根据四类滤镜选择范围
- (void)setSliderValRange:(float) min and:(float)max
{
    self.sliderVal.minimumValue = min;
    self.sliderVal.maximumValue = max;
    self.sliderVal.value = 0.5;
}

//合并图片和保存按键
- (void)docPicture {
    if ([self.picBtn.title  isEqual: @"图片"]) {
        [self.totalVc presentViewController:imagePicker animated:YES completion:nil];
        self.picBtn.title = @"保存";
    }else{
        UIImageWriteToSavedPhotosAlbum(self.imageView.image, nil, nil,nil);
        self.picBtn.title = @"图片";
    }
}

#pragma mark - imagePickerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    
    [self.totalVc dismissViewControllerAnimated:YES completion:nil];
    UIImage *selectedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    UIImage *tinyImage = [self transImage:selectedImage];
    self.imageView.image = tinyImage;
    tmpImage = [CIImage imageWithCGImage:tinyImage.CGImage];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.totalVc dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Picker Data Source Methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
    return [characterNames count];
}

#pragma mark Picker Delegate Methods
- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    return characterNames[row];
}

//选择相应的滤镜
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSString *selectStr = [NSString stringWithString:characterNames[row]];
    if ([selectStr  isEqualToString: @"模糊"]) {
        [self setSliderValRange:0 and:10];
        [self showSome:true];
        filterState = filter_1;
    }else if([selectStr isEqualToString:@"鱼眼"]){
        [self setSliderValRange:-4 and:4];
        [self showSome:true];
        filterState = filter_2;
    }else if([selectStr isEqualToString:@"颜色"]){
        [self setSliderValRange:-6.28 and:6.28];
        [self showSome:true];
        filterState = filter_3;
    }else{
        [self setSliderValRange:0 and:30];
        [self showSome:true];
        filterState = filter_4;
    }
}

- (UIImage *)transImage:(UIImage *)image//图片转换成小图
{
    CGSize origImageSize = image.size;
    CGRect newRect = CGRectMake(0, 0,SCREEN_With,SCREEN_Height);
    //    得到的图片尺寸
    
    float ratio = MAX(newRect.size.width / origImageSize.width, newRect.size.height / origImageSize.height);
    
    UIGraphicsBeginImageContextWithOptions(newRect.size, NO, 0.0);//根据当前设备屏幕的scaling factor创建透明的位图上下文
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:newRect cornerRadius:8.0];
    
    [path addClip];
    CGRect projectRect;
    projectRect.size.width = ratio * origImageSize.width;
    projectRect.size.height = ratio * origImageSize.height;
    projectRect.origin.x = (newRect.size.width - projectRect.size.width) / 2.0;
    projectRect.origin.y = (newRect.size.height - projectRect.size.height) / 2.0;
    
    [image drawInRect:projectRect];
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    return smallImage;
}


@end
