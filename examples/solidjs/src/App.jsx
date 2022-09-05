import { createSignal, createMemo, createEffect } from "solid-js";
import { View, Text, Button } from "@rehax/solidjs-components"

function App() {
  const [count, setCount] = createSignal(10);

  return (
    <View>
      <Button
        title="Click me"
        onPress={() => {
          setCount(count() + 1);
        }}
      ></Button>
      Count: {count()}
    </View>
  );
}

export default App;
