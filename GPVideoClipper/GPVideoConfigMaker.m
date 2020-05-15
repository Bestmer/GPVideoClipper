//
//  GPVideoConfigMaker.m
//  GPVideoClipper
//
//  Created by Roc Kwok on 2020/5/6.
//  Copyright © 2020 Roc Kwok. All rights reserved.
//

#import "GPVideoConfigMaker.h"

@implementation GPVideoConfigMaker

- (instancetype)init {
    if (self = [super init]) {
        self.clippedVideoMinDuration = 3.0f;
        self.clippedVideoMaxDuration = 15.0f;
        self.leftMargin = 30.0;
        self.rightMargin = 30.0;
        self.defaultSelectedImageCount = 8;
        self.selectedImageWidth = 15.0f;
        self.isHiddenSelectedTimeTag = NO;
        self.selectedBoxColor = UIColor.whiteColor;
        self.leftButtonTitle = @"取消";
        self.leftButtonFont = [UIFont boldSystemFontOfSize:16];
        self.leftButtonFontColor = UIColor.whiteColor;
        self.leftButtonBackgroundColor = UIColor.clearColor;
        self.rightButtonTitle = @"完成";
        self.rightButtonFont = [UIFont boldSystemFontOfSize:16];
        self.rightButtonFontColor = UIColor.whiteColor;
        self.rightButtonBackgroundColor = [UIColor colorWithRed:65/255.0 green:200/255.0 blue:86/255.0 alpha:1.0];
    }
    return self;
}

@end
