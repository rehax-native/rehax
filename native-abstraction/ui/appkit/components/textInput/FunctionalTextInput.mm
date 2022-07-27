#include "FunctionalTextInput.h"

@implementation FunctionalNSTextField

- (void)setCallback:(std::function<void(void)>)cb
{
  self.delegate = self;
  callback = cb;
}

- (void)controlTextDidChange:(id)notification
{
  callback();
}

@end
