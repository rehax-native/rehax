import { isWeb } from "./util";
// function gestureEnsure(node: RehaxView) {
//   if (!node._rhx_gestureHandler) {
//     const gesture = new rehax.Gesture();
//     function action() {
//       node._rhx_gestureHandler?.action();
//     }
//     function onMouseDown(x: number, y: number) {
//       node._rhx_gestureHandler?.onMouseDown({ x, y });
//     }
//     function onMouseUp(x: number, y: number) {
//       node._rhx_gestureHandler?.onMouseUp({ x, y });
//     }
//     function onMouseMove(x: number, y: number) {
//       node._rhx_gestureHandler?.onMouseMove({ x, y });
//     }
//     gesture.setup(action, onMouseDown, onMouseUp, onMouseMove);
//     node.addGesture(gesture);
//     node._rhx_gestureHandler = {
//       gesture,
//       action: () => {},
//       onMouseDown: () => {},
//       onMouseUp: () => {},
//       onMouseMove: () => {},
//     };
//   }
// }
let ViewMap = {};
if (isWeb) {
    ViewMap = {
        rehaxView: () => document.createElement("div"),
        rehaxText: () => {
            const el = document.createElement("p");
            el.style.margin = "0";
            return el;
        },
        rehaxButton: () => document.createElement("button"),
        rehaxInput: () => {
            const el = document.createElement("input");
            return el;
        },
        rehaxSelect: () => document.createElement("select"),
        rehaxToggle: () => {
            const el = document.createElement("input");
            el.setAttribute("type", "checkbox");
            return el;
        },
        rehaxStackLayout: () => ({ isLayout: true, type: "stack" }),
        rehaxFlexLayout: () => ({ isLayout: true, type: "flex" }),
        rehaxVectorContainer: () => {
            const el = document.createElement("svg");
            // todo namespace
            return el;
        },
        // rehaxVectorRect: rehax.VectorRect,
        // rehaxVectorPath: rehax.VectorPath,
    };
}
function convertLength(prop) {
    var _a;
    if (prop.type === "fixed") {
        return `${(_a = prop.value) !== null && _a !== void 0 ? _a : 0}px`;
    }
    else if (prop.type === "fill") {
        return `100%`;
    }
}
function convertColor(prop) {
    return `rgba(${prop.red}, ${prop.green}, ${prop.blue}, ${prop.alpha})`;
}
const styleProps = {
    backgroundColor: {
        name: "backgroundColor",
        convert: convertColor,
    },
    textColor: {
        name: "color",
        convert: convertColor,
    },
    underlined: {
        name: "textDecoration",
        convert: (value) => (value ? "underline" : "none"),
    },
    strikeThrough: {
        name: "textDecoration",
        convert: (value) => (value ? "line-through" : "none"),
    },
    italic: {
        name: "fontStyle",
        convert: (value) => (value ? "italic" : "normal"),
    },
    fontSize: {
        name: "fontSize",
        convert: (value) => `${value}px`,
    },
    fontFamilies: {
        name: "fontFamily",
        convert: (value) => value.join(", "),
    },
    width: {
        name: "width",
        convert: convertLength,
    },
    height: {
        name: "height",
        convert: convertLength,
    },
};
const elementProps = {
    BUTTON: {
        title: (node, value) => (node.innerText = value),
        onPress: (node, value) => (node.onclick = value),
    },
    INPUT: {
        value: (node, value) => {
            const input = node;
            if (input.type === "checkbox") {
                input.checked = value;
            }
            else {
                input.value = value;
            }
        },
    },
    P: {
    // text: (node: HTMLElement, value: string) => (node.textContent = value),
    },
};
const props = {};
// const PropHandlers: Record<string, (node: Node, value: any) => void> = {
//   // onMouseDown: (node: RehaxView, value: any) => {
//   //   gestureEnsure(node);
//   //   if (node._rhx_gestureHandler) {
//   //     node._rhx_gestureHandler.onMouseDown = value;
//   //   }
//   // },
//   // onMouseUp: (node: RehaxView, value: any) => {
//   //   gestureEnsure(node);
//   //   if (node._rhx_gestureHandler) {
//   //     node._rhx_gestureHandler.onMouseUp = value;
//   //   }
//   // },
//   // onMouseMove: (node: RehaxView, value: any) => {
//   //   gestureEnsure(node);
//   //   if (node._rhx_gestureHandler) {
//   //     node._rhx_gestureHandler.onMouseMove = value;
//   //   }
//   // },
//   onKey: (node: HTMLElement, value) => {
//     // const keyHandler = new rehax.KeyHandler();
//     // keyHandler.setup(value);
//     // node.addKeyHandler(keyHandler);
//     // node.addEventListener('keydown', (e) => {
//     // })
//   },
//   onMouse: (node: HTMLElement, value: any) => {
//     // node.addEventListener('mouseup')
//   },
// } as const;
function setLayoutOptions(el, layout) {
    var _a, _b, _c, _d, _e, _f, _g, _h;
    // el.style.display = layout.type === "flex" ? "flex" : "block";
    el.style.display = "flex";
    el.style.flexDirection = "column"; // This is the default in rehax
    // if (layout.type === "flex") {
    // }
    if (layout.type === "flex") {
        for (const key of Object.keys((_a = layout.options) !== null && _a !== void 0 ? _a : {})) {
            el.style[key] = (_b = layout.options) === null || _b === void 0 ? void 0 : _b[key];
        }
        if ((_c = layout.options) === null || _c === void 0 ? void 0 : _c.gap) {
            el.style.gap = `${(_d = layout.options) === null || _d === void 0 ? void 0 : _d.gap}px`;
        }
    }
    else {
        el.style.padding = `${(_f = (_e = layout.options) === null || _e === void 0 ? void 0 : _e.spacing) !== null && _f !== void 0 ? _f : 0}px`;
        el.style.gap = `${(_h = (_g = layout.options) === null || _g === void 0 ? void 0 : _g.spacing) !== null && _h !== void 0 ? _h : 0}px`;
        el.style.alignItems = "flex-start";
    }
}
export const WebRenderer = {
    createElement(str) {
        const Component = ViewMap[str];
        if (Component) {
            const el = Component();
            if (el.style) {
                setLayoutOptions(el, {
                    isLayout: true,
                    type: "stack",
                });
            }
            return el;
        }
        return null;
    },
    createTextNode(value) {
        const el = document.createTextNode(value);
        return el;
    },
    replaceText(el, value) {
        el.textContent = value;
    },
    setProperty(node, name, value) {
        var _a, _b;
        if (!node) {
            return;
        }
        if ("isLayout" in node && node.isLayout) {
            node.options = Object.assign({}, node.options, value);
            if (node.el) {
                setLayoutOptions(node.el, node);
            }
            return;
        }
        const el = node;
        if (name === "layout") {
            const layout = value;
            layout.el = el; // This might be bad?
            setLayoutOptions(el, layout);
            return;
        }
        if (styleProps[name]) {
            const prop = styleProps[name];
            el.style[prop.name] = prop.convert(value);
            return;
        }
        if ((_a = elementProps[el.tagName]) === null || _a === void 0 ? void 0 : _a[name]) {
            (_b = elementProps[el.tagName]) === null || _b === void 0 ? void 0 : _b[name](el, value);
            return;
        }
        console.log(name, value);
        // const handler = PropHandlers[name];
        // if (handler) {
        //   handler(node, value);
        //   return;
        // }
        // if (node.__className === "VectorPath" && name === "operations") {
        //   node.beginPath();
        //   for (const op of value) {
        //     op(node);
        //   }
        //   node.endPath();
        //   return;
        // }
        // const setterName = `set${capitalize(name)}`;
        // if (setterName in node) {
        //   node[setterName](value);
        // } else {
        //   console.error(`Unknown property on ${node.__className}: ${name}`);
        // }
    },
    insertNode(parent, node, anchor) {
        parent.insertBefore(node, anchor !== null && anchor !== void 0 ? anchor : null);
    },
    isTextNode(node) {
        return Boolean(node.TEXT_NODE);
    },
    removeNode(parent, node) {
        parent.removeChild(node);
    },
    getParentNode(node) {
        return node.parentNode;
    },
    getFirstChild(node) {
        return node.firstChild;
    },
    getNextSibling(node) {
        return node.nextSibling;
    },
};
