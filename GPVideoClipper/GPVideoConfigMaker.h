//
//  GPVideoConfigMaker.h
//  GPVideoClipper
//
//  Created by Roc Kwok on 2020/5/6.
//  Copyright © 2020 Roc Kwok. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GPVideoConfigMaker : NSObject

#pragma mark - Required
/** 开始时间 */
@property (nonatomic, assign) CGFloat startTime;
/** 结束时间 */
@property (nonatomic, assign) CGFloat endTime;
/** 裁剪后视频的最小时长 */
@property (nonatomic, assign) CGFloat clippedVideoMinDuration;
/** 裁剪后视频的最长时长 */
@property (nonatomic, assign) CGFloat clippedVideoMaxDuration;
/** 源视频总时长（框架内部进行计算,使用者不需要关心） */
@property (nonatomic, assign) CGFloat sourceVideoTotalDuration;

#pragma mark - Optional
/** 是否隐藏已选择时间标签 */
@property (nonatomic, assign) BOOL isHiddenSelectedTimeTag;
/** 选择框颜色 */
@property (nonatomic, strong) UIColor *selectedBoxColor;
/** 左边框图片 */
@property (nonatomic, strong) UIImage *leftSelectedImage;
/** 右边框图片 */
@property (nonatomic, strong) UIImage *rightSelectedImage;
/** 左右选择框图片的宽度 */
@property (nonatomic, assign) CGFloat selectedImageWidth;
/** 初始化时选择框中选中的图片张数 */
@property (nonatomic, assign) NSInteger defaultSelectedImageCount;
/** 选择框整体左间距 */
@property (nonatomic, assign) CGFloat leftMargin;
/** 选择框整体右间距 */
@property (nonatomic, assign) CGFloat rightMargin;
/** 左边按钮字体 */
@property (nonatomic, strong) UIFont *leftButtonFont;
/** 左边按钮文字颜色 */
@property (nonatomic, strong) UIColor *leftButtonFontColor;
/** 左边按钮背景色 */
@property (nonatomic, strong) UIColor *leftButtonBackgroundColor;
/** 左边按钮标题 */
@property (nonatomic, copy) NSString *leftButtonTitle;
/** 右边按钮字体 */
@property (nonatomic, strong) UIFont *rightButtonFont;
/** 右边按钮文字颜色 */
@property (nonatomic, strong) UIColor *rightButtonFontColor;
/** 右边按钮背景色 */
@property (nonatomic, strong) UIColor *rightButtonBackgroundColor;
/** 右边按钮标题 */
@property (nonatomic, copy) NSString *rightButtonTitle;

@end

NS_ASSUME_NONNULL_END
