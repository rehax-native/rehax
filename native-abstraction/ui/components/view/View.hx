package rehax.components.view.cpp;

#if cpp
using rehax.components.root.cpp.Root;
using rehax.components.layout.Layout;
using haxe.EnumTools.EnumValueTools;

import cpp.Pointer;
import cpp.RawPointer;

@:include("rehax/components/view/cpp/NativeView.h")
@:unreflective
@:native("NativePosition")
@:structAccess
extern class NativePosition {
  public static function create(x:Float, y:Float):NativePosition;
  public var x:Float;
  public var y:Float;
}

@:include("rehax/components/view/cpp/NativeView.h")
@:unreflective
@:native("NativeSize")
@:structAccess
extern class NativeSize {
  public static function create(width:Float, height:Float):NativeSize;
  public var width:Float;
  public var height:Float;
}

@:include("rehax/components/view/cpp/NativeView.h")
@:unreflective
@:native("NativeFrame")
@:structAccess
extern class NativeFrame {
  @:native("NativeFrame") public inline function new() {}
  public static function create(position:NativePosition, size:NativeSize):NativeFrame;
  public var position:NativePosition;
  public var size:NativeSize;
}

@:include("rehax/components/view/cpp/NativeView.h")
@:unreflective
@:native("NativeColor")
@:structAccess
extern class NativeColor {
  @:native("NativeColor") public inline function new() {}
  public static function create(r:Float, g:Float, b:Float, a:Float):NativeColor;
  public var red:Float;
  public var green:Float;
  public var blue:Float;
  public var alpha:Float;
}

@:include("rehax/components/view/cpp/NativeView.h")
@:unreflective
@:native("NativeView")
@:structAccess
extern class NativeView {
  @:native("new NativeView") private static function _new():RawPointer<NativeView>;
  public static inline function createInstance():Pointer<NativeView> {
    return Pointer.fromRaw(_new());
  }
  function createFragment():Void;
  function addView(child:NativeView):Void;
  function removeFromParent():Void;
  function teardown():Void;

  function setWidthFill():Void;
  function setHeightFill():Void;
  function setWidthNatural():Void;
  function setHeightNatural():Void;
  function setWidthFixed(width:Float):Void;
  function setHeightFixed(height:Float):Void;
  function setWidthPercentage(percent:Float):Void;
  function setHeightPercentage(percent:Float):Void;

  function setVerticalPositionNatural(previousView:cpp.RawPointer<NativeView>):Void;
  function setHorizontalPositionNatural(previousView:cpp.RawPointer<NativeView>):Void;
  function setVerticalPositionFixed(x:Float):Void;
  function setHorizontalPositionFixed(y:Float):Void;

  function setBackgroundColor(color:NativeColor):Void;
  function setTextColor(color:NativeColor):Void;
  function setOpacity(opacity:Float):Void;

  function setNativeViewRaw(view:cpp.RawPointer<Void>):Void;

  function addGesture(gesture:rehax.components.view.cpp.Gesture.NativeGesture):Void;
}

class View {
  private var native:Null<cpp.Pointer<NativeView>> = null;
  public var slots:Map<String, View> = [];
  private var isMounted = false;
  private var hoverStyle:Style;

  public var parent:Null<View>;
  public var children:Array<View> = [];

  public function new() {}

  public function createFragment() {
    native = NativeView.createInstance();
    native.ptr.createFragment();
  }

  public function destroyFragment() {
    for (rec in recognizers) {
      rec.destroy();
    }
    recognizers = [];
    layout = null;
    if (native != null) {
      native.ptr.teardown();
      native.destroy();
      native = null;
    }
  }

  public function addChild(child:View, atIndex:Int) {
    children.insert(atIndex, child);
    relayout();
  }

  public function mount(parent:View, atIndex:Null<Int> = null) {

    if (parent.slots.exists('default')) {
      var slot = parent.slots['default'];
      this.parent = slot;
      slot.native.ptr.addView(native.ptr);
      slot.addChild(this, atIndex == null ? parent.children.length : atIndex);
    } else if (parent.native != null) {
      this.parent = parent;
      parent.native.ptr.addView(native.ptr);
      parent.addChild(this, atIndex == null ? parent.children.length : atIndex);
    }

    isMounted = true;

    setNativeWidth();
    setNativeHeight();

    set_position(position);

    relayout();

    componentDidMount();
  }

  public function componentDidMount() {}

  public function unmount() {
    layout = null;
    if (parent != null) {
      native.ptr.removeFromParent();
      parent.children.remove(this);
      parent.relayout();
    }
    isMounted = false;
    this.parent = null;
  }

