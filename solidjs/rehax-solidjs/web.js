import { createRenderer } from "solid-js/universal";
import parseSvgPath from "parse-svg-path";
import parseColor from "pure-color/parse";

function capitalize(str) {
  return str.charAt(0).toUpperCase() + str.slice(1);
}

function convertColor(color) {
  const result = parseColor(color);
  return {
    red: result[0],
    green: result[1],
    blue: result[2],
    alpha: result[3],
  };
}

function parseLength(value) {
  if (typeof value === "number") {
    return {
      value,
      type: "px",
    };
  }
  if (value.trim().endsWith("%")) {
    return {
      value: parseFloat(value),
      type: "%",
    };
  }

  return {
    value: parseFloat(value),
    type: "px",
  };
}

function flexEnsureOptions(node) {
  if (!node._rhx_styleFlexOptions) {
    node._rhx_styleFlexOptions = {
      direction: "row",
      justifyContent: "flex-start",
      alignItems: "flex-start",
    };
  }
  return node._rhx_styleFlexOptions;
}

function gestureEnsure(node) {
  if (!node._rhx_gestureHandler) {
    const gesture = new Gesture();
    function action() {
      node._rhx_gestureHandler.action({ x, y });
    }
    function onMouseDown(x, y) {
      node._rhx_gestureHandler.onMouseDown({ x, y });
    }
    function onMouseUp(x, y) {
      node._rhx_gestureHandler.onMouseUp({ x, y });
    }
    function onMouseMove(x, y) {
      node._rhx_gestureHandler.onMouseMove({ x, y });
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

const ViewMap = {
  div: View, //> view: div -> View
  p: Text, //> view: p -> Text
  button: Button, //> view: button -> Button
  input: TextInput, //> view: input -> TextInput
  svg: VectorContainer, //> view: svg -> VectorContainer
  path: VectorPath, //> view: path -> VectorPath
};

const StylePropHandlers = {
  width: (value, node) => {
    /*>
      view prop: width -> setWidth
      `px` will be converted to setWidthFixed
      `%` will be converted to setWidthPercentage
    */
    const length = parseLength(value);
    if (length.type === "%") {
      node.setWidthPercentage(length.value);
    } else if (length.type === "px") {
      node.setWidthFixed(length.value);
    }
  },
  height: (value, node) => {
    /*>
      view prop: height -> setHeight
      `px` will be converted to setHeightFixed
      `%` will be converted to setHeightPercentage
    */
    const length = parseLength(value);
    if (length.type === "%") {
      node.setHeightPercentage(length.value);
    } else if (length.type === "px") {
      node.setHeightFixed(length.value);
    }
  },
  display: (value, node) => {
    /*>
      view prop: display -> layout
      If the display is set to `flex`, it will create a FlexLayout and assign it to the view
      Otherwise, it will create a StackLayout and assign it to the view
    */
    if (value === "flex" && node._rhx_styleDisplay !== "flex") {
      node._rhx_styleDisplay = "flex";
      node._rhx_flexLayout = new FlexLayout();
      node.setLayout(node._rhx_flexLayout);
    } else if (value !== "flex" && node._rhx_styleDisplay === "flex") {
      node._rhx_styleDisplay = null;
      node._rhx_stackLayout = new StackLayout();
      node.setLayout(node._rhx_stackLayout);
    }
  },

  flexDirection: (value, node) => {
    const options = flexEnsureOptions(node);
    options.direction = value
    if (node._rhx_flexLayout) {
      node._rhx_flexLayout.setOptions(options);
      node.layout();
    }
  },
  justifyContent: (value, node) => {
    const options = flexEnsureOptions(node);
    options.justifyContent = value
    if (node._rhx_flexLayout) {
      node._rhx_flexLayout.setOptions(options);
      node.layout();
    }
  },
  alignItems: (value, node) => {
    const options = flexEnsureOptions(node);
    options.alignItems = value;
    if (node._rhx_flexLayout) {
      node._rhx_flexLayout.setOptions(options);
      node.layout();
    }
  },
  color: (value, node) => {
    //> p prop: color -> setTextColor
    node.setTextColor(convertColor(value));
  },
  fontSize: (value, node) => {
    //> p prop: fontSize -> setFontSize
    node.setFontSize(Number(value));
  },
};

const AttributeHandlers = {
  style: (node, value) => {
    // We try to set all the properties of the style object
    // Everything we don't know we just ignore
    for (let key of Object.keys(value)) {
      if (StylePropHandlers[key]) {
        StylePropHandlers[key](value[key], node);
      } else {
        const setterName = `set${capitalize(key)}`;
        if (setterName in node) {
          node[setterName](value[key]);
        }
      }
    }
  },

  d: (node, value) => {
    /*>
      path prop: d
      This takes the same format as the path attribute of a svg element
      It calls the `beginPath`, then the converted commands, then `endPath` of the VectorPath
      M x y -> pathMoveTo(x, y)
      m x y -> pathMoveBy(x, y)
      L x y -> pathLineTo(x, y)
      Z -> pathClose
      z -> pathClose
    */
    const parts = parseSvgPath(value);
    const mapCommand = {
      M: "pathMoveTo",
      m: "pathMoveBy",
      L: "pathLineTo",
      A: "pathArc",
      Q: "pathQuadraticBezier",
      C: "pathCubicBezier",
      Z: "pathClose",
      z: "pathClose",
    };
    node.beginPath();
    for (let part of parts) {
      if (mapCommand[part[0]] in node) {
        node[mapCommand[part[0]]](...part.slice(1));
      } else {
        console.error(`Unknown svg path command ${part[0]}`);
      }
    }
    node.endPath();
  },
  fill: (node, value) => {
    //> svg prop: fill -> setFill
    node.setFillColor(convertColor(value));
  },
  stroke: (node, value) => {
    //> svg prop: stroke -> setStroke
    node.setStrokeColor(convertColor(value));
  },
  strokeWidth: (node, value) => {
    //> svg prop: strokeWidth -> setLineWidth
    node.setLineWidth(Number(value));
  },
  strokeLinecap: (node, value) => {
    //> svg prop: strokeLineJoin -> setLineCap
    node.setLineCap(value);
  },
  strokeLinejoin: (node, value) => {
    //> svg prop: strokeLinejoin -> setLineJoin
    node.setLineJoin(value);
  },
  filter: (node, value) => {
    const filter = node._rhx_parent.__rhx_internal.find(
      (item) => item.__type === "filter" && item.id === "blurry"
    );
    node.setFilters({
      defs: filter.__rhx_internal.map((item) => ({
        type: item.__type === "feGaussianBlur" ? 0 : 0,
        blurRadius: Number(item.stdDeviation),
      })),
    });
  },

  onMouseDown: (node, value) => {
    gestureEnsure(node);
    node._rhx_gestureHandler.onMouseDown = value;
  },
  onMouseUp: (node, value) => {
    gestureEnsure(node);
    node._rhx_gestureHandler.onMouseUp = value;
  },
  onMouseMove: (node, value) => {
    gestureEnsure(node);
    node._rhx_gestureHandler.onMouseMove = value;
  },
};

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
    const Component = ViewMap[string];
    if (Component) {
      return new Component();
    }
    if (string === "filter" || string === "feGaussianBlur") {
      return {
        __internal: true,
        __type: string,
      };
    }
    return null;
  },
  createTextNode(value) {
    // console.log(`Create text: ${value}`);
    //> view: text -> Text
    var textView = new Text();
    textView.setText(value);
    return textView;
  },
  replaceText(textView, value) {
    // console.log(`Replace text: ${value}`);
    textView.setText(value);
  },
  setProperty(node, name, value) {
    // console.log(`Set prop: ${node} ${name}`);
    if (node.__internal) {
      node[name] = value;
      return;
    }
    const handler = AttributeHandlers[name];
    if (handler) {
      handler(node, value);
    } else {
      const setterName = `set${capitalize(name)}`;
      if (setterName in node) {
        if (typeof value === "string") {
          // There seems to be a bug where when we don't use the string before sending it to JavascriptCore, it will crash
          value.trim();
          node[setterName](String(value));
        } else {
          node[setterName](value);
        }
      } else {
        console.error(`Unknown property: ${name}`);
      }
    }
  },
  insertNode(parent, node, anchor) {
    if (node.__internal) {
      parent.__rhx_internal = [...(parent.__rhx_internal || []), node];
      return;
    }
    // console.log(`Insert node`);
    node._rhx_parent = parent;
    parent.addView(node, anchor);
  },
  isTextNode(node) {
    // console.log(`Is text ${node.__className}`);
    return node.__className === "Text";
  },
  removeNode(parent, node) {
    if (node.__internal) {
      return;
    }
    // console.log('Remove node')
    node._rhx_parent = null;
    parent.removeView(node);
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
