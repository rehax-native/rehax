cmake_minimum_required(VERSION 3.23)

project(Rehax)
set(CMAKE_CXX_STANDARD 20)


# ---- Example appkit kitchen sink
add_executable(
    example-solidjs-appkit MACOSX_BUNDLE
    main.appkit.mm
    distNative/index.native.js
)
set_target_properties(
    example-solidjs-appkit PROPERTIES
    BUNDLE True
    MACOSX_BUNDLE_GUI_IDENTIFIER dev.rehax.rehax.example-solidjs-appkit
    MACOSX_BUNDLE_BUNDLE_NAME example-solidjs-appkit
    MACOSX_BUNDLE_BUNDLE_VERSION "0.1"
    MACOSX_BUNDLE_SHORT_VERSION_STRING "0.1"
    MACOSX_BUNDLE_INFO_PLIST examples/solidjs/info.plist
    RESOURCE distNative/index.native.js
)
target_link_libraries(
    example-solidjs-appkit
    jsc-bindings
    "-framework Foundation"
    "-framework QuartzCore"
    "-framework AppKit"
    "-framework JavascriptCore"

    # These shouldn't be here, need to figure this out
    fluxe-mac
    icu
    skia
    skparagraph
    skshaper
    sktext
    skunicode
)
target_compile_definitions(example-solidjs-appkit PUBLIC -DREHAX_WITH_APPKIT)

add_custom_command(
    TARGET example-solidjs-appkit PRE_BUILD
    COMMAND PATH=/Users/denis/.nvm/versions/node/v16.16.0/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Library/Apple/usr/bin pnpm run buildNative
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)



# ---- Example fluxe kitchen sink
add_executable(
    example-solidjs-fluxe MACOSX_BUNDLE
    main.fluxe.mm
    distNative/index.native.js
)
set_target_properties(
    example-solidjs-fluxe PROPERTIES
    BUNDLE True
    MACOSX_BUNDLE_GUI_IDENTIFIER dev.rehax.rehax.example-solidjs-fluxe
    MACOSX_BUNDLE_BUNDLE_NAME example-solidjs-fluxe
    MACOSX_BUNDLE_BUNDLE_VERSION "0.1"
    MACOSX_BUNDLE_SHORT_VERSION_STRING "0.1"
    MACOSX_BUNDLE_INFO_PLIST examples/solidjs/info.plist
    RESOURCE distNative/index.native.js
)
target_link_libraries(
    example-solidjs-fluxe
    rehax-fluxe-mac
    jsc-bindings
    fluxe-mac
    "-framework Foundation"
    "-framework QuartzCore"
    "-framework AppKit"
    "-framework JavascriptCore"
    icu
    skia
    skparagraph
    skshaper
    sktext
    skunicode
)
target_compile_definitions(example-solidjs-fluxe PUBLIC -DREHAX_WITH_FLUXE)

add_custom_command(
    TARGET example-solidjs-fluxe PRE_BUILD
    COMMAND PATH=/Users/denis/.nvm/versions/node/v16.16.0/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Library/Apple/usr/bin pnpm run buildNative
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)



# ---- Example fluxe kitchen sink with quickjs
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
target_link_libraries(
    example-solidjs-fluxe-quickjs
    rehax-fluxe-mac
    quickjs-bindings
    fluxe-mac
    "-framework Foundation"
    "-framework QuartzCore"
    "-framework AppKit"
    icu
    skia
    skparagraph
    skshaper
    sktext
    skunicode
)
target_compile_definitions(example-solidjs-fluxe-quickjs PUBLIC -DREHAX_WITH_FLUXE)

add_custom_command(
    TARGET example-solidjs-fluxe-quickjs PRE_BUILD
    COMMAND PATH=/Users/denis/.nvm/versions/node/v16.16.0/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Library/Apple/usr/bin pnpm run buildNative
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)


# ---- Example appkit kitchen sink with quickjs
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
target_link_libraries(
    example-solidjs-appkit-quickjs
    rehax-fluxe-mac
    quickjs-bindings
    fluxe-mac
    "-framework Foundation"
    "-framework QuartzCore"
    "-framework AppKit"
    icu
    skia
    skparagraph
    skshaper
    sktext
    skunicode
)
target_compile_definitions(example-solidjs-appkit-quickjs PUBLIC -DREHAX_WITH_APPKIT)

add_custom_command(
    TARGET example-solidjs-appkit-quickjs PRE_BUILD
    COMMAND PATH=/Users/denis/.nvm/versions/node/v16.16.0/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Library/Apple/usr/bin pnpm run buildNative
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)
