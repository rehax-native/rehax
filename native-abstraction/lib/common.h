#ifndef RHX_EXPORT
#if defined(_WIN64) || defined(_WIN32)
#define RHX_EXPORT __declspec(dllexport)
#else
#define RHX_EXPORT
#endif
#endif