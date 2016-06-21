//
//  XHCameraVC.m
//  idbao
//
//  Created by 陈江红 on 16/3/15.
//  Copyright © 2016年 陈江红. All rights reserved.
//

#import "XHCameraVC.h"
#import <AVFoundation/AVFoundation.h>

@interface XHCameraVC ()<AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate>

@property (nonatomic, strong)       AVCaptureSession            * session;
//AVCaptureSession对象来执行输入设备和输出设备之间的数据传递
@property (nonatomic, strong)       AVCaptureDeviceInput        * videoInput;
//AVCaptureDeviceInput对象是输入流
@property (nonatomic, strong)       AVCaptureVideoPreviewLayer  * previewLayer;
//预览图层，来显示照相机拍摄到的画面
@property (nonatomic, strong)       AVCaptureStillImageOutput   * stillImageOutput;
//照片输出流对象，当然我的照相机只有拍照功能，所以只需要这个对象就够了
@property (nonatomic, strong)       AVCaptureConnection         * videoConnection;

@property (nonatomic, strong)       UIBarButtonItem             * toggleButton;
//切换前后镜头的按钮
@property (nonatomic, strong)       UIButton                    * shutterButton;
//拍照按钮
@property (nonatomic, strong)       UIView                      * cameraShowView;

@end

@implementation XHCameraVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initialSession];
}

- (IBAction)closeCamera:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)initialSession
{
    //这个方法的执行我放在init方法里了
    self.session = [[AVCaptureSession alloc] init];
    self.session.sessionPreset = AVCaptureSessionPreset640x480;
    self.videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self backCamera] error:nil];
    //[self backCamera]方法会返回一个AVCaptureDevice对象，因为我初始化时是采用后摄像头，所以这么写，具体的实现方法后面会介绍
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary * outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey, nil];
    //这是输出流的设置参数AVVideoCodecJPEG参数表示以JPEG的图片格式输出图片
    [self.stillImageOutput setOutputSettings:outputSettings];

    if ([self.session canAddInput:self.videoInput]) {
        [self.session addInput:self.videoInput];
    }
    if ([self.session canAddOutput:self.stillImageOutput]) {
        [self.session addOutput:self.stillImageOutput];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setUpCameraLayer];
    if (self.session) {
        [self.session startRunning];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear: animated];
    if (self.session) {
        [self.session stopRunning];
    }
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}

- (AVCaptureDevice *)backCamera
{
    return [self cameraWithPosition:AVCaptureDevicePositionBack];
}

- (void)setUpCameraLayer
{
    if (self.previewLayer == nil) {
        self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
        CALayer * viewLayer = [self.view layer];
        [self.previewLayer setFrame:CGRectMake(0, 50, kScreenWidth, kScreenHeight-170)];
        [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        [viewLayer insertSublayer:self.previewLayer below:[[viewLayer sublayers] objectAtIndex:0]];
    }
}

- (IBAction)clickTakePhoto:(id)sender
{
    self.videoConnection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    if (!self.videoConnection) {
        
        if ([self.delegate respondsToSelector:@selector(XHCameraVC:getPhotoFailedWithMessage:)])
        {
            [self.delegate XHCameraVC:self getPhotoFailedWithMessage:@"take photo failed!"];
        }
        return;
    }
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:self.videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (imageDataSampleBuffer == NULL) {
            return;
        }
        NSData * imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        UIImage * image = [UIImage imageWithData:imageData];
        NSLog(@"image size = %@",NSStringFromCGSize(image.size));
        if ([self.delegate respondsToSelector:@selector(XHCameraVC:getImgae:)])
        {
            [self.delegate XHCameraVC:self getImgae:image];
        }
    }];
}

@end
