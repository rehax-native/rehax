import { createRenderer } from "solid-js/universal";
import parseSvgPath from "parse-svg-path";
import parseColor from "pure-color/parse";


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
    // console.log(`Create element: ${string} ${View}`);
    switch (string) {
      case "div":
        return new View();
      case "button":
        return new Button();
      case "input":
        return new TextInput();
      case "svg":
        return new VectorContainer();
      case "path":
        return new VectorPath();
      default:
        return null;
    }
  },
  createTextNode(value) {
    // console.log(`Create text: ${value}`);
    var textView = new Text();
    textView.setText(value);
    return textView;
  },
  replaceText(textView, value) {
    // console.log(`Replace text: ${value}`);
    textView.setText(value);
  },
  setProperty(node, name, value) {
    console.log(`${node}`)
    // console.log(`Set prope: ${name}`);
    if (name === "style") {
      // We try to set all the properties of the style object
      // Everything we don't know we just ignore
      for (let key of Object.keys(value)) {
        if (key === "width") {
          node.setWidthFixed(Number(value[key])); // todo parse %, px, etc
        } else if (key === "height") {
          node.setHeightFixed(Number(value[key])); // todo parse %, px, etc
        } else {
          const setterName = `set${capitalize(key)}`;
          if (setterName in node) {
            node[setterName](value[key]);
          }
        }
      }
      return;
    } else if (name === 'd') {
      const parts = parseSvgPath(value);
      const mapCommand = {
        M: 'pathMoveTo',
        m: 'pathMoveBy',
        L: 'pathLineTo',
        // l: 'pathLineBy',
        // C: 'bezierCurveTo',
        Z: 'closePath',
        z: 'closePath',
      }
      node.beginPath();
      for (let part of parts) {
        if (mapCommand[part[0]] in node) {
          node[mapCommand[part[0]]](...part.slice(1))
        } else {
          console.error(`Unknown svg path command ${part[0]}`)
        }
      }
      node.endPath();
      return;
    }

    if (name == 'fill') {
      node.setFillColor(parseColor(value));
      return;
    } else if (name == 'stroke') {
      node.setStrokeColor(parseColor(value));
      return;
    } else if (name == 'strokeWidth') {
      node.setLineWidth(Number(value));
      return;
    }

    const setterName = `set${capitalize(name)}`;
    if (setterName in node) {
      node[setterName](value);
    } else {
      console.error(`Unknown property: ${name}`);
    }
    // if (name === "style") Object.assign(node.style, value);
    // else if (name.startsWith("on")) node[name.toLowerCase()] = value;
    // // else if (PROPERTIES.has(name)) node[name] = value;
    // else node.setAttribute(name, value);
  },
  insertNode(parent, node, anchor) {
    // console.log(`Insert node`);
    parent.addView(node, anchor);
  },
  isTextNode(node) {
    // console.log(`Is text ${node.__className}`);
    return node.__className === "Text";
  },
  removeNode(parent, node) {
    // console.log('Remove node')
    parent.removeChild(node);
  },
  getParentNode(node) {
    // console.log('Get parent')
    return node.getParent();
  },
  getFirstChild(node) {
    // console.log('Get first child')
    return node.getFirstChild();
  },
  getNextSibling(node) {
    // console.log('Get next sibling')
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
