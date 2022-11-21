#include "Text.h"
#include "../../../base.h"
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#include <iostream>

namespace rehax::ui::appkit::impl {

#include "../../../shared/components/Text.cc"

std::string Text::description() {
  std::ostringstream stringStream;
  stringStream << instanceClassName() << "/NSTextView (Appkit) " << this << ": " << getText();
  return stringStream.str();
}

void Text::createNativeView() {
  NSTextView * view = [NSTextView new];
  [view setFrame:NSMakeRect(0, 0, 200, 200)];
  [view setString:@""];
  view.editable = NO;
  view.richText = YES;
  view.selectable = NO;
//  view.linkTextAttributes = @{NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle)};
  [view setBackgroundColor:[NSColor clearColor]];
  [view sizeToFit];
  this->nativeView = (void *) CFBridgingRetain(view);
}

void Text::setText(std::string text) {
  this->text = text;
  rebuildAttributedString();
}

std::string Text::getText() {
  return text;
}

void Text::setTextColor(rehax::ui::Color color) {
  this->color = color;
  hasColor = true;
  rebuildAttributedString();
}

void Text::setTextColor(::rehax::ui::DefaultValue) {
  hasColor = false;
}

void Text::setFontSize(float size) {
  fontSize = size;
  hasFontSize = true;
  rebuildAttributedString();
}

void Text::setItalic(bool italic) {
  this->isItalic = italic;
  rebuildAttributedString();
}

void Text::setUnderlined(bool underlined) {
  this->isUnderlined = underlined;
  rebuildAttributedString();
}

void Text::setStrikeThrough(bool strikeThrough) {
  this->isStrikeThrough = strikeThrough;
  rebuildAttributedString();
}

void Text::setFontFamilies(std::vector<std::string> fontFamilies) {
  this->fontFamilies = fontFamilies;
  rebuildAttributedString();
}

void Text::addNativeView(void * child) {
//  View::addNativeView(child);
//  NSTextView * view = (__bridge NSTextView *) this->nativeView;
//  [view sizeToFit];
}

void Text::addNativeView(void * child, void * beforeView) {
//  View::addNativeView(child, beforeView);
//  NSTextView * view = (__bridge NSTextView *) this->nativeView;
//  [view sizeToFit];
}

void Text::addView(ObjectPointer<View> view) {
  if (view->instanceClassName() != "Text") {
    std::cerr << "Can only add Text children to Text" << std::endl;
    return;
  }
  View::addView(view);
  auto childText = rehaxUtils::dynamic_pointer_cast<Text>(view);
  childText->isRootTextView = false;
  childText->removeFromNativeParent();
  childText->destroyNativeView();
  rebuildAttributedString();
}

void Text::addView(ObjectPointer<View> view, ObjectPointer<View> beforeView) {
  if (view->instanceClassName() != "Text") {
    std::cerr << "Can only add Text children to Text" << std::endl;
    return;
  }
  View::addView(view, beforeView);
  auto childText = rehaxUtils::dynamic_pointer_cast<Text>(view);
  childText->isRootTextView = false;
  childText->removeFromNativeParent();
  childText->destroyNativeView();
  rebuildAttributedString();
}

void Text::rebuildAttributedString() {
  if (!isRootTextView) {
    if (parent.isValid()) {
      ((Text*) parent.get())->rebuildAttributedString();
    }
    return;
  }
    
  NSString * textString = [NSString stringWithUTF8String:(text + collectChildrenText()).c_str()];
    
  NSMutableAttributedString * str = [[NSMutableAttributedString new] initWithString:textString];
  [str beginEditing];
  applyAttributes(0, (__bridge void *) str);
  [str endEditing];
    
  NSTextView * view = (__bridge NSTextView *) this->nativeView;
  [view.textStorage setAttributedString:str];
  [view sizeToFit];

  view.textContainerInset = NSMakeSize(0, 0);
  view.frame = CGRectMake(0, 0, 1000, 1000); // Need this otherwise if you update the text the letters will appear vertically

  [view.layoutManager ensureLayoutForTextContainer:view.textContainer];
  CGSize size = [view.layoutManager usedRectForTextContainer:view.textContainer].size;
    
  NSArray * constraints = [view.constraints copy];
  for (NSLayoutConstraint * constraint : constraints) {
    if ([constraint.identifier isEqualToString:@"rhx_text_size"]) {
      [view removeConstraint:constraint];
    }
  }

  NSLayoutConstraint * constraint;
  constraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:size.height];
  constraint.identifier = @"rhx_text_size";
  [view addConstraint:constraint];

  constraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:size.width + 2];
  constraint.identifier = @"rhx_text_size";
  [view addConstraint:constraint];
}

std::string Text::collectChildrenText() {
  std::string childrenText = "";
  for (auto & child : children) {
    Text * childText = (Text*) child;
    childrenText += childText->text + childText->collectChildrenText();
  }
  childrenTextLength = [NSString stringWithUTF8String:childrenText.c_str()].length;
  return childrenText;
}

unsigned int Text::applyAttributes(unsigned int pos, void * attributedString) {
  NSMutableAttributedString * str = (__bridge NSMutableAttributedString *) attributedString;
  
  NSString * nsStr = [NSString stringWithUTF8String:text.c_str()];
  auto strLength = nsStr.length;
  auto rangeLength = strLength + childrenTextLength;
  
  if (hasFontSize || hasFontWeight || fontFamilies.size() > 0) {
    NSFont * font = nil;
    for (int i = 0; i < fontFamilies.size(); i++)
    {
      NSString * str = [NSString stringWithCString:fontFamilies[i].c_str() encoding:NSUTF8StringEncoding];
      font = [NSFont fontWithName:str size:fontSize];
      if (font != nullptr) {
        break;
      }
    }
    if (font == nil) {
      font = [NSFont systemFontOfSize:fontSize weight:NSFontWeightRegular];
    }
    [str addAttribute:NSFontAttributeName value:font range:NSMakeRange(pos, rangeLength)];
  }
  if (isRootTextView || hasColor) {
    if (hasColor) {
      NSColor * c = [NSColor colorWithRed:color.r green:color.g blue:color.b alpha:color.a];
      [str addAttribute:NSForegroundColorAttributeName value:c range:NSMakeRange(pos, rangeLength)];
    } else {
      NSColor * c = [NSColor textColor];
      [str addAttribute:NSForegroundColorAttributeName value:c range:NSMakeRange(pos, rangeLength)];
    }
    //   if (text == "red") {
    // [str addAttribute:NSLinkAttributeName value:@"https://google.com" range:NSMakeRange(pos, rangeLength)];
    //   }
  }
  if (isUnderlined) {
    [str addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleSingle] range:NSMakeRange(pos, rangeLength)];
  }
  if (isStrikeThrough) {
    [str addAttribute:NSStrikethroughStyleAttributeName value:[NSNumber numberWithInt:1] range:NSMakeRange(pos, rangeLength)];
  }
  if (isItalic) {
    [str addAttribute:NSObliquenessAttributeName value:[NSNumber numberWithFloat:0.2] range:NSMakeRange(pos, rangeLength)];
  }
  int childrenSize = 0;
  for (auto & child : children) {
    Text * childText = (Text*) child;
    childrenSize += childText->applyAttributes(pos + strLength + childrenSize, attributedString);
  }
  return strLength + childrenTextLength;
}

void Text::layout() {
  rebuildAttributedString();
}

void Text::setLayout(rehaxUtils::ObjectPointer<ILayout> layout) {}

}
