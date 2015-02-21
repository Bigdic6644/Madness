//  Copyright (c) 2014 Rob Rix. All rights reserved.

/// Convenience for describing the types of parser combinators.
///
/// \param Tree  The type of parse tree generated by the parser.
public struct Parser<S: Sliceable, Tree where S.SubSlice == S> {
	/// The type of parser combinators.
	public typealias Function = S -> Result

	/// The type produced by parser combinators.
	public typealias Result = (Tree, S.SubSlice)?
}


/// Parses `string` with `parser`, returning the parse trees or `nil` if nothing could be parsed or if parsing did not consume the entire input.
public func parse<Tree>(parser: Parser<String, Tree>.Function, string: String) -> Tree? {
	return parser(string).map { $1 == "" ? $0 : nil } ?? nil
}


// MARK: - Terminals

/// Returns a parser which parses any single character.
public func any(input: String) -> (String, String)? {
	return input.isEmpty ? nil : divide(input, 1)
}


/// Returns a parser which parses a `literal` sequence of elements from the input.
///
/// This overload enables e.g. `%"xyz"` to produce `String -> (String, String)`.
public prefix func % <S: Sliceable where S.SubSlice == S, S.Generator.Element: Equatable> (literal: S) -> Parser<S, S>.Function {
	return {
		startsWith($0, literal) ?
			(literal, divide($0, count(literal)).1)
		:	nil
	}
}


/// Returns a parser which parses a `literal` sequence of elements from the input.
///
/// This overload enables e.g. `parse(%[c1, c2, c3], "123")` where `c1`, `c2`, and `c3` are each of type `Character`.
public prefix func % <S: Sliceable, C: CollectionType where S.SubSlice == S, C.Generator.Element == S.Generator.Element, C.Index.Distance == S.Index.Distance, C.Generator.Element: Equatable> (literal: C) -> Parser<S, C>.Function {
	return {
		startsWith($0, literal) ?
			(literal, divide($0, count(literal)).1)
		:	nil
	}
}


/// Returns a parser which parses a `literal` element from the input.
public prefix func % <S: Sliceable where S.SubSlice == S, S.Generator.Element: Equatable> (literal: S.Generator.Element) -> Parser<S, S.Generator.Element>.Function {
	return {
		(first($0) == literal) ?
			(literal, divide($0, 1).1)
		:	nil
	}
}


/// Returns a parser which parses any character in `interval`.
public prefix func %<I: IntervalType where I.Bound == Character>(interval: I) -> Parser<String, String>.Function {
	return { string in
		first(string).map { interval.contains($0) ? ("" + [$0], divide(string, 1).1) : nil } ?? nil
	}
}


// MARK: - Nonterminals

// MARK: Mapping

/// Returns a parser which maps parse trees into another type.
public func --> <S: Sliceable, T, U>(parser: Parser<S, T>.Function, f: T -> U) -> Parser<S, U>.Function {
	return {
		parser($0).map { (f($0), $1) }
	}
}


// MARK: Ignoring input

/// Ignores any parse trees produced by `parser`.
public func ignore<S: Sliceable, T>(parser: Parser<S, T>.Function) -> Parser<S, ()>.Function {
	return parser --> const(())
}

/// Ignores any parse trees produced by a parser which parses `string`.
public func ignore(string: String) -> Parser<String, ()>.Function {
	return ignore(%string)
}


// MARK: - Operators

/// Map operator.
infix operator --> {
	/// Associates to the left.
	associativity left

	/// Lower precedence than |.
	precedence 100
}


/// Literal operator.
prefix operator % {}


// MARK: - Imports

import Either
import Prelude
