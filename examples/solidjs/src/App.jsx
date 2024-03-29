import { createSignal, createMemo, createEffect, Show, Switch } from "solid-js";
import {
  Color,
  Length,
  View,
  Text,
  VectorContainer,
  VectorPath,
  VectorRect,
  TextInput,
  Button,
  MoveTo,
  Arc,
  FlexLayout,
  StackLayout,
  Select,
  Toggle,
  ThemeProvider,
  useApplicationTheme,
} from "@rehax/solidjs-components";
import fetch from "@rehax/fetch";
import crypto from "crypto";

function Example1() {
  const [count, setCount] = createSignal(10);
  const [display, setDisplay] = createSignal("flex");
  const [justifyContent, setJustifyContent] = createSignal("flex-start");
  const [alignItems, setAlignItems] = createSignal("flex-start");
  const [cb, setCb] = createSignal(() => console.log(2));
  const [showRect, setShowRect] = createSignal(true);
  const [toggleVal, setToggleVal] = createSignal(true);

  return (
    <View
      height={Length.Fill()}
      width={Length.Fill()}
      // backgroundColor={Color.RGBA(0, 255, 0, 0.3)}
    >
      Count: {count()}
      <Toggle
        value={toggleVal()}
        onValueChange={(value) => {
          console.log(`New value ${value}`);
          setToggleVal(value);
        }}
      />
      <Button
        title="Test"
        onPress={async () => {
          // const res = await fetch('https://jsonplaceholder.typicode.com/photos')
          // console.log('res')
          // const text = await res.json()
          // console.log(text)

          // const timer = setInterval(() => {
          //   console.log('timeout')
          // clearTimeout(timer)
          // }, 2000)

          // console.log(rehax.app.getApplicationSupportDirectory())
          // console.log(rehax.app.getCurrentUserHomeDirectory())
          // console.log(rehax.app.getCurrentUserDesktopDirectory())
          // console.log(rehax.app.getApplicationSupportDirectoryForApp())
          // console.log(rehax.os.name())

          // localStorage.setItem('test', 'my string');
          // console.log(localStorage.getItem("test"));

          const rnd = crypto.randomBytes(10);
          console.log(rnd);
          console.log(rnd.readUInt32BE(0));
          console.log(rnd.readUInt32BE(1));

          const n = rnd.readUInt32BE(0);
          setCb(() => () => console.log(n));

          setShowRect(false);

          // }
          // const result = rehax.fs.readdirSync("path")
          // console.log(JSON.stringify(result))
        }}
      />
      <Button title="loop" onPress={cb()} />
      <VectorContainer width={Length.Fixed(20)} height={Length.Fixed(20)}>
        <Show when={showRect()}>
          <VectorRect
            size={{ width: 20, height: 15 }}
            fillColor={Color.RGBA(255, 0, 0, 1)}
          />
        </Show>
      </VectorContainer>
      <Button
        title={`Switch flex/stack ${display()}`}
        onPress={() => {
          setCount(count() + 1);
          setDisplay(display() === "flex" ? "none" : "flex");
        }}
      ></Button>
      <Button
        title={`Switch justify content ${justifyContent()}`}
        onPress={() => {
          setCount(count() + 1);
          const list = ["flex-start", "flex-end", "center"];
          const nextIndex = (list.indexOf(justifyContent()) + 1) % list.length;
          setJustifyContent(list[nextIndex]);
        }}
      ></Button>
      <Button
        title={`Switch align items ${alignItems()}`}
        onPress={() => {
          setCount(count() + 1);
          const list = ["flex-start", "flex-end", "center", "stretch"];
          const nextIndex = (list.indexOf(alignItems()) + 1) % list.length;
          setAlignItems(list[nextIndex]);
        }}
      ></Button>
      <TextInput />
      <View
        width={Length.Fixed(100)}
        height={Length.Fixed(100)}
        backgroundColor={Color.RGBA(0, 255, 0, 0.3)}
      ></View>
      <View
        height={Length.Fixed(250)}
        width={Length.Fill()}
        layout={
          display() === "flex" ? (
            <FlexLayout
              options={{
                direction: "column",
                justifyContent: justifyContent(),
                alignItems: alignItems(),
                gap: 10,
                // alignItems: 'center'
              }}
            />
          ) : (
            <StackLayout />
          )
        }
      >
        <View>Flex item 1</View>
        <View>Flex item 2 a little longer</View>
        <View>Flex item 3</View>
      </View>
      <View height={Length.Fixed(250)}>
        <View>Stack item 1</View>
        <View>Stack item 2 a little longer</View>
        <View>Stack item 3</View>
      </View>
    </View>
  );
}

