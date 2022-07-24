import { createRenderer } from "solid-js/universal";

function capitalize(str) {
  return str.charAt(0).toUpperCase() + str.slice(1);
}

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
  createElement(string) {
    switch (string) {
      case "div":
        return new View();
      case "button":
        return new Button();
      default:
        return null;
    }
  },
  createTextNode(value) {
    var textView = new Text();
    textView.setText(value);
    return textView;
  },
  replaceText(textView, value) {
    textView.setText(value);
  },
  setProperty(node, name, value) {
    if (name === 'style') {
      // We try to set all the properties of the style object
      // Everything we don't know we just ignore
      for (let key in Object.keys(value)) {
        const setterName = `set${capitalize(key)}`;
        if (setterName in node) {
          node[setterName](value[key]);
        }
      }
      return
    }

    const setterName = `set${capitalize(name)}`;
    if (setterName in node) {
      node[setterName](value);
    } else {
      console.error("Unknown property:", name);
    }
    // if (name === "style") Object.assign(node.style, value);
    // else if (name.startsWith("on")) node[name.toLowerCase()] = value;
    // // else if (PROPERTIES.has(name)) node[name] = value;
    // else node.setAttribute(name, value);
  },
  insertNode(parent, node, anchor) {
    parent.addView(node, anchor);
  },
  isTextNode(node) {
    return node.constructor.name === 'Text';
  },
  removeNode(parent, node) {
    parent.removeChild(node);
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

export function getRootView() {
  return rootView;
}
