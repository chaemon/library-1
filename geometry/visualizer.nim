include "./template.nim"
include "./polygon.nim"

import nigui

const D = 900

type CanvasData = object
  p: seq[(Point, string, Color)]
  l: seq[(Line, string, Color)]
  s: seq[(Segment, string, Color)]
  c: seq[(Circle, string, Color)]
  poly: seq[(Polygon, string, Color)]
  width, height: int
  xmin, ymin: float
  d: float


proc convert(self:CanvasData, p:Point):Point =
  return initPoint((p.re - self.xmin)/self.d * D, (p.im - self.ymin)/self.d * D)
proc convert(self:CanvasData, c:Circle):Circle =
  return initCircle(self.convert c.p, c.r/self.d*D)
proc convert(self:CanvasData, l:Line):Line =
  return initLine(self.convert l.a, self.convert l.b)
proc convert(self:CanvasData, l:Segment):Segment =
  return initSegment(self.convert l.a, self.convert l.b)
proc convert(self:CanvasData, p:Polygon):Polygon =
  for p in p: result.add(self.convert p)

proc setCanvasSize(self: var CanvasData) =
  var
    xmin = float.inf
    xmax = -float.inf
    ymin = float.inf
    ymax = -float.inf
  proc update(p:Point) =
    xmin.min=p.re
    xmax.max=p.re
    ymin.min=p.im
    ymax.max=p.im
  for p in self.p:
    update(p[0])
  for p in self.s:
    update(p[0].a)
    update(p[0].b)
  for p in self.c:
    let
      c = p[0].p
      r = p[0].r
    update(initPoint(c.re+r,c.im+r))
    update(initPoint(c.re-r,c.im-r))
  xmin -= 10.0;ymin -= 10.0
  xmax += 10.0;ymax += 10.0
  let d = max(xmax - xmin, ymax - ymin)
  self.xmin = xmin
  self.ymin = ymin
  self.d = d
  

type Canvas = object
  Win: Window
  Ctl: Control
  canvas_data: CanvasData

# initCanvas {{{
proc init(self: var Canvas) =
  app.init()
  self = Canvas(Win:newWindow("Canvas"), Ctl:newControl(), canvas_data: CanvasData())
  self.Ctl.widthMode=WidthMode_Fill
  self.Ctl.heightMode=HeightMode_Fill
  self.Win.add(self.Ctl)
  self.Win.width = D
  self.Win.height = D
  var s = self.canvas_data.addr

  self.Ctl.onClick = proc(c:ClickEvent)=
    echo "Canvas"

  self.Ctl.onDraw = proc(e:DrawEvent) =
    let Cv=e.control.canvas
  
    Cv.areaColor=rgb(255,240,180)
    Cv.fill()
    s[].setCanvasSize()

    for (p, label, col) in s[].p:
      let p = s[].convert p
      Cv.areaColor = col
      Cv.drawEllipseArea(p.re.int - 3, p.im.int - 3, 6, 6)
      Cv.textColor = col
      Cv.drawText(label, p.re.int + 10, p.im.int - 20)
    for (l, label, col) in s[].l:
      let l = s[].convert l
      Cv.lineColor = col
      Cv.drawLine(l.a.re.int, l.a.im.int, l.b.re.int, l.b.im.int)
      Cv.textColor = col
      Cv.drawText(label, l.a.re.int + 10, l.a.im.int - 20)
    for (l, label, col) in s[].l:
      let l = s[].convert l
      Cv.lineColor = col
      Cv.drawLine(l.a.re.int, l.a.im.int, l.b.re.int, l.b.im.int)
      Cv.textColor = col
      Cv.drawText(label, l.a.re.int + 10, l.a.im.int - 20)
    for (c, label, col) in s[].c:
      let c = s[].convert c
      Cv.lineColor = col
      Cv.drawArcOutline(c.p.re.int, c.p.im.int, c.r, 0.0, PI * 2.0)
      Cv.textColor = col
      Cv.drawText(label, (c.p.re + c.r/2.0).int, (c.p.im - c.r/2.0).int)
    for (poly, label, col) in s[].poly:
      let poly = s[].convert poly
      Cv.lineColor = col
      for i in 0..<poly.len:
        let
          p = poly[i]
          q = poly[(i + 1) mod poly.len]
        Cv.drawLine(p.re.int, p.im.int, q.re.int, q.im.int)
      let p = poly[0]
      Cv.textColor = col
      Cv.drawText(label, p.re.int + 10, p.im.int - 20)

#    Cv.textColor=rgb(0,255,0) # green
#    Cv.fontSize=20
#    Cv.drawText("text",10,180)
#  
#  #  Cv.areaColor=rgb(0,0,255) # blue
#  #  Cv.drawRectArea(120,120,180,200)
#  
#    Cv.lineColor=rgb(255,0,0) # red
#    Cv.drawLine(30,150,180,40)
#  
#    Cv.drawArcOutline(100, 100, 50.0, 1.57, 3.14)
#    Cv.lineColor=rgb(0, 0, 0) # black
#    Cv.areaColor=rgb(0, 0, 0) # red
#    Cv.drawEllipseArea(200, 200, 5, 5)
#
##  Cv.drawImage(Img,10,10,65)

# }}}

proc addPoint(self: var Canvas, p:Point, label = "", color = rgb(0, 0, 0)) =
  self.canvas_data.p.add((p, label, color))
proc addLine(self: var Canvas, l:Line, label = "", color = rgb(0, 0, 0)) =
  self.canvas_data.l.add((l, label, color))
proc addSegment(self: var Canvas, s:Segment, label = "", color = rgb(0, 0, 0)) =
  self.canvas_data.s.add((s, label, color))
proc addCircle(self: var Canvas, c:Circle, label = "", color = rgb(0, 0, 0)) =
  self.canvas_data.c.add((c, label, color))
proc addPolygon(self: var Canvas, p:Polygon, label = "", color = rgb(0, 0, 0)) =
  self.canvas_data.poly.add((p, label, color))

proc show(self: Canvas) =
  self.Win.show()
  app.run()

#var d = Canvas()
#d.init()

#d.addPoint(initPoint(200, 150), "X")
#d.addPoint(initPoint(233, 150), "Y")
#d.addLine(initLine(initPoint(222, 333), initPoint(333, 444)))
#d.addCircle(initCircle(initPoint(100, 100), 50), "C")
#d.addPolygon(@[initPoint(111, 222), initPoint(222, 222), initPoint(222, 111), initPoint(111, 111)], "P")

#d.show()
