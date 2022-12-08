import {
  RehaxVectorRect,
  RehaxVectorPath,
  RehaxILayout,
  RehaxView,
  RehaxText,
  RehaxButton,
  RehaxTextInput,
  RehaxSelect,
  RehaxToggle,
  RehaxFlexLayout,
  RehaxStackLayout,
  RehaxVectorContainer,
  KeyEvent,
  MouseEvent,
} from "../rehax-solidjs-renderer/global";
import {
  Accessor,
  createContext,
  createSignal,
  JSX,
  onCleanup,
  onMount,
  useContext,
} from "solid-js";

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
  horizontalPosition?: LengthType;
  verticalPosition?: LengthType;
  width?: LengthType;
  height?: LengthType;
}

export interface ViewProps extends ViewBaseProps {
  backgroundColor?: ColorType;
  layout?: RehaxILayout;
  children?: JSX.Element;
  onKey?: (e: KeyEvent) => void;
  onMouse?: (e: MouseEvent) => void;
}

/** A base view */
export function View(props: ViewProps): RehaxView {
  return <rehaxView {...props} />;
}

View.DefaultBackgroundColor = () => rehax.View.DefaultBackgroundColor();

export interface TextProps extends ViewBaseProps {
  children?: string | RehaxText | Array<string | RehaxText>;
  backgroundColor?: ColorType;
  textColor?: ColorType;
  fontSize?: number;
  italic?: boolean;
  strikeThrough?: boolean;
  underlined?: boolean;
  fontFamilies?: string[];
}

/** A text view that can be styled and nested */
export function Text(props: TextProps): RehaxText {
  return <rehaxText {...props} />;
}

export interface ButtonProps extends ViewBaseProps {
  backgroundColor?: ColorType;
  title: string;
  onPress?: () => void;
}

/** A button */
export function Button(props: ButtonProps): RehaxButton {
  return <rehaxButton {...props} />;
}

export interface TextInputProps extends ViewBaseProps {
  backgroundColor?: ColorType;
  value?: string;
  onValueChange?: (value: string) => void;

  onFocus?: () => void;
  onBlur?: () => void;
  onSubmit?: () => void;
}

/** A text input to capture all kind of user input */
export function TextInput(props: TextInputProps): RehaxTextInput {
  return <rehaxInput {...props} />;
}

interface SelectOption {
  value: string;
  name: string;
}

export interface SelectProps extends ViewBaseProps {
  options?: SelectOption[];
  onValueChange?: (value?: SelectOption) => void;
  value?: string;
}

export function Select(props: SelectProps): RehaxSelect {
  return <rehaxSelect {...props} />;
}

export interface ToggleProps extends ViewBaseProps {
  value?: boolean;
  onValueChange?: (value?: boolean) => void;
}

export function Toggle(props: ToggleProps): RehaxToggle {
  return <rehaxToggle {...props} />;
}

export interface FlexLayoutProps {
  options?: {
    direction?: "row" | "column" | "row-reverse" | "column-reverse";
    justifyContent?:
      | "flex-start"
      | "flex-end"
      | "center"
      | "space-between"
      | "space-around";
    alignItems?: "flex-start" | "flex-end" | "center" | "stretch"; // | "baseline";
    gap?: number;
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

export interface StackLayoutProps {
  options?: {
    direction?: "horizontal" | "vertical";
    spacing?: number;
  };
}

export function StackLayout(props: StackLayoutProps): RehaxStackLayout {
  return <rehaxStackLayout {...props} />;
}

export interface VectorContainerProps extends ViewBaseProps {
  backgroundColor?: ColorType;
  children?: JSX.Element;
}

export function VectorContainer(
  props: VectorContainerProps
): RehaxVectorContainer {
  return <rehaxVectorContainer {...props} />;
}

export interface VectorElementProps extends ViewBaseProps {
  lineWidth?: number;
  strokeColor?: ColorType;
  fillColor?: ColorType;
  lineCap?: "butt" | "round" | "square";
  lineJoin?: "miter" | "bevel" | "round";
  filters?: {
    defs: Array<{
      type: "blur";
      blurRadius: number;
    }>;
  };
}

export interface VectorRectProps extends VectorElementProps {
  size: { width: number; height: number };
}

export function VectorRect(props: VectorRectProps): RehaxVectorRect {
  return <rehaxVectorRect {...props} />;
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

export function CubicBezier(
  x1: number,
  y1: number,
  x2: number,
  y2: number,
  x: number,
  y: number
) {
  return (path: RehaxVectorPath) => path.pathCubicBezier(x1, y1, x2, y2, x, y);
}

export function Close() {
  return (path: RehaxVectorPath) => path.pathClose();
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

export type Theme = "unsupported" | "system-dark" | "system-light";
type ThemeChangeListener = number;

export const ThemeContext = createContext<[Accessor<Theme>]>([
  () => "unsupported",
]);

const isWeb = typeof rehax === "undefined";

const themeProvider = isWeb
  ? {
      app: {
        getApplicationTheme: () => "unsupported" as Theme,
        addApplicationThemeChangeListener: (listener: (theme: Theme) => void) =>
          0,
        removeApplicationThemeChangeListener: (
          listener: ThemeChangeListener
        ) => {},
      },
    }
  : (rehax as unknown as {
      app: {
        getApplicationTheme: () => Theme;
        addApplicationThemeChangeListener: (
          listener: (theme: Theme) => void
        ) => ThemeChangeListener;
        removeApplicationThemeChangeListener: (
          listener: ThemeChangeListener
        ) => void;
      };
    });

export function ThemeProvider(props: { children: JSX.Element }) {
  const [theme, setTheme] = createSignal<Theme>(
    themeProvider.app.getApplicationTheme()
  );
  onMount(() => {
    const listener = themeProvider.app.addApplicationThemeChangeListener(
      (theme: Theme) => {
        setTheme(theme);
      }
    );
    onCleanup(() => {
      themeProvider.app.removeApplicationThemeChangeListener(listener);
    });
  });
  return <ThemeContext.Provider value={[theme]} children={props.children} />;
}

export function useApplicationTheme() {
  return useContext(ThemeContext);
}
