'use strict';

require('crypto');

const equalFn = (a, b) => a === b;

const $PROXY = Symbol("solid-proxy");
const signalOptions = {
  equals: equalFn
};
let runEffects = runQueue;
const NOTPENDING = {};
const STALE = 1;
const PENDING = 2;
const UNOWNED = {
  owned: null,
  cleanups: null,
  context: null,
  owner: null
};
var Owner = null;
let Transition = null;
let Listener = null;
let Pending = null;
let Updates = null;
let Effects = null;
let ExecCount = 0;

function createRoot(fn, detachedOwner) {
  const listener = Listener,
        owner = Owner,
        unowned = fn.length === 0,
        root = unowned && !false ? UNOWNED : {
    owned: null,
    cleanups: null,
    context: null,
    owner: detachedOwner || owner
  },
        updateFn = unowned ? fn : () => fn(() => cleanNode(root));
  Owner = root;
  Listener = null;

  try {
    return runUpdates(updateFn, true);
  } finally {
    Listener = listener;
    Owner = owner;
  }
}

function createSignal(value, options) {
  options = options ? Object.assign({}, signalOptions, options) : signalOptions;
  const s = {
    value,
    observers: null,
    observerSlots: null,
    pending: NOTPENDING,
    comparator: options.equals || undefined
  };

  const setter = value => {
    if (typeof value === "function") {
      value = value(s.pending !== NOTPENDING ? s.pending : s.value);
    }

    return writeSignal(s, value);
  };

  return [readSignal.bind(s), setter];
}

function createRenderEffect(fn, value, options) {
  const c = createComputation(fn, value, false, STALE);
  updateComputation(c);
}

function createMemo(fn, value, options) {
  options = options ? Object.assign({}, signalOptions, options) : signalOptions;
  const c = createComputation(fn, value, true, 0);
  c.pending = NOTPENDING;
  c.observers = null;
  c.observerSlots = null;
  c.comparator = options.equals || undefined;

  updateComputation(c);

  return readSignal.bind(c);
}

function batch(fn) {
  if (Pending) return fn();
  let result;
  const q = Pending = [];

  try {
    result = fn();
  } finally {
    Pending = null;
  }

  runUpdates(() => {
    for (let i = 0; i < q.length; i += 1) {
      const data = q[i];

      if (data.pending !== NOTPENDING) {
        const pending = data.pending;
        data.pending = NOTPENDING;
        writeSignal(data, pending);
      }
    }
  }, false);
  return result;
}

function untrack(fn) {
  let result,
      listener = Listener;
  Listener = null;
  result = fn();
  Listener = listener;
  return result;
}

function readSignal() {
  const runningTransition = Transition ;

  if (this.sources && (this.state || runningTransition )) {
    const updates = Updates;
    Updates = null;
    this.state === STALE || runningTransition  ? updateComputation(this) : lookUpstream(this);
    Updates = updates;
  }

  if (Listener) {
    const sSlot = this.observers ? this.observers.length : 0;

    if (!Listener.sources) {
      Listener.sources = [this];
      Listener.sourceSlots = [sSlot];
    } else {
      Listener.sources.push(this);
      Listener.sourceSlots.push(sSlot);
    }

    if (!this.observers) {
      this.observers = [Listener];
      this.observerSlots = [Listener.sources.length - 1];
    } else {
      this.observers.push(Listener);
      this.observerSlots.push(Listener.sources.length - 1);
    }
  }
  return this.value;
}

function writeSignal(node, value, isComp) {
  if (Pending) {
    if (node.pending === NOTPENDING) Pending.push(node);
    node.pending = value;
    return value;
  }

  if (node.comparator) {
    if (node.comparator(node.value, value)) return value;
  }

  let TransitionRunning = false;

  node.value = value;

  if (node.observers && node.observers.length) {
    runUpdates(() => {
      for (let i = 0; i < node.observers.length; i += 1) {
        const o = node.observers[i];
        if (TransitionRunning && Transition.disposed.has(o)) ;

        if (TransitionRunning && !o.tState || !TransitionRunning && !o.state) {
          if (o.pure) Updates.push(o);else Effects.push(o);
          if (o.observers) markDownstream(o);
        }

        if (TransitionRunning) ;else o.state = STALE;
      }

      if (Updates.length > 10e5) {
        Updates = [];
        if (false) ;
        throw new Error();
      }
    }, false);
  }

  return value;
}

