//
//  ViewController.m
//  rehax-jsc-appkit-runtime-playground
//
//  Created by Denis on 12.07.22.
//

#import "ViewController.h"
//#import "../../../../../rehax-v2/runtimes/jsc-appkit/rehax-jsc-appkit-runtime/rehax-jsc-appkit-runtime/rehax_jsc_appkit_runtime.h"
#import "../../../../bindings/generated/AppKit.framework/binding.mm"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSButton new] addSubview:self.view];
    
    JSContextGroupRef contextGroup = JSContextGroupCreate();
    JSGlobalContextRef globalContext = JSGlobalContextCreateInGroup(contextGroup, NULL);
    JSObjectRef globalObject = JSContextGetGlobalObject(globalContext);
    
    setupAppKitBindings(globalContext);
    
    JSValueRef exception = NULL;
    JSStringRef rootView = JSStringCreateWithUTF8CString("rootView");
    JSObjectSetProperty(globalContext, globalObject, rootView, rehaxMakeAppKitNSViewInstanceObject(globalContext, self.view), kJSPropertyAttributeNone, &exception);
//    NSButton *btn;
//    btn.target
//    btn.action
    if (exception) {
        JSStringRef messageProp = JSStringCreateWithUTF8CString("message");
        JSStringRef message = (JSStringRef) JSObjectGetProperty(globalContext, (JSObjectRef) exception, messageProp, NULL);
        NSLog(@"%@", JSStringToNSString(globalContext, message));
    }
    
    JSStringRef script = JSStringCreateWithUTF8CString("\
        var btn = AppKit.NSButton.new(); \
        btn.setStringValue('My btn'); \
        rootView.addSubview(btn); \
        btn.setFrame({ origin: { x: 10, y: 30 }, size: { width: 100, height: 40 } });");
    
    exception = NULL;
    JSEvaluateScript(globalContext, script, NULL, NULL, 1, &exception);
    if (exception) {
        JSStringRef messageProp = JSStringCreateWithUTF8CString("message");
        JSStringRef message = (JSStringRef) JSObjectGetProperty(globalContext, (JSObjectRef) exception, messageProp, NULL);
        NSLog(@"%@", JSStringToNSString(globalContext, message));
    }
        
        /* memory management code to prevent memory leaks */
        
//        JSGlobalContextRelease(globalContext);
//        JSContextGroupRelease(contextGroup);
//        JSStringRelease(logFunctionName);
//        JSStringRelease(logCallStatement);

    // Do any additional setup after loading the view.
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
