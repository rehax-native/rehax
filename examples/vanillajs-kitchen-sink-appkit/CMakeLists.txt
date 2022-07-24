cmake_minimum_required(VERSION 3.23)

project(Rehax)
set(CMAKE_CXX_STANDARD 20)


# ---- Example appkit kitchen sink
add_executable(
    example-vanillajs-kitchen-sink-appkit MACOSX_BUNDLE
    main.mm
)
set_target_properties(
    example-vanillajs-kitchen-sink-appkit PROPERTIES
    BUNDLE True
    MACOSX_BUNDLE_GUI_IDENTIFIER dev.rehax.rehax.vanillajs-kitchen-sink-appkit
    MACOSX_BUNDLE_BUNDLE_NAME vanillajs-kitchen-sink-appkit
    MACOSX_BUNDLE_BUNDLE_VERSION "0.1"
    MACOSX_BUNDLE_SHORT_VERSION_STRING "0.1"
    MACOSX_BUNDLE_INFO_PLIST examples/vanillajs-kitchen-sink-appkit/info.plist
)
target_link_libraries(
    example-vanillajs-kitchen-sink-appkit
    rehax-appkit-mac
    "-framework Foundation"
    "-framework QuartzCore"
    "-framework AppKit"
    "-framework JavascriptCore"
)