function updateComputation(node) {
  if (!node.fn) return;
  cleanNode(node);
  const owner = Owner,
        listener = Listener,
        time = ExecCount;
  Listener = Owner = node;
  runComputation(node, node.value, time);

  Listener = listener;
  Owner = owner;
}

function runComputation(node, value, time) {
  let nextValue;

  try {
    nextValue = node.fn(value);
  } catch (err) {
    handleError(err);
  }

  if (!node.updatedAt || node.updatedAt <= time) {
    if (node.observers && node.observers.length) {
      writeSignal(node, nextValue);
    } else node.value = nextValue;

    node.updatedAt = time;
  }
}

function createComputation(fn, init, pure, state = STALE, options) {
  const c = {
    fn,
    state: state,
    updatedAt: null,
    owned: null,
    sources: null,
    sourceSlots: null,
    cleanups: null,
    value: init,
    owner: Owner,
    context: null,
    pure
  };

  if (Owner === null) ;else if (Owner !== UNOWNED) {
    {
      if (!Owner.owned) Owner.owned = [c];else Owner.owned.push(c);
    }
  }

  return c;
}

function runTop(node) {
  const runningTransition = Transition ;
  if (node.state === 0 || runningTransition ) return;
  if (node.state === PENDING || runningTransition ) return lookUpstream(node);
  if (node.suspense && untrack(node.suspense.inFallback)) return node.suspense.effects.push(node);
  const ancestors = [node];

  while ((node = node.owner) && (!node.updatedAt || node.updatedAt < ExecCount)) {
    if (node.state || runningTransition ) ancestors.push(node);
  }

  for (let i = ancestors.length - 1; i >= 0; i--) {
    node = ancestors[i];

    if (node.state === STALE || runningTransition ) {
      updateComputation(node);
    } else if (node.state === PENDING || runningTransition ) {
      const updates = Updates;
      Updates = null;
      lookUpstream(node, ancestors[0]);
      Updates = updates;
    }
  }
}

function runUpdates(fn, init) {
  if (Updates) return fn();
  let wait = false;
  if (!init) Updates = [];
  if (Effects) wait = true;else Effects = [];
  ExecCount++;

  try {
    const res = fn();
    completeUpdates(wait);
    return res;
  } catch (err) {
    if (!Updates) Effects = null;
    handleError(err);
  }
}

function completeUpdates(wait) {
  if (Updates) {
    runQueue(Updates);
    Updates = null;
  }

  if (wait) return;

  if (Effects.length) batch(() => {
    runEffects(Effects);
    Effects = null;
  });else {
    Effects = null;
  }
}

function runQueue(queue) {
  for (let i = 0; i < queue.length; i++) runTop(queue[i]);
}

function lookUpstream(node, ignore) {
  const runningTransition = Transition ;
  node.state = 0;

  for (let i = 0; i < node.sources.length; i += 1) {
    const source = node.sources[i];

    if (source.sources) {
      if (source.state === STALE || runningTransition ) {
        if (source !== ignore) runTop(source);
      } else if (source.state === PENDING || runningTransition ) lookUpstream(source, ignore);
    }
  }
}

function markDownstream(node) {
  const runningTransition = Transition ;

  for (let i = 0; i < node.observers.length; i += 1) {
    const o = node.observers[i];

    if (!o.state || runningTransition ) {
      o.state = PENDING;
      if (o.pure) Updates.push(o);else Effects.push(o);
      o.observers && markDownstream(o);
    }
  }
}

