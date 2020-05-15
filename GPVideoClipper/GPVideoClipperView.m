//
//  GPVideoClipperView.m
//  GPVideoClipper
//
//  Created by Roc Kwok on 2020/5/6.
//  Copyright © 2020 Roc Kwok. All rights reserved.
//

#import "GPVideoClipperView.h"

static const CGFloat kDurationLabelWidth = 70.0f;
static const CGFloat kButtonWidth = 60.0f;
static const CGFloat kButtonHeight = 30.0f;
static const CGFloat kLineHeight = 3.0f;

@interface GPVideoClipperView()<UICollectionViewDelegate, UICollectionViewDataSource> {
    CGFloat _preOriginX;
    CGFloat _selectedTime;
    CGFloat _cellWidth;
    NSInteger _cellCount;
    CGFloat _perSecondWidth;
    UIEdgeInsets _collectionInsets;
}

@property (nonatomic, strong) GPVideoConfigMaker *maker;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UILabel *durationLabel;
@property (nonatomic, strong) UIImageView *leftImageView;
@property (nonatomic, strong) UIImageView *rightImageView;
@property (nonatomic, strong) UIImageView *topLineView;
@property (nonatomic, strong) UIImageView *bottomLineView;
@property (nonatomic, strong) UIView *selectedImageView;
@property (nonatomic, strong) UIButton *progressView;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *doneButton;
@property (nonatomic, strong) AVAssetImageGenerator *imageGenerator;
@property (nonatomic, strong) NSMutableArray *imagesArray;

@end

@implementation GPVideoClipperView

- (instancetype)initWithFrame:(CGRect)frame maker:(GPVideoConfigMaker *)maker {
    if (self = [super initWithFrame:frame]) {
        self.maker = maker;
        self.userInteractionEnabled = YES;
        self.clipsToBounds = YES;
        self.backgroundColor = UIColor.clearColor;
        _cellWidth = (self.frame.size.width - self.maker.leftMargin - self.maker.rightMargin - self.maker.selectedImageWidth * 2) / self.maker.defaultSelectedImageCount;
        if (self.maker.sourceVideoTotalDuration <= self.maker.clippedVideoMaxDuration) {
            self.maker.endTime = self.maker.sourceVideoTotalDuration;
            _cellCount = self.maker.defaultSelectedImageCount;
        } else {
            self.maker.endTime = self.maker.clippedVideoMaxDuration;
            _cellCount = self.maker.sourceVideoTotalDuration / (self.maker.endTime / self.maker.defaultSelectedImageCount);
        }
        _perSecondWidth = (self.frame.size.width - self.maker.leftMargin - self.maker.rightMargin - self.maker.selectedImageWidth - self.maker.selectedImageWidth) / (self.maker.endTime - self.maker.startTime);
        _collectionInsets = UIEdgeInsetsMake(0, self.maker.leftMargin + self.maker.selectedImageWidth, 0, self.maker.rightMargin + self.maker.selectedImageWidth);
        [self p_configSubview];
    }
    return self;
}

#pragma mark - Private

- (void)p_configSubview {
    [self addSubview:self.collectionView];
    [self addSubview:self.durationLabel];
    [self addSubview:self.topLineView];
    [self addSubview:self.bottomLineView];
    [self addSubview:self.leftImageView];
    [self addSubview:self.rightImageView];
    [self addSubview:self.progressView];
    [self addSubview:self.cancelButton];
    [self addSubview:self.doneButton];

    self.durationLabel.frame = CGRectMake(self.frame.size.width - kDurationLabelWidth - 30, 8, kDurationLabelWidth, 20);
    self.topLineView.frame = CGRectMake(self.maker.leftMargin + self.maker.selectedImageWidth , _collectionView.frame.origin.y, self.frame.size.width - self.maker.leftMargin - self.maker.rightMargin - self.maker.selectedImageWidth * 2, kLineHeight);
    self.bottomLineView.frame = CGRectMake(self.topLineView.frame.origin.x, CGRectGetMaxY(self.collectionView.frame) - kLineHeight, self.topLineView.frame.size.width, kLineHeight);
    self.leftImageView.frame = CGRectMake(self.maker.leftMargin, _collectionView.frame.origin.y, self.maker.selectedImageWidth, _collectionView.frame.size.height);
    self.rightImageView.frame = CGRectMake(self.frame.size.width - self.maker.selectedImageWidth - self.maker.rightMargin, _collectionView.frame.origin.y, self.maker.selectedImageWidth, _collectionView.frame.size.height);
    self.progressView.frame = CGRectMake(CGRectGetMaxX(self.leftImageView.frame), CGRectGetMaxY(_topLineView.frame), 3, 54);
    self.cancelButton.frame = CGRectMake(30, self.frame.size.height - kButtonHeight, kButtonWidth, kButtonHeight);
    self.doneButton.frame = CGRectMake(self.frame.size.width - kButtonWidth - 30, self.frame.size.height - kButtonHeight, kButtonWidth, kButtonHeight);
}

