// import { ColorType, LengthType, ViewProps } from "../rehax-solidjs-components/components";

export class RehaxGesture {
  setup(
    action: () => void,
    onMouseDown: (x: number, y: number) => void,
    onMouseMove: (x: number, y: number) => void,
    onMouseUp: (x: number, y: number) => void
  ): void;
}

export interface XYCoords {
  x: number;
  y: number;
}

export class RehaxView {
  __className: string;
  addView(node: RehaxView, anchor?: RehaxView);
  removeView(node: RehaxView);
  getParent();
  getFirstChild();
  getNextSibling();

  setWidth(width: LengthType): void;
  setHeight(height: LengthType): void;
  setBackgroundColor(color: ColorType): void;

  addGesture(gesture: RehaxGesture): void;

  _rhx_gestureHandler?: {
    gesture: RehaxGesture;
    action: () => void;
    onMouseDown: (coords: XYCoords) => void;
    onMouseMove: (coords: XYCoords) => void;
    onMouseUp: (coords: XYCoords) => void;
  };
}

export class RehaxText extends RehaxView {
  setText(text: string): void;
}

export class RehaxButton extends RehaxView {}

export class RehaxTextInput extends RehaxView {}

export class RehaxVectorContainer extends RehaxView {}

export class RehaxVectorPath extends RehaxView {
  pathHorizontalTo(x: number): void;
  pathVerticalTo(y: number): void;
  pathMoveTo(x: number, y: number): void;
  pathMoveBy(x: number, y: number): void;
  pathLineTo(x: number, y: number): void;
  pathQuadraticBezier(x1: number, y1: number, x: number, y: number): void;
  pathCubicBezier(x1: number, y1: number, x2: number, y2: number, x: number, y: number): void;
  pathArc(
    rx: number,
    ry: number,
    xAxisRotation: number,
    largeArc: number,
    sweepFlag: number,
    x: number,
    y: number
  ): void;
}

export class RehaxILayout {}

export class RehaxStackLayout extends RehaxILayout {}

export class RehaxFlexLayout extends RehaxILayout {}

declare global {
  export const rehax = {
    rootView: RehaxView,
    Gesture: RehaxGesture,
    View: RehaxView,
    Text: RehaxText,
    Button: RehaxButton,
    TextInput: RehaxTextInput,
    VectorContainer: RehaxVectorContainer,
    VectorPath: RehaxVectorPath,
    StackLayout: RehaxStackLayout,
    FlexLayout: RehaxFlexLayout,
  }
}

export {};