function cleanNode(node) {
  let i;

  if (node.sources) {
    while (node.sources.length) {
      const source = node.sources.pop(),
            index = node.sourceSlots.pop(),
            obs = source.observers;

      if (obs && obs.length) {
        const n = obs.pop(),
              s = source.observerSlots.pop();

        if (index < obs.length) {
          n.sourceSlots[s] = index;
          obs[index] = n;
          source.observerSlots[index] = s;
        }
      }
    }
  }

  if (node.owned) {
    for (i = 0; i < node.owned.length; i++) cleanNode(node.owned[i]);

    node.owned = null;
  }

  if (node.cleanups) {
    for (i = 0; i < node.cleanups.length; i++) node.cleanups[i]();

    node.cleanups = null;
  }

  node.state = 0;
  node.context = null;
}

function handleError(err) {
  throw err;
}

function createComponent$1(Comp, props) {

  return untrack(() => Comp(props || {}));
}

function trueFn() {
  return true;
}

const propTraps = {
  get(_, property, receiver) {
    if (property === $PROXY) return receiver;
    return _.get(property);
  },

  has(_, property) {
    return _.has(property);
  },

  set: trueFn,
  deleteProperty: trueFn,

  getOwnPropertyDescriptor(_, property) {
    return {
      configurable: true,
      enumerable: true,

      get() {
        return _.get(property);
      },

      set: trueFn,
      deleteProperty: trueFn
    };
  },

  ownKeys(_) {
    return _.keys();
  }

};

function resolveSource(s) {
  return (s = typeof s === "function" ? s() : s) == null ? {} : s;
}

function mergeProps$2(...sources) {
  return new Proxy({
    get(property) {
      for (let i = sources.length - 1; i >= 0; i--) {
        const v = resolveSource(sources[i])[property];
        if (v !== undefined) return v;
      }
    },

    has(property) {
      for (let i = sources.length - 1; i >= 0; i--) {
        if (property in resolveSource(sources[i])) return true;
      }

      return false;
    },

    keys() {
      const keys = [];

      for (let i = 0; i < sources.length; i++) keys.push(...Object.keys(resolveSource(sources[i])));

      return [...new Set(keys)];
    }

  }, propTraps);
}

function Show(props) {
  let strictEqual = false;
  const condition = createMemo(() => props.when, undefined, {
    equals: (a, b) => strictEqual ? a === b : !a === !b
  });
  return createMemo(() => {
    const c = condition();

    if (c) {
      const child = props.children;
      return (strictEqual = typeof child === "function" && child.length > 0) ? untrack(() => child(c)) : child;
    }

    return props.fallback;
  });
}

function memo$1(fn, equals) {
  return createMemo(fn, undefined, !equals ? {
    equals
  } : undefined);
}

