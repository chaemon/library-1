#{{{ complex class
{.push checks: off, line_dir: off, stack_trace: off, debugger: off.}
# the user does not want to trace a part of the standard library!

import math

type
  Complex* = object
    re*, im*: float

proc complex*(re: float; im: float = 0.0): Complex =
  result.re = re
  result.im = im

template im*(arg: typedesc[float]): Complex = complex(0, 1)
template im*(arg: float): Complex = complex(0, arg)

proc abs*(z: Complex): float =
  ## Return the distance from (0,0) to ``z``.
  result = hypot(z.re, z.im)

proc abs2*(z: Complex): float =
  ## Return the squared distance from (0,0) to ``z``.
  result = z.re*z.re + z.im*z.im

proc conjugate*(z: Complex): Complex =
  ## Conjugate of complex number ``z``.
  result.re = z.re
  result.im = -z.im

proc `==` *(x, y: Complex): bool =
  ## Compare two complex numbers ``x`` and ``y`` for equality.
  result = x.re == y.re and x.im == y.im

#proc `+` *(x: float; y: Complex): Complex =
#  ## Add a real number to a complex number.
#  result.re = x + y.re
#  result.im = y.im

proc `+` *(x: Complex; y: float): Complex =
  ## Add a complex number to a real number.
  result.re = x.re + y
  result.im = x.im

proc `+` *(x, y: Complex): Complex =
  ## Add two complex numbers.
  result.re = x.re + y.re
  result.im = x.im + y.im

proc `-` *(z: Complex): Complex =
  ## Unary minus for complex numbers.
  result.re = -z.re
  result.im = -z.im

#proc `-` *(x: float; y: Complex): Complex =
#  ## Subtract a complex number from a real number.
#  x + (-y)

proc `-` *(x: Complex; y: float): Complex =
  ## Subtract a real number from a complex number.
  result.re = x.re - y
  result.im = x.im

proc `-` *(x, y: Complex): Complex =
  ## Subtract two complex numbers.
  result.re = x.re - y.re
  result.im = x.im - y.im

proc `*` *(x, y: Complex): Complex =
  ## Multiply ``x`` with ``y``.
  result.re = x.re * y.re - x.im * y.im
  result.im = x.im * y.re + x.re * y.im

#proc `*` *(x: float; y: Complex): Complex =
#  ## Multiply a real number and a complex number.
#  result.re = x * y.re
#  result.im = x * y.im

proc `*` *(x: Complex; y: float): Complex =
  ## Multiply a complex number with a real number.
  result.re = x.re * y
  result.im = x.im * y

proc `/` *(x: Complex; y: float): Complex =
  ## Divide complex number ``x`` by real number ``y``.
  result.re = x.re / y
  result.im = x.im / y

proc inv*(z: Complex): Complex =
  ## Multiplicative inverse of complex number ``z``.
  conjugate(z) / abs2(z)

#proc `/` *(x: float; y: Complex): Complex =
#  ## Divide real number ``x`` by complex number ``y``.
#  result = x * inv(y)

proc `/` *(x, y: Complex): Complex =
  ## Divide ``x`` by ``y``.
  var r, den: float
  if abs(y.re) < abs(y.im):
    r = y.re / y.im
    den = y.im + r * y.re
    result.re = (x.re * r + x.im) / den
    result.im = (x.im * r - x.re) / den
  else:
    r = y.im / y.re
    den = y.re + r * y.im
    result.re = (x.re + r * x.im) / den
    result.im = (x.im - r * x.re) / den

proc `+=` *(x: var Complex; y: Complex) =
  ## Add ``y`` to ``x``.
  x.re += y.re
  x.im += y.im

proc `-=` *(x: var Complex; y: Complex) =
  ## Subtract ``y`` from ``x``.
  x.re -= y.re
  x.im -= y.im

