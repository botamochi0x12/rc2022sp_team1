# 画面上に表示でき得点を保持するスコアボード
class Score
  N_DIGITS = 3

  attr_accessor :scene, :camera, :points

  def initialize(screen_width, screen_height, points: 0)
    @camera = Mittsu::OrthographicCamera.new(
      -screen_width / 2.0, screen_width / 2.0,
      screen_height / 2.0, -screen_height / 2.0,
      0.0, 1.0
    )
    @scene = Mittsu::Scene.new
    @points = points
    dx = 64

    @maps = (0..9).map do |index|
      Mittsu::ImageUtils.load_texture("images/#{index}.png")
    end
    @digits = format("%0#{N_DIGITS}d", @points).chars.map.with_index do |point, index|
      map = @maps[point.to_i]
      material = Mittsu::SpriteMaterial.new(map:)
      Mittsu::Sprite.new(material).tap do |sprite|
        sprite.scale.set(128, 128, 1.0)
        sprite.position.set(
          -(screen_width / 2.0) + 64 + (dx * index),
          (screen_height / 2.0) - 64,
          0.0
        )
        @scene.add(sprite)
      end
    end
  end

  def update_points
    format("%0#{N_DIGITS}d", @points).chars.each_with_index do |point, index|
      map = @maps[point.to_i]
      sprite = @digits[index]
      sprite.material.set_values(map:)
    end
  end
end
