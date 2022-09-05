export const Color = {
    /**
     * RGB are in range 0 - 255, alpha is 0.0 - 1.0
     */
    RGBA(red, green, blue, alpha) {
        return {
            red,
            green,
            blue,
            alpha,
        };
    },
};
export const Length = {
    Fill() {
        return {
            type: "fill",
        };
    },
    Natural() {
        return {
            type: "natural",
        };
    },
    Fixed(value) {
        return {
            value,
            type: "fixed",
        };
    },
    Percent(value) {
        return {
            value,
            type: "percent",
        };
    },
};
/** A base view */
export function View(props) {
    return <rehaxView {...props}/>;
}
/** A text view that can be styled and nested */
export function Text(props) {
    return <rehaxText {...props}/>;
}
/** A button */
export function Button(props) {
    return <rehaxButton {...props}/>;
}
/** A text input to capture all kind of user input */
export function TextInput(props) {
    return <rehaxInput {...props}/>;
}
export function FlexLayout(props) {
    return <rehaxFlexLayout {...props}/>;
}
export function StackLayout(props) {
    return <rehaxStackLayout {...props}/>;
}
export function VectorContainer(props) {
    return <rehaxVectorContainer {...props}/>;
}
export function VectorPath(props) {
    return <rehaxVectorPath {...props}/>;
}
// Vector Path operations
export function HorizontalTo(x) {
    return (path) => path.pathHorizontalTo(x);
}
export function VerticalTo(x) {
    return (path) => path.pathVerticalTo(x);
}
export function MoveTo(x, y) {
    return (path) => path.pathMoveTo(x, y);
}
export function MoveBy(x, y) {
    return (path) => path.pathMoveBy(x, y);
}
export function LineTo(x, y) {
    return (path) => path.pathLineTo(x, y);
}
export function QuadraticBezier(x1, y1, x, y) {
    return (path) => path.pathQuadraticBezier(x1, y1, x, y);
}
export function CubicBezier(x1, y1, x2, y2, x, y) {
    return (path) => path.pathCubicBezier(x1, y1, x2, y2, x, y);
}
export function Arc(rx, ry, xAxisRotation, largeArc, sweepFlag, x, y) {
    return (path) => path.pathArc(rx, ry, xAxisRotation, largeArc, sweepFlag, x, y);
}