proc `*=` *(x: var Complex; y: Complex) =
  ## Multiply ``y`` to ``x``.
  let im = x.im * y.re + x.re * y.im
  x.re = x.re * y.re - x.im * y.im
  x.im = im

proc `/=` *(x: var Complex; y: Complex) =
  ## Divide ``x`` by ``y`` in place.
  x = x / y


proc sqrt*(z: Complex): Complex =
  ## Square root for a complex number ``z``.
  var x, y, w, r: float

  if z.re == 0.0 and z.im == 0.0:
    result = z
  else:
    x = abs(z.re)
    y = abs(z.im)
    if x >= y:
      r = y / x
      w = sqrt(x) * sqrt(0.5 * (1.0 + sqrt(1.0 + r * r)))
    else:
      r = x / y
      w = sqrt(y) * sqrt(0.5 * (r + sqrt(1.0 + r * r)))

    if z.re >= 0.0:
      result.re = w
      result.im = z.im / (w * 2.0)
    else:
      result.im = if z.im >= 0.0: w else: -w
      result.re = z.im / (result.im + result.im)

proc exp*(z: Complex): Complex =
  ## ``e`` raised to the power ``z``.
  var
    rho = exp(z.re)
    theta = z.im
  result.re = rho * cos(theta)
  result.im = rho * sin(theta)

proc ln*(z: Complex): Complex =
  ## Returns the natural log of ``z``.
  result.re = ln(abs(z))
  result.im = arctan2(z.im, z.re)

proc log10*(z: Complex): Complex =
  ## Returns the log base 10 of ``z``.
  result = ln(z) / ln(10.0)

proc log2*(z: Complex): Complex =
  ## Returns the log base 2 of ``z``.
  result = ln(z) / ln(2.0)

proc pow*(x, y: Complex): Complex =
  ## ``x`` raised to the power ``y``.
  if x.re == 0.0 and x.im == 0.0:
    if y.re == 0.0 and y.im == 0.0:
      result.re = 1.0
      result.im = 0.0
    else:
      result.re = 0.0
      result.im = 0.0
  elif y.re == 1.0 and y.im == 0.0:
    result = x
  elif y.re == -1.0 and y.im == 0.0:
    result = complex(1.0) / x
  else:
    var
      rho = abs(x)
      theta = arctan2(x.im, x.re)
      s = pow(rho, y.re) * exp(-y.im * theta)
      r = y.re * theta + y.im * ln(rho)
    result.re = s * cos(r)
    result.im = s * sin(r)

proc pow*(x: Complex; y: float): Complex =
  ## Complex number ``x`` raised to the power ``y``.
  pow(x, complex(y))


proc sin*(z: Complex): Complex =
  ## Returns the sine of ``z``.
  result.re = sin(z.re) * cosh(z.im)
  result.im = cos(z.re) * sinh(z.im)

proc arcsin*(z: Complex): Complex =
  ## Returns the inverse sine of ``z``.
  result = -im(float) * ln(im(float) * z + sqrt(complex(1.0) - z*z))

proc cos*(z: Complex): Complex =
  ## Returns the cosine of ``z``.
  result.re = cos(z.re) * cosh(z.im)
  result.im = -sin(z.re) * sinh(z.im)

proc arccos*(z: Complex): Complex =
  ## Returns the inverse cosine of ``z``.
  result = -im(float) * ln(z + sqrt(z*z - float(1.0)))

proc tan*(z: Complex): Complex =
  ## Returns the tangent of ``z``.
  result = sin(z) / cos(z)

proc arctan*(z: Complex): Complex =
  ## Returns the inverse tangent of ``z``.
  result = complex(0.5)*im(float) * (ln(complex(1.0) - im(float)*z) - ln(complex(1.0) + im(float)*z))

proc cot*(z: Complex): Complex =
  ## Returns the cotangent of ``z``.
  result = cos(z)/sin(z)

