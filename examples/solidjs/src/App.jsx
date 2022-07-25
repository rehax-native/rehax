import { createSignal, createMemo, createEffect } from 'solid-js';

function App() {
  const [count, setCount] = createSignal(10);

  return (
    <div>
      <button title="Click me" onPress={() => {
        setCount(count() + 1)
      }}></button>
      {'                       '}Count: {count()}
    </div>
  );
}

export default App;
