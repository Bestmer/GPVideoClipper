//
//  GPVideoPlayerView.h
//  GPVideoClipper
//
//  Created by Roc Kwok on 2020/5/6.
//  Copyright © 2020 Roc Kwok. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPVideoConfigMaker.h"
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol GPVideoPlayerViewDelegate <NSObject>

- (void)gp_videoReadyToPlay;

@end

@interface GPVideoPlayerView : UIView

@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) GPVideoConfigMaker *maker;
@property (nonatomic, weak) id <GPVideoPlayerViewDelegate> delegate;

- (void)play;
- (void)pause;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame videoURL:(NSURL *)videoURL NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
