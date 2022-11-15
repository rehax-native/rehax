cmake_minimum_required(VERSION 3.21)

# project(Rehax)
set(CMAKE_CXX_STANDARD 20)

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
        "RUNTIME;BACKEND;BUNDLE_COMMAND;FLUXE_LOCATION"
        ""
    )

    if (${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
        set(MACOSX TRUE)
    endif()
    if (WIN32)
        set(WIN TRUE)
    endif()


    include(FetchContent)

    # Dependencies

    # FetchContent_Declare(fluxe
    #   GIT_REPOSITORY https://github.com/rehax-native/fluxe.git
    #   GIT_TAG        main
    # )
    # FetchContent_MakeAvailable(fluxe)

    if (NOT TARGET quickjs-lib)
        if (${WIN})
            # quickjs isn't compatible with VS code out of the box
            # This fork is.
            FetchContent_Declare(quickjs
                GIT_REPOSITORY https://github.com/c-smile/quickjspp.git
                GIT_TAG        master
            )
        else()
            FetchContent_Declare(quickjs
                GIT_REPOSITORY https://github.com/bellard/quickjs.git
                GIT_TAG        master
            )
        endif()

        FetchContent_MakeAvailable(quickjs)
        file(GLOB QUICK_JS_SRCS
            ${quickjs_SOURCE_DIR}/quickjs.c
            ${quickjs_SOURCE_DIR}/quickjs-libc.c
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

        if (${WIN})
            target_compile_definitions(quickjs-lib PUBLIC -DJS_STRICT_NAN_BOXING -DCONFIG_BIGNUM)
        endif()

        set_property(TARGET quickjs-lib PROPERTY CXX_STANDARD 17)
    endif()

    FetchContent_Declare(rehaxUtils
        GIT_REPOSITORY https://github.com/rehax-native/utils.git
        GIT_TAG        main
    )
    FetchContent_MakeAvailable(rehaxUtils)


    include_directories(${quickjs_SOURCE_DIR}/..)
    include_directories(${rehaxUtils_SOURCE_DIR})

    if (NOT "${REHAX_FLUXE_LOCATION}" STREQUAL "")
        # include_directories(${CMAKE_CURRENT_FUNCTION_LIST_DIR}/../fluxe)
        # include_directories(${CMAKE_CURRENT_FUNCTION_LIST_DIR}/../fluxe/third_party/skia)
        include_directories(${REHAX_FLUXE_LOCATION})
        include_directories(${REHAX_FLUXE_LOCATION}/third_party/skia)
    endif()

    find_library(
        ICU_LIB
        NAMES icu
        PATHS "${REHAX_FLUXE_LOCATION}/dist/out"
    )
    find_library(
        SKIA_LIB
        NAMES skia
        PATHS "${REHAX_FLUXE_LOCATION}/dist/out"
    )
    find_library(
        SKPARAGRAPH_LIB
        NAMES skparagraph
        PATHS "${REHAX_FLUXE_LOCATION}/dist/out"
    )
    find_library(
        SKSHAPER_LIB
        NAMES skshaper
        PATHS "${REHAX_FLUXE_LOCATION}/dist/out"
    )
    find_library(
        SKTEXT_LIB
        NAMES sktext
        PATHS "${REHAX_FLUXE_LOCATION}/dist/out"
    )
    find_library(
        SKUNICODE_LIB
        NAMES skunicode
        PATHS "${REHAX_FLUXE_LOCATION}/dist/out"
    )


    file(GLOB REHAX_SRC_FILES ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/native-abstraction/ui/style.cc)
    file(GLOB REHAX_FLUXE_SRC_FILES ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/native-abstraction/ui/fluxe/components/**/*.cc)
    file(GLOB REHAX_APPKIT_SRC_FILES ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/native-abstraction/ui/appkit/components/**/*.mm)
    file(GLOB REHAX_JSC_SRC_FILES ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/runtimes/jsc/runtime.mm ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/runtimes/jsc/bindings.cc ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/runtimes/jsc/runtimeUtils.mm)
    file(GLOB REHAX_QUICKJS_SRC_FILES ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/runtimes/quickjs/runtime.cc ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/runtimes/quickjs/bindings.cc ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/runtimes/quickjs/runtimeUtils.cc)
    file(REAL_PATH ${CMAKE_CURRENT_FUNCTION_LIST_DIR} REHAX_HEADER_INCLUDE_DIR)

    include_directories(${REHAX_HEADER_INCLUDE_DIR})

    if ("${REHAX_RUNTIME}" STREQUAL "")
        message(FATAL_ERROR "RUNTIME not set. Please set RUNTIME. Candidates: jsc, quickjs")
    elseif (${REHAX_RUNTIME} STREQUAL jsc)
        target_sources(${app_name} PUBLIC ${REHAX_JSC_SRC_FILES})
        target_link_libraries(
            ${app_name}
            rehax-utils-mac
            "-framework JavascriptCore"
        )
    elseif (${REHAX_RUNTIME} STREQUAL quickjs)
        target_sources(${app_name} PUBLIC ${REHAX_QUICKJS_SRC_FILES})
        target_link_libraries(
            ${app_name}
            quickjs-lib
        )
        if (${MACOSX})
            target_link_libraries(
                ${app_name}
                rehax-utils-mac
            )
        endif()
        if (${WIN})
            target_link_libraries(
                ${app_name}
                rehax-utils-win
            )
        endif()
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
            rehax-utils-mac
        )
        target_compile_definitions(${app_name} PUBLIC -DREHAX_WITH_APPKIT)
    elseif (${REHAX_BACKEND} STREQUAL fluxe)
        if ("${REHAX_FLUXE_LOCATION}" STREQUAL "")
            message(FATAL_ERROR "fluxe selected as backend, but no FLUXE_LOCATION was passed")
        endif()
        target_sources(${app_name} PUBLIC ${REHAX_FLUXE_SRC_FILES} ${REHAX_SRC_FILES})
        if (${MACOSX})
            find_library(
                FLUXE_MAC_LIB 
                NAMES fluxe
                PATHS "${REHAX_FLUXE_LOCATION}/dist/out"
                # PATHS "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/../fluxe/dist/out"
            )
            message(WARNING ${FLUXE_MAC_LIB})
            message(WARNING ${SKIA_LIB})
            target_link_libraries(
                ${app_name}
                ${FLUXE_MAC_LIB}
                "-framework Foundation"
                "-framework QuartzCore"
                "-framework AppKit"
                "-framework Metal"
                "-framework MetalKit"
                rehax-utils-mac
                ${ICU_LIB}
                ${SKIA_LIB}
                ${SKPARAGRAPH_LIB}
                ${SKSHAPER_LIB}
                ${SKTEXT_LIB}
                ${SKUNICODE_LIB}
            )
        endif()
        if (${WIN})
            find_library(
                FLUXE_WIN_LIB 
                NAMES fluxe
                PATHS "${REHAX_FLUXE_LOCATION}/dist/out"
                # PATHS "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/../fluxe/dist/out"
                #  "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/../fluxe/build/Debug"
            )
            # message(WARNING "${REHAX_FLUXE_LOCATION}/dist/out")
            # message(WARNING ${FLUXE_WIN_LIB})
            # message(WARNING ${SKIA_LIB})
            # message(WARNING ${SKUNICODE_LIB})
            target_link_libraries(
                ${app_name}
                ${FLUXE_WIN_LIB}
                rehax-utils-win
                ${ICU_LIB}
                ${SKIA_LIB}
                ${SKPARAGRAPH_LIB}
                ${SKSHAPER_LIB}
                ${SKTEXT_LIB}
                ${SKUNICODE_LIB}
                opengl32
            )
            target_compile_definitions(${app_name} PUBLIC -DWINVER=0x0605)
        endif()
        target_compile_definitions(${app_name} PUBLIC -DREHAX_WITH_FLUXE)
        # target_include_directories(${app_name} ${fluxe_SOURCE_DIR}/..)
        include_directories(${CMAKE_CURRENT_FUNCTION_LIST_DIR}/../fluxe)
    else ()
        message(FATAL_ERROR "Backend not supported: ${REHAX_BACKEND}. please set BACKEND. Candidates: appkit, fluxe")
    endif ()

    # message(WARNING "${REHAX_BUNDLE_COMMAND}")
    if (NOT "${REHAX_BUNDLE_COMMAND}" STREQUAL "")
        separate_arguments(REHAX_BUNDLE_COMMAND NATIVE_COMMAND "${REHAX_BUNDLE_COMMAND}")
        add_custom_command(
            TARGET ${app_name} PRE_BUILD
            COMMAND ${REHAX_BUNDLE_COMMAND}
            WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        )
    endif ()

endfunction ()
