//
//  GPVideoClipperController.m
//  GPVideoClipper
//
//  Created by Roc Kwok on 2020/5/6.
//  Copyright © 2020 Roc Kwok. All rights reserved.
//

#import "GPVideoClipperController.h"
#import "GPVideoPlayerView.h"
#import "GPVideoClipperView.h"
#import <sys/utsname.h>

static NSString *kCutVideoPath =  @"cutDoneVideo.mp4";
static CGFloat kClipViewHeight = 135;

@interface GPVideoClipperController ()<GPVideoPlayerViewDelegate, GPVideoClipperViewDelegate> {
    NSURL *_outputURL;
}

@property (nonatomic, strong) GPVideoPlayerView *playerView;
@property (nonatomic, strong) GPVideoClipperView *clipperView;
@property (nonatomic, strong) GPVideoConfigMaker *maker;
@property (nonatomic, strong) id timeObserver;
@property (nonatomic, strong) UIImage *coverImage;
@property (nonatomic, strong) PHFetchResult *collectonResuts;

@end

@implementation GPVideoClipperController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.blackColor;
    [self.view addSubview:self.playerView];
    [self.view addSubview:self.clipperView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark - Private

- (void)gp_playVideo {
    [self.playerView.player seekToTime:CMTimeMake(self.maker.startTime * 1000, 1000) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    [self.playerView.player play];
    if (self.timeObserver) {
      [self.playerView.player removeTimeObserver:self.timeObserver];
      self.timeObserver = nil;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __weak __typeof(self) weakSelf = self;
        self.timeObserver = [self.playerView.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 10) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
            __strong __typeof(self) strongSelf = weakSelf;
            CGFloat delta = CMTimeGetSeconds(time);
            [strongSelf.clipperView gp_updateProgressViewWithProgress:(delta - strongSelf.maker.startTime) / (strongSelf.maker.endTime - strongSelf.maker.startTime)];
        }];
    });
}

- (CGFloat)gp_safeAreaBottomHeight {
    CGFloat bottom = 0;
    if (@available(iOS 11.0, *)) {
        bottom = UIApplication.sharedApplication.windows.firstObject.safeAreaInsets.bottom;
    }
    if (bottom <= 0 && [self gp_isIphoneXSeries]) {
        bottom = 34;
    }
    return bottom;
}

- (BOOL)gp_isIphoneXSeries {
    static BOOL isIphoneX = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSSet *platformSet = [NSSet setWithObjects:@"iPhone10,3", @"iPhone10,6", @"iPhone11,8", @"iPhone11,2", @"iPhone11,4", @"iPhone11,6", nil];
        struct utsname systemInfo;
        uname(&systemInfo);
        NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
        if ([platform isEqualToString:@"x86_64"] || [platform isEqualToString:@"i386"]) {
            platform = NSProcessInfo.processInfo.environment[@"SIMULATOR_MODEL_IDENTIFIER"];
        }
        isIphoneX = [platformSet containsObject:platform];
    });
    return isIphoneX;
}

- (void)gp_saveVideo {
    if (self.videoURL.absoluteString.length > 0 && _maker.startTime >= 0 && _maker.endTime > _maker.startTime) {
        __weak typeof(self) weakSelf = self;
        [self gp_clippVideoWithCompletion:^{
            __strong typeof(self) self = weakSelf;
            [self gp_saveVideoToAlbumWithVideoURL:self->_outputURL success:^(PHAsset *asset) {
                __weak typeof(self) weakSelf = self;
                [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:nil resultHandler:^(AVAsset * _Nullable avAsset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                    __strong typeof(self) self = weakSelf;
                    AVURLAsset *urlAsset = (AVURLAsset *)avAsset;
                    NSURL *url = urlAsset.URL;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (self.callback) {
                            [self gp_back];
                            self.callback(url, asset, self.coverImage);
                        }
                    });
                }];
            } failure:^(NSString *message) {
                NSLog(@"Save failed:%@", message);
            }];
        }];
    }
}

- (void)gp_clippVideoWithCompletion:(void(^)(void))completionHandle {
    AVURLAsset *asset = [AVURLAsset assetWithURL:self.videoURL];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetPassthrough];
    NSString *outputPath = [NSTemporaryDirectory() stringByAppendingPathComponent:kCutVideoPath];
    _outputURL = [NSURL fileURLWithPath:outputPath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:outputPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:outputPath error:nil];
    }
    exportSession.outputFileType = AVFileTypeMPEG4;
    exportSession.outputURL = _outputURL;
    exportSession.shouldOptimizeForNetworkUse = YES;
    
    CMTime start = CMTimeMakeWithSeconds(self.maker.startTime, asset.duration.timescale);
    CMTime duration = CMTimeMakeWithSeconds(self.maker.endTime - self.maker.startTime,asset.duration.timescale);
    CMTimeRange range = CMTimeRangeMake(start, duration);
    exportSession.timeRange = range;
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        completionHandle();
    }];
}

