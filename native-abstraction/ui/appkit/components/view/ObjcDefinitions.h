// Objective C has a flat namespace and it doesn't allow hiding symbols
// When two libraries link against a static Objective C library that contain classes with same names, there's a name collision
// We allow the user to prevent this by defining a `OBJC_NAMESPACE_PREFIX`

#define MakePrefixedClassName(x, y) MakePrefixedClassNameAgain(x, y)
#define MakePrefixedClassNameAgain(x, y) x##y
#define MakeClassName(x) MakePrefixedClassName(OBJC_NAMESPACE_PREFIX, x)
#define BaseView MakeClassName(BaseView)
