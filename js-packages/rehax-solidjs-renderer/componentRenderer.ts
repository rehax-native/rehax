import { createRenderer } from "solid-js/universal";
import { RehaxView, RehaxText } from "./global";

function capitalize(str: string) {
  return str.charAt(0).toUpperCase() + str.slice(1);
}

function gestureEnsure(node: RehaxView) {
  if (!node._rhx_gestureHandler) {
    const gesture = new rehax.Gesture();
    function action() {
      node._rhx_gestureHandler?.action();
    }
    function onMouseDown(x: number, y: number) {
      node._rhx_gestureHandler?.onMouseDown({ x, y });
    }
    function onMouseUp(x: number, y: number) {
      node._rhx_gestureHandler?.onMouseUp({ x, y });
    }
    function onMouseMove(x: number, y: number) {
      node._rhx_gestureHandler?.onMouseMove({ x, y });
    }
    gesture.setup(action, onMouseDown, onMouseUp, onMouseMove);
    node.addGesture(gesture);
    node._rhx_gestureHandler = {
      gesture,
      action: () => {},
      onMouseDown: () => {},
      onMouseUp: () => {},
      onMouseMove: () => {},
    };
  }
}

const ViewMap: Record<string, any> = {
  rehaxView: rehax.View,
  rehaxText: rehax.Text,
  rehaxButton: rehax.Button,
  rehaxInput: rehax.TextInput,
  rehaxStackLayout: rehax.StackLayout,
  rehaxFlexLayout: rehax.FlexLayout,
  rehaxVectorContainer: rehax.VectorContainer,
  rehaxVectorRect: rehax.VectorRect,
  rehaxVectorPath: rehax.VectorPath,
} as const;

const PropHandlers: Record<string, (node: RehaxView, value: any) => void> = {
  onMouseDown: (node: RehaxView, value: any) => {
    gestureEnsure(node);
    if (node._rhx_gestureHandler) {
      node._rhx_gestureHandler.onMouseDown = value;
    }
  },
  onMouseUp: (node: RehaxView, value: any) => {
    gestureEnsure(node);
    if (node._rhx_gestureHandler) {
      node._rhx_gestureHandler.onMouseUp = value;
    }
  },
  onMouseMove: (node: RehaxView, value: any) => {
    gestureEnsure(node);
    if (node._rhx_gestureHandler) {
      node._rhx_gestureHandler.onMouseMove = value;
    }
  },
} as const;

export const {
  render,
  effect,
  memo,
  createComponent,
  createElement,
  createTextNode,
  insertNode,
  insert,
  spread,
  setProp,
  mergeProps,
} = createRenderer({
  createElement(str: string) {
    const Component = ViewMap[str];
    if (Component) {
      return new Component();
    }
    return null;
  },
  createTextNode(value: string) {
    var textView = new rehax.Text();
    textView.setText(String(value));
    return textView;
  },
  replaceText(textView, value: string) {
    textView.setText(value);
  },
  setProperty(node, name: string, value: any) {
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
    } else {
      console.error(`Unknown property on ${node.__className}: ${name}`);
    }
  },
  insertNode(parent: RehaxView, node: RehaxView, anchor?: RehaxView) {
    parent.addView(node, anchor);
  },
  isTextNode(node: RehaxView) {
    return node.__className === "Text";
  },
  removeNode(parent: RehaxView, node: RehaxView) {
    parent.removeView(node);
  },
  getParentNode(node: RehaxView) {
    return node.getParent();
  },
  getFirstChild(node: RehaxView) {
    return node.getFirstChild();
  },
  getNextSibling(node: RehaxView) {
    return node.getNextSibling();
  },
});

// Forward Solid control flow
export {
  For,
  Show,
  Suspense,
  SuspenseList,
  Switch,
  Match,
  Index,
  ErrorBoundary,
} from "solid-js";
