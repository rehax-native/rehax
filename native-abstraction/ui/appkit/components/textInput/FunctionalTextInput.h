#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface FunctionalNSTextField : NSTextField <NSTextFieldDelegate>
{
  @public
  std::function<void(void)> callback;
}

- (void)setCallback:(std::function<void(void)>)callback;
- (void)controlTextDidChange:(id)notification;

@end
