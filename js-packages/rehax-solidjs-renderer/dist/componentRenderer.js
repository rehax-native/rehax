import { createRenderer } from "solid-js/universal";
function capitalize(str) {
    return str.charAt(0).toUpperCase() + str.slice(1);
}
function gestureEnsure(node) {
    if (!node._rhx_gestureHandler) {
        const gesture = new rehax.Gesture();
        function action() {
            var _a;
            (_a = node._rhx_gestureHandler) === null || _a === void 0 ? void 0 : _a.action();
        }
        function onMouseDown(x, y) {
            var _a;
            (_a = node._rhx_gestureHandler) === null || _a === void 0 ? void 0 : _a.onMouseDown({ x, y });
        }
        function onMouseUp(x, y) {
            var _a;
            (_a = node._rhx_gestureHandler) === null || _a === void 0 ? void 0 : _a.onMouseUp({ x, y });
        }
        function onMouseMove(x, y) {
            var _a;
            (_a = node._rhx_gestureHandler) === null || _a === void 0 ? void 0 : _a.onMouseMove({ x, y });
        }
        gesture.setup(action, onMouseDown, onMouseUp, onMouseMove);
        node.addGesture(gesture);
        node._rhx_gestureHandler = {
            gesture,
            action: () => { },
            onMouseDown: () => { },
            onMouseUp: () => { },
            onMouseMove: () => { },
        };
    }
}
const ViewMap = {
    rehaxView: rehax.View,
    rehaxText: rehax.Text,
    rehaxButton: rehax.Button,
    rehaxInput: rehax.TextInput,
    rehaxSelect: rehax.Select,
    rehaxStackLayout: rehax.StackLayout,
    rehaxFlexLayout: rehax.FlexLayout,
    rehaxVectorContainer: rehax.VectorContainer,
    rehaxVectorRect: rehax.VectorRect,
    rehaxVectorPath: rehax.VectorPath,
};
const PropHandlers = {
    onMouseDown: (node, value) => {
        gestureEnsure(node);
        if (node._rhx_gestureHandler) {
            node._rhx_gestureHandler.onMouseDown = value;
        }
    },
    onMouseUp: (node, value) => {
        gestureEnsure(node);
        if (node._rhx_gestureHandler) {
            node._rhx_gestureHandler.onMouseUp = value;
        }
    },
    onMouseMove: (node, value) => {
        gestureEnsure(node);
        if (node._rhx_gestureHandler) {
            node._rhx_gestureHandler.onMouseMove = value;
        }
    },
    onKey: (node, value) => {
        const keyHandler = new rehax.KeyHandler();
        keyHandler.setup(value);
        node.addKeyHandler(keyHandler);
    },
};
export const { render, effect, memo, createComponent, createElement, createTextNode, insertNode, insert, spread, setProp, mergeProps, } = createRenderer({
    createElement(str) {
        const Component = ViewMap[str];
        if (Component) {
            return new Component();
        }
        return null;
    },
    createTextNode(value) {
        var textView = new rehax.Text();
        textView.setText(String(value));
        return textView;
    },
    replaceText(textView, value) {
        textView.setText(value);
    },
    setProperty(node, name, value) {
        const handler = PropHandlers[name];
        if (handler) {
            handler(node, value);
            return;
        }
        if (node.__className === "VectorPath" && name === "operations") {
            node.beginPath();
            for (const op of value) {
                op(node);
            }
            node.endPath();
            return;
        }
        const setterName = `set${capitalize(name)}`;
        if (setterName in node) {
            node[setterName](value);
        }
        else {
            console.error(`Unknown property on ${node.__className}: ${name}`);
        }
    },
    insertNode(parent, node, anchor) {
        parent.addView(node, anchor);
    },
    isTextNode(node) {
        return node.__className === "Text";
    },
    removeNode(parent, node) {
        parent.removeView(node);
    },
    getParentNode(node) {
        return node.getParent();
    },
    getFirstChild(node) {
        return node.getFirstChild();
    },
    getNextSibling(node) {
        return node.getNextSibling();
    },
});
// Forward Solid control flow
export { For, Show, Suspense, SuspenseList, Switch, Match, Index, ErrorBoundary, } from "solid-js";
