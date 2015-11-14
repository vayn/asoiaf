# CSS Selector Converter

A CSS Selector to XPath Selector for Objective-C. Support mostly used subset of  [CSS Selector Level 3](http://www.w3.org/TR/css3-selectors/).

I build this converter so that I can use `.class` instead of `//*[contains(concat(' ', normalize-space(@class), ' '), ' class ')]` in [IGHTMLQuery](https://github.com/siuying/IGHTMLQuery/).

## Usage

```objective-c
#import "CSSSelectorConverter.h"

CSSSelectorToXPathConverter* converter = [[CSSSelectorToXPathConverter alloc] init];
[converter xpathWithCSS:@"p" error:nil];
// => "//p"

[converter xpathWithCSS:@"p.intro" error:nil];
// => "//p[contains(concat(' ', normalize-space(@class), ' '), ' intro ')]"
```

## Status

It supports following CSS Selectors:

```
*                                "//*"
p                                "//p"
p.intro                          "//p[contains(concat(' ', normalize-space(@class), ' '), ' intro ')]"
p#apple                          "//p[@id = 'apple']"
p *                              "//p//*"
p > *                            "//p/*"
H1 + P                           "//H1/following-sibling::*[1]/self::P"
H1 ~ P                           "//H1/following-sibling::P"
ul, ol                           "//ul | //ol"
p[align]                         "//p[@align]"
p[class~="intro"]                "//p[contains(concat(\" \", @class, \" \"),concat(\" \", 'intro', \" \"))]"
div[att|="val"]                  "//div[@att = \"val\" or starts-with(@att, concat(\"val\", '-'))]"
```

It supports following pseduo classes:

- first-child
- last-child
- first-of-type
- last-of-type
- only-child
- only-of-type
- empty

Currently pseduo classes with parameters are not supported (I probably will not implement them until I really NEEDS them):

- nth-child()
- nth-last-child()
- nth-of-type() 
- nth-last-of-type()
- not()

Following pseduo classes will not be supported:

- Dynamic pseudo classes (:link, :visied, :hover ... etc)
- UI elements states pseudo-classes (:enabled, :checked, :indeterminate)
- :target
- :lang
- :root

## Development

### Building the project

1. Install cocoapods
2. Install pods: ``pod install``

## License

MIT License. See License.txt.