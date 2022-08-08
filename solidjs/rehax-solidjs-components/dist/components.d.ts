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
export interface ViewProps {
    width?: LengthType;
    height?: LengthType;
    backgroundColor?: ColorType;
}
/** A base view */
export declare function View(props: ViewProps): any;
export interface ButtonProps extends ViewProps {
    title: string;
    onPress: () => void;
}
/** A button */
export declare function Button(props: ButtonProps): any;
export interface TextInputProps extends ViewProps {
    value: string;
    onValueChange: () => void;
}
/** A text input to capture all kind of user input */
export declare function TextInput(props: TextInputProps): any;
export interface FlexLayoutProps extends ViewProps {
}
export declare function FlexLayout(props: FlexLayoutProps): any;
export interface StackLayoutProps extends ViewProps {
}
export declare function StackLayout(props: StackLayoutProps): any;
export interface VectorContainerProps extends ViewProps {
}
export declare function VectorContainer(props: VectorContainerProps): any;
export interface VectorPathProps extends ViewProps {
}
export declare function VectorPath(props: VectorPathProps): any;
export declare function MoveTo(x: number, y: number): (path: RehaxVectorPath) => void;
export declare function Arc(rx: number, ry: number, xAxisRotation: number, largeArc: number, sweepFlag: number, x: number, y: number): (path: RehaxVectorPath) => void;
