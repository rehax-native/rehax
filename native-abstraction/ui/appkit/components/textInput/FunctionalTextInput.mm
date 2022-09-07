#include "FunctionalTextInput.h"
#include <iostream>

@implementation FunctionalNSTextField

- (void)setCallback:(std::function<void(std::string)>)cb
{
  self.delegate = self;
  callback = cb;
}

- (void)setOnFocusCallback:(std::function<void(void)>)cb
{
  self.delegate = self;
  focusCallback = cb;
}

- (void)setOnBlurCallback:(std::function<void(void)>)cb
{
  self.delegate = self;
  blurCallback = cb;
}

- (void)setOnSubmitCallback:(std::function<void(void)>)cb
{
  self.target = self;
  submitCallback = cb;
  self.action = @selector(onSubmit);
}

- (void)controlTextDidChange:(id)notification
{
  if (callback) {
    callback(std::string(self.stringValue.UTF8String));
  }
}

- (void)controlTextDidBeginEditing:(NSNotification *)obj
{
  if (focusCallback) {
    focusCallback();
  }
}

- (BOOL)resignFirstResponder
{
  bool ret = [super resignFirstResponder];
  if (ret && focusCallback) {
    focusCallback();
  }
  return ret;
}

- (void)controlTextDidEndEditing:(NSNotification *)obj
{
  if (blurCallback) {
    blurCallback();
  }
}

- (void)onSubmit
{
  if (submitCallback) {
    submitCallback();
  }
}

@end
