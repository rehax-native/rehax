#pragma once

namespace rehax::ui {

/** This is a universal default type. It is used everywhere there can be a default value. */
struct DefaultValue {};

namespace LengthTypes {
  /** Natural, meaning the size that the view reports **/
  struct Natural {};

  /** Fixed size in screen independent pixels **/
  struct Fixed
  {
    float length;
  };

  /** Fill the parent (looking at the parent's layout constraints) **/
  struct Fill {};

  /** Percentage of parent (looking at the parent's layout constraints) **/
  struct Percentage {
    float percent;
  };
}

using Length = std::variant<
  LengthTypes::Natural,
  LengthTypes::Fixed,
  LengthTypes::Fill,
  LengthTypes::Percentage
>;

}