- (void)p_loadThumbnailImages {
    _selectedTime = _maker.endTime - _maker.startTime;
    self.durationLabel.text = [NSString stringWithFormat:@"已选取%@s",[NSString stringWithFormat:@"%.0f", _selectedTime]];
    
    NSMutableArray *array = [NSMutableArray array];
    
    CMTime startTime = kCMTimeZero;
    CMTime addTime = CMTimeMakeWithSeconds(_maker.sourceVideoTotalDuration / _cellCount, 1000);
    CMTime endTime = CMTimeMakeWithSeconds(_maker.sourceVideoTotalDuration, 1000);

    while (CMTIME_COMPARE_INLINE(startTime, <=, endTime)) {
        [array addObject:[NSValue valueWithCMTime:startTime]];
        startTime = CMTimeAdd(startTime, addTime);
    }
    
    __weak __typeof(self) weakSelf = self;
    __block int index = 0;
    [self.imageGenerator generateCGImagesAsynchronouslyForTimes:array completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
        if (result == AVAssetImageGeneratorSucceeded) {
            UIImage *img = [[UIImage alloc] initWithCGImage:image];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.imagesArray addObject:img];
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
                [weakSelf.collectionView insertItemsAtIndexPaths:@[indexPath]];
                index++;
            });
        }
    }];
}

#pragma mark - Public

- (void)gp_updateProgressViewWithProgress:(CGFloat)progress {
    if (self.selectedImageView != nil) {
        return;
    }
    CGFloat width = CGRectGetMinX(self.rightImageView.frame) - CGRectGetMaxX(self.leftImageView.frame);
    CGFloat newX = CGRectGetMaxX(self.leftImageView.frame) + progress * width;
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction animations:^{
        self.progressView.frame = CGRectMake(newX, self.progressView.frame.origin.y, self.progressView.frame.size.width,  self.progressView.frame.size.height);
    } completion:nil];
}

#pragma mark - <UICollectionViewDelegate, UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imagesArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    GPVideoClipperImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(GPVideoClipperImageCell.self) forIndexPath:indexPath];
    cell.imageView.image = self.imagesArray[indexPath.item];
    return cell;
}

#pragma mark - Action

- (void)cancelButtonAction:(UIButton *)button {
    if (self.delegate && [self.delegate respondsToSelector:@selector(gp_cancelButtonAction:)]) {
        [self.delegate gp_cancelButtonAction:button];
    }
}

- (void)doneButtonAction:(UIButton *)button {
    if (self.delegate && [self.delegate respondsToSelector:@selector(gp_doneButtonAction:)]) {
        [self.delegate gp_doneButtonAction:button];
    }
}