function createRenderer$1({
  createElement,
  createTextNode,
  isTextNode,
  replaceText,
  insertNode,
  removeNode,
  setProperty,
  getParentNode,
  getFirstChild,
  getNextSibling
}) {
  function insert(parent, accessor, marker, initial) {
    if (marker !== undefined && !initial) initial = [];
    if (typeof accessor !== "function") return insertExpression(parent, accessor, initial, marker);
    createRenderEffect(current => insertExpression(parent, accessor(), current, marker), initial);
  }

  function insertExpression(parent, value, current, marker, unwrapArray) {
    while (typeof current === "function") current = current();

    if (value === current) return current;
    const t = typeof value,
          multi = marker !== undefined;

    if (t === "string" || t === "number") {
      if (t === "number") value = value.toString();

      if (multi) {
        let node = current[0];

        if (node && isTextNode(node)) {
          replaceText(node, value);
        } else node = createTextNode(value);

        current = cleanChildren(parent, current, marker, node);
      } else {
        if (current !== "" && typeof current === "string") {
          replaceText(getFirstChild(parent), current = value);
        } else {
          cleanChildren(parent, current, marker, createTextNode(value));
          current = value;
        }
      }
    } else if (value == null || t === "boolean") {
      current = cleanChildren(parent, current, marker);
    } else if (t === "function") {
      createRenderEffect(() => {
        let v = value();

        while (typeof v === "function") v = v();

        current = insertExpression(parent, v, current, marker);
      });
      return () => current;
    } else if (Array.isArray(value)) {
      const array = [];

      if (normalizeIncomingArray(array, value, unwrapArray)) {
        createRenderEffect(() => current = insertExpression(parent, array, current, marker, true));
        return () => current;
      }

      if (array.length === 0) {
        const replacement = cleanChildren(parent, current, marker);
        if (multi) return current = replacement;
      } else {
        if (Array.isArray(current)) {
          if (current.length === 0) {
            appendNodes(parent, array, marker);
          } else reconcileArrays(parent, current, array);
        } else if (current == null || current === "") {
          appendNodes(parent, array);
        } else {
          reconcileArrays(parent, multi && current || [getFirstChild(parent)], array);
        }
      }

      current = array;
    } else {
      if (Array.isArray(current)) {
        if (multi) return current = cleanChildren(parent, current, marker, value);
        cleanChildren(parent, current, null, value);
      } else if (current == null || current === "" || !getFirstChild(parent)) {
        insertNode(parent, value);
      } else replaceNode(parent, value, getFirstChild(parent));

      current = value;
    }

    return current;
  }

  function normalizeIncomingArray(normalized, array, unwrap) {
    let dynamic = false;

    for (let i = 0, len = array.length; i < len; i++) {
      let item = array[i],
          t;
      if (item == null || item === true || item === false) ;else if (Array.isArray(item)) {
        dynamic = normalizeIncomingArray(normalized, item) || dynamic;
      } else if ((t = typeof item) === "string" || t === "number") {
        normalized.push(createTextNode(item));
      } else if (t === "function") {
        if (unwrap) {
          while (typeof item === "function") item = item();

          dynamic = normalizeIncomingArray(normalized, Array.isArray(item) ? item : [item]) || dynamic;
        } else {
          normalized.push(item);
          dynamic = true;
        }
      } else normalized.push(item);
    }

    return dynamic;
  }

  function reconcileArrays(parentNode, a, b) {
    let bLength = b.length,
        aEnd = a.length,
        bEnd = bLength,
        aStart = 0,
        bStart = 0,
        after = getNextSibling(a[aEnd - 1]),
        map = null;

    while (aStart < aEnd || bStart < bEnd) {
      if (a[aStart] === b[bStart]) {
        aStart++;
        bStart++;
        continue;
      }

      while (a[aEnd - 1] === b[bEnd - 1]) {
        aEnd--;
        bEnd--;
      }

      if (aEnd === aStart) {
        const node = bEnd < bLength ? bStart ? getNextSibling(b[bStart - 1]) : b[bEnd - bStart] : after;

        while (bStart < bEnd) insertNode(parentNode, b[bStart++], node);
      } else if (bEnd === bStart) {
        while (aStart < aEnd) {
          if (!map || !map.has(a[aStart])) removeNode(parentNode, a[aStart]);
          aStart++;
        }
      } else if (a[aStart] === b[bEnd - 1] && b[bStart] === a[aEnd - 1]) {
        const node = getNextSibling(a[--aEnd]);
        insertNode(parentNode, b[bStart++], getNextSibling(a[aStart++]));
        insertNode(parentNode, b[--bEnd], node);
        a[aEnd] = b[bEnd];
      } else {
        if (!map) {
          map = new Map();
          let i = bStart;

          while (i < bEnd) map.set(b[i], i++);
        }

        const index = map.get(a[aStart]);

        if (index != null) {
          if (bStart < index && index < bEnd) {
            let i = aStart,
                sequence = 1,
                t;

            while (++i < aEnd && i < bEnd) {
              if ((t = map.get(a[i])) == null || t !== index + sequence) break;
              sequence++;
            }

            if (sequence > index - bStart) {
              const node = a[aStart];

              while (bStart < index) insertNode(parentNode, b[bStart++], node);
            } else replaceNode(parentNode, b[bStart++], a[aStart++]);
          } else aStart++;
        } else removeNode(parentNode, a[aStart++]);
      }
    }
  }

  function cleanChildren(parent, current, marker, replacement) {
    if (marker === undefined) {
      let removed;

      while (removed = getFirstChild(parent)) removeNode(parent, removed);

      replacement && insertNode(parent, replacement);
      return "";
    }

    const node = replacement || createTextNode("");

    if (current.length) {
      let inserted = false;

      for (let i = current.length - 1; i >= 0; i--) {
        const el = current[i];

        if (node !== el) {
          const isParent = getParentNode(el) === parent;
          if (!inserted && !i) isParent ? replaceNode(parent, node, el) : insertNode(parent, node, marker);else isParent && removeNode(parent, el);
        } else inserted = true;
      }
    } else insertNode(parent, node, marker);

    return [node];
  }

  function appendNodes(parent, array, marker) {
    for (let i = 0, len = array.length; i < len; i++) insertNode(parent, array[i], marker);
  }

  function replaceNode(parent, newNode, oldNode) {
    insertNode(parent, newNode, oldNode);
    removeNode(parent, oldNode);
  }

  function spreadExpression(node, props, prevProps = {}, skipChildren) {
    props || (props = {});

    if (!skipChildren && "children" in props) {
      createRenderEffect(() => prevProps.children = insertExpression(node, props.children, prevProps.children));
    }

    props.ref && props.ref(node);
    createRenderEffect(() => {
      for (const prop in props) {
        if (prop === "children" || prop === "ref") continue;
        const value = props[prop];
        if (value === prevProps[prop]) continue;
        setProperty(node, prop, value, prevProps[prop]);
        prevProps[prop] = value;
      }
    });
    return prevProps;
  }

  return {
    render(code, element) {
      let disposer;
      createRoot(dispose => {
        disposer = dispose;
        insert(element, code());
      });
      return disposer;
    },

    insert,

    spread(node, accessor, skipChildren) {
      if (typeof accessor === "function") {
        createRenderEffect(current => spreadExpression(node, accessor(), current, skipChildren));
      } else spreadExpression(node, accessor, undefined, skipChildren);
    },

    createElement,
    createTextNode,
    insertNode,

    setProp(node, name, value, prev) {
      setProperty(node, name, value, prev);
      return value;
    },

    mergeProps: mergeProps$1,
    effect: createRenderEffect,
    memo: memo$1,
    createComponent: createComponent$1
  };
}

