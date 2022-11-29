#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#include <functional>

@interface FunctionalNSSwitch : NSSwitch
{
  @public
    std::function<void(void)> callback;
}

- (void)setCallback:(std::function<void(void)>)callback;
- (void)handleValue:(NSSwitch*)item;

@end
