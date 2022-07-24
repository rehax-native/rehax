cmake_minimum_required(VERSION 3.23)

project(Rehax)
set(CMAKE_CXX_STANDARD 20)



include_directories(../fluxe)
include_directories(../fluxe/third_party/skia)
link_directories(../fluxe/dist)
link_directories(../fluxe/build/Debug)

file(GLOB REHAX_FLUXE_SRC_FILES
    native-abstraction/ui/fluxe/components/view/*.cpp
    native-abstraction/ui/fluxe/components/button/*.cpp
)

file(GLOB REHAX_APPKIT_SRC_FILES
    native-abstraction/ui/appkit/components/view/*.mm
    native-abstraction/ui/appkit/components/button/*.mm
)

file(GLOB REHAX_SRC_FILES
    runtimes/*.cc
    runtimes/*.mm
)

add_library(
    rehax-fluxe-mac STATIC
    ${REHAX_SRC_FILES}
    ${REHAX_APPKIT_SRC_FILES}
    ${REHAX_FLUXE_SRC_FILES}
)

add_executable(
    example-vanillajs-kitchen-sink-fluxe MACOSX_BUNDLE
    examples/vanilla-js-kitchen-sink-fluxe/main.mm
)

set_target_properties(
    example-vanillajs-kitchen-sink-fluxe PROPERTIES
    BUNDLE True
    MACOSX_BUNDLE_GUI_IDENTIFIER dev.rehax.rehax.vanilla-js-kitchen-sink-fluxe
    MACOSX_BUNDLE_BUNDLE_NAME vanilla-js-kitchen-sink-fluxe
    MACOSX_BUNDLE_BUNDLE_VERSION "0.1"
    MACOSX_BUNDLE_SHORT_VERSION_STRING "0.1"
    MACOSX_BUNDLE_INFO_PLIST examples/vanilla-js-kitchen-sink-fluxe/info.plist
)


target_link_libraries(example-vanillajs-kitchen-sink-fluxe rehax-fluxe-mac)
target_link_libraries(example-vanillajs-kitchen-sink-fluxe fluxe-mac)
target_link_libraries(example-vanillajs-kitchen-sink-fluxe "-framework Foundation")
target_link_libraries(example-vanillajs-kitchen-sink-fluxe "-framework QuartzCore")
target_link_libraries(example-vanillajs-kitchen-sink-fluxe "-framework AppKit")
target_link_libraries(example-vanillajs-kitchen-sink-fluxe "-framework JavascriptCore")
target_link_libraries(example-vanillajs-kitchen-sink-fluxe icu)
target_link_libraries(example-vanillajs-kitchen-sink-fluxe skia)
target_link_libraries(example-vanillajs-kitchen-sink-fluxe skparagraph)
target_link_libraries(example-vanillajs-kitchen-sink-fluxe skshaper)
target_link_libraries(example-vanillajs-kitchen-sink-fluxe sktext)
target_link_libraries(example-vanillajs-kitchen-sink-fluxe skunicode)





# include(ExternalProject)

# set(EXTERNAL_INSTALL_LOCATION ${CMAKE_BINARY_DIR}/external)

# ExternalProject_Add(fluxe
#     GIT_REPOSITORY https://github.com/rehax-native/fluxe
#     GIT_TAG main
#     CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTERNAL_INSTALL_LOCATION}
# )

# add_executable(
#     example-vanillajs-kitchen-sink-fluxe
#     examples/vanilla-js-kitchen-sink-fluxe/main.mm
# )
# add_dependencies(example-vanillajs-kitchen-sink-fluxe fluxe)

# # To create an xcode project for development:
# # cmake -G Xcode -S . -B build