function mergeProps$1(...sources) {
  const target = {};

  for (let i = 0; i < sources.length; i++) {
    let source = sources[i];
    if (typeof source === "function") source = source();
    const descriptors = Object.getOwnPropertyDescriptors(source);
    Object.defineProperties(target, descriptors);
  }

  return target;
}

function createRenderer(options) {
  const renderer = createRenderer$1(options);
  renderer.mergeProps = mergeProps$2;
  return renderer;
}

function capitalize(str) {
  return str.charAt(0).toUpperCase() + str.slice(1);
}
const isWeb$1 = typeof rehax === "undefined";

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

let ViewMap$1 = {};
let PropHandlers = {};

if (!isWeb$1) {
  ViewMap$1 = {
    rehaxView: rehax.View,
    rehaxText: rehax.Text,
    rehaxButton: rehax.Button,
    rehaxInput: rehax.TextInput,
    rehaxSelect: rehax.Select,
    rehaxToggle: rehax.Toggle,
    rehaxStackLayout: rehax.StackLayout,
    rehaxFlexLayout: rehax.FlexLayout,
    rehaxVectorContainer: rehax.VectorContainer,
    rehaxVectorRect: rehax.VectorRect,
    rehaxVectorPath: rehax.VectorPath
  };
  PropHandlers = {
    // onMouseDown: (node: RehaxView, value: any) => {
    //   gestureEnsure(node);
    //   if (node._rhx_gestureHandler) {
    //     node._rhx_gestureHandler.onMouseDown = value;
    //   }
    // },
    // onMouseUp: (node: RehaxView, value: any) => {
    //   gestureEnsure(node);
    //   if (node._rhx_gestureHandler) {
    //     node._rhx_gestureHandler.onMouseUp = value;
    //   }
    // },
    // onMouseMove: (node: RehaxView, value: any) => {
    //   gestureEnsure(node);
    //   if (node._rhx_gestureHandler) {
    //     node._rhx_gestureHandler.onMouseMove = value;
    //   }
    // },
    onKey: (node, value) => {
      const keyHandler = new rehax.KeyHandler();
      keyHandler.setup(value);
      node.addKeyHandler(keyHandler);
    },
    onMouse: (node, value) => {
      const mouseHandler = new rehax.MouseHandler();
      mouseHandler.setup(value);
      node.addMouseHandler(mouseHandler);
    }
  };
}

