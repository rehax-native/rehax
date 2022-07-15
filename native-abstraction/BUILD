cc_library(
    name = "rehax-ui-appkit",
    visibility = ["//visibility:public"],
    
    srcs = glob([
        "ui/appkit/**/*.cpp",
    ]),
    hdrs = glob([
        "ui/appkit/**/*.h",
        "ui/base.h",
        "lib/common.h",
        # "style.h",
        "rehax.h",
    ]),

    copts = ["-x objective-c++"],

    # alwayslink = True,
    # runtime_deps = ["AppKit"],
    # sdk_frameworks = ["AppKit"],
)