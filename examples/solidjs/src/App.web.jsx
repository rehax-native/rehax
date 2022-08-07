import { createSignal, createMemo, createEffect } from "solid-js";

function Knob({ value }) {

  const WIDTH = 100.0;
  const HEIGHT = 100.0;
  const radius = 40.0;
  const HALF_WIDTH = 50.0;
  const HALF_HEIGHT = 50.0;
  const OPEN_ANGLE = 70.0;

  // const value = 0.3;

  function getViewboxCoord(angle, radius) {
    var a = angle * Math.PI / 180.0;
    var r = radius;
    var x = Math.cos(a) * r;
    var y = Math.sin(a) * r;
    return {
        x: HALF_WIDTH + x,
        y: HALF_HEIGHT - y
    }
  }
  function calc() {
    var a0 = 0.0;
    var maxAngle = 360.0 - OPEN_ANGLE;
    var a1 = -(maxAngle - a0) * value();

    var startPos = getViewboxCoord(a0 - 90.0 - OPEN_ANGLE / 2.0, radius);
    var valuePos = getViewboxCoord(a1 - 90.0 - OPEN_ANGLE / 2.0, radius);
    var endPos = getViewboxCoord(-maxAngle - 90.0 - OPEN_ANGLE / 2.0, radius);

    var delta_angle = (a0 - a1 + 360.0) % 360.0;

    const largeArc = delta_angle < 180.0 ? 0 : 1;
    const arcDirection = 1;

    return {
      arcDirection,
      largeArc,
      startPosX: startPos.x,
      startPosY: startPos.y,
      endPosX: endPos.x,
      endPosY: endPos.y,
      valuePosX: valuePos.x,
      valuePosY: valuePos.y,
    }
  }

  const values = createMemo(calc, {
    arcDirection: 1,
    largeArc: 1,
    startPosX: 0.0,
    startPosY: 0.0,
    endPosX: 0.0,
    endPosY: 0.0,
    valuePosX: 0.0,
    valuePosY: 0.0,
  })

  return (
    <svg style={{ width: WIDTH, height: HEIGHT }}>
      <filter id="blurry">
        <feGaussianBlur in="SourceAlpha" stdDeviation="5" />
      </filter>

      <path
        d={`M ${values().startPosX} ${values().startPosY} A ${radius} ${radius} 0 1 ${values().arcDirection} ${values().endPosX} ${values().endPosY}`}
        strokeWidth={5}
        stroke="rgba(0, 0, 0, 0.3)"
        strokeLinecap="round"
      ></path>

      <path
        d={`M ${values().startPosX} ${values().startPosY} A ${radius} ${radius} 0 ${values().largeArc} ${values().arcDirection} ${values().valuePosX} ${values().valuePosY}`}
        strokeWidth={5}
        stroke="rgba(255, 0, 0, 1)"
        strokeLinecap="round"
        filter="url(#blurry)"
      ></path>
      <path
        d={`M ${values().startPosX} ${values().startPosY} A ${radius} ${radius} 0 ${values().largeArc} ${values().arcDirection} ${values().valuePosX} ${values().valuePosY}`}
        strokeWidth={5}
        stroke="rgba(255, 0, 0, 1)"
        strokeLinecap="round"
      ></path>
    </svg>
  );
}

function App() {
  const [count, setCount] = createSignal(10);
  const [display, setDisplay] = createSignal("flex");
  const [justifyContent, setJustifyContent] = createSignal("flex-start");
  const [alignItems, setAlignItems] = createSignal("flex-start");

  const [gestureStartPosition, setGestureStartPosition] = createSignal({ x: 0, y: 0 });
  const [startValue, setStartValue] = createSignal(0.0);
  const [value, setValue] = createSignal(0.0);

  return (
    <div>
      Count: {count()}
      <button
        title={`Switch flex/stack ${display()}`}
        onPress={() => {
          setCount(count() + 1);
          setDisplay(display() === "flex" ? "none" : "flex");
        }}
      ></button>
      <button
        title={`Switch justify content ${justifyContent()}`}
        onPress={() => {
          setCount(count() + 1);
          const list = ["flex-start", "flex-end", "center"];
          const nextIndex = (list.indexOf(justifyContent()) + 1) % list.length;
          setJustifyContent(list[nextIndex]);
        }}
      ></button>
      <button
        title={`Switch align items ${alignItems()}`}
        onPress={() => {
          setCount(count() + 1);
          const list = ["flex-start", "flex-end", "center", "stretch"];
          const nextIndex = (list.indexOf(alignItems()) + 1) % list.length;
          setAlignItems(list[nextIndex]);
        }}
      ></button>
      <input />
      <div
        style={{ width: 100, height: 100 }}
        onMouseDown={(e) => {
          setStartValue(value());
          setGestureStartPosition(e);
        }}
        onMouseMove={(e) =>
          setValue(
            Math.min(
              1.0,
              Math.max(
                0.0,
                startValue() + (gestureStartPosition().y - e.y) / 100.0
              )
            )
          )
        }
        // onMouseUp={(e) => console.log(e)}
      >
        <Knob value={value} />
      </div>
      {/* <svg style={{ width: 100, height: 100 }}>
        <path
          d="M 0 0 L 50 50 L 70 50 L 70 80 L 10 20"
          strokeWidth={3}
          fill="rgba(0, 255, 0, 1)"
          stroke="rgba(255, 0, 0, 1)"
        ></path>
      </svg> */}
      <div
        style={{
          display: display(),
          justifyContent: justifyContent(),
          alignItems: alignItems(),
        }}
      >
        <div>Flex item 1</div>
        <div>Flex item 2</div>
        <div>Flex item 3</div>
      </div>
    </div>
  );
}

export default App;
