import { RehaxVectorPath } from "../rehax-solidjs-renderer/global";

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

export interface ViewProps {
  width?: LengthType;
  height?: LengthType;
  backgroundColor?: ColorType;
}

/** A base view */
export function View(props: ViewProps) {
  return <rehaxView {...props} />;
}

export interface ButtonProps extends ViewProps {
  title: string;
  onPress: () => void;
}

/** A button */
export function Button(props: ButtonProps) {
  return <rehaxButton {...props} />;
}

export interface TextInputProps extends ViewProps {
  value: string;
  onValueChange: () => void;
}

/** A text input to capture all kind of user input */
export function TextInput(props: TextInputProps) {
  return <rehaxInput {...props} />;
}

export interface FlexLayoutProps extends ViewProps {}

export function FlexLayout(props: FlexLayoutProps) {
  return <rehaxFlexLayout {...props} />;
}

export interface StackLayoutProps extends ViewProps {}

export function StackLayout(props: StackLayoutProps) {
  return <rehaxStackLayout {...props} />;
}

export interface VectorContainerProps extends ViewProps {}

export function VectorContainer(props: VectorContainerProps) {
  return <rehaxVectorContainer {...props} />;
}

export interface VectorPathProps extends ViewProps {}

export function VectorPath(props: VectorPathProps) {
  return <rehaxVectorPath {...props} />;
}

// Vector Path operations

export function MoveTo(x: number, y: number) {
  return (path: RehaxVectorPath) => path.pathMoveTo(x, y);
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