const RehaxRenderer = {
  createElement(str) {
    const Component = ViewMap$1[str];

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
    } else {
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
  }

};

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

if (isWeb$1) {
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
    rehaxStackLayout: () => ({
      isLayout: true,
      type: "stack"
    }),
    rehaxFlexLayout: () => ({
      isLayout: true,
      type: "flex"
    }),
    rehaxVectorContainer: () => {
      const el = document.createElement("svg"); // todo namespace

      return el;
    } // rehaxVectorRect: rehax.VectorRect,
    // rehaxVectorPath: rehax.VectorPath,

  };
}

function convertLength(prop) {
  var _a;

  if (prop.type === "fixed") {
    return `${(_a = prop.value) !== null && _a !== void 0 ? _a : 0}px`;
  } else if (prop.type === "fill") {
    return `100%`;
  }
}

function convertColor(prop) {
  return `rgba(${prop.red}, ${prop.green}, ${prop.blue}, ${prop.alpha})`;
}

const styleProps = {
  backgroundColor: {
    name: "backgroundColor",
    convert: convertColor
  },
  textColor: {
    name: "color",
    convert: convertColor
  },
  underlined: {
    name: "textDecoration",
    convert: value => value ? "underline" : "none"
  },
  strikeThrough: {
    name: "textDecoration",
    convert: value => value ? "line-through" : "none"
  },
  italic: {
    name: "fontStyle",
    convert: value => value ? "italic" : "normal"
  },
  fontSize: {
    name: "fontSize",
    convert: value => `${value}px`
  },
  fontFamilies: {
    name: "fontFamily",
    convert: value => value.join(", ")
  },
  width: {
    name: "width",
    convert: convertLength
  },
  height: {
    name: "height",
    convert: convertLength
  }
};
const elementProps = {
  BUTTON: {
    title: (node, value) => node.innerText = value,
    onPress: (node, value) => node.onclick = value
  },
  INPUT: {
    value: (node, value) => {
      const input = node;

      if (input.type === "checkbox") {
        input.checked = value;
      } else {
        input.value = value;
      }
    }
  },
  P: {// text: (node: HTMLElement, value: string) => (node.textContent = value),
  }
};
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
  var _a, _b, _c, _d, _e, _f, _g, _h; // el.style.display = layout.type === "flex" ? "flex" : "block";


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
  } else {
    el.style.padding = `${(_f = (_e = layout.options) === null || _e === void 0 ? void 0 : _e.spacing) !== null && _f !== void 0 ? _f : 0}px`;
    el.style.gap = `${(_h = (_g = layout.options) === null || _g === void 0 ? void 0 : _g.spacing) !== null && _h !== void 0 ? _h : 0}px`;
    el.style.alignItems = "flex-start";
  }
}