- (void)gp_saveVideoToAlbumWithVideoURL:(NSURL *)videoURL success:(void(^)(PHAsset *))completionHandler failure:(void(^)(NSString *))failure{ {
    __block PHAssetCollection *_targetCollection = nil;
    __block PHAsset *_asset = nil;
    __block NSString *_assetIdentifier = nil;
    __block NSString *_collectionIdentifier = nil;
    
    NSString *collectionTitle = [NSBundle mainBundle].infoDictionary[(NSString *)kCFBundleNameKey];
    
    PHFetchResult<PHAssetCollection *> *results = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection *collection in results) {
        if ([collection.localizedTitle isEqualToString:collectionTitle]) {
            _targetCollection = collection;
        }
    }
  
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        _assetIdentifier = [PHAssetCreationRequest creationRequestForAssetFromVideoAtFileURL:videoURL].placeholderForCreatedAsset.localIdentifier;
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                if (!_targetCollection) {
                    _collectionIdentifier =  [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:collectionTitle].placeholderForCreatedAssetCollection.localIdentifier;
                }
            } completionHandler:^(BOOL success, NSError * _Nullable error) {
                if (success) {
                    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                        if (!_targetCollection) {
                            _targetCollection = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[_collectionIdentifier] options:nil].lastObject;
                        }
                        _asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[_assetIdentifier] options:nil].lastObject;
                        PHAssetCollectionChangeRequest *requestCollection = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:_targetCollection];
                        [requestCollection addAssets:@[_asset]];
                    } completionHandler:^(BOOL success, NSError * _Nullable error) {
                        if (success) {
                            self.coverImage = [self gp_getVideoPreViewImage:self->_outputURL];
                            if (completionHandler) {
                                completionHandler(_asset);
                            }
                            NSLog(@"Save succeed");
                        }
                    }];
                }
            }];
         }
    }];
  }
}

- (UIImage*)gp_getVideoPreViewImage:(NSURL *)path {
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:path options:nil];
    AVAssetImageGenerator *assetGen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetGen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [assetGen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *videoImage = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    return videoImage;
}

#pragma mark - Action

- (void)gp_back {
    if (self.navigationController && [self.navigationController.viewControllers indexOfObject:self] != 0) {
         [self.navigationController popViewControllerAnimated:YES];
    } else if (self.presentingViewController) {
         [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - <GPVideoClipperViewDelegate>

- (void)gp_doneButtonAction:(UIButton *)button {
    [self gp_saveVideo];
}

- (void)gp_cancelButtonAction:(UIButton *)button {
    [self gp_back];
}

- (void)gp_videoLengthDidChanged:(CGFloat)time {
    if (time < 0) return;
    if (self.playerView.playerItem.status == AVPlayerItemStatusReadyToPlay) {
        [self.playerView.player seekToTime:CMTimeMake(time * 1000, 1000) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
        [self.playerView.player pause];
    }
}

- (void)gp_didEndDragging {
    self.playerView.playerItem.forwardPlaybackEndTime = CMTimeMake(self.maker.endTime * 1000, 1000);
    [self gp_playVideo];
}

#pragma mark - <GPVideoPlayerViewDelegate>

- (void)gp_videoReadyToPlay {
    self.playerView.playerItem.forwardPlaybackEndTime = CMTimeMake(self.maker.endTime * 1000, 1000);
    [self gp_playVideo];
}

#pragma mark - Getters

- (GPVideoPlayerView *)playerView {
    if (!_playerView) {
        CGFloat statusBarHeight = [[UIApplication sharedApplication] windows].firstObject.windowScene.statusBarManager.statusBarFrame.size.height;;
        _playerView = [[GPVideoPlayerView alloc] initWithFrame:CGRectMake(30, statusBarHeight + 44, self.view.frame.size.width - 60, self.view.frame.size.height - statusBarHeight - 44 - kClipViewHeight - [self gp_safeAreaBottomHeight] - 25) videoURL:self.videoURL];
        _playerView.delegate = self;
        _playerView.maker = self.maker;
    }
    return _playerView;
}

- (GPVideoClipperView *)clipperView {
    if (!_clipperView) {
        _clipperView = [[GPVideoClipperView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - kClipViewHeight - 25 - [self gp_safeAreaBottomHeight], self.view.bounds.size.width, kClipViewHeight) maker:self.maker];
        _clipperView.avAsset = [AVAsset assetWithURL:self.videoURL];
        _clipperView.delegate = self;
    }
    return _clipperView;
}

- (GPVideoConfigMaker *)maker {
    if (!_maker) {
        _maker = [GPVideoConfigMaker new];
        _maker.startTime = 0;
        _maker.endTime = 15;
        _maker.clippedVideoMinDuration = 3.0;
        _maker.clippedVideoMaxDuration = 15.0f;
        _maker.sourceVideoTotalDuration = CMTimeGetSeconds([AVURLAsset assetWithURL:self.videoURL].duration);
    }
    return _maker;
}

@end

