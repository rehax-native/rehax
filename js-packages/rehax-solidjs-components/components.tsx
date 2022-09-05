import {
  RehaxVectorPath,
  RehaxILayout,
  RehaxView,
  RehaxText,
  RehaxButton,
  RehaxTextInput,
  RehaxFlexLayout,
  RehaxStackLayout,
  RehaxVectorContainer,
} from "../rehax-solidjs-renderer/global";
import { JSX } from 'solid-js'

export interface ColorType {
  /** Range 0 - 255 */
  red: number;
  /** Range 0 - 255 */
  green: number;
  /** Range 0 - 255 */
  blue: number;
  /** Range 0 - 1 */
  alpha: number;
}

export const Color = {
  /**
   * RGB are in range 0 - 255, alpha is 0.0 - 1.0
   */
  RGBA(red: number, green: number, blue: number, alpha: number): ColorType {
    return {
      red,
      green,
      blue,
      alpha,
    };
  },
};

/** Tries to fill the parent size fully */
export interface FillLengthType {
  type: "fill";
}

/** The natural length */
export interface NaturalLengthType {
  type: "natural";
}

/** A fixed length in screen independent pixels */
export interface FixedLengthType {
  type: "fixed";
  value: number;
}

/** A percentage of the parent */
export interface PercentLengthType {
  type: "percent";
  value: number;
}

export type LengthType =
  | FillLengthType
  | NaturalLengthType
  | FixedLengthType
  | PercentLengthType;

export const Length = {
  Fill(): FillLengthType {
    return {
      type: "fill",
    };
  },
  Natural(): NaturalLengthType {
    return {
      type: "natural",
    };
  },
  Fixed(value: number): FixedLengthType {
    return {
      value,
      type: "fixed",
    };
  },
  Percent(value: number): PercentLengthType {
    return {
      value,
      type: "percent",
    };
  },
};

export interface ViewBaseProps {
  width?: LengthType;
  height?: LengthType;
  backgroundColor?: ColorType;
  layout?: RehaxILayout;

  onMouseDown?: (e: { x: number; y: number }) => void;
  onMouseMove?: (e: { x: number; y: number }) => void;
  onMouseUp?: (e: { x: number; y: number }) => void;
}

export interface ViewProps extends ViewBaseProps {
  children?: JSX.Element
}

/** A base view */
export function View(props: ViewProps): RehaxView {
  return <rehaxView {...props} />;
}

export interface TextProps extends ViewBaseProps {
  children?: string | RehaxText | Array<string | RehaxText>;
  textColor?: ColorType;
  fontSize?: number;
  italic?: boolean;
  strikeThrough?: boolean;
  underlined?: boolean;
  setFontFamilies?: string[]
}

/** A text view that can be styled and nested */
export function Text(props: TextProps): RehaxText {
  return <rehaxText {...props} />;
}

export interface ButtonProps extends ViewBaseProps {
  title: string;
  onPress?: () => void;
}

/** A button */
export function Button(props: ButtonProps): RehaxButton {
  return <rehaxButton {...props} />;
}

export interface TextInputProps extends ViewBaseProps {
  value: string;
  onValueChange: () => void;
}

/** A text input to capture all kind of user input */
export function TextInput(props: TextInputProps): RehaxTextInput {
  return <rehaxInput {...props} />;
}

export interface FlexLayoutProps extends ViewBaseProps {
  options?: {
    direction?: "row" | "column" | "row-reverse" | "column-reverse";
    justifyContent?:
      | "flex-start"
      | "flex-end"
      | "center"
      | "space-between"
      | "space-around";
    alignItems?: "flex-start" | "flex-end" | "center" | "stretch"; // | "baseline";
    items?: Array<{
      flexGrow?: number;
      order?: number;
      alignSelf?: "flex-start" | "flex-end" | "center" | "stretch"; // | "baseline";
    }>;
  };
}

export function FlexLayout(props: FlexLayoutProps): RehaxFlexLayout {
  return <rehaxFlexLayout {...props} />;
}

export interface StackLayoutProps extends ViewBaseProps {
  options?: {
    direction?: "horizontal" | "vertical";
    spacing?: number;
  };
}

export function StackLayout(props: StackLayoutProps): RehaxStackLayout {
  return <rehaxStackLayout {...props} />;
}

export interface VectorContainerProps extends ViewBaseProps {
  children?: JSX.Element
}

export function VectorContainer(
  props: VectorContainerProps
): RehaxVectorContainer {
  return <rehaxVectorContainer {...props} />;
}

export interface VectorElementProps extends ViewBaseProps {
  lineWidth?: number;
  strokeColor?: ColorType;
  lineCap?: "butt" | "round" | "square";
  lineJoin?: "miter" | "bevel" | "round";
  filters?: {
    defs: Array<{
      type: "blur";
      blurRadius: number;
    }>;
  };
}

export interface VectorPathProps extends VectorElementProps {
  operations: Array<(path: RehaxVectorPath) => void>;
}

export function VectorPath(props: VectorPathProps): RehaxVectorPath {
  return <rehaxVectorPath {...props} />;
}

// Vector Path operations

export function HorizontalTo(x: number) {
  return (path: RehaxVectorPath) => path.pathHorizontalTo(x);
}

export function VerticalTo(x: number) {
  return (path: RehaxVectorPath) => path.pathVerticalTo(x);
}

export function MoveTo(x: number, y: number) {
  return (path: RehaxVectorPath) => path.pathMoveTo(x, y);
}

export function MoveBy(x: number, y: number) {
  return (path: RehaxVectorPath) => path.pathMoveBy(x, y);
}

export function LineTo(x: number, y: number) {
  return (path: RehaxVectorPath) => path.pathLineTo(x, y);
}

export function QuadraticBezier(x1: number, y1: number, x: number, y: number) {
  return (path: RehaxVectorPath) => path.pathQuadraticBezier(x1, y1, x, y);
}

export function CubicBezier(x1: number, y1: number, x2: number, y2: number, x: number, y: number) {
  return (path: RehaxVectorPath) => path.pathCubicBezier(x1, y1, x2, y2, x, y);
}

export function Arc(
  rx: number,
  ry: number,
  xAxisRotation: number,
  largeArc: number,
  sweepFlag: number,
  x: number,
  y: number
) {
  return (path: RehaxVectorPath) =>
    path.pathArc(rx, ry, xAxisRotation, largeArc, sweepFlag, x, y);
}
