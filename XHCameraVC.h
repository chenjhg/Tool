//
//  XHCameraVC.h
//  idbao
//
//  Created by 陈江红 on 16/3/15.
//  Copyright © 2016年 陈江红. All rights reserved.
//  自定义摄像头

#import <UIKit/UIKit.h>

@class XHCameraVC;

@protocol XHCameraVCDelegate <NSObject>

- (void)XHCameraVC:(XHCameraVC *)camera getImgae:(UIImage *)photoImage;
- (void)XHCameraVC:(XHCameraVC *)camera getPhotoFailedWithMessage:(NSString *)message;

@end

@interface XHCameraVC : UIViewController

@property (nonatomic, weak) id<XHCameraVCDelegate> delegate;


@end
