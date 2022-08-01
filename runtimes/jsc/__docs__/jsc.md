## Bindings for *JavascriptCore*

## Types
### Color
Converts from/to an object with shape `{ red: number, green: number, blue: number, alpha: number }`. The range for `alpha` is 0.0 - 1.0, and the ranges for the others is 0.0 - 255.0.

### FlexLayoutOptions
Converts from/to an object with shape `{ direction: 'Column' | 'ColumnReverse' | 'Row' | 'RowReverse', TODO }`.

### StackLayoutOptions
Converts from/to an object with shape `{ spacing: float, direction: 'Horizontal' | 'Vertical' }`.


## Views
### Button
 - `void setTitle(std::string)`
 - `std::string getTitle()`
 - `void setOnPress(std::function<void ()>)`


### FlexLayout
 - `void setOptions(rehax::ui::appkit::impl::FlexLayoutOptions)`


### Gesture
 - `void setup(std::function<void ()>, std::function<void (float, float)>, std::function<void (float, float)>, std::function<void (float, float)>)`
 - `void setState(rehax::ui::appkit::impl::GestureState)`


### StackLayout
 - `void setOptions(rehax::ui::appkit::impl::StackLayoutOptions)`


### Text
 - `void setText(std::string)`
 - `std::string getText()`
 - `void setTextColor(rehax::ui::Color)`
 - `void setFontSize(float)`


### TextInput
 - `void setValue(std::string)`
 - `std::string getValue()`


### VectorContainer


### VectorElement
 - `void setLineWidth(float)`
 - `void setLineJoin(rehax::ui::appkit::impl::VectorLineJoin)`
 - `void setLineCap(rehax::ui::appkit::impl::VectorLineCap)`
 - `void setFillColor(rehax::ui::Color)`
 - `void setStrokeColor(rehax::ui::Color)`
 - `void setFillGradient(rehax::ui::appkit::impl::Gradient)`
 - `void setStrokeGradient(rehax::ui::appkit::impl::Gradient)`
 - `void setFilters(rehax::ui::appkit::impl::Filters)`


### VectorPath
 - `void beginPath()`
 - `void pathHorizontalTo(float)`
 - `void pathVerticalTo(float)`
 - `void pathMoveTo(float, float)`
 - `void pathMoveBy(float, float)`
 - `void pathLineTo(float, float)`
 - `void pathQuadraticBezier(float, float, float, float)`
 - `void pathArc(float, float, float, int, int, float, float)`
 - `void pathCubicBezier(float, float, float, float, float, float)`
 - `void pathClose()`
 - `void endPath()`


### View
 - `std::string toString()`
 - `void removeFromParent()`
 - `void setWidthFixed(float)`
 - `void setHeightFixed(float)`
 - `void addView(View)`
 - `void removeView(View)`
 - `View getParent()`
 - `View getFirstChild()`
 - `View getNextSibling()`
 - `void setLayout(Layout)`
