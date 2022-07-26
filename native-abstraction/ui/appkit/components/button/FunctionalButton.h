#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#include <functional>


@interface FunctionalNSButton : NSButton
{
  @public
  std::function<void(void)> callback;
}

- (void)setOnPress:(std::function<void(void)>)callback;
- (void)onPress:(id)sender;

@end
