To use rehax in a CMake project, add this to your `CMakeLists.txt`

```
cmake_minimum_required(VERSION 3.23)

project(ExampleApp)
set(CMAKE_CXX_STANDARD 20)

# This is your app
add_executable(
    example-app
    main.cc
)

# Include FetchContent and fetch the rehax repo

include(FetchContent)
FetchContent_Declare(rehax
  GIT_REPOSITORY https://github.com/rehax-native/rehax.git
  GIT_TAG        main
)
FetchContent_MakeAvailable(rehax)

# The next line adds rehax to the executable
rehax_add_to_executable(
    example-app
    RUNTIME jsc
    BACKEND appkit
    BUNDLE_COMMAND pnpm run build
)
```

Possible options for `rehax_add_to_executable`:

- `RUNTIME`: `jsc`, `quickjs`
- `BACKEND`: `appkit`, `fluxe`
- `BUNDLE_COMMAND`: This command will be run before the project is building and can be anything. In most cases you want to bundle your javascript application to include the output in your app.