function Example3() {
  return (
    <View
      width={Length.Fill()}
      height={Length.Fill()}
      // layout={
      //   <FlexLayout
      //     options={{
      //       items: [{}, { flexGrow: 1 }],
      //     }}
      //   />
      // }
    >
      <Text text="EDA">
        <Text underlined>??</Text>{" "}
        <Text fontSize={20} textColor={Color.RGBA(255, 100, 0, 1)} italic>
          red
        </Text>{" "}
        SNDX.io
        <Text strikeThrough fontFamilies={["Courier New", "Roboto"]}>
          Henlo
        </Text>
      </Text>
      {/* <View>
        <View
          layout={
            <FlexLayout
              options={{
                justifyContent: "center",
                alignItems: "center",
              }}
            />
          }
        >
          <Button title="My bytton"></Button>
        </View>
      </View> */}
    </View>
    // <View
    //   width={Length.Fill()}
    //   height={Length.Fill()}
    //   backgroundColor={Color.RGBA(0, 0, 255, 0.3)}
    //   layout={
    //     <FlexLayout
    //       options={{
    //         direction: "row",
    //         // justifyContent: "center",
    //         // alignItems: alignItems(),
    //         alignItems: 'stretch',
    //         items: [
    //           {},
    //           { flexGrow: 1 },
    //         ]
    //       }}
    //     />
    //   }
    // >
    //   <View
    //     width={Length.Fixed(200)}
    //     height={Length.Fixed(200)}
    //     backgroundColor={Color.RGBA(255, 0, 0, 0.3)}
    //   >
    //   </View>
    //   <View
    //     width={Length.Fixed(200)}
    //     height={Length.Fixed(200)}
    //     backgroundColor={Color.RGBA(0, 255, 0, 0.3)}
    //   >
    //   </View>
    // </View>
  );
}

function Example4Comp() {
  return (
    <View
      width={Length.Fixed(100)}
      layout={
        <FlexLayout
          options={{
            alignItems: "center",
          }}
        />
      }
    >
      My name 01
    </View>
  );
}

function Example4() {
  let input;
  return (
    <View
      layout={<StackLayout options={{ spacing: 20 }} />}
      // onKey={e => console.log(JSON.stringify(e))}
    >
      <Example4Comp />
      <Example4Comp />
      <Example4Comp />
      <Text
        horizontalPosition={Length.Fixed(100)}
        verticalPosition={Length.Fixed(5)}
        onMouse={(e) => console.log(e.x)}
      >
        Hello
      </Text>
      <TextInput
        onValueChange={() => console.log("change")}
        onBlur={() => console.log("blurred")}
        onSubmit={() => console.log("submitted")}
      />
      <TextInput
        ref={input}
        onValueChange={() => console.log("change")}
        onFocus={() => console.log("focused")}
      />
      <Button title="Focus input" onPress={() => input.focus()} />
      <Select
        options={[
          { value: "val1", name: "Value 1" },
          { value: "val2", name: "Value 2" },
        ]}
        onValueChange={(value) => console.log(value.name)}
      ></Select>
    </View>
  );
}

function Example5() {
  const [show, setShow] = createSignal(true);
  return (
    <View
      layout={<FlexLayout />}
      // onMouse={() => {
      //   console.log("Outer view mouse up called");
      // }}
      onKey={(e) => {
        console.log("key");
        console.log(JSON.stringify(e));
        e.propagates = false;
      }}
      onMouse={(event) => {
        if (event.isDown) {
          console.log("Prevent");
          console.log(JSON.stringify(event));
        }
      }}
    >
      <Button
        title="Remove"
        onPress={async () => {
          const color = View.DefaultBackgroundColor();
          console.log(2);
          console.log(JSON.stringify(color));
          await new Promise((resolve) => setTimeout(resolve, 2000));
          setShow(false);

          // const res = await fetch("https://www.toptal.com/developers/postbin/1668597792320-0728177467826", {
          //   method: "POST",
          //   headers: {
          //     "Content-Type": "application/json",
          //   },
          //   body: JSON.stringify({
          //     test: '123',
          //   }),
          // });
          // console.log(res.status)
        }}
      />
      <View
        onMouse={(event) => {
          event.propagates = false;
          if (event.isDown) {
            console.log("stopped");
          }
        }}
      >
        <Text
        // onMouse={() => {
        //   console.log("Prevent");
        // }}
        >
          Hello
        </Text>
      </View>
      <View
        onMouse={(event) => {
          // event.propagates = true;
          if (event.isDown) {
            console.log("propagates");
          }
        }}
      >
        <Text>Hello</Text>
      </View>
      <Show when={show()}>
        <Text>Hello</Text>
        <Text>Hello</Text>
        <Text>Hello</Text>
        <Text>Hello</Text>
        <Text>Hello</Text>
        <Text>Hello</Text>
      </Show>
    </View>
  );
}

function ThemeExample() {
  function ThemedComponent() {
    const [theme] = useApplicationTheme()
    createEffect(() => {
      console.log(theme());
      console.log(JSON.stringify(View.DefaultBackgroundColor()));
    });
    return (
      <View>
        <Text
          textColor={
            theme() === "system-dark"
              ? Color.RGBA(255, 255, 255, 1)
              : Color.RGBA(0, 0, 0, 1)
          }
        >
          I'm themed!
        </Text>
      </View>
    );
  }
  return <ThemeProvider>
    <ThemedComponent />
  </ThemeProvider>
}

function App() {
  // return <Example1 />;
  // return <Example3 />;
  // return <Example4 />;
  return <Example5 />;
  // return <Tester />;
  // return <ThemeExample />;
}

export default App;
