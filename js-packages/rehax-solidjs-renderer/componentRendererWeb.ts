import { RendererOptions } from "solid-js/universal/types/universal";
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

let ViewMap: Record<string, any> = {};
// let PropHandlers: Record<string, (node: RehaxView, value: any) => void> = {}

interface Layout {
  isLayout: true;
  type: "flex" | "stack";
  options?: Record<string, any>;
  el?: HTMLElement;
}

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
  } as const;
}
function convertLength(prop: { type: "fixed" | "fill"; value?: number }) {
  if (prop.type === "fixed") {
    return `${prop.value ?? 0}px`;
  } else if (prop.type === "fill") {
    return `100%`;
  }
}

function convertColor(prop: any) {
  return `rgba(${prop.red}, ${prop.green}, ${prop.blue}, ${prop.alpha})`;
}

const styleProps: Record<
  string,
  { name: string; convert: (prop: any) => any }
> = {
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
    convert: (value: boolean) => (value ? "underline" : "none"),
  },
  strikeThrough: {
    name: "textDecoration",
    convert: (value: boolean) => (value ? "line-through" : "none"),
  },
  italic: {
    name: "fontStyle",
    convert: (value: boolean) => (value ? "italic" : "normal"),
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
} as const;

const elementProps: Record<
  string,
  Record<string, (node: HTMLElement, value: any) => void>
> = {
  BUTTON: {
    title: (node: HTMLElement, value: string) => (node.innerText = value),
    onPress: (node: HTMLElement, value: () => void) => (node.onclick = value),
  },
  INPUT: {
    value: (node: HTMLElement, value: string | boolean) => {
      const input = node as HTMLInputElement;
      if (input.type === "checkbox") {
        input.checked = value as boolean;
      } else {
        input.value = value as string;
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

function setLayoutOptions(el: HTMLElement, layout: Layout) {
  // el.style.display = layout.type === "flex" ? "flex" : "block";
  el.style.display = "flex";
  el.style.flexDirection = "column"; // This is the default in rehax
  // if (layout.type === "flex") {
  // }
  if (layout.type === "flex") {
    for (const key of Object.keys(layout.options ?? {})) {
      el.style[key as any] = layout.options?.[key];
    }
    if (layout.options?.gap) {
      el.style.gap = `${layout.options?.gap}px`;
    }
  } else {
    el.style.padding = `${layout.options?.spacing ?? 0}px`;
    el.style.gap = `${layout.options?.spacing ?? 0}px`;
    el.style.alignItems = "flex-start";
  }
}

export const WebRenderer: RendererOptions<any> = {
  createElement(str: string) {
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
  createTextNode(value: string) {
    const el = document.createTextNode(value);
    return el;
  },
  replaceText(el: Text, value: string) {
    el.textContent = value;
  },
  setProperty(node: HTMLElement | Layout, name: string, value: any) {
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
    const el = node as HTMLElement;
    if (name === "layout") {
      const layout = value as Layout;
      layout.el = el; // This might be bad?
      setLayoutOptions(el, layout);
      return;
    }
    if (styleProps[name]) {
      const prop = styleProps[name];
      el.style[prop.name as any] = prop.convert(value);
      return;
    }
    if (elementProps[el.tagName]?.[name]) {
      elementProps[el.tagName]?.[name](el, value);
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
  insertNode(parent: Node, node: Node, anchor?: Node) {
    parent.insertBefore(node, anchor ?? null);
  },
  isTextNode(node: Node | Text) {
    return node.nodeType === Node.TEXT_NODE;
  },
  removeNode(parent: Node, node: Node) {
    parent.removeChild(node);
  },
  getParentNode(node: Node) {
    return node.parentNode;
  },
  getFirstChild(node: Node) {
    return node.firstChild;
  },
  getNextSibling(node: Node) {
    return node.nextSibling;
  },
};
