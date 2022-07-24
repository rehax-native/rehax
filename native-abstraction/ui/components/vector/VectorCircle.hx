package rehax.components.vector.cpp;

#if cpp
using rehax.components.view.View;
using rehax.components.vector.Common;
using rehax.components.vector.cpp.Common;
using rehax.components.view.cpp.View;

import cpp.Pointer;
import cpp.RawPointer;

@:include("rehax/components/vector/cpp/NativeVectorContainer.h")
@:unreflective
@:native("NativeVectorCircle")
@:structAccess
extern class NativeVectorCircle extends NativeView {
  @:native("new NativeVectorCircle") private static function _new():RawPointer<NativeVectorCircle>;
  public static inline function createInstance():Pointer<NativeVectorCircle> {
    return Pointer.fromRaw(_new());
  }

  function setCenterX(cx:Float):Void;
  function setCenterY(cy:Float):Void;
  function setRadius(r:Float):Void;
}

class VectorCircle extends VectorElement {
  public function new() {
    super();
  }

  public override function createFragment() {
    var container = NativeVectorCircle.createInstance();
    native = container.reinterpret();
    container.ptr.createFragment();
  }

  public var centerX(get, set):Float;

  public function set_centerX(cx:Float):Float {
    var el:Pointer<NativeVectorCircle> = native.reinterpret();
    el.ptr.setCenterX(cx);
    return cx;
  }

  public function get_centerX():Float {
    return 0;
  }

  public var centerY(get, set):Float;

  public function set_centerY(cy:Float):Float {
    var el:Pointer<NativeVectorCircle> = native.reinterpret();
    el.ptr.setCenterX(cy);
    return cy;
  }

  public function get_centerY():Float {
    return 0;
  }

  public var radius(get, set):Float;

  public function set_radius(radius:Float):Float {
    var el:Pointer<NativeVectorCircle> = native.reinterpret();
    el.ptr.setRadius(radius);
    return radius;
  }

  public function get_radius():Float {
    return 0;
  }
}
#end