const WebRenderer = {
  createElement(str) {
    const Component = ViewMap[str];

    if (Component) {
      const el = Component();

      if (el.style) {
        setLayoutOptions(el, {
          isLayout: true,
          type: "stack"
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

    console.log(name, value); // const handler = PropHandlers[name];
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
    return node.nodeType === Node.TEXT_NODE;
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
  }

};

const {
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
  mergeProps
} = createRenderer(isWeb$1 ? WebRenderer : RehaxRenderer); // Forward Solid control flow

function getRootView() {
  const isWeb = typeof rehax === "undefined";
  return isWeb ? document.getElementById("root") : rehax.rootView;
}

/** A base view */

function View(props) {
  return (() => {
    const _el$ = createElement("rehaxView");

    spread(_el$, props, false);

    return _el$;
  })();
}

View.DefaultBackgroundColor = () => rehax.View.DefaultBackgroundColor();
/** A text view that can be styled and nested */


function Text(props) {
  return (() => {
    const _el$2 = createElement("rehaxText");

    spread(_el$2, props, false);

    return _el$2;
  })();
}
/** A button */

function Button(props) {
  return (() => {
    const _el$3 = createElement("rehaxButton");

    spread(_el$3, props, false);

    return _el$3;
  })();
}
function FlexLayout(props) {
  return (() => {
    const _el$7 = createElement("rehaxFlexLayout");

    spread(_el$7, props, false);

    return _el$7;
  })();
}
const isWeb = typeof rehax === "undefined";
isWeb ? {
  app: {
    getApplicationTheme: () => "unsupported",
    addApplicationThemeChangeListener: listener => 0,
    removeApplicationThemeChangeListener: listener => {}
  }
} : rehax;

undefined && undefined.__awaiter || function (thisArg, _arguments, P, generator) {
  function adopt(value) {
    return value instanceof P ? value : new P(function (resolve) {
      resolve(value);
    });
  }

  return new (P || (P = Promise))(function (resolve, reject) {
    function fulfilled(value) {
      try {
        step(generator.next(value));
      } catch (e) {
        reject(e);
      }
    }

    function rejected(value) {
      try {
        step(generator["throw"](value));
      } catch (e) {
        reject(e);
      }
    }

    function step(result) {
      result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected);
    }

    step((generator = generator.apply(thisArg, _arguments || [])).next());
  });
};

function Example5() {
  const [show, setShow] = createSignal(true);
  return createComponent(View, {
    get layout() {
      return createComponent(FlexLayout, {});
    },

    onKey: e => {
      console.log("key");
      console.log(JSON.stringify(e));
      e.propagates = false;
    },
    onMouse: event => {
      if (event.isDown) {
        console.log("Prevent");
        console.log(JSON.stringify(event));
      }
    },

    get children() {
      return [createComponent(Button, {
        title: "Remove",
        onPress: async () => {
          const color = View.DefaultBackgroundColor();
          console.log(2);
          console.log(JSON.stringify(color));
          await new Promise(resolve => setTimeout(resolve, 2000));
          setShow(false); // const res = await fetch("https://www.toptal.com/developers/postbin/1668597792320-0728177467826", {
          //   method: "POST",
          //   headers: {
          //     "Content-Type": "application/json",
          //   },
          //   body: JSON.stringify({
          //     test: '123',
          //   }),
          // });
          // console.log(res.status)
        }
      }), createComponent(View, {
        onMouse: event => {
          event.propagates = false;

          if (event.isDown) {
            console.log("stopped");
          }
        },

        get children() {
          return createComponent(Text // onMouse={() => {
          //   console.log("Prevent");
          // }}
          , {
            children: "Hello"
          });
        }

      }), createComponent(View, {
        onMouse: event => {
          // event.propagates = true;
          if (event.isDown) {
            console.log("propagates");
          }
        },

        get children() {
          return createComponent(Text, {
            children: "Hello"
          });
        }

      }), createComponent(Show, {
        get when() {
          return show();
        },

        get children() {
          return [createComponent(Text, {
            children: "Hello"
          }), createComponent(Text, {
            children: "Hello"
          }), createComponent(Text, {
            children: "Hello"
          }), createComponent(Text, {
            children: "Hello"
          }), createComponent(Text, {
            children: "Hello"
          }), createComponent(Text, {
            children: "Hello"
          })];
        }

      })];
    }

  });
}

function App() {
  // return <Example1 />;
  // return <Example3 />;
  // return <Example4 />;
  return createComponent(Example5, {}); // return <Tester />;
  // return <ThemeExample />;
}

render(() => createComponent(App, {}), getRootView());
