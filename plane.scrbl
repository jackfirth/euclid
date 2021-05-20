#lang scribble/manual


@(require (for-label euclid/plane))


@title{Plane Geometry}
@defmodule[euclid/plane]


Euclidian geometry in two dimensions is called @deftech{plane geometry}. The space that all two
dimensional geometric objects exist in is called the @deftech{Euclidean plane}.


@include-section[(lib "euclid/plane/point.scrbl")]
@include-section[(lib "euclid/plane/angle.scrbl")]
