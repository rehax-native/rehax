cmake_minimum_required(VERSION 3.23)

# project(Rehax)
# set(CMAKE_CXX_STANDARD 20)


# # To create an xcode project for development:
# # cmake -G Xcode -S examples/solidjs -B build_examples


## Function to add rehax to an executable 
# rehax_add_to_executable(
#     example-app
#     RUNTIME jsc
#     BACKEND appkit
#     BUNDLE_COMMAND pnpm run build
# )
function (rehax_add_to_executable app_name)
    cmake_parse_arguments(
        PARSE_ARGV 1
        REHAX
        ""
        "RUNTIME;BACKEND;BUNDLE_COMMAND"
        ""
    )

    include(FetchContent)

    # Dependencies

    # FetchContent_Declare(fluxe
    #   GIT_REPOSITORY https://github.com/rehax-native/fluxe.git
    #   GIT_TAG        main
    # )
    # FetchContent_MakeAvailable(fluxe)

    if (NOT TARGET quickjs-lib)
        FetchContent_Declare(quickjs
            GIT_REPOSITORY https://github.com/bellard/quickjs.git
            GIT_TAG        master
        )
        FetchContent_MakeAvailable(quickjs)
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
    endif ()

    FetchContent_Declare(rehaxUtils
        GIT_REPOSITORY https://github.com/rehax-native/utils.git
        GIT_TAG        main
    )
    FetchContent_MakeAvailable(rehaxUtils)


    include_directories(${quickjs_SOURCE_DIR}/..)
    include_directories(${rehaxUtils_SOURCE_DIR})

    include_directories(${CMAKE_CURRENT_FUNCTION_LIST_DIR}/../fluxe)
    include_directories(${CMAKE_CURRENT_FUNCTION_LIST_DIR}/../fluxe/third_party/skia)
    link_directories(${CMAKE_CURRENT_FUNCTION_LIST_DIR}/../fluxe/dist)
    link_directories(${CMAKE_CURRENT_FUNCTION_LIST_DIR}/../fluxe/build/Debug)


    file(GLOB REHAX_SRC_FILES ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/native-abstraction/ui/style.cc)
    file(GLOB REHAX_FLUXE_SRC_FILES ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/native-abstraction/ui/fluxe/components/**/*.cc)
    file(GLOB REHAX_APPKIT_SRC_FILES ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/native-abstraction/ui/appkit/components/**/*.mm)
    file(GLOB REHAX_JSC_SRC_FILES ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/runtimes/jsc/runtime.mm ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/runtimes/jsc/bindings.mm ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/runtimes/jsc/runtimeUtils.mm)
    file(GLOB REHAX_QUICKJS_SRC_FILES ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/runtimes/quickjs/runtime.cc ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/runtimes/quickjs/bindings.mm ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/runtimes/quickjs/runtimeUtils.mm)
    file(REAL_PATH ${CMAKE_CURRENT_FUNCTION_LIST_DIR} REHAX_HEADER_INCLUDE_DIR)

    include_directories(${REHAX_HEADER_INCLUDE_DIR})

    if ("${REHAX_RUNTIME}" STREQUAL "")
        message(FATAL_ERROR "RUNTIME not set. Please set RUNTIME. Candidates: jsc, quickjs")
    elseif (${REHAX_RUNTIME} STREQUAL jsc)
        target_sources(${app_name} PUBLIC ${REHAX_JSC_SRC_FILES})
        target_link_libraries(
            ${app_name}
            "-framework JavascriptCore"
        )
    elseif (${REHAX_RUNTIME} STREQUAL quickjs)
        target_sources(${app_name} PUBLIC ${REHAX_QUICKJS_SRC_FILES})
        target_link_libraries(
            ${app_name}
            quickjs-lib
        )
    else ()
        message(FATAL_ERROR "Runtime not supported: ${REHAX_RUNTIME}. please set RUNTIME. Candidates: jsc, quickjs")
    endif ()

    if ("${REHAX_BACKEND}" STREQUAL "")
        message(FATAL_ERROR "BACKEND not set. Please set BACKEND. Candidates: appkit, fluxe")
    elseif (${REHAX_BACKEND} STREQUAL appkit)
        target_sources(${app_name} PUBLIC ${REHAX_APPKIT_SRC_FILES} ${REHAX_SRC_FILES})
        target_link_libraries(
            ${app_name}
            "-framework AppKit"
            "-framework QuartzCore" # For vector graphics
        )
        target_compile_definitions(${app_name} PUBLIC -DREHAX_WITH_APPKIT)
    elseif (${REHAX_BACKEND} STREQUAL fluxe)
        target_sources(${app_name} PUBLIC ${REHAX_FLUXE_SRC_FILES} ${REHAX_SRC_FILES})
        target_link_libraries(
            ${app_name}
            fluxe-mac
            "-framework Foundation"
            "-framework QuartzCore"
            "-framework AppKit"
            "-framework Metal"
            "-framework MetalKit"
            icu
            skia
            skparagraph
            skshaper
            sktext
            skunicode
        )
        target_compile_definitions(${app_name} PUBLIC -DREHAX_WITH_FLUXE)
    else ()
        message(FATAL_ERROR "Backend not supported: ${REHAX_BACKEND}. please set BACKEND. Candidates: appkit, fluxe")
    endif ()

    if (NOT "${REHAX_BUNDLE_COMMAND}" STREQUAL "")
        separate_arguments(REHAX_BUNDLE_COMMAND NATIVE_COMMAND "${REHAX_BUNDLE_COMMAND}")
        add_custom_command(
            TARGET ${app_name} PRE_BUILD
            COMMAND ${REHAX_BUNDLE_COMMAND}
            WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        )
    endif ()

endfunction ()
