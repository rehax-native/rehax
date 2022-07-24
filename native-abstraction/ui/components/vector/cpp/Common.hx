package rehax.components.vector.cpp;

#if cpp
using rehax.components.view.View;
using rehax.Style;
using rehax.components.vector.Common;
using rehax.components.view.cpp.View;

import cpp.Pointer;
import cpp.RawPointer;

class VectorElement extends View {
  public function new() {
    super();
  }

  public var vectorStyle(default, set):Array<VectorStyleProperty> = [];

  public function set_vectorStyle(styles:Array<VectorStyleProperty>):Array<VectorStyleProperty> {
    this.vectorStyle = styles;
    var el:Pointer<NativeVectorElement> = native.reinterpret();

    for (style in vectorStyle) {
      switch (style) {
        case Fill(color):
          el.ptr.setFillColor(NativeColor.create(color.red, color.green, color.blue, color.alpha));
        case Stroke(color):
          el.ptr.setStrokeColor(NativeColor.create(color.red, color.green, color.blue, color.alpha));
        case StrokeWidth(width):
          el.ptr.setLineWidth(width);
        case StrokeLineCap(cap):
          switch (cap) {
            case Butt:
              el.ptr.setLineCap(0);
            case Square:
              el.ptr.setLineCap(1);
            case Round:
              el.ptr.setLineCap(2);
          }
        case StrokeLineJoin(join):
          switch (join) {
            case Miter:
              el.ptr.setLineJoin(0);
            case Round:
              el.ptr.setLineJoin(1);
            case Bevel:
              el.ptr.setLineJoin(2);
          }
        case FillWithDefinition(name):
          var container = cast(parent, VectorContainer);
          if (container == null) {
            continue;
          }
          for (gradient in container.linearGradients) {
            if (gradient.id == name) {
              var nativeGradient = NativeGradient.create();
              for (stop in gradient.stops) {
                nativeGradient.addStop(NativeColor.create(stop.color.red, stop.color.green, stop.color.blue, stop.color.alpha), stop.offset);
              }
              el.ptr.setFillGradient(nativeGradient);
              break;
            }
          }
          for (gradient in container.radialGradients) {
            if (gradient.id == name) {
              var nativeGradient = NativeGradient.create();
              for (stop in gradient.stops) {
                nativeGradient.addStop(NativeColor.create(stop.color.red, stop.color.green, stop.color.blue, stop.color.alpha), stop.offset);
              }
              el.ptr.setFillGradient(nativeGradient);
              break;
            }
          }
        case StrokeWithDefinition(name):
          var container = cast(parent, VectorContainer);
          if (container == null) {
            continue;
          }
          for (gradient in container.linearGradients) {
            if (gradient.id == name) {
              var nativeGradient = NativeGradient.create();
              for (stop in gradient.stops) {
                nativeGradient.addStop(NativeColor.create(stop.color.red, stop.color.green, stop.color.blue, stop.color.alpha), stop.offset);
              }
              el.ptr.setStrokeGradient(nativeGradient);
              break;
            }
          }
          for (gradient in container.radialGradients) {
            if (gradient.id == name) {
              var nativeGradient = NativeGradient.create();
              for (stop in gradient.stops) {
                nativeGradient.addStop(NativeColor.create(stop.color.red, stop.color.green, stop.color.blue, stop.color.alpha), stop.offset);
              }
              el.ptr.setStrokeGradient(nativeGradient);
              break;
            }
          }
        case Filters(filters):
          var native = NativeFilters.create();
          for (filter in filters) {
            switch (filter) {
              case Blur(radius):
                native.addBlurFilter(radius);
            }
          }
          el.ptr.setFilters(native);
      }
    }

    return styles;
  }

  public override function mount(parent:View, atIndex:Null<Int> = null) {
    super.mount(parent, atIndex);
    set_vectorStyle(vectorStyle);
  }
}

// @:unreflective
// @:structAccess
// @:include("rehax/components/vector/cpp/NativeVectorContainer.h")
// @:native("NativeFilterDef")
// extern class NativeFilterDef {
// 	public static inline function create():NativeFilterDef {
// 		return untyped __cpp__("{}");
// 	}

//   function setType(type:Int):Void;
//   function setBlurRadius(blurRadius:Float):Void;
// }

@:unreflective
@:structAccess
@:include("rehax/components/vector/cpp/NativeVectorContainer.h")
@:native("NativeFilters")
extern class NativeFilters {
	public static inline function create():NativeFilters {
		return untyped __cpp__("{}");
	}

  function addBlurFilter(blurRadius:Float):Void;
}

@:unreflective
@:structAccess
@:include("rehax/components/vector/cpp/NativeVectorContainer.h")
@:native("NativeGradient")
extern class NativeGradient {
	public static inline function create():NativeGradient {
		return untyped __cpp__("{}");
	}

  function addStop(color:NativeColor, offset:Float):Void;
}

@:include("rehax/components/vector/cpp/NativeVectorContainer.h")
@:unreflective
@:native("NativeVectorContainer")
@:structAccess
extern class NativeVectorContainer extends NativeView {
  @:native("new NativeVectorContainer") private static function _new():RawPointer<NativeVectorContainer>;
  public static inline function createInstance():Pointer<NativeVectorContainer> {
    return Pointer.fromRaw(_new());
  }
}

@:include("rehax/components/vector/cpp/NativeVectorContainer.h")
@:unreflective
@:native("NativeVectorElement")
@:structAccess
extern class NativeVectorElement extends NativeView {
  @:native("new NativeVectorElement") private static function _new():RawPointer<NativeVectorElement>;
  public static inline function createInstance():Pointer<NativeVectorElement> {
    return Pointer.fromRaw(_new());
  }

  function setLineWidth(width:Float):Void;
  function setLineCap(apsStyle:Int):Void;
  function setLineJoin(joinStyle:Int):Void;

  function setFillColor(color:NativeColor):Void;
  function setStrokeColor(color:NativeColor):Void;
  function setFillGradient(gradient:NativeGradient):Void;
  function setStrokeGradient(gradient:NativeGradient):Void;
  function setFilters(filters:NativeFilters):Void;

  function setWidthNatural():Void;
  function setHeightNatural():Void;
  override function setVerticalPositionNatural(previousView:Pointer<NativeView>):Void;
  override function setHorizontalPositionNatural(previousView:Pointer<NativeView>):Void;
}

#end
