cmake_minimum_required(VERSION 3.23)

project(Rehax)
set(CMAKE_CXX_STANDARD 20)


# ---- Example fluxe kitchen sink
add_executable(
    example-solidjs MACOSX_BUNDLE
    main.mm
    distNative/index.native.js
)
set_target_properties(
    example-solidjs PROPERTIES
    BUNDLE True
    MACOSX_BUNDLE_GUI_IDENTIFIER dev.rehax.rehax.example-solidjs
    MACOSX_BUNDLE_BUNDLE_NAME example-solidjs
    MACOSX_BUNDLE_BUNDLE_VERSION "0.1"
    MACOSX_BUNDLE_SHORT_VERSION_STRING "0.1"
    MACOSX_BUNDLE_INFO_PLIST examples/solidjs/info.plist
    RESOURCE distNative/index.native.js
)
target_link_libraries(
    example-solidjs
    rehax-appkit-mac
    "-framework Foundation"
    "-framework QuartzCore"
    "-framework AppKit"
    "-framework JavascriptCore"
)
target_compile_definitions(example-solidjs PUBLIC -DREHAX_WITH_APPKIT)

# target_link_libraries(
#     example-solidjs
#     rehax-fluxe-mac
#     fluxe-mac
#     "-framework Foundation"
#     "-framework QuartzCore"
#     "-framework AppKit"
#     "-framework JavascriptCore"
#     icu
#     skia
#     skparagraph
#     skshaper
#     sktext
#     skunicode
# )

add_custom_command(
    TARGET example-solidjs PRE_BUILD
    # OUTPUT distNative/index.native.js
    COMMAND PATH=/Users/denis/.nvm/versions/node/v16.16.0/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Library/Apple/usr/bin pnpm run buildNative
    # DEPENDS src/index.native.js
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)
# add_custom_command(
#     TARGET example-solidjs POST_BUILD
#     COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/distNative/index.native.js ${CMAKE_CURRENT_BINARY_DIR}/index.native.js
#     # DEPENDS src/index.native.js
#     # WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
# )

# get_target_property(BUNDLE_LOCATION example-solidjs MACOSX_PACKAGE_LOCATION)
# message(${MACOSX_PACKAGE_LOCATION(example-solidjs)})
# message(${CMAKE_CURRENT_BINARY_DIR}/\${CONFIGURATION}/${APP_NAME}.app)

# set_property(SOURCE ${CMAKE_CURRENT_SOURCE_DIR}/distNative/index.native.js PROPERTY MACOSX_PACKAGE_LOCATION "Resources/script.js")

# add_custom_command(
#     TARGET example-solidjs POST_BUILD
#     COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/distNative/index.native.js $<TARGET_BUNDLE_DIR:example-solidjs>/Resources/script.js
#     # DEPENDS src/index.native.js
#     # WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
# )

# include_directories(${CMAKE_CURRENT_BINARY_DIR})
# add_executable(example-solidjs ${SOURCE_FILES} foo.hh)
# configure_file(${CMAKE_CURRENT_SOURCE_DIR}/distNative/index.native.js ${CMAKE_CURRENT_BINARY_DIR}/index.native.js COPYONLY)
# configure_file(distNative/index.native.js ${CMAKE_CURRENT_BINARY_DIR}/index.native.js COPYONLY)