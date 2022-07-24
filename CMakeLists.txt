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
    native-abstraction/ui/appkit/components/**/*.mm
)

file(GLOB REHAX_SRC_FILES
    runtimes/*.cc
    runtimes/*.mm
)

add_library(
    rehax-fluxe-mac STATIC
    ${REHAX_SRC_FILES}
    ${REHAX_FLUXE_SRC_FILES}
)
target_compile_definitions(rehax-fluxe-mac PUBLIC -DREHAX_WITH_FLUXE)

add_library(
    rehax-appkit-mac STATIC
    ${REHAX_SRC_FILES}
    ${REHAX_APPKIT_SRC_FILES}
)
target_compile_definitions(rehax-appkit-mac PUBLIC -DREHAX_WITH_APPKIT)


add_subdirectory(examples/vanillajs-kitchen-sink-fluxe)
add_subdirectory(examples/vanillajs-kitchen-sink-appkit)
add_subdirectory(examples/solidjs)



# include(ExternalProject)

# set(EXTERNAL_INSTALL_LOCATION ${CMAKE_BINARY_DIR}/external)

# ExternalProject_Add(fluxe
#     GIT_REPOSITORY https://github.com/rehax-native/fluxe
#     GIT_TAG main
#     CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${EXTERNAL_INSTALL_LOCATION}
# )

# add_executable(
#     example-vanillajs-kitchen-sink-fluxe
#     examples/vanillajs-kitchen-sink-fluxe/main.mm
# )
# add_dependencies(example-vanillajs-kitchen-sink-fluxe fluxe)

# # To create an xcode project for development:
# # cmake -G Xcode -S . -B build