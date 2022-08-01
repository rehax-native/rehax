'use strict';

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

var parseSvgPath = parse$1;
/**
 * expected argument lengths
 * @type {Object}
 */

var length = {
  a: 7,
  c: 6,
  h: 1,
  l: 2,
  m: 2,
  q: 4,
  s: 4,
  t: 2,
  v: 1,
  z: 0
};
/**
 * segment pattern
 * @type {RegExp}
 */

var segment = /([astvzqmhlc])([^astvzqmhlc]*)/ig;
/**
 * parse an svg path data string. Generates an Array
 * of commands where each command is an Array of the
 * form `[command, arg1, arg2, ...]`
 *
 * @param {String} path
 * @return {Array}
 */

function parse$1(path) {
  var data = [];
  path.replace(segment, function (_, command, args) {
    var type = command.toLowerCase();
    args = parseValues(args); // overloaded moveTo

    if (type == 'm' && args.length > 2) {
      data.push([command].concat(args.splice(0, 2)));
      type = 'l';
      command = command == 'm' ? 'l' : 'L';
    }

    while (true) {
      if (args.length == length[type]) {
        args.unshift(command);
        return data.push(args);
      }

      if (args.length < length[type]) throw new Error('malformed path data');
      data.push([command].concat(args.splice(0, length[type])));
    }
  });
  return data;
}

var number = /-?[0-9]*\.?[0-9]+(?:e[-+]?\d+)?/ig;

function parseValues(args) {
  var numbers = args.match(number);
  return numbers ? numbers.map(Number) : [];
}

var component = /-?\d+(\.\d+)?%?/g;

function extractComponents$2(color) {
  return color.match(component);
}

var extractComponents_1 = extractComponents$2;

function clamp$2(val, min, max) {
  return Math.min(Math.max(val, min), max);
}

var clamp_1 = clamp$2;

var extractComponents$1 = extractComponents_1;
var clamp$1 = clamp_1;

function parseHslComponent(component, i) {
  component = parseFloat(component);

  switch (i) {
    case 0:
      return clamp$1(component, 0, 360);

    case 1:
    case 2:
      return clamp$1(component, 0, 100);

    case 3:
      return clamp$1(component, 0, 1);
  }
}

function hsl$1(color) {
  return extractComponents$1(color).map(parseHslComponent);
}

var hsl_1 = hsl$1;

function expand(hex) {
  var result = "#";

  for (var i = 1; i < hex.length; i++) {
    var val = hex.charAt(i);
    result += val + val;
  }

  return result;
}

function hex$1(hex) {
  // #RGB or #RGBA
  if (hex.length === 4 || hex.length === 5) {
    hex = expand(hex);
  }

  var rgb = [parseInt(hex.substring(1, 3), 16), parseInt(hex.substring(3, 5), 16), parseInt(hex.substring(5, 7), 16)]; // #RRGGBBAA

  if (hex.length === 9) {
    var alpha = parseFloat((parseInt(hex.substring(7, 9), 16) / 255).toFixed(2));
    rgb.push(alpha);
  }

  return rgb;
}

var hex_1 = hex$1;

var extractComponents = extractComponents_1;
var clamp = clamp_1;

function parseRgbComponent(component, i) {
  if (i < 3) {
    if (component.indexOf('%') != -1) {
      return Math.round(255 * clamp(parseInt(component, 10), 0, 100) / 100);
    } else {
      return clamp(parseInt(component, 10), 0, 255);
    }
  } else {
    return clamp(parseFloat(component), 0, 1);
  }
}

function rgb$1(color) {
  return extractComponents(color).map(parseRgbComponent);
}

var rgb_1 = rgb$1;

function hsl2rgb$1(hsl) {
  var h = hsl[0] / 360,
      s = hsl[1] / 100,
      l = hsl[2] / 100,
      t1,
      t2,
      t3,
      rgb,
      val;

  if (s == 0) {
    val = l * 255;
    return [val, val, val];
  }

  if (l < 0.5) t2 = l * (1 + s);else t2 = l + s - l * s;
  t1 = 2 * l - t2;
  rgb = [0, 0, 0];

  for (var i = 0; i < 3; i++) {
    t3 = h + 1 / 3 * -(i - 1);
    t3 < 0 && t3++;
    t3 > 1 && t3--;
    if (6 * t3 < 1) val = t1 + (t2 - t1) * 6 * t3;else if (2 * t3 < 1) val = t2;else if (3 * t3 < 2) val = t1 + (t2 - t1) * (2 / 3 - t3) * 6;else val = t1;
    rgb[i] = val * 255;
  }

  return rgb;
}

var hsl2rgb_1 = hsl2rgb$1;

var hsl = hsl_1;
var hex = hex_1;
var rgb = rgb_1;
var hsl2rgb = hsl2rgb_1;

function hsl2rgbParse(color) {
  var h = hsl(color);
  var r = hsl2rgb(h); // handle alpha since hsl2rgb doesn't know (or care!) about it

  if (h.length === 4) {
    r.push(h[3]);
  }

  return r;
}

var space2parser = {
  "#": hex,
  "hsl": hsl2rgbParse,
  "rgb": rgb
};

function parse(color) {
  for (var scheme in space2parser) {
    if (color.indexOf(scheme) === 0) {
      return space2parser[scheme](color);
    }
  }
}

