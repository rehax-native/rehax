#pragma once

#include <functional>
#include <iostream>
#include "../view/View.h"

#if __OBJC__
@class NSTimer;
#else
typedef void NSTimer;
#endif

namespace rehax {

class Timer {
private:
    NSTimer * timer;
  
    friend class Util;
};

class Util
{
public:
  RHX_EXPORT static void openUrl(std::string url);

  RHX_EXPORT static Timer * startInterval(int intervalMs, std::function<void(void)> tick);
  RHX_EXPORT static void stopTimer(Timer * timer);
};

}
