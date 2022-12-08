import { createRenderer } from "solid-js/universal";
import { RehaxRenderer } from "./componentRendererRehax";
import { WebRenderer } from "./componentRendererWeb";
import { isWeb } from "./util";

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
} = createRenderer(isWeb ? WebRenderer : RehaxRenderer);

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
