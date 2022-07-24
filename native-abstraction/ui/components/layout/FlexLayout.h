#pragma once

#include <vector>
#include "../view/View.h"

namespace rehax {

enum FlexDirection {
  FlexDirection_Column,
  FlexDirection_Row,
  FlexDirection_ColumnReverse,
  FlexDirection_RowReverse,
};

enum FlexJustifyContent {
  /** items are packed toward the start line
      |AABBCCC    |
  **/
  FlexJustifyContent_FlexStart,

  /** items are packed toward to end line
      |    AABBCCC|
  **/
  FlexJustifyContent_FlexEnd,

  /** items are centered along the line
      |  AABBCCC  |
  **/
  FlexJustifyContent_Center,


  // Not implemented yet

  // /** items are evenly distributed in the line; first item is on the start line, last item on the end line  
  //     |AA  BB  CCC|
  // **/
  // var SpaceBetween;

  // /** items are evenly distributed in the line with equal space around them
  //     | AA BB CCC |
  // **/
  // var SpaceAround;

  // /** items are distributed so that the spacing between any two adjacent alignment subjects, before the first alignment subject, and after the last alignment subject is the same
  // **/
  // var SpaceEvenly;
};

enum FlexAlignItems {
  FlexAlignItems_FlexStart, // cross-start margin edge of the items is placed on the cross-start line
  FlexAlignItems_FlexEnd, // cross-end margin edge of the items is placed on the cross-end line
  FlexAlignItems_Center, // items are centered in the cross-axis
  // Baseline, // items are aligned such as their baselines align
  FlexAlignItems_Stretch, // stretch to fill the container (still respect min-width/max-width)
};

struct FlexItem {
  float flexGrow;
  bool hasFlexGrow;
  int order;
  FlexAlignItems alignSelf = FlexAlignItems_FlexStart;
};

struct FlexLayoutOptions {
  FlexDirection direction = FlexDirection_Column;
	std::vector<FlexItem> items;
  FlexJustifyContent justifyContent = FlexJustifyContent_FlexStart;
  FlexAlignItems alignItems = FlexAlignItems_FlexStart;
};

class FlexLayout : public ILayout
{
public:
  RHX_EXPORT FlexLayout();
  RHX_EXPORT ~FlexLayout();

  RHX_EXPORT void setOptions(FlexLayoutOptions flexLayoutOptions);
  RHX_EXPORT void layoutContainer(std::shared_ptr<View> container);
  RHX_EXPORT void cleanUp(std::shared_ptr<View> container);

  RHX_EXPORT void clearItems();
  RHX_EXPORT void addItem(FlexItem item);

private:
  std::vector<FlexItem> items;

  bool isHorizontal;
  bool isReverse;
  FlexJustifyContent justifyContent;
  FlexAlignItems alignItems;

  void * nativeInfo = nullptr;
};

}
