//
//  PicViewModel.m
//  AIRPicDeal
//
//  Created by Air_chen on 16/6/28.
//  Copyright © 2016年 Air_chen. All rights reserved.
//

#import "PicViewModel.h"

@interface PicViewModel(){
    UIImagePickerController *_imagePicker;
    CIContext *_ctx;
    CIImage *_tmpImage;
    CIFilter *_filter;
    NSArray *_characterNames;
    NSInteger _currentItemIndex;
}

@property (nonatomic, readwrite, strong) UILabel *lab;
@end

@implementation PicViewModel

- (instancetype)init
{
    if (self = [super init]) {
        [self bindEvents];
    }
    return self;
}

- (void)bindEvents
{
    _picCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        
        [self viewWillAppear];
        RACSignal *sig = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            
            return nil;
        }];

        return sig;
    }];
}

- (void)viewWillAppear
{
    _imagePicker = [[UIImagePickerController alloc] init];
    _imagePicker.delegate = self;
    
    _ctx = [CIContext contextWithOptions: nil];
    
    [self hiddenController];
    
    _characterNames = [[NSArray alloc] initWithObjects:@"模糊",@"鱼眼",@"颜色",@"像素", nil];
    
    self.picker.delegate = self;
    self.picker.dataSource = self;
    
    //    添加手势
    self.imageView.userInteractionEnabled = YES;
    self.imageView.multipleTouchEnabled = YES;
    
    UISwipeGestureRecognizer*gesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftGesture:)];
    gesture.numberOfTouchesRequired = 1;
    gesture.direction = 1 << 0;//right
    [self.imageView addGestureRecognizer:gesture];

    UITapGestureRecognizer *gesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(docPicture)];
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 64)];
    lab.text = @"图片";
    lab.userInteractionEnabled = YES;
    [lab addGestureRecognizer:gesture1];
    [self.picItem setCustomView:lab];
    [self.picItem setAction:@selector(docPicture)];
    
    self.lab = lab;
    
    [[self.dealBtn rac_signalForControlEvents:UIControlEventTouchDown]subscribeNext:^(id x) {
        
        CGFloat slideValue = self.valSlider.value;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            switch (_currentItemIndex) {
                case 0:
                    _filter = [CIFilter filterWithName:@"CIGaussianBlur"];
                    [_filter setValue:[NSNumber numberWithFloat:slideValue] forKey:@"inputRadius"];
                    break;
                case 1:
                    _filter = [CIFilter filterWithName:@"CIBumpDistortion"];
                    [_filter setValue:[CIVector vectorWithX:150 Y:240]forKey:@"inputCenter"];
                    [_filter setValue:[NSNumber numberWithFloat:150]forKey:@"inputRadius"];
                    [_filter setValue:[NSNumber numberWithFloat:slideValue]forKey:@"inputScale"];
                    break;
                case 2:
                    _filter = [CIFilter filterWithName:@"CIHueAdjust"];
                    [_filter setValue:[NSNumber numberWithFloat:slideValue] forKey:@"inputAngle"];
                    break;
                case 3:
                    _filter = [CIFilter filterWithName:@"CIPixellate"];
                    [_filter setValue:[CIVector vectorWithX:150 Y:240]forKey:@"inputCenter"];
                    [_filter setValue:[NSNumber numberWithFloat:slideValue]forKey:@"inputScale"];
                    break;
                default:
                    break;
            }
            
            [_filter setValue:_tmpImage forKey:@"inputImage"];
            CIImage* outImage = [_filter outputImage];
            CGImageRef tmp = [_ctx createCGImage:outImage fromRect:[outImage extent]];
            UIImage* tmpUImage = [UIImage imageWithCGImage:tmp];
            CGImageRelease(tmp);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.imageView setImage:tmpUImage];
                
                _tmpImage = outImage;
                self.valSlider.value = 0.5f;
            });
        });
        
        [self hiddenController];
    }];
}

- (void)leftGesture:(UISwipeGestureRecognizer *)ges
{
    [self showController];
}

- (void)hiddenController{
    self.valSlider.enabled = NO;
    self.valSlider.alpha = 0;
    self.dealBtn.enabled = NO;
    self.dealBtn.alpha = 0;
    
    self.picker.hidden = YES;
}

- (void)showController{
    self.valSlider.enabled = YES;
    self.valSlider.alpha = 1;
    self.dealBtn.enabled = YES;
    self.dealBtn.alpha = 1;
    
    self.picker.hidden = NO;
    
    switch (_currentItemIndex) {
        case 0:
            [self setSliderValRange:0 and:10];
            break;
        case 1:
            [self setSliderValRange:-4 and:4];
            break;
        case 2:
            [self setSliderValRange:-6.28 and:6.28];
            break;
        case 3:
            [self setSliderValRange:0 and:30];
            break;
            
        default:
            break;
    }
}

- (void)setSliderValRange:(float) min and:(float)max
{
    self.valSlider.minimumValue = min;
    self.valSlider.maximumValue = max;
    self.valSlider.value = 0.5;
}

- (void)docPicture {
    if ([self.lab.text isEqualToString:@"图片"]) {
        [self.totalVc presentViewController:_imagePicker animated:YES completion:nil];
        self.lab.text = @"保存";
    }else{
        UIImageWriteToSavedPhotosAlbum(self.imageView.image, nil, nil,nil);
        self.lab.text= @"图片";
    }
}

#pragma mark - imagePickerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [self.totalVc dismissViewControllerAnimated:YES completion:nil];
    UIImage *selectedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    UIImage *tinyImage = [self transImage:selectedImage];
    self.imageView.image = tinyImage;
    _tmpImage = [CIImage imageWithCGImage:tinyImage.CGImage];
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
    return [_characterNames count];
}

#pragma mark Picker Delegate Methods
- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    return _characterNames[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    _currentItemIndex = row;
    [self showController];
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
