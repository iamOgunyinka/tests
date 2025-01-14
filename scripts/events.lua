-- Copyright (C) 2021  Igara Studio S.A.
--
-- This file is released under the terms of the MIT license.
-- Read LICENSE.txt for more information.

dofile('./test_utils.lua')

-- Test app.events
do
  local i = 0
  local listener = app.events:on('sitechange',
                                 function() i = i + 1 end)
  assert(i == 0)
  local a = Sprite(32, 32)
  expect_eq(a, app.activeSprite)
  expect_eq(1, i)
  local b = Sprite(32, 32)
  expect_eq(b, app.activeSprite)
  expect_eq(2, i)
  app.activeSprite = a
  expect_eq(3, i)
  app.events:off(listener)
  app.activeSprite = b
  expect_eq(3, i)
end

do
  local pref = app.preferences
  pref.color_bar.fg_color = Color(0, 0, 0)
  pref.color_bar.bg_color = Color(0, 0, 0)

  local fg, bg = 0, 0
  local a = app.events:on('fgcolorchange', function() fg = fg + 1 end)
  local b = app.events:on('bgcolorchange', function() bg = bg + 1 end)
  assert(fg == 0)
  assert(bg == 0)

  pref.color_bar.fg_color = Color(255, 0, 0)
  pref.color_bar.bg_color = Color(255, 0, 0)
  assert(fg == 1)
  assert(bg == 1)
  pref.color_bar.fg_color = Color(255, 0, 0) -- No change (same color)
  assert(fg == 1)
  pref.color_bar.fg_color = Color(0, 0, 0)
  assert(fg == 2)
  app.events:off(a)
  app.events:off(b)
  pref.color_bar.fg_color = Color(255, 0, 0)
  assert(fg == 2)
end

-- Test Sprite.events
do
  local spr = Sprite(32, 64)
  local changes = 0
  function incChanges() changes = changes + 1 end
  spr.events:on('change', incChanges)
  expect_eq(0, changes)
  spr.width = 64
  expect_eq(1, changes)
  app.undo()
  expect_eq(2, changes)
  app.redo()
  expect_eq(3, changes)
  spr.events:off(incChanges)
  app.undo()
  expect_eq(3, changes)
end

-- Multiple listeners
do
  local spr = Sprite(2, 2)
  local ai, bi = 0, 0
  function a() ai = ai + 1 end
  function b() bi = bi + 1 end

  spr.events:on('change', a)
  spr.events:on('change', b)
  spr.width = 4
  expect_eq(1, ai)
  expect_eq(1, bi)

  spr.events:off(a)
  spr.width = 8
  expect_eq(1, ai)
  expect_eq(2, bi)

  spr.events:off(b)
  spr.width = 16
  expect_eq(1, ai)
  expect_eq(2, bi)
end

-- Avoid removing invalid listener when we use Events:off(function)
do
  local spr = Sprite(2, 2)

  local i = 0
  function inc() i = i + 1 end
  spr.events:on('change', inc)

  spr.width = 4
  expect_eq(1, i)

  app.events:off(inc)
  spr.width = 8

  -- If this fails is because app.events:off(inc) removed the sprite
  -- listener instead of doing nothing.
  expect_eq(2, i)
end
