load("@build_bazel_rules_apple//apple:macos.bzl", "macos_application")

objc_library(
    name = "example-simple-window-lib",
    srcs = ["main.mm"],
    deps = ["//:rehax-ui-appkit"],
)

macos_application(
    name = "example-simple-window",
    deps = [":example-simple-window-lib"],
    bundle_id = "dev.rehax.example-simple-window",
    infoplists = [":info.plist"],
    minimum_os_version = "10.9",
)