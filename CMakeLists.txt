cmake_minimum_required(VERSION 3.23)

project(Rehax)
set(CMAKE_CXX_STANDARD 20)

include(FetchContent)


# FetchContent_Declare(fluxe
#   GIT_REPOSITORY https://github.com/rehax-native/fluxe.git
#   GIT_TAG        main
# )
# FetchContent_MakeAvailable(fluxe)

FetchContent_Declare(quickjs
  GIT_REPOSITORY https://github.com/bellard/quickjs.git
  GIT_TAG        master
)
FetchContent_MakeAvailable(quickjs)

FetchContent_Declare(rehaxUtils
  GIT_REPOSITORY https://github.com/rehax-native/utils.git
  GIT_TAG        main
)
FetchContent_MakeAvailable(rehaxUtils)


include_directories(${quickjs_SOURCE_DIR}/..)
include_directories(${rehaxUtils_SOURCE_DIR})

include_directories(../fluxe)
include_directories(../fluxe/third_party/skia)
link_directories(../fluxe/dist)
link_directories(../fluxe/build/Debug)

file(GLOB REHAX_FLUXE_SRC_FILES
    native-abstraction/ui/fluxe/components/**/*.cc
)

file(GLOB REHAX_APPKIT_SRC_FILES
    native-abstraction/ui/appkit/components/**/*.mm
)

file(GLOB REHAX_JSC_SRC_FILES
    runtimes/jsc/runtime.mm
    runtimes/jsc/bindings.mm
)

file(GLOB REHAX_QUICKJS_SRC_FILES
    runtimes/quickjs/runtime.cc
    runtimes/quickjs/bindings.mm
)

file(GLOB QUICK_JS_SRCS
    ${quickjs_SOURCE_DIR}/quickjs.c
    ${quickjs_SOURCE_DIR}/libregexp.c
    ${quickjs_SOURCE_DIR}/libunicode.c
    ${quickjs_SOURCE_DIR}/libbf.c
    ${quickjs_SOURCE_DIR}/cutils.c
)

add_library(
    quickjs-lib STATIC
    ${QUICK_JS_SRCS}
)
target_compile_definitions(quickjs-lib PUBLIC -DCONFIG_VERSION="1.0.0")

add_library(
    jsc-bindings STATIC
    ${REHAX_JSC_SRC_FILES}
    ${REHAX_APPKIT_SRC_FILES}
)
add_library(
    quickjs-bindings STATIC
    ${REHAX_QUICKJS_SRC_FILES}
    ${REHAX_APPKIT_SRC_FILES}
)
target_link_libraries(
    quickjs-bindings
    quickjs-lib
)
target_compile_definitions(quickjs-bindings PUBLIC -DREHAX_WITH_FLUXE)
target_compile_definitions(quickjs-bindings PUBLIC -DREHAX_WITH_APPKIT)

add_library(
    rehax-fluxe-mac STATIC
    ${REHAX_FLUXE_SRC_FILES}
)

target_compile_definitions(jsc-bindings PUBLIC -DREHAX_WITH_FLUXE)
target_compile_definitions(jsc-bindings PUBLIC -DREHAX_WITH_APPKIT)

# add_library(
#     rehax-appkit-mac STATIC
# )


add_subdirectory(examples/vanillajs-kitchen-sink-fluxe)
add_subdirectory(examples/vanillajs-kitchen-sink-appkit)
add_subdirectory(examples/solidjs)



# # To create an xcode project for development:
# # cmake -G Xcode -S . -B build