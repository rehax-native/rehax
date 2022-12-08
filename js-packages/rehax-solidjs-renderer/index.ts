
export function getRootView() {
  const isWeb = typeof rehax === "undefined";
  return isWeb ? document.getElementById("root") : rehax.rootView;
}

export * from './componentRenderer'
