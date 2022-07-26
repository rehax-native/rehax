#import "FunctionalButton.h"

@implementation FunctionalNSButton

- (void)setOnPress:(std::function<void(void)>)cb
{
  callback = cb;
  [self setTarget:self];
  [self setAction:@selector(onPress:)];
}

- (void)onPress:(id)sender
{
  callback();
}

@end
