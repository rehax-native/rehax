package rehax.components.vector.cpp;

#if cpp
using rehax.components.view.View;
using rehax.components.view.cpp.View;
using rehax.components.vector.Common;
using rehax.components.vector.cpp.Common;

import cpp.Pointer;
import cpp.RawPointer;
using rehax.Style;

class VectorRadialGradient extends VectorElement {
  public function new() {
    super();
  }

  public override function createFragment() {
  }

  public override function mount(parent:View, atIndex:Null<Int> = null) {
    this.parent = parent;
    isMounted = true;
    var container = cast(parent, VectorContainer);
    container.addRadialGradientDefinition(this);
  }

  public var id:String;

  public var stops:Array<{
    var offset:Float;
    var color:Color;
  }>;
}
#end
