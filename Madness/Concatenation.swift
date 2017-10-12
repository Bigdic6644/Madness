//  Copyright (c) 2015 Rob Rix. All rights reserved.

/// Parses the concatenation of `left` and `right`, pairing their parse trees.
public func <*> <C: CollectionType, T, U> (left: Parser<C, T -> U>.Function, right: Parser<C, T>.Function) -> Parser<C, U>.Function {
	return left >>- { $0 <^> right }
}

/// Parses the concatenation of `left` and `right`, dropping `right`’s parse tree.
public func <* <C: CollectionType, T, U> (left: Parser<C, T>.Function, right: Parser<C, U>.Function) -> Parser<C, T>.Function {
	return left >>- { x in { _ in x } <^> right }
}

/// Parses the concatenation of `left` and `right`, dropping `left`’s parse tree.
public func *> <C: CollectionType, T, U> (left: Parser<C, T>.Function, right: Parser<C, U>.Function) -> Parser<C, U>.Function {
	return left >>- { _ in right }
}


infix operator <*> {
	associativity left
	precedence 130
}

infix operator *> {
	associativity left
	precedence 130
}

infix operator <* {
	associativity left
	precedence 130
}
