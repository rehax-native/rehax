#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#include <functional>

@interface FunctionalNSTextField : NSTextField <NSTextFieldDelegate>
{
  @public
    std::function<void(std::string)> callback;
    std::function<void(void)> focusCallback;
    std::function<void(void)> blurCallback;
}

- (void)setCallback:(std::function<void(std::string)>)callback;
- (void)setOnFocusCallback:(std::function<void(void)>)callback;
- (void)setOnBlurCallback:(std::function<void(void)>)callback;
- (void)controlTextDidChange:(id)notification;
- (void)controlTextDidBeginEditing:(NSNotification *)obj;
- (void)controlTextDidEndEditing:(NSNotification *)obj;

@end
