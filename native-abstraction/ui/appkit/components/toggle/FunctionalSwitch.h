#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#include <functional>
#include "../view/ObjcDefinitions.h"

#define FunctionalNSSwitch MakeClassName(FunctionalNSSwitch)

@interface FunctionalNSSwitch : NSSwitch
{
  @public
    std::function<void(void)> callback;
}

- (void)setCallback:(std::function<void(void)>)callback;
- (void)handleValue:(NSSwitch*)item;

@end
