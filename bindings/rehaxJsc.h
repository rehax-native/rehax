#import <JavaScriptCore/JavaScriptCore.h>

class StaticDefine {
  class PropertyDefine {
    std::string name;
    GetterCallback getter = nullptr;
    SetterCallback setter = nullptr;
    std::string traceName = name;

    PropertyDefine(std::string name, GetterCallback getter, SetterCallback setter,
                   std::string traceName)
        : name(std::move(name)),
          getter(std::move(getter)),
          setter(std::move(setter)),
          traceName(std::move(traceName)) {}

    SCRIPTX_CLASS_DEFINE_FRIENDS;
  };

  struct FunctionDefine {
    std::string name;
    FunctionCallback callback;
    std::string traceName = name;

    FunctionDefine(std::string name, FunctionCallback callback, std::string traceName)
        : name(std::move(name)), callback(std::move(callback)), traceName(std::move(traceName)) {}

    SCRIPTX_CLASS_DEFINE_FRIENDS;
  };

  const std::vector<FunctionDefine> functions{};
  const std::vector<PropertyDefine> properties{};

  StaticDefine(std::vector<FunctionDefine> functions, std::vector<PropertyDefine> properties)
      : functions(std::move(functions)), properties(std::move(properties)) {}

  SCRIPTX_CLASS_DEFINE_FRIENDS;
};

template <typename T>
class InstanceDefine {
  static_assert(std::is_void_v<T> || std::is_base_of_v<ScriptClass, T>,
                "T must be subclass of ScriptClass, "
                "and can be void if no instance is required.");

  using Constructor = InstanceConstructor<T>;

  class PropertyDefine {
    using SetterCallback = InstanceSetterCallback<T>;
    using GetterCallback = InstanceGetterCallback<T>;

    std::string name;
    GetterCallback getter;
    SetterCallback setter;
    std::string traceName = name;

    PropertyDefine(std::string name, GetterCallback getter, SetterCallback setter,
                   std::string traceName)
        : name(std::move(name)),
          getter(std::move(getter)),
          setter(std::move(setter)),
          traceName(std::move(traceName)) {}

    SCRIPTX_CLASS_DEFINE_FRIENDS;
  };

  class FunctionDefine {
    using FunctionCallback = InstanceFunctionCallback<T>;

    std::string name;
    FunctionCallback callback;
    std::string traceName;

    FunctionDefine(std::string name, FunctionCallback callback, std::string traceName)
        : name(std::move(name)), callback(std::move(callback)), traceName(std::move(traceName)) {}

    SCRIPTX_CLASS_DEFINE_FRIENDS;
  };

  /**
   * constructor a native class associated with the script object.
   * when null is returned, an exception is thrown.
   * (Either inside the constructor, or if not, by the ScriptEngine).
   */
  const Constructor constructor{};
  const std::vector<FunctionDefine> functions{};
  const std::vector<PropertyDefine> properties{};
  const size_t instanceSize = internal::sizeof_helper_v<T>;

  InstanceDefine(Constructor constructor, std::vector<FunctionDefine> functions,
                 std::vector<PropertyDefine> properties)
      : constructor(std::move(constructor)),
        functions(std::move(functions)),
        properties(std::move(properties)) {}

  SCRIPTX_CLASS_DEFINE_FRIENDS;
};

template <typename T>
class ClassDefine {
  static_assert(std::is_same_v<T, std::remove_pointer_t<std::decay_t<T>>>,
                "T must be decayed value type, ie. no reference, pointer, cv qualifier.");

 public:
//   /**
//    * erase the template type.
//    * so you can has a collection of different ClassDefines.
//    */
//   NativeRegister getNativeRegister() const;

  void visit(ClassDefineVisitor& visitor) const;

  const std::string& getClassName() const { return className; };

  const std::string& getNameSpace() const { return nameSpace; }

 private:
  const std::string className;
  const std::string nameSpace;

  /**
   * static methods & properties
   */
  const internal::StaticDefine staticDefine;

  /**
   * instance methods & properties
   */
  const internal::InstanceDefine<T> instanceDefine;

  ClassDefine(std::string className, std::string nameSpace, internal::StaticDefine staticDefine,
              internal::InstanceDefine<T> instanceDefine)
      : className(std::move(className)),
        nameSpace(std::move(nameSpace)),
        staticDefine(std::move(staticDefine)),
        instanceDefine(std::move(instanceDefine)) {}

  SCRIPTX_CLASS_DEFINE_FRIENDS;
};


void bindJsc()
{
    JSClassDefinition instanceDefine = kJSClassDefinitionEmpty;
    instanceDefine.attributes = kJSClassAttributeNone;
    instanceDefine.className = "View";
    
    instanceDefine.finalize = [] (JSObjectRef thiz) {
        auto * t = static_cast<View *>(JSObjectGetPrivate(thiz));
        // Not sure we should delete this here, could still be in the view hierarchy.
        delete t;
    };
    instanceDefine.callAsConstructor = [] (JSContextRef ctx, JSObjectRef constructor, size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception)
    {
        auto clazz = classRegistry["View"];
        auto view = View::Create();
        auto object = JSObjectMake(ctx, clazz, view);
        return object;
    };
    instanceDefine.getProperty = [] (JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef *exception)
    {
        if (propertyName == "addView") {
            
        }
        return JSValueMakeNull(ctx);
    };
    
    auto clazz = JSClassCreate(&instanceDefine);
    classRegistry["View"] = clazz;



//    registry.instanceClass = clazz;
    
//     JSClassDefinition staticDefine = kJSClassDefinitionEmpty;
    
// //    staticDefine.callAsConstructor = createConstructor<T>();
// //    staticDefine.hasInstance = [](JSContextRef ctx, JSObjectRef constructor,
// //                                  JSValueRef possibleInstance, JSValueRef* exception) -> bool {
// //        auto engine = static_cast<JscEngine*>(JSObjectGetPrivate(JSContextGetGlobalObject(ctx)));
// //        auto def = static_cast<ClassDefine<T>*>(JSObjectGetPrivate(constructor));
// //        return engine->isInstanceOfImpl(make<Local<Value>>(possibleInstance), def);
// //    };
    
//     auto staticClass = JSClassCreate(&staticDefine);
// //    object = Local<Object>(JSObjectMake(context_, staticClass, const_cast<ClassDefine<T>*>(classDefine)));
//     // not used anymore
//     JSClassRelease(staticClass);
//    registry.constructor = object.asObject();
    
//    auto prototype = defineInstancePrototype(classDefine);
//    object.asObject().set("prototype", prototype);
//
//    registry.prototype = prototype;
}
