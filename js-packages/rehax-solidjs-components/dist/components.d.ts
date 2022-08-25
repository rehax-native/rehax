import { RehaxVectorPath, RehaxILayout, RehaxView, RehaxText, RehaxButton, RehaxTextInput, RehaxFlexLayout, RehaxStackLayout, RehaxVectorContainer } from "../rehax-solidjs-renderer/global";
import { JSX } from 'solid-js';
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
    width?: LengthType;
    height?: LengthType;
    backgroundColor?: ColorType;
    layout?: RehaxILayout;
    onMouseDown?: (e: {
        x: number;
        y: number;
    }) => void;
    onMouseMove?: (e: {
        x: number;
        y: number;
    }) => void;
    onMouseUp?: (e: {
        x: number;
        y: number;
    }) => void;
}
export interface ViewProps extends ViewBaseProps {
    children?: JSX.Element;
}
/** A base view */
export declare function View(props: ViewProps): RehaxView;
export interface TextProps extends ViewBaseProps {
    children?: string | RehaxText | Array<string | RehaxText>;
    color: ColorType;
}
/** A text view that can be styled and nested */
export declare function Text(props: TextProps): RehaxText;
export interface ButtonProps extends ViewBaseProps {
    title: string;
    onPress?: () => void;
}
/** A button */
export declare function Button(props: ButtonProps): RehaxButton;
export interface TextInputProps extends ViewBaseProps {
    value: string;
    onValueChange: () => void;
}
/** A text input to capture all kind of user input */
export declare function TextInput(props: TextInputProps): RehaxTextInput;
export interface FlexLayoutProps extends ViewBaseProps {
    options?: {
        direction?: "row" | "column" | "row-reverse" | "column-reverse";
        justifyContent?: "flex-start" | "flex-end" | "center" | "space-between" | "space-around";
        alignItems?: "flex-start" | "flex-end" | "center" | "stretch";
        items?: Array<{
            flexGrow?: number;
            order?: number;
            alignSelf?: "flex-start" | "flex-end" | "center" | "stretch";
        }>;
    };
}
export declare function FlexLayout(props: FlexLayoutProps): RehaxFlexLayout;
export interface StackLayoutProps extends ViewBaseProps {
    options?: {
        direction?: "horizontal" | "vertical";
        spacing?: number;
    };
}
export declare function StackLayout(props: StackLayoutProps): RehaxStackLayout;
export interface VectorContainerProps extends ViewBaseProps {
    children?: JSX.Element;
}
export declare function VectorContainer(props: VectorContainerProps): RehaxVectorContainer;
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
export declare function VectorPath(props: VectorPathProps): RehaxVectorPath;
export declare function MoveTo(x: number, y: number): (path: RehaxVectorPath) => void;
export declare function Arc(rx: number, ry: number, xAxisRotation: number, largeArc: number, sweepFlag: number, x: number, y: number): (path: RehaxVectorPath) => void;
