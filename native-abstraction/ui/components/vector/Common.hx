package rehax.components.vector;

using rehax.Style;

enum StrokeLineCap {
  Butt;
  Square;
  Round;
}

enum StrokeLineJoin {
  Miter;
  Round;
  Bevel;
}

typedef GradientDefintion = {
  var name:String;
  var stops:Array<{
    var offset:Float;
    var color:Color;
  }>;
}

enum VectorFilter {
  Blur(radius:Float);
}

enum VectorStyleProperty {
  Fill(color:Color);
  Stroke(color:Color);
  FillWithDefinition(name:String);
  StrokeWithDefinition(name:String);
  StrokeWidth(width:Float);
  StrokeLineCap(cap:StrokeLineCap);
  StrokeLineJoin(join:StrokeLineJoin);
  Filters(filters:Array<VectorFilter>);
}
