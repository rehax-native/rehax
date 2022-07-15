#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#include "Util.h"

void rehax::Util::openUrl(std::string url)
{
    NSString * nsUrl = [NSString stringWithUTF8String:url.c_str()];
    NSURL * nsUrlObj = [NSURL URLWithString:nsUrl];
    [[NSWorkspace sharedWorkspace] openURL:nsUrlObj];
}

rehax::Timer * rehax::Util::startInterval(int intervalMs, std::function<void(void)> tick)
{
    NSTimer * nativeTimer = [NSTimer scheduledTimerWithTimeInterval:(float)intervalMs / 1000.0
                                                            repeats:YES
                                                                block:^ (NSTimer *timer) {
        tick();
    }];
    Timer * timer = new Timer();
    timer->timer = nativeTimer;
    return timer;
}

void rehax::Util::stopTimer(Timer * timer)
{
    [timer->timer invalidate];
    timer->timer = nullptr;
    delete timer;
}
