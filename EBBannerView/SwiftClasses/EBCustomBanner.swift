//
//  EBCustomBanner.swift
//  EBBannerViewSwift
//
//  Created by pikacode on 2020/1/2.
//

import UIKit
import AudioToolbox

class EBCustomBanner: NSObject {
    
    static var sharedBanners = [EBCustomBanner]()
    static let sharedWindow = EBBannerWindow.shared

    enum TransitionStyle {
        case top, left, right, bottom
        case centerDefault// (0.3, 0.2, 0.1)
        case center(durations: (alpha: TimeInterval, max: TimeInterval, final: TimeInterval))
    }
    
    init(view: UIView) {
        self.view = view
        super.init()
    }
    
    ///make a custom view and show immediately,
    @discardableResult
    static func show(_ view: UIView) -> EBCustomBanner { return EBCustomBanner(view: view).show() }

    
    
    @discardableResult
    func show() -> EBCustomBanner {
        let banner = self
        return banner
    }
      
    func hide() {
        
    }
    
    
    private var view: UIView
    private let maker = EBCustomBannerMaker()
    
}

   /*

//make a custom view and show later
+(EBCustomBannerView*)customView:(UIView*)view block:(void(^)(EBCustomBannerViewMaker *make))block{
    EBCustomBannerView *bannerView = [EBCustomBannerView new];
    EBCustomBannerViewMaker *maker = [EBCustomBannerViewMaker makerWithView:view];
    bannerView.maker = maker;
    block(maker);
    [[NSNotificationCenter defaultCenter] addObserver:bannerView selector:@selector(applicationDidChangeStatusBarOrientationNotification) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    return bannerView;
}

-(void)applicationDidChangeStatusBarOrientationNotification{
    if (sharedCustomViews.count == 0) {
        return;
    }
    if ([self currentIsLandscape]) {
        [sharedCustomViews enumerateObjectsUsingBlock:^(EBCustomBannerView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.maker.view.frame = obj.maker.landscapeFrame;
        }];
    } else {
        [sharedCustomViews enumerateObjectsUsingBlock:^(EBCustomBannerView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.maker.view.frame = obj.maker.portraitFrame;
        }];
    }
}

-(void)show{

    [EBCustomBannerView sharedCustomBannerViewInit];
    
    [sharedCustomViews addObject:self];
    
    if (_maker.soundName || _maker.soundID != 0) {
        SystemSoundID soundID;
        if (_maker.soundName) {
            NSURL *url = [[NSBundle mainBundle] URLForResource:_maker.soundName withExtension:nil];
            AudioServicesCreateSystemSoundID((__bridge CFURLRef)(url), &soundID);
        } else {
            soundID = _maker.soundID;
        }
        WEAK_SELF(weakSelf);
        [[EBMuteDetector sharedDetecotr] detectComplete:^(BOOL isMute) {
            if (isMute && weakSelf.maker.vibrateOnMute) {
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            } else {
                AudioServicesPlaySystemSound(soundID);
            }
        }];
    }

    [sharedWindow.rootViewController.view addSubview:_maker.view];

    
    if ([self currentAppearMode] == EBCustomViewAppearModeCenter) {
        dispatch_async(dispatch_get_main_queue(), ^{
            WEAK_SELF(weakSelf);
            UIView *view = weakSelf.maker.view;
            view.frame = [weakSelf showFrame];
            view.alpha = 0;
            [UIView animateWithDuration:weakSelf.maker.centerModeDurations[0].doubleValue animations:^{
                view.alpha = 1;
            }];
            view.alpha = 0;
            
            view.layer.shouldRasterize = YES;
            view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.4, 0.4);
            [UIView animateWithDuration:weakSelf.maker.centerModeDurations[1].doubleValue animations:^{
                view.alpha = 1;
                view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:weakSelf.maker.centerModeDurations[2].doubleValue delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    view.alpha = 1;
                    view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
                } completion:^(BOOL finished2) {
                    view.layer.shouldRasterize = NO;
                    if (weakSelf.maker.stayDuration > 0) {
                        [NSTimer eb_scheduledTimerWithTimeInterval:weakSelf.maker.stayDuration block:^(NSTimer *timer) {
                            [weakSelf hide];
                        } repeats:NO];
                    }
                }];
            }];
        });
    } else {
        _maker.view.frame = [self hideFrame];
        WEAK_SELF(weakSelf);
        [UIView animateWithDuration:_maker.animationDuration animations:^{
            weakSelf.maker.view.frame = [weakSelf showFrame];
        } completion:^(BOOL finished) {
            if (weakSelf.maker.stayDuration > 0) {
                [NSTimer eb_scheduledTimerWithTimeInterval:weakSelf.maker.stayDuration block:^(NSTimer *timer) {
                    [weakSelf hide];
                } repeats:NO];
            }
        }];
    }
}

-(void)hide{
    if (!self.maker.view.superview) {
        return;
    }
    if ([self currentAppearMode] == EBCustomViewAppearModeCenter) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            WEAK_SELF(weakSelf);
            UIView *view = weakSelf.maker.view;
            [UIView animateWithDuration:weakSelf.maker.centerModeDurations[0].doubleValue animations:^{
                view.alpha = 0;
            }];
            
            view.layer.shouldRasterize = YES;
            [UIView animateWithDuration:weakSelf.maker.centerModeDurations[2].doubleValue animations:^{
                view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
            } completion:^(BOOL finished){
                [UIView animateWithDuration:weakSelf.maker.centerModeDurations[1].doubleValue delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    view.alpha = 0;
                    view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.4, 0.4);
                } completion:^(BOOL finished){
                    [view removeFromSuperview];
                    [sharedCustomViews removeObject:weakSelf];
                }];
            }];
        });
        
    } else {
        WEAK_SELF(weakSelf);
        [UIView animateWithDuration:_maker.animationDuration animations:^{
            weakSelf.maker.view.frame = [weakSelf hideFrame];
        } completion:^(BOOL finished) {
            if (weakSelf.maker.view.superview) {
                [weakSelf.maker.view removeFromSuperview];
            }
            if ([sharedCustomViews containsObject:weakSelf]) {
                [sharedCustomViews removeObject:weakSelf];
            }
        }];
    }
}

-(BOOL)currentIsLandscape{
    return UIDeviceOrientationIsLandscape(UIDevice.currentDevice.orientation);
}

-(CGRect)showFrame{
    return [self currentIsLandscape] ? _maker.landscapeFrame : _maker.portraitFrame;
}

-(CGRect)hideFrame{
    CGRect hideFrame = [self showFrame];
    switch ([self currentAppearMode]) {
        case EBCustomViewAppearModeTop:
            hideFrame.origin.y = -hideFrame.size.height;
            break;
        case EBCustomViewAppearModeLeft:
            hideFrame.origin.x = -hideFrame.size.width;
            break;
        case EBCustomViewAppearModeRight:
            hideFrame.origin.x = ScreenWidth + hideFrame.size.width;
            break;
        case EBCustomViewAppearModeBottom:
            hideFrame.origin.y = ScreenHeight;
            break;
        case EBCustomViewAppearModeCenter:
            break;
        default:
            break;
    }
    return hideFrame;
}

-(EBCustomBannerViewAppearMode)currentAppearMode{
    return [self currentIsLandscape] ? _maker.landscapeMode : _maker.portraitMode;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
 
*/
