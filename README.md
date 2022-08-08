# Rehax

Rehax is a native first, cross platform UI toolkit. It allows you to build native user interfaces with a javascript for mobile, web and desktop.
Unlike react native it is framework agnostic, which means you can use it with react, but you can also use other frameworks like [SolidJS](https://www.solidjs.com/)
(Currently we support SolidJS only).

## How does it work

There are three parts to make this work

#### Native UI abstraction

There is a thin layer of abstraction written in C++ to support different native UI libraries.
This way you can write C++ code that looks like this.

```c++
auto view = View::Create();
auto btn = Button::Create();
btn->setTitle("My Button");
btn->setOnPress([] () { std::cout << "Press" << std::endl; });
view->addView(btn);
```

This code looks the same regardless of what UI library is used under the hood.

#### JavaScript Bindings

Rehax creates bindings for this abstraction layer to different javascript interpreters.
You create the interpreter in your application, expose the bindings, and then you're able to interact with the abstraction layer from JS.

```c++

auto vm = new rehax::jsc::Runtime(); // Create the interpreter
vm->makeConsole(); // Expose console.log method
vm->bindAppkitToJsc(); // Make the bindings
vm->setRootView(view); // Set the root view so we can interact with it from JS
    
vm->evaluate(" \
    var button = new Button(); \
    button.setTitle('My JS Button'); \
    button.setOnPress(() => console.log('Native button called from Javascript!')); \
    rootView.addView(button); \
    ");
```

#### JavaScript Frameworks

Now that we're able to interactive with native components from JavaScript, we have to make our frameworks of choice work.

[SolidJs](https://www.solidjs.com/) makes this simple, we provide a [custom renderer](https://github.com/solidjs/solid/tree/main/packages/solid/universal) to call these methods. With this you can use SolidJS code that looks like this

```jsx
import { render, getRootView } from '!rehax/solidjs-renderer';
import { View, Button } from '!rehax/solidjs-components';
import { createSignal } from 'solid-js';

function App() {
  const [count, setCount] = createSignal(10);

  return (
    <View>
      <Button title="Click me" onPress={() => {
        setCount(count() + 1)
      }}></Button>
      Count: {count()}
    </View>
  );
}

render(() => <App />, getRootView());
```

and the custom renderer will call the objects/functions exposed by rehax.


## Supported JS interpreters

- JavascriptCore on Mac/iOS
- [QuickJS](https://bellard.org/quickjs/)
- __Planned__: Lua
- __Planned__: V8

# Supported UI libraries

- AppKit
- [Fluxe](https://github.com/rehax-native/fluxe)
- __Planned__: UIKit
- __Planned__: GTK

# Development

Clone the repo, make sure you have cmake installed and run:

```sh
cmake -S examples/solidjs -B build_examples
```

Use the -G flag to generate a project of your choice (e.g. `-G Xcode`)

This will create a project in the `build_examples` directory which you can use for development.

