require 'mittsu'
require_relative 'src/game'

SCREEN_WIDTH = 800
SCREEN_HEIGHT = 600
ASPECT = SCREEN_WIDTH.to_f / SCREEN_HEIGHT.to_f

renderer = Mittsu::OpenGLRenderer.new width: SCREEN_WIDTH, height: SCREEN_HEIGHT, title: 'Sample Game'

game = Game.new(renderer, SCREEN_WIDTH, SCREEN_HEIGHT)

renderer.window.run do
  game.play
end