proc arccot*(z: Complex): Complex =
  ## Returns the inverse cotangent of ``z``.
  result = complex(0.5)*im(float) * (ln(complex(1.0) - im(float)/z) - ln(complex(1.0) + im(float)/z))

proc sec*(z: Complex): Complex =
  ## Returns the secant of ``z``.
  result = complex(1.0) / cos(z)

proc arcsec*(z: Complex): Complex =
  ## Returns the inverse secant of ``z``.
  result = -im(float) * ln(im(float) * sqrt(complex(1.0) - complex(1.0)/(z*z)) + complex(1.0)/z)

proc csc*(z: Complex): Complex =
  ## Returns the cosecant of ``z``.
  result = complex(1.0) / sin(z)

proc arccsc*(z: Complex): Complex =
  ## Returns the inverse cosecant of ``z``.
  result = -im(float) * ln(sqrt(complex(1.0) - complex(1.0)/(z*z)) + im(float)/z)

proc sinh*(z: Complex): Complex =
  ## Returns the hyperbolic sine of ``z``.
  result = complex(0.5) * (exp(z) - exp(-z))

proc arcsinh*(z: Complex): Complex =
  ## Returns the inverse hyperbolic sine of ``z``.
  result = ln(z + sqrt(z*z + 1.0))

proc cosh*(z: Complex): Complex =
  ## Returns the hyperbolic cosine of ``z``.
  result = complex(0.5) * (exp(z) + exp(-z))

proc arccosh*(z: Complex): Complex =
  ## Returns the inverse hyperbolic cosine of ``z``.
  result = ln(z + sqrt(z*z - float(1.0)))

proc tanh*(z: Complex): Complex =
  ## Returns the hyperbolic tangent of ``z``.
  result = sinh(z) / cosh(z)

proc arctanh*(z: Complex): Complex =
  ## Returns the inverse hyperbolic tangent of ``z``.
  result = complex(0.5) * (ln((complex(1.0)+z) / (complex(1.0)-z)))

proc sech*(z: Complex): Complex =
  ## Returns the hyperbolic secant of ``z``.
  result = complex(2.0) / (exp(z) + exp(-z))

proc arcsech*(z: Complex): Complex =
  ## Returns the inverse hyperbolic secant of ``z``.
  result = ln(1.0.complex/z + sqrt(complex(1.0)/z+float(1.0)) * sqrt(complex(1.0)/z-float(1.0)))

proc csch*(z: Complex): Complex =
  ## Returns the hyperbolic cosecant of ``z``.
  result = complex(2.0) / (exp(z) - exp(-z))

proc arccsch*(z: Complex): Complex =
  ## Returns the inverse hyperbolic cosecant of ``z``.
  result = ln(complex(1.0)/z + sqrt(complex(1.0)/(z*z) + float(1.0)))

proc coth*(z: Complex): Complex =
  ## Returns the hyperbolic cotangent of ``z``.
  result = cosh(z) / sinh(z)

proc arccoth*(z: Complex): Complex =
  ## Returns the inverse hyperbolic cotangent of ``z``.
  result = complex(0.5) * (ln(complex(1.0) + complex(1.0)/z) - ln(complex(1.0) - complex(1.0)/z))

proc phase*(z: Complex): float =
  ## Returns the phase of ``z``.
  arctan2(z.im, z.re)

proc polar*(z: Complex): tuple[r, phi: float] =
  ## Returns ``z`` in polar coordinates.
  (r: abs(z), phi: phase(z))

proc rect*(r, phi: float): Complex =
  ## Returns the complex number with polar coordinates ``r`` and ``phi``.
  ##
  ## | ``result.re = r * cos(phi)``
  ## | ``result.im = r * sin(phi)``
  complex(r * cos(phi), r * sin(phi))


proc `$`*(z: Complex): string =
  ## Returns ``z``'s string representation as ``"(re, im)"``.
  result = "(" & $z.re & ", " & $z.im & ")"

{.pop.}
#}}}
