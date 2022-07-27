cmake_minimum_required(VERSION 3.23)

project(rehax_solidjs_example)
set(CMAKE_CXX_STANDARD 20)


include(../../CMakeLists.txt)


# Example appkit jsc
add_executable(
    example-solidjs-appkit-jsc MACOSX_BUNDLE
    main.appkit.jsc.mm
    distNative/index.native.js
)
set_target_properties(
    example-solidjs-appkit-jsc PROPERTIES
    BUNDLE True
    MACOSX_BUNDLE_GUI_IDENTIFIER dev.rehax.rehax.example-solidjs-appkit-jsc
    MACOSX_BUNDLE_BUNDLE_NAME example-solidjs-appkit-jsc
    MACOSX_BUNDLE_BUNDLE_VERSION "0.1"
    MACOSX_BUNDLE_SHORT_VERSION_STRING "0.1"
    MACOSX_BUNDLE_INFO_PLIST examples/solidjs/info.plist
    RESOURCE distNative/index.native.js
)
rehax_add_to_executable(
    example-solidjs-appkit-jsc
    RUNTIME jsc
    BACKEND appkit
    BUNDLE_COMMAND "PATH=/Users/denis/.nvm/versions/node/v16.16.0/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Library/Apple/usr/bin pnpm run buildNative"
)

# Example appkit quickjs
add_executable(
    example-solidjs-appkit-quickjs MACOSX_BUNDLE
    main.appkit.quickjs.mm
    distNative/index.native.js
)
set_target_properties(
    example-solidjs-appkit-quickjs PROPERTIES
    BUNDLE True
    MACOSX_BUNDLE_GUI_IDENTIFIER dev.rehax.rehax.example-solidjs-appkit-quickjs
    MACOSX_BUNDLE_BUNDLE_NAME example-solidjs-appkit-quickjs
    MACOSX_BUNDLE_BUNDLE_VERSION "0.1"
    MACOSX_BUNDLE_SHORT_VERSION_STRING "0.1"
    MACOSX_BUNDLE_INFO_PLIST examples/solidjs/info.plist
    RESOURCE distNative/index.native.js
)
rehax_add_to_executable(
    example-solidjs-appkit-quickjs
    RUNTIME quickjs
    BACKEND appkit
    BUNDLE_COMMAND "PATH=/Users/denis/.nvm/versions/node/v16.16.0/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Library/Apple/usr/bin pnpm run buildNative"
)

# Example fluxe jsc
add_executable(
    example-solidjs-fluxe-jsc MACOSX_BUNDLE
    main.fluxe.jsc.mm
    distNative/index.native.js
)
set_target_properties(
    example-solidjs-fluxe-jsc PROPERTIES
    BUNDLE True
    MACOSX_BUNDLE_GUI_IDENTIFIER dev.rehax.rehax.example-solidjs-fluxe-jsc
    MACOSX_BUNDLE_BUNDLE_NAME example-solidjs-fluxe-jsc
    MACOSX_BUNDLE_BUNDLE_VERSION "0.1"
    MACOSX_BUNDLE_SHORT_VERSION_STRING "0.1"
    MACOSX_BUNDLE_INFO_PLIST examples/solidjs/info.plist
    RESOURCE distNative/index.native.js
)
rehax_add_to_executable(
    example-solidjs-fluxe-jsc
    RUNTIME jsc
    BACKEND fluxe
    BUNDLE_COMMAND "PATH=/Users/denis/.nvm/versions/node/v16.16.0/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Library/Apple/usr/bin pnpm run buildNative"
)

# Example fluxe quickjs
add_executable(
    example-solidjs-fluxe-quickjs MACOSX_BUNDLE
    main.fluxe.quickjs.mm
    distNative/index.native.js
)
set_target_properties(
    example-solidjs-fluxe-quickjs PROPERTIES
    BUNDLE True
    MACOSX_BUNDLE_GUI_IDENTIFIER dev.rehax.rehax.example-solidjs-fluxe-quickjs
    MACOSX_BUNDLE_BUNDLE_NAME example-solidjs-fluxe-quickjs
    MACOSX_BUNDLE_BUNDLE_VERSION "0.1"
    MACOSX_BUNDLE_SHORT_VERSION_STRING "0.1"
    MACOSX_BUNDLE_INFO_PLIST examples/solidjs/info.plist
    RESOURCE distNative/index.native.js
)
rehax_add_to_executable(
    example-solidjs-fluxe-quickjs
    RUNTIME quickjs
    BACKEND fluxe
    BUNDLE_COMMAND "PATH=/Users/denis/.nvm/versions/node/v16.16.0/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Library/Apple/usr/bin pnpm run buildNative"
)
