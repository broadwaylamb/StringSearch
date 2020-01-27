import XCTest
import StringSearch

final class StringSearchTests: XCTestCase {
    func testHello() {
        assertSearchResultEqual(search: "hll",
                                in: ["hello", "hell", "hl", "ll", "hllo", "hll", "fhll", "fhell"],
                                expect: [("hll", [0 ..< 3]),
                                         ("hllo", [0 ..< 3]),
                                         ("fhll", [1 ..< 4]),
                                         ("hell", [0 ..< 1, 2 ..< 4]),
                                         ("hello", [0 ..< 1, 2 ..< 4]),
                                         ("fhell", [1 ..< 2, 3 ..< 5])])
    }

    func testAbracadabra() {
        assertSearchResultEqual(search: "abracadabra",
                                in: ["labracadabra",
                                     "abrabracadabra",
                                     "abracabracadabra",
                                     "abracaldabra"],
                                expect: [("labracadabra", [1 ..< 12]),
                                         ("abracaldabra", [0 ..< 6, 7 ..< 12]),
                                         ("abracabracadabra", [0 ..< 6, 11 ..< 16]),
                                         ("abrabracadabra", [0 ..< 4, 7 ..< 14])])
    }

    func testProgrammingLanguages() {
        let languages = [
            "Name",
            "C",
            "Fortran",
            "C++",
            "Cppx",
            "Assembly",
            "CUDA",
            "Python",
            "LLVM IR",
            "D",
            "ispc",
            "Analysis",
            "Nim",
            "Go",
            "Rust",
            "Clean",
            "Pascal",
            "Haskell",
            "Ada",
            "OCaml",
            "Swift",
            "Zig"
        ]


        assertSearchResultEqual(search: "c",
                                in: languages,
                                expect: [("C", [0 ..< 1]),
                                         ("C++", [0 ..< 1]),
                                         ("Cppx", [0 ..< 1]),
                                         ("CUDA", [0 ..< 1]),
                                         ("Clean", [0 ..< 1]),
                                         ("OCaml", [1 ..< 2]),
                                         ("ispc", [3 ..< 4]),
                                         ("Pascal", [3 ..< 4])],
                                caseSensitive: false)

        assertSearchResultEqual(search: "as",
                                in: languages,
                                expect: [("Assembly", [0 ..< 2]),
                                         ("Pascal", [1 ..< 3]),
                                         ("Haskell", [1 ..< 3]),
                                         ("Analysis", [0 ..< 1, 5 ..< 6])],
                                caseSensitive: false)

        assertSearchResultEqual(search: "Ca",
                                in: languages,
                                expect: [("OCaml", [1 ..< 3]),
                                         ("Pascal", [3 ..< 5]),
                                         ("CUDA", [0 ..< 1, 3 ..< 4]),
                                         ("Clean", [0 ..< 1, 3 ..< 4])],
                                caseSensitive: false)
    }

    static let allTests = [
        ("testHello", testHello),
        ("testAbracadabra", testAbracadabra),
        ("testProgrammingLanguages", testProgrammingLanguages),
    ]
}

private func assertSearchResultEqual(search query: String,
                                     in collection: [String],
                                     expect: [(String, [Range<Int>])],
                                     caseSensitive: Bool = true,
                                     file: StaticString = #file,
                                     line: UInt = #line) {
    let findings = caseSensitive
        ? search(for: query, in: collection)
        : searchIgnoringCase(for: query, in: collection)
    let actual = findings.map { ($1.content, $1.matchingOffsetRanges) }

    guard actual.count == expect.count else {
        XCTFail("\(actual) is not equal to \(expect)", file: file, line: line)
        return
    }

    XCTAssert(zip(actual, expect).allSatisfy(==),
              "\(actual) is not equal to \(expect)",
        file: file,
        line: line)
}
