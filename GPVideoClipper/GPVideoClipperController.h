//
//  GPVideoClipperController.h
//  GPVideoClipper
//
//  Created by Roc Kwok on 2020/5/6.
//  Copyright © 2020 Roc Kwok. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "GPVideoConfigMaker.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^ClipperCallback)(NSURL *videoURL, PHAsset *videoAsset, UIImage *coverImage);

@interface GPVideoClipperController : UIViewController

+ (instancetype)clipperWithVideoURL:(NSURL *)videoURL
                             maker:(void (^__nullable)(GPVideoConfigMaker *maker))makerBlock
                           callback:(ClipperCallback)callback;

@end

NS_ASSUME_NONNULL_END
