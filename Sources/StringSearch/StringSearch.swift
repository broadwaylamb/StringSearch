public struct SearchResult<C: BidirectionalCollection> {
    public let content: C
    public let distance: Double
    public let matchingOffsetRanges: [Range<Int>]

    public var matchingCollectionRanges: [Range<C.Index>] {
        matchingOffsetRanges.map {
            content.index(content.startIndex, offsetBy: $0.lowerBound) ..<
                content.index(content.startIndex, offsetBy: $0.upperBound)
        }
    }

    internal init(content: C,
                  distance: Double,
                  matchingRanges: [Range<Int>]) {
        self.content = content
        self.distance = distance
        self.matchingOffsetRanges = matchingRanges
    }
}

extension SearchResult: Equatable where C: Equatable {}

extension SearchResult: Hashable where C: Hashable {}

internal func search<SearchQuery: BidirectionalCollection,
                     PotentialMatch: BidirectionalCollection>(
    for searchQuery: SearchQuery,
    in potentialMatch: PotentialMatch,
    equalityTest: (PotentialMatch.Element, SearchQuery.Element) -> Bool
) -> SearchResult<PotentialMatch>?
    where SearchQuery.Element == PotentialMatch.Element
{
    let count = potentialMatch.count
    let difference = searchQuery.difference(from: potentialMatch, by: equalityTest)

    guard difference.insertions.isEmpty else {
        // If any of the characters of the search query is not in the potential match,
        // this is a not a match. Discard it.
        return nil
    }

    var matchingRanges = [Range<Int>]()
    var previousMatchEndIndex = 0
    var distance = 0.0
    var penalty = 1.0
    for removal in difference.removals {
        switch removal {
        case let .remove(offset, _, nil):
            // The more the offset, the less the penalty.
            distance += Double(count - offset) / Double(count) * penalty
            penalty *= 0.4
            let matchStart = previousMatchEndIndex
            previousMatchEndIndex = offset
            let range = matchStart ..< previousMatchEndIndex
            if !range.isEmpty {
                matchingRanges.append(range)
            }
            previousMatchEndIndex += 1
        default:
            assertionFailure("unreachable")
            continue
        }
    }

    if matchingRanges.last?.upperBound != count &&
        previousMatchEndIndex < count  {
        matchingRanges.append(previousMatchEndIndex ..< count)
    }

    return SearchResult(content: potentialMatch,
                        distance: distance,
                        matchingRanges: matchingRanges)
}

public func search<SearchQuery: BidirectionalCollection, PotentialMatches: Collection>(
    for query: SearchQuery,
    in potentialMatches: PotentialMatches,
    equalityTest: (PotentialMatches.Element.Element, SearchQuery.Element) -> Bool
) -> [(PotentialMatches.Index, SearchResult<PotentialMatches.Element>)]
    where PotentialMatches.Element: BidirectionalCollection,
          SearchQuery.Element == PotentialMatches.Element.Element
{
    potentialMatches.indices.compactMap { i in
        search(for: query, in: potentialMatches[i], equalityTest: equalityTest).map {
            (i, $0)
        }
    }.sorted {
        ($0.1.matchingOffsetRanges.count, $0.1.distance) <
            ($1.1.matchingOffsetRanges.count, $1.1.distance)
    }
}

public func search<SearchQuery: BidirectionalCollection, PotentialMatches: Collection>(
    for query: SearchQuery,
    in potentialMatches: PotentialMatches
) -> [(PotentialMatches.Index, SearchResult<PotentialMatches.Element>)]
    where SearchQuery.Element: Equatable,
          SearchQuery.Element == PotentialMatches.Element.Element
{
    search(for: query, in: potentialMatches, equalityTest: ==)
}

public func searchIgnoringCase<SearchQuery: StringProtocol,
                               PotentialMatches: Collection>(
    for query: SearchQuery,
    in potentialMatches: PotentialMatches
) -> [(PotentialMatches.Index, SearchResult<PotentialMatches.Element>)]
    where PotentialMatches.Element: StringProtocol
{
    search(for: query, in: potentialMatches) { lhs, rhs in
        lhs.lowercased() == rhs.lowercased()
    }
}