- (void)panGesture:(UIPanGestureRecognizer *)gesture {
    CGPoint point = [gesture translationInView:self.superview];
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan: {
            _preOriginX = 0;
            _selectedImageView = gesture.view;
        }
            break;
        case UIGestureRecognizerStateChanged: {
            CGFloat offsetX = point.x - _preOriginX;
            _preOriginX = point.x;
            if (_selectedImageView == _leftImageView) {
                CGRect frame = _leftImageView.frame;
                frame.origin.x += offsetX;
                if (frame.origin.x <= self.maker.leftMargin) {
                    offsetX += self.maker.leftMargin - frame.origin.x;
                    frame.origin.x = self.maker.leftMargin;
                }
                CGFloat minLength =  self.rightImageView.frame.origin.x - self.maker.clippedVideoMinDuration * _perSecondWidth - self.maker.selectedImageWidth;
                if (frame.origin.x >= minLength) {
                    offsetX -= frame.origin.x - minLength;
                    frame.origin.x = minLength;
                }
                CGFloat time = offsetX / _perSecondWidth;
                _maker.startTime = _maker.startTime + time;
                _leftImageView.frame = frame;
                if (self.delegate && [self.delegate respondsToSelector:@selector(gp_videoLengthDidChanged:)]) {
                    [self.delegate gp_videoLengthDidChanged:_maker.startTime];
                }
            } else if (_selectedImageView == _rightImageView) {
                CGRect frame = _rightImageView.frame;
                frame.origin.x += offsetX;
                CGFloat rightImageMaxX = self.frame.size.width - self.maker.rightMargin - self.maker.selectedImageWidth;
                if (frame.origin.x >= rightImageMaxX) {
                    offsetX -= frame.origin.x - rightImageMaxX;
                    frame.origin.x = rightImageMaxX;
                }
                CGFloat rightImageMinX = CGRectGetMaxX(self.leftImageView.frame) + self.maker.clippedVideoMinDuration * _perSecondWidth;
                if (frame.origin.x <= rightImageMinX) {
                    offsetX += rightImageMinX - frame.origin.x;
                    frame.origin.x = rightImageMinX;
                }
                CGFloat time = offsetX / _perSecondWidth;
                _maker.endTime = _maker.endTime + time;
                _rightImageView.frame = frame;
                if ([_delegate respondsToSelector:@selector(gp_videoLengthDidChanged:)]) {
                    [_delegate gp_videoLengthDidChanged:_maker.endTime];
                }
            }
            _progressView.frame = CGRectMake(CGRectGetMaxX(_leftImageView.frame), _progressView.frame.origin.y, _progressView.frame.size.width, _progressView.frame.size.height);
            _selectedTime = _maker.endTime - _maker.startTime;
            _durationLabel.text = [NSString stringWithFormat:@"已选取%@s", [NSString stringWithFormat:@"%.0f", _selectedTime]];
            
            CGRect topLineFrame = _topLineView.frame;
            CGRect bottomLineFrame = _bottomLineView.frame;
            topLineFrame.origin.x = bottomLineFrame.origin.x = CGRectGetMaxX(_leftImageView.frame);
            topLineFrame.size.width = bottomLineFrame.size.width = CGRectGetMinX(_rightImageView.frame) - CGRectGetMaxX(_leftImageView.frame) ;
            _topLineView.frame = topLineFrame;
            _bottomLineView.frame = bottomLineFrame;
        }
            break;
        case UIGestureRecognizerStateEnded: {
            _selectedImageView = nil;
            if ([_delegate respondsToSelector:@selector(gp_didEndDragging)]) {
                [_delegate gp_didEndDragging];
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - <ScrollViewDelegate>

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat time = (scrollView.contentOffset.x + _collectionInsets.left) / _perSecondWidth;
    CGFloat startTime = time + (CGRectGetMaxX(self.leftImageView.frame) - _collectionInsets.left) / _perSecondWidth;
    if (startTime < 0) return;
    
    self.maker.startTime = startTime;
    CGFloat endTime = self.maker.startTime + _selectedTime;
    self.maker.endTime = endTime > self.maker.sourceVideoTotalDuration ? self.maker.sourceVideoTotalDuration:endTime;
    self.maker.startTime = self.maker.endTime - _selectedTime;
    [self gp_updateProgressViewWithProgress:0.0];
    if ([_delegate respondsToSelector:@selector(gp_videoLengthDidChanged:)]) {
        [_delegate gp_videoLengthDidChanged:self.maker.startTime + self.progressTime];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if ([_delegate respondsToSelector:@selector(gp_didEndDragging)]) {
        [_delegate gp_didEndDragging];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (!decelerate) {
        if ([_delegate respondsToSelector:@selector(gp_didEndDragging)]) {
            [_delegate gp_didEndDragging];
        }
    }
}

#pragma mark - Setters

- (void)setAvAsset:(AVAsset *)avAsset {
    _avAsset = avAsset;
    [self p_loadThumbnailImages];
}

#pragma mark - Getters

- (GPVideoConfigMaker *)maker {
    if (!_maker) {
        _maker = [GPVideoConfigMaker new];
    }
    return _maker;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(_cellWidth , 60);
        layout.minimumLineSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 35, self.frame.size.width, 60) collectionViewLayout:layout];
        _collectionView.contentInset = _collectionInsets;
        _collectionView.backgroundColor = UIColor.clearColor;
        _collectionView.alwaysBounceHorizontal = YES;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.clipsToBounds = NO;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[GPVideoClipperImageCell class] forCellWithReuseIdentifier:NSStringFromClass(GPVideoClipperImageCell.self)];
    }
    return _collectionView;
}