parse.rgb = rgb;
parse.hsl = hsl;
parse.hex = hex;
var parse_1 = parse;

function capitalize(str) {
  return str.charAt(0).toUpperCase() + str.slice(1);
}

function convertColor(color) {
  const result = parse_1(color);
  return {
    red: result[0],
    green: result[1],
    blue: result[2],
    alpha: result[3]
  };
}

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
} = createRenderer({
  createElement(string) {
    // console.log(`Create element: ${string} ${View}`);
    switch (string) {
      case "div":
        //> view: div -> View
        return new View();

      case "button":
        //> view: button -> Button
        return new Button();

      case "input":
        //> view: input -> TextInput
        return new TextInput();

      case "svg":
        //> view: svg -> VectorContainer
        return new VectorContainer();

      case "path":
        //> view: path -> VectorPath
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
    // console.log(`Set prop: ${node} ${name}`);
    if (name === "style") {
      // We try to set all the properties of the style object
      // Everything we don't know we just ignore
      for (let key of Object.keys(value)) {
        if (key === "width") {
          /*>
            view prop: width -> setWidth
            `px` will be converted to setWidthFixed
            `%` will be converted to setWidthPercentage
          */
          node.setWidthFixed(Number(value[key])); // todo parse %, px, etc
        } else if (key === "height") {
          /*>
            view prop: height -> setHeight
            `px` will be converted to setHeightFixed
            `%` will be converted to setHeightPercentage
          */
          node.setHeightFixed(Number(value[key])); // todo parse %, px, etc
        } else if (key === 'display') {
          if (value[key] === 'flex' && node._rhx_styleDisplay !== 'flex') {
            node._rhx_styleDisplay = 'flex';
            node.setLayout(new FlexLayout());
          } else if (value[key] !== 'flex' && node._rhx_styleDisplay === 'flex') {
            node._rhx_styleDisplay = null;
            node.setLayout(new StackLayout());
          }
        } else {
          const setterName = `set${capitalize(key)}`;

          if (setterName in node) {
            node[setterName](value[key]);
          }
        }
      }

      return;
    } else if (name === 'd') {
      /*>
        path prop: d
        This takes the same format as the path attribute of a svg element
        It calls the `beginPath`, then the converted commands, then `endPath` of the VectorPath
        M x y -> pathMoveTo(x, y)
        m x y -> pathMoveBy(x, y)
        L x y -> pathLineTo(x, y)
        Z -> closePath
        z -> closePath
      */
      const parts = parseSvgPath(value);
      const mapCommand = {
        M: 'pathMoveTo',
        m: 'pathMoveBy',
        L: 'pathLineTo',
        // l: 'pathLineBy',
        // C: 'bezierCurveTo',
        Z: 'closePath',
        z: 'closePath'
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
      return;
    }

    if (name == 'fill') {
      //> svg prop: fill -> setFill
      node.setFillColor(convertColor(value));
      return;
    } else if (name == 'stroke') {
      //> svg prop: stroke -> setStroke
      node.setStrokeColor(convertColor(value));
      return;
    } else if (name == 'strokeWidth') {
      //> svg prop: strokeWidth -> setLineWidth
      node.setLineWidth(Number(value));
      return;
    }

    const setterName = `set${capitalize(name)}`;

    if (setterName in node) {
      node[setterName](value);
    } else {
      console.error(`Unknown property: ${name}`);
    } // if (name === "style") Object.assign(node.style, value);
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
  }

}); // Forward Solid control flow
function getRootView() {
  return rootView;
}

function App() {
  const [count, setCount] = createSignal(10);
  return (() => {
    const _el$ = createElement("div"),
          _el$2 = createElement("button"),
          _el$3 = createTextNode(`Count: `),
          _el$4 = createElement("input"),
          _el$5 = createElement("svg"),
          _el$6 = createElement("path"),
          _el$7 = createElement("div"),
          _el$8 = createElement("div"),
          _el$10 = createElement("div"),
          _el$12 = createElement("div");

    insertNode(_el$, _el$2);

    insertNode(_el$, _el$3);

    insertNode(_el$, _el$4);

    insertNode(_el$, _el$5);

    insertNode(_el$, _el$7);

    setProp(_el$2, "title", "Click me");

    setProp(_el$2, "onPress", () => {
      setCount(count() + 1);
    });

    insert(_el$, count, _el$4);

    insertNode(_el$5, _el$6);

    setProp(_el$5, "style", {
      width: 100,
      height: 100
    });

    setProp(_el$6, "d", "M 0 0 L 50 50 L 70 50 L 70 80 L 10 20");

    setProp(_el$6, "strokeWidth", 3);

    setProp(_el$6, "fill", "rgba(0, 255, 0, 1)");

    setProp(_el$6, "stroke", "rgba(255, 0, 0, 1)");

    insertNode(_el$7, _el$8);

    insertNode(_el$7, _el$10);

    insertNode(_el$7, _el$12);

    setProp(_el$7, "style", {
      display: 'flex'
    });

    insertNode(_el$8, createTextNode(`Flex item 1`));

    insertNode(_el$10, createTextNode(`Flex item 2`));

    insertNode(_el$12, createTextNode(`Flex item 3`));

    return _el$;
  })();
}

render(() => createComponent(App, {}), getRootView());
