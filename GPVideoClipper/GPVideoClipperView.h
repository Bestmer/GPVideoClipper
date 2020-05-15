//
//  GPVideoClipperView.h
//  GPVideoClipper
//
//  Created by Roc Kwok on 2020/5/6.
//  Copyright © 2020 Roc Kwok. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "GPVideoConfigMaker.h"

NS_ASSUME_NONNULL_BEGIN

@protocol GPVideoClipperViewDelegate <NSObject>

@required
- (void)gp_cancelButtonAction:(UIButton *)button;
- (void)gp_doneButtonAction:(UIButton *)button;
- (void)gp_videoLengthDidChanged:(CGFloat)time;
- (void)gp_didEndDragging;

@end

@interface GPVideoClipperView : UIView

@property (nonatomic, strong) AVAsset *avAsset;
@property (nonatomic, weak) id <GPVideoClipperViewDelegate> delegate;
@property (nonatomic,assign) CGFloat progressTime;

- (void)gp_updateProgressViewWithProgress:(CGFloat)progress;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame maker:(GPVideoConfigMaker *)maker NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END


NS_ASSUME_NONNULL_BEGIN

@interface GPVideoClipperImageCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;

@end

NS_ASSUME_NONNULL_END
