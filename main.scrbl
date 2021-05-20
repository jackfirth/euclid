#lang scribble/manual


@(require (for-label euclid))


@title{Euclid}
@defmodule[euclid]


The Euclid package provides data structures and algorithms related to Euclidian geometry.
Specifically, this package provides tools for working with @tech{plane geometry}, which is
two-dimensional, and @tech{solid geometry}, which is three-dimensional. Rather than being generic in
the number of dimensions, modules and data types in this package are instead specific to either plane
or solid geometry.


@table-of-contents[]


@include-section[(lib "euclid/plane.scrbl")]
@include-section[(lib "euclid/solid.scrbl")]
