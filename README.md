# StringSearch

A simple algorithm for searching for a string in a collection of strings, based on Swift 5.1 [ordered collection diffing](https://github.com/apple/swift-evolution/blob/master/proposals/0240-ordered-collection-diffing.md).

- Produces something like Xcode's code completion matching.
- Not limited to strings, works with any `BidirectionalCollection`.
- Does not depend on anything but the standard library.

I'm too lazy to add documentation, but it's simple, you can figure it out yourself.

## Requirements

- Swift 5.1
- iOS 13
- macOS 10.15
- watchOS 6
- tvOS 13
- Any non-Apple platform where you can compile Swift code.
