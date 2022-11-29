import { RehaxVectorRect, RehaxVectorPath, RehaxILayout, RehaxView, RehaxText, RehaxButton, RehaxTextInput, RehaxSelect, RehaxToggle, RehaxFlexLayout, RehaxStackLayout, RehaxVectorContainer, KeyEvent, MouseEvent } from "../rehax-solidjs-renderer/global";
import { JSX } from "solid-js";
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
export declare const Color: {
    /**
     * RGB are in range 0 - 255, alpha is 0.0 - 1.0
     */
    RGBA(red: number, green: number, blue: number, alpha: number): ColorType;
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
export declare type LengthType = FillLengthType | NaturalLengthType | FixedLengthType | PercentLengthType;
export declare const Length: {
    Fill(): FillLengthType;
    Natural(): NaturalLengthType;
    Fixed(value: number): FixedLengthType;
    Percent(value: number): PercentLengthType;
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
export declare function View(props: ViewProps): RehaxView;
export declare namespace View {
    var DefaultBackgroundColor: () => ColorType;
}
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
export declare function Text(props: TextProps): RehaxText;
export interface ButtonProps extends ViewBaseProps {
    backgroundColor?: ColorType;
    title: string;
    onPress?: () => void;
}
/** A button */
export declare function Button(props: ButtonProps): RehaxButton;
export interface TextInputProps extends ViewBaseProps {
    backgroundColor?: ColorType;
    value?: string;
    onValueChange?: (value: string) => void;
    onFocus?: () => void;
    onBlur?: () => void;
    onSubmit?: () => void;
}
/** A text input to capture all kind of user input */
export declare function TextInput(props: TextInputProps): RehaxTextInput;
interface SelectOption {
    value: string;
    name: string;
}
export interface SelectProps extends ViewBaseProps {
    options?: SelectOption[];
    onValueChange?: (value?: SelectOption) => void;
    value?: string;
}
export declare function Select(props: SelectProps): RehaxSelect;
export interface ToggleProps extends ViewBaseProps {
    onValueChange?: (value?: boolean) => void;
}
export declare function Toggle(props: ToggleProps): RehaxToggle;
export interface FlexLayoutProps {
    options?: {
        direction?: "row" | "column" | "row-reverse" | "column-reverse";
        justifyContent?: "flex-start" | "flex-end" | "center" | "space-between" | "space-around";
        alignItems?: "flex-start" | "flex-end" | "center" | "stretch";
        gap?: number;
        items?: Array<{
            flexGrow?: number;
            order?: number;
            alignSelf?: "flex-start" | "flex-end" | "center" | "stretch";
        }>;
    };
}
export declare function FlexLayout(props: FlexLayoutProps): RehaxFlexLayout;
export interface StackLayoutProps {
    options?: {
        direction?: "horizontal" | "vertical";
        spacing?: number;
    };
}
export declare function StackLayout(props: StackLayoutProps): RehaxStackLayout;
export interface VectorContainerProps extends ViewBaseProps {
    backgroundColor?: ColorType;
    children?: JSX.Element;
}
export declare function VectorContainer(props: VectorContainerProps): RehaxVectorContainer;
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
    size: {
        width: number;
        height: number;
    };
}
export declare function VectorRect(props: VectorRectProps): RehaxVectorRect;
export interface VectorPathProps extends VectorElementProps {
    operations: Array<(path: RehaxVectorPath) => void>;
}
export declare function VectorPath(props: VectorPathProps): RehaxVectorPath;
export declare function HorizontalTo(x: number): (path: RehaxVectorPath) => void;
export declare function VerticalTo(x: number): (path: RehaxVectorPath) => void;
export declare function MoveTo(x: number, y: number): (path: RehaxVectorPath) => void;
export declare function MoveBy(x: number, y: number): (path: RehaxVectorPath) => void;
export declare function LineTo(x: number, y: number): (path: RehaxVectorPath) => void;
export declare function QuadraticBezier(x1: number, y1: number, x: number, y: number): (path: RehaxVectorPath) => void;
export declare function CubicBezier(x1: number, y1: number, x2: number, y2: number, x: number, y: number): (path: RehaxVectorPath) => void;
export declare function Close(): (path: RehaxVectorPath) => void;
export declare function Arc(rx: number, ry: number, xAxisRotation: number, largeArc: number, sweepFlag: number, x: number, y: number): (path: RehaxVectorPath) => void;
export {};
