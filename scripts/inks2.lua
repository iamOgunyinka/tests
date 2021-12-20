
dofile('./test_utils.lua')


function perform_test(pc, ec, image, ink_)
  app.useTool{ tool="spray", color=pc, points={Point(4,4)},
               ink=ink_}
  local hasTouch = false
  for it in image:pixels() do
    if it() == ec then
      hasTouch = true
      break
    end
  end
  assert(hasTouch)
end


function paint_bg(image, bgColor)
  -- draw the same color all over the canvas
  for x=0, image.width-1 do
    for y=0,image.height-1 do
      image:drawPixel(x, y, bgColor)
    end
  end
end


function test_alpha_ink(image)
  local paintColor = 0
  local expColor = 2

  paint_bg(image, expColor)
  -- test transparent color
  perform_test(paintColor, expColor, image, Ink.ALPHA_COMPOSITING)
end


function test_simple_ink(image)
  -- paint with one color, expect to see the color
  local paintColor = 1
  local expectedColor = 1

  -- paint the canvas
  paint_bg(image, 4)

  -- test opaque color
  perform_test(paintColor, expectedColor, image, Ink.SIMPLE)

  paintColor = 0
  expectedColor = 0

  -- repaint the canvas pink
  paint_bg(image, 3)

  -- test transparent color
  perform_test(paintColor, expectedColor, image, Ink.SIMPLE)
end


function main()
  local size=7
  local sprite=Sprite(size+1, size+1, ColorMode.INDEXED)
  assert(sprite.layers[1].isTransparent)

  local pal = sprite.palettes[1]
  pal:setColor(1, Color(255, 0, 0))
  pal:setColor(2, Color(255, 192, 192))
  pal:setColor(3, Color(192, 255, 128))
  pal:setColor(4, Color(12, 25, 18))
  pal:resize(5)

  assert(sprite.layers[1].opacity == 255)
  assert(pal:getColor(0).alpha == 255)
  assert(pal:getColor(0).red == 0)
  assert(pal:getColor(0).green == 0)
  assert(pal:getColor(0).blue == 0)


  local image=sprite.cels[1].image
  app.preferences.tool(app.activeTool).spray.width = 16
  app.preferences.tool(app.activeTool).spray.speed = 32

  -- test with Simple Ink
  test_simple_ink(image)

  -- test with Alpha Ink
  test_alpha_ink(image)
end


main()

