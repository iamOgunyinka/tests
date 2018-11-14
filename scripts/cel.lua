-- Copyright (C) 2018  David Capello
--
-- This file is released under the terms of the MIT license.
-- Read LICENSE.txt for more information.

local s = Sprite(32, 64)
assert(#s.layers == 1)
assert(#s.cels == 1)

local c = s.cels[1]
assert(c.sprite == s)
assert(c.layer == s.layers[1])
assert(c.frame == 1)
assert(c.image)
assert(c.bounds == Rectangle(0, 0, 32, 64))
assert(c.position == Point(0, 0))
assert(c.color == Color())
assert(c.data == "")

c.color = Color{ r=255, g=100, b=20 }
c.data = "test"
assert(c.color == Color{ r=255, g=100, b=20 })
assert(c.data == "test")

c.position = Point(2, 4)
assert(c.position == Point(2, 4))
assert(c.bounds == Rectangle(2, 4, 32, 64))