//
//  GPVideoClipperController.h
//  GPVideoClipper
//
//  Created by Roc Kwok on 2020/5/6.
//  Copyright © 2020 Roc Kwok. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface GPVideoClipperController : UIViewController

@property (nonatomic, strong) NSURL *videoURL;
@property (nonatomic, copy) void(^callback)(NSURL *videoURL, PHAsset *videoAsset, UIImage *coverImage);

@end

NS_ASSUME_NONNULL_END