- (UILabel *)durationLabel {
    if (!_durationLabel) {
        _durationLabel = [UILabel new];
        _durationLabel.font = [UIFont boldSystemFontOfSize:12];
        _durationLabel.backgroundColor = UIColor.blackColor;
        _durationLabel.textColor = [UIColor whiteColor];
        _durationLabel.textAlignment = NSTextAlignmentRight;
        _durationLabel.hidden = self.maker.isHiddenSelectedTimeTag;
    }
    return _durationLabel;
}

- (UIImageView *)leftImageView {
    if (!_leftImageView) {
        _leftImageView = [UIImageView new];
        _leftImageView.userInteractionEnabled = YES;
        _leftImageView.contentMode = UIViewContentModeScaleAspectFill;
        if (self.maker.selectedBoxColor) {
            _leftImageView.backgroundColor = self.maker.selectedBoxColor;
        }
        if (self.maker.leftSelectedImage) {
            _leftImageView.image = self.maker.leftSelectedImage;
        }
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
        panGesture.maximumNumberOfTouches = 1;
        [_leftImageView addGestureRecognizer:panGesture];
    }
    return _leftImageView;
}

- (UIImageView *)rightImageView {
    if (!_rightImageView) {
       _rightImageView = [UIImageView new];
       _rightImageView.userInteractionEnabled = YES;
       _rightImageView.contentMode = UIViewContentModeScaleAspectFill;
       if (self.maker.selectedBoxColor) {
           _rightImageView.backgroundColor = self.maker.selectedBoxColor;
       }
       if (self.maker.rightSelectedImage) {
           _rightImageView.image = self.maker.rightSelectedImage;
       }
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
        panGesture.maximumNumberOfTouches = 1;
        panGesture.minimumNumberOfTouches = 1;
        [_rightImageView addGestureRecognizer:panGesture];
    }
    return _rightImageView;
}

- (UIImageView *)topLineView {
    if (!_topLineView) {
        _topLineView = [UIImageView new];
        if (self.maker.selectedBoxColor) {
           _topLineView.backgroundColor = self.maker.selectedBoxColor;
        }
    }
    return _topLineView;
}

- (UIImageView *)bottomLineView {
    if (!_bottomLineView) {
        _bottomLineView = [UIImageView new];
         if (self.maker.selectedBoxColor) {
           _bottomLineView.backgroundColor = self.maker.selectedBoxColor;
        }
    }
    return _bottomLineView;
}

- (UIButton *)progressView {
    if (!_progressView) {
        _progressView = [UIButton buttonWithType:UIButtonTypeCustom];
        _progressView.backgroundColor = [UIColor colorWithRed:171/255.0 green:169/255.0 blue:166/255.0 alpha:0.7];
        _progressView.layer.cornerRadius = 3.0 / 2.0;
        _progressView.enabled = NO;
        _progressView.userInteractionEnabled = YES;
    }
    return _progressView;
}

- (NSMutableArray *)imagesArray {
    if (!_imagesArray) {
        _imagesArray = [NSMutableArray array];
    }
    return _imagesArray;
}

- (AVAssetImageGenerator *)imageGenerator {
    if (!_imageGenerator) {
        _imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:self.avAsset];
        _imageGenerator.appliesPreferredTrackTransform = YES;
        _imageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
        _imageGenerator.requestedTimeToleranceAfter = kCMTimeZero;
        _imageGenerator.maximumSize = CGSizeMake(320, 320);
    }
    return _imageGenerator;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelButton.titleLabel.font = self.maker.leftButtonFont;
        [_cancelButton setTitle:self.maker.leftButtonTitle forState:UIControlStateNormal];
        [_cancelButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

- (UIButton *)doneButton {
    if (!_doneButton) {
        _doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _doneButton.titleLabel.font = self.maker.rightButtonFont;
        _doneButton.backgroundColor = self.maker.rightButtonBackgroundColor;
        _doneButton.layer.cornerRadius = 5.0f;
        _doneButton.clipsToBounds = YES;
        [_doneButton setTitle:self.maker.rightButtonTitle forState:UIControlStateNormal];
        [_doneButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [_doneButton addTarget:self action:@selector(doneButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _doneButton;
}

- (CGFloat)progressTime{
    return (CGRectGetMinX(_progressView.frame) - CGRectGetMaxX(_leftImageView.frame)) / _perSecondWidth;
}

@end

#pragma mark - Custom Cell

@implementation GPVideoClipperImageCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.imageView];
        self.contentView.backgroundColor = self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = UIImageView.new;
        _imageView.frame = self.contentView.bounds;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
    }
    return _imageView;
}

@end

