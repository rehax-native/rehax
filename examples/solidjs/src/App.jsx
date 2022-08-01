import { createSignal, createMemo, createEffect } from "solid-js";

function App() {
  const [count, setCount] = createSignal(10);

  return (
    <div>
      <button
        title="Click me"
        onPress={() => {
          setCount(count() + 1);
        }}
      ></button>
      Count: {count()}
      <input />
      <svg style={{ width: 100, height: 100 }}>
        <path
          d="M 0 0 L 50 50 L 70 50 L 70 80 L 10 20"
          strokeWidth={3}
          fill="rgba(0, 255, 0, 1)"
          stroke="rgba(255, 0, 0, 1)"
        ></path>
      </svg>

      <div style={{ display: 'flex' }}>
        <div>
          Flex item 1
        </div>
        <div>
          Flex item 2
        </div>
        <div>
          Flex item 3
        </div>
      </div>
    </div>
  );
}

export default App;
