#pragma once

namespace rehax::ui {

enum class FlexLayoutDirection {
  Column,
  Row,
  ColumnReverse,
  RowReverse,
};

enum class FlexJustifyContent {
  /** items are packed toward the start line
      |AABBCCC    |
  **/
  FlexStart,

  /** items are packed toward to end line
      |    AABBCCC|
  **/
  FlexEnd,

  /** items are centered along the line
      |  AABBCCC  |
  **/
  Center,


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

enum class FlexAlignItems {
  FlexStart, // cross-start margin edge of the items is placed on the cross-start line
  FlexEnd, // cross-end margin edge of the items is placed on the cross-end line
  Center, // items are centered in the cross-axis
  // Baseline, // items are aligned such as their baselines align
  Stretch, // stretch to fill the container (still respect min-width/max-width)
};

struct FlexItem {
  float flexGrow = 0.0f;
  bool hasFlexGrow = false;
  int order = 0;
  FlexAlignItems alignSelf = FlexAlignItems::FlexStart;
};

struct FlexLayoutOptions {
  FlexLayoutDirection direction = FlexLayoutDirection::Column;
	std::vector<FlexItem> items;
  float gap = 0;
  FlexJustifyContent justifyContent = FlexJustifyContent::FlexStart;
  FlexAlignItems alignItems = FlexAlignItems::FlexStart;
};

}
