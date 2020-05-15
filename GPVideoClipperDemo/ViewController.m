//
//  ViewController.m
//  GPVideoClipperDemo
//
//  Created by Roc Kwok on 2020/5/13.
//  Copyright © 2020 Roc Kwok. All rights reserved.
//

#import "ViewController.h"
#import "GPVideoClipperController.h"
#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVMediaFormat.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import <CoreServices/CoreServices.h>

@interface ViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)testAction:(id)sender {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            switch (status) {
                case PHAuthorizationStatusAuthorized:
                    [self album];
                    break;
                case PHAuthorizationStatusDenied: {
                    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"提示" message:@"去打开权限" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *leftAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                        [controller dismissViewControllerAnimated:YES completion:nil];
                    }];
                    UIAlertAction *rightAction = [UIAlertAction actionWithTitle:@"打开" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{UIApplicationOpenURLOptionUniversalLinksOnly : @NO} completionHandler:nil];

                        [controller dismissViewControllerAnimated:YES completion:nil];
                    }];
                    [controller addAction:leftAction];
                    [controller addAction:rightAction];
                    [self presentViewController:controller animated:YES completion:nil];
                }
                    break;
                case PHAuthorizationStatusRestricted:
                    break;
                default:
                    break;
            }
        });
    }];
    
}

- (void)album {
    UIImagePickerController *picker = UIImagePickerController.new;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.mediaTypes = @[(NSString *)kUTTypeMovie];
    
    
    [self presentViewController:picker animated:YES completion:^{
        
    }];
}

#pragma mark - <UIImagePickerControllerDelegate>

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:^{

    }];
    GPVideoClipperController *controller = GPVideoClipperController.new;
    controller.videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
    [controller setCallback:^(NSURL * _Nonnull videoURL, PHAsset * _Nonnull videoAsset, UIImage * _Nonnull coverImage) {
        // 处理裁剪后的videoURL，videoAsset，视频封面
        NSLog(@"videoURL:%@ \n videoAsset:%@ \n coverImage:%@",videoURL, videoAsset, coverImage);
    
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"提示" message:@"视频保存成功，请前往相册中查看!" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *doneAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [controller dismissViewControllerAnimated:YES completion:nil];
        }];
        [controller addAction:doneAction];
        [self presentViewController:controller animated:YES completion:nil];
        
    }];
    [self.navigationController pushViewController:controller animated:NO];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:^{

    }];
}

@end
