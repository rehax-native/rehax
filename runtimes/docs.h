#pragma once

#include <iostream>
#include <map>
#include <string_view>

#if RHX_GEN_DOCS

// This small utility class is used to generate documentation for the runtimes.

namespace rehax::docs {

struct ArgumentDocs {
  std::string name;
  std::string_view type;
};

struct MethodDocs {
  std::string name;
  std::string_view nativeName;
  std::string_view returnType;
  std::vector<ArgumentDocs> arguments;
};

struct ViewDocs {
  std::string name;
  std::vector<MethodDocs> methods;
};

struct TypeDocs {
  std::string_view type;
  std::string note;
};


template <typename T>
constexpr auto get_type_name() -> std::string_view
{
#if defined(__clang__)
  constexpr auto prefix = std::string_view{"[T = "};
  constexpr auto suffix = "]";
  constexpr auto function = std::string_view{__PRETTY_FUNCTION__};
#elif defined(__GNUC__)
  constexpr auto prefix = std::string_view{"with T = "};
  constexpr auto suffix = "; ";
  constexpr auto function = std::string_view{__PRETTY_FUNCTION__};
#elif defined(__MSC_VER)
  constexpr auto prefix = std::string_view{"get_type_name<"};
  constexpr auto suffix = ">(void)";
  constexpr auto function = std::string_view{__FUNCSIG__};
#else
# error Unsupported compiler
#endif

  const auto start = function.find(prefix) + prefix.size();
  const auto end = function.find(suffix);
  const auto size = end - start;

  return function.substr(start, size);
}

template <typename T>
class Docs {
public:
  Docs(std::string bindingsName)
  :bindingsName(bindingsName) {}

  template <typename View>
  void collectView(ViewDocs docs) {
    this->docs[View::ClassName()] = docs;
  }

  template <typename View>
  void collectMethod(MethodDocs docs) {
    this->docs[View::ClassName()].methods.push_back(docs);
  }

  void collectType(std::string name, TypeDocs docs) {
    this->typeDocs[name] = docs;
  }

  void printJson() {
    std::string whitespace = "  ";
    std::cout << "{" << std::endl;
    std::cout << whitespace << "\"bindings\": " << "\"" << bindingsName << "\"," << std::endl;
    std::cout << whitespace << "\"types\": {" << std::endl;
    int i1 = 0;
    for (auto it : typeDocs) {
      std::cout << whitespace << whitespace << "\"" << it.first << "\": {" << std::endl;
      std::cout << whitespace << whitespace << whitespace << "\"note\": \"" << it.second.note << "\"" << std::endl;
      std::cout << whitespace << whitespace << "}";
      if (i1 < typeDocs.size() - 1) {
        std::cout << ",";
      }
      i1++;
      std::cout << std::endl;
    }
    std::cout << whitespace << "}," << std::endl;
    std::cout << whitespace << "\"views\": {" << std::endl;
    i1 = 0;
    for (auto it : docs) {
      std::cout << whitespace << whitespace << "\"" << it.first << "\": {" << std::endl;
      int i2 = 0;
      for (auto it2 : it.second.methods) {
        std::cout << whitespace << whitespace << whitespace << "\"" << it2.name << "\": {" << std::endl;
        std::cout << whitespace << whitespace << whitespace << whitespace << "\"returnType\": \"" << it2.returnType << "\"," << std::endl;
        std::cout << whitespace << whitespace << whitespace << whitespace << "\"arguments\": [" << std::endl;
        int i3 = 0;
        for (auto it3 : it2.arguments) {
          std::cout << whitespace << whitespace << whitespace << whitespace << whitespace << "\"" << it3.type << "\"";
          if (i3 < it2.arguments.size() - 1) {
            std::cout << ",";
          }
          i3++;
          std::cout << std::endl;
        }
        std::cout << whitespace << whitespace << whitespace << whitespace << "]" << std::endl;
        std::cout << whitespace << whitespace << whitespace << "}";
        if (i2 < it.second.methods.size() - 1) {
          std::cout << ",";
        }
        i2++;
        std::cout << std::endl;
      }
      std::cout << whitespace << whitespace << "}";
      if (i1 < docs.size() - 1) {
        std::cout << ",";
      }
      i1++;
      std::cout << std::endl;
    }
    std::cout << whitespace << "}" << std::endl;
    std::cout << "}" << std::endl;
  }

  void printMarkdown() {
    std::cout << "## Bindings for *" << bindingsName << "*" << std::endl;
    std::cout << std::endl;
    std::cout << "## Types" << std::endl;
    for (auto it : typeDocs) {
      std::cout << "### " << it.first << std::endl << it.second.note << std::endl;
      std::cout << std::endl;
    }
    std::cout << std::endl;
    std::cout << "## Views" << std::endl;
    for (auto it : docs) {
      std::cout << "### " << it.first << std::endl;
      for (auto it2 : it.second.methods) {

        std::cout << " - `";
        if (it2.returnType.length() > 0) {
          std::cout << it2.returnType;
        } else {
          std::cout << "void";
        }
        std::cout << " " << it2.name << "(";
        int i3 = 0;
        for (auto it3 : it2.arguments) {
          std::cout << it3.type;
          if (i3 < it2.arguments.size() - 1) {
            std::cout << ", ";
          }
          i3++;
        }
        std::cout << ")`" << std::endl;
      }
      std::cout << std::endl;
      std::cout << std::endl;
    }
    std::cout << std::endl;
    std::cout << std::endl;
  }

  std::string bindingsName;
  std::map<std::string, TypeDocs> typeDocs;
  std::map<std::string, ViewDocs> docs;
};


}

#endif
