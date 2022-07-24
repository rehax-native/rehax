package rehax.components.vector.cpp;

#if cpp
using rehax.components.view.View;
using rehax.components.view.cpp.View;
using rehax.components.vector.Common;
using rehax.components.vector.cpp.Common;
using rehax.Style;

import cpp.Pointer;
import cpp.RawPointer;

@:include("rehax/components/vector/cpp/NativeVectorContainer.h")
@:unreflective
@:native("NativeVectorPath")
@:structAccess
extern class NativeVectorPath extends NativeVectorElement {
  @:native("new NativeVectorPath") private static function _new():RawPointer<NativeVectorPath>;
  public static inline function createInstance():Pointer<NativeVectorPath> {
    return Pointer.fromRaw(_new());
  }

  override function createFragment():Void;

  function beginPath():Void;
  function pathHorizontalTo(x:Float):Void;
  function pathVerticalTo(y:Float):Void;
  function pathMoveTo(x:Float, y:Float):Void;
  function pathMoveBy(x:Float, y:Float):Void;
  function pathLineTo(x:Float, y:Float):Void;
  function pathArc(rx:Float, ry:Float, xAxisRotation:Float, largeArcFlag:Int, sweepFlag:Int, x:Float, y:Float):Void;
  function pathCubicBezier(x1:Float, y1:Float, x2:Float, y2:Float, x:Float, y:Float):Void;
  function pathQuadraticBezier(x1:Float, y1:Float, x:Float, y:Float):Void;
  function pathClose():Void;
  function endPath():Void;
}

enum VectorPathOperation {
  HorizontalTo(x:Float);
  VerticalTo(y:Float);
  MoveTo(x:Float, y:Float);
  MoveBy(x:Float, y:Float);
  LineTo(x:Float, y:Float);
  Arc(rx:Float, ry:Float, xAxisRotation:Float, largeArcFlag:Int, sweepFlag:Int, x:Float, y:Float);
  CubicBezier(x1:Float, y1:Float, x2:Float, y2:Float, x:Float, y:Float);
  QuadraticBezier(x1:Float, y1:Float, x:Float, y:Float);
  Close;
}

class VectorPath extends VectorElement {
  public function new() {
    super();
  }

  public override function createFragment() {
    var container = NativeVectorPath.createInstance();
    native = container.reinterpret();
    container.ptr.createFragment();
  }

  public var operations(default, set):Array<VectorPathOperation>;

  public function set_operations(ops:Array<VectorPathOperation>):Array<VectorPathOperation> {
    this.operations = ops;
    var el:Pointer<NativeVectorPath> = native.reinterpret();
    el.ptr.beginPath();
    for (op in operations) {
      switch (op) {
        case HorizontalTo(x):
          el.ptr.pathHorizontalTo(x);
        case VerticalTo(y):
          el.ptr.pathVerticalTo(y);
        case MoveTo(x, y):
          el.ptr.pathMoveTo(x, y);
        case MoveBy(x, y):
          el.ptr.pathMoveBy(x, y);
        case LineTo(x, y):
          el.ptr.pathLineTo(x, y);
        case Arc(rx, ry, xAxisRotation, largeArcFlag, sweepFlag, x, y):
          el.ptr.pathArc(rx, ry, xAxisRotation, largeArcFlag, sweepFlag, x, y);
        case CubicBezier(x1, y1, x2, y2, x, y):
          el.ptr.pathCubicBezier(x1, y1, x2, y2, x, y);
        case QuadraticBezier(x1, y1, x, y):
          el.ptr.pathQuadraticBezier(x1, y1, x, y);
        case Close:
          el.ptr.pathClose();
      }
    }
    el.ptr.endPath();
    return ops;
  }
}
#end
