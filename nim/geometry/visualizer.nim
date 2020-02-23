include "./template.nim"

import nigui

type CanvasData = object
  p: seq[(Point, string, Color)]
  l: seq[(Line, string, Color)]
  s: seq[(Segment, string, Color)]
  c: seq[(Circle, string, Color)]
  poly: seq[(Polygon, string, Color)]
  width, height: int
  xmin, xmax, ymin, ymax: float

type Canvas = object
  Win: Window
  Ctl: Control

var canvas_data = CanvasData()

# initCanvas {{{
proc initCanvas():Canvas =
  app.init()
  result = Canvas(Win:newWindow("Canvas"), Ctl:newControl())
  result.Ctl.widthMode=WidthMode_Fill
  result.Ctl.heightMode=HeightMode_Fill
  result.Win.add(result.Ctl)
  result.Win.width = 900
  result.Win.height = 900

  result.Ctl.onClick = proc(c:ClickEvent)=
    echo "Canvas"

  result.Ctl.onDraw = proc(e:DrawEvent) =
    let Cv=e.control.canvas
  
    Cv.areaColor=rgb(255,240,180)
    Cv.fill()

    for (p, label, col) in canvas_data.p:
      Cv.areaColor = col
      Cv.drawEllipseArea(p.re.int - 3, p.im.int - 3, 6, 6)
      Cv.textColor = col
      Cv.drawText(label, p.re.int + 10, p.im.int - 20)
    for (l, label, col) in canvas_data.l:
      Cv.lineColor = col
      Cv.drawLine(l.a.re.int, l.a.im.int, l.b.re.int, l.b.im.int)
      Cv.textColor = col
      Cv.drawText(label, l.a.re.int + 10, l.a.im.int - 20)
    for (s, label, col) in canvas_data.l:
      Cv.lineColor = col
      Cv.drawLine(s.a.re.int, s.a.im.int, s.b.re.int, s.b.im.int)
      Cv.textColor = col
      Cv.drawText(label, s.a.re.int + 10, s.a.im.int - 20)
    for (c, label, col) in canvas_data.c:
      Cv.lineColor = col
      Cv.drawArcOutline(c.p.re.int, c.p.im.int, c.r, 0.0, PI * 2.0)
      Cv.textColor = col
      Cv.drawText(label, (c.p.re + c.r/2.0).int, (c.p.im - c.r/2.0).int)
    for (poly, label, col) in canvas_data.poly:
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

proc addPoint(p:Point, label = "", color = rgb(0, 0, 0)) =
  canvas_data.p.add((p, label, color))
proc addLine(l:Line, label = "", color = rgb(0, 0, 0)) =
  canvas_data.l.add((l, label, color))
proc addSegment(s:Segment, label = "", color = rgb(0, 0, 0)) =
  canvas_data.s.add((s, label, color))
proc addCircle(c:Circle, label = "", color = rgb(0, 0, 0)) =
  canvas_data.c.add((c, label, color))
proc addPolygon(p:Polygon, label = "", color = rgb(0, 0, 0)) =
  canvas_data.poly.add((p, label, color))

proc show(self: Canvas) =
  self.Win.show()
  app.run()

#addPoint(initPoint(200, 150))
#addPoint(initPoint(233, 150))
#addLine(initLine(initPoint(222, 333), initPoint(333, 444)))
#addCircle(initCircle(initPoint(100, 100), 50), "C")
#addPolygon(@[initPoint(111, 222), initPoint(222, 222), initPoint(222, 111), initPoint(111, 111)], "P")

var d = initCanvas()
d.show()