  private function relayout() {
    if (native.ptr == null) {
      return;
    }
    if (layout == null) {
      this.layout = rehax.components.layout.StackLayout.Create({});
    } else {
      // TODO it is inefficient to calc the layout for all children every time one is added
      layout.cleanUp(this.native);
      layout.layout(this.native);
    }
  }

  public var layout(default, set):Null<ILayout>;

  public function set_layout(layout:Null<ILayout>):Null<ILayout> {
    if (this.layout != null) {
      this.layout.cleanUp(this.native);
      this.layout.destroy();
      this.layout = null;
    }
    this.layout = layout;
    if (this.layout != null) {
      layout.layout(this.native);
    }
    return layout;
  }

  public var style(default, set):rehax.Style;

  public function set_style(style:rehax.Style):rehax.Style {
    this.style = style;
    setElementStyle(style);
    return style;
  }

  @:isVar
  public var size(default, set):Size = {
    width: Natural,
    height: Natural,
  };

  public function set_size(size:Size):Size {
    if (!isMounted) {
      this.size = size;
      return size;
    }

    var needsWidth = !this.size.width.equals(size.width);
    var needsHeight = !this.size.height.equals(size.height);

    this.size = size;

    if (needsWidth) {
      setNativeWidth();
    }
    if (needsHeight) {
      setNativeHeight();
    }

    return size;
  }

  private function setNativeWidth() {
    switch (size.width) {
      case Natural:
        native.ptr.setWidthNatural();
      case Fixed(size):
        native.ptr.setWidthFixed(size);
      case Fill:
        native.ptr.setWidthFill();
      case Percentage(percent):
        native.ptr.setWidthPercentage(percent);
    }
  }

  private function setNativeHeight() {
    switch (size.height) {
      case Natural:
        native.ptr.setHeightNatural();
      case Fixed(size):
        native.ptr.setHeightFixed(size);
      case Fill:
        native.ptr.setHeightFill();
      case Percentage(percent):
        native.ptr.setHeightPercentage(percent);
    }
  }

  public var position(default, set):Position = {
    left: Natural,
    top: Natural,
  };

  public function set_position(position:Position):Position {
    this.position = position;
    if (!isMounted) {
      return position;
    }
    switch (position.left) {
      case Natural:
      //   var previousView = null;
      //   if (parent != null && parent.layoutDirection == Horizontal) {
      //     var nextIndex = parent.children.indexOf(this) - 1;
      //     while (previousView == null && nextIndex >= 0) {
      //       if (parent.children[nextIndex].position.left == Natural) {
      //         previousView = parent.children[nextIndex];
      //         break;
      //       }
      //       nextIndex--;
      //     }
      //   }
      //   native.ptr.setHorizontalPositionNatural(previousView != null ? previousView.native.raw : null);
      case Fixed(size):
        native.ptr.setHorizontalPositionFixed(size);
    }
    switch (position.top) {
      case Natural:
      //   var previousView = null;
      //   if (parent != null && parent.layoutDirection == Vertical) {
      //     var nextIndex = parent.children.indexOf(this) - 1;
      //     while (previousView == null && nextIndex >= 0) {
      //       if (parent.children[nextIndex].position.top == Natural) {
      //         previousView = parent.children[nextIndex];
      //         break;
      //       }
      //       nextIndex--;
      //     }
      //   }
      //   native.ptr.setVerticalPositionNatural(previousView != null ? previousView.native.raw : null);
      case Fixed(size):
        native.ptr.setVerticalPositionFixed(size);
    }
    return position;
  }

  public var frame(get, set):Frame;

  public function set_frame(frame:Frame):Frame {
    position = frame.position;
    size = frame.size;
    return frame;
  }

  public function get_frame():Frame {
    return {
      position: position,
      size: size,
    }
  }

  public function setElementStyle(style:Style) {
    for (item in style) {
      switch (item) {
        case backgroundColor(color):
          native.ptr.setBackgroundColor(NativeColor.create(color.red, color.green, color.blue, color.alpha));
        case textColor(color):
        // view.setBackgroundColor();
        // el.style.color = 'rgba(${color.red}, ${color.green}, ${color.blue}, ${color.alpha})';
        case opacity(amount):
        // el.style.opacity = Std.string(amount);
      }
    }
  }

  private var recognizers:Array<Gesture> = [];
  public function addGesture(gesture:Gesture) {
    recognizers.push(gesture);
    native.ptr.addGesture(gesture.native);
  }
}
#end
