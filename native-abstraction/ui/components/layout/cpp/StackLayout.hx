package rehax.components.layout.cpp;

#if cpp

@:include("rehax/components/layout/cpp/NativeStackLayout.h")
@:unreflective
@:native("NativeStackLayout")
extern class NativeStackLayout {
  @:native("new NativeStackLayout") public static function Create(isHorizontal:Bool, spacing:Float):cpp.Pointer<NativeStackLayout>;
  public extern function layoutContainer(container:cpp.Pointer<rehax.components.view.cpp.View.NativeView>):Void;
  public extern function cleanUp(container:cpp.Pointer<rehax.components.view.cpp.View.NativeView>):Void;
}

class StackLayout implements rehax.components.layout.Layout.ILayout {

  public static function Create(options:rehax.components.layout.StackLayout.StackLayoutOptions) {
    var layout = new StackLayout(options.direction == Horizontal, options.spacing != null ? options.spacing : 0.0);
    return layout;
  }

  public function new(isHorizontal:Bool, spacing:Float) {
    this.nativeLayout = NativeStackLayout.Create(isHorizontal, spacing);
  }

  private var nativeLayout:cpp.Pointer<NativeStackLayout>;

  public function layout(container:cpp.Pointer<rehax.components.view.cpp.View.NativeView>) {
    nativeLayout.ptr.layoutContainer(container);
  }

  public function cleanUp(container:cpp.Pointer<rehax.components.view.cpp.View.NativeView>) {
    nativeLayout.ptr.cleanUp(container);
  }

  public function destroy():Void {
    nativeLayout.destroy();
    nativeLayout = null;
  }
}

#end
