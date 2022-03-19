# 画面上に表示でき固有の時間をカウントダウンする時計
class CountDownClock
  FPS = 60
  DEFAULT_TIMELIMIT = 30
  N_DIGITS = 3

  attr_accessor :scene, :camera
  attr_reader :time_left, :expired

  def initialize(screen_width, screen_height, time_left: DEFAULT_TIMELIMIT)
    @camera = Mittsu::OrthographicCamera.new(
      -screen_width / 2.0, screen_width / 2.0, screen_height / 2.0, -screen_height / 2.0, 0.0, 1.0
    )
    @scene = Mittsu::Scene.new
    @time_left = time_left
    @time_frame_spent = 0
    @expired = false
    ds = 32

    @maps = (0..9).map do |index|
      Mittsu::ImageUtils.load_texture("images/#{index}.png")
    end
    @digits = format("%0#{N_DIGITS}d", @time_left).chars.map.with_index do |point, index|
      map = @maps[point.to_i]
      material = Mittsu::SpriteMaterial.new(map:)
      Mittsu::Sprite.new(material).tap do |sprite|
        sprite.scale.set(2 * ds, 2 * ds, 1.0)
        sprite.position.set(
          (screen_width / 2.0) - (ds * (1 + N_DIGITS)) + (ds * index),
          (screen_height / 2.0) - ds,
          0.0
        )
        @scene.add(sprite)
      end
    end
  end

  def update_by_frame
    return if @expired

    @time_frame_spent += 1
    return unless (@time_frame_spent % FPS).zero?

    @time_left -= 1
    @expired = @time_left <= 0
    update_material
  end

  def update_material
    format("%0#{N_DIGITS}d", @time_left % (10**N_DIGITS)).chars.each_with_index do |point, index|
      map = @maps[point.to_i]
      sprite = @digits[index]
      sprite.material.set_values(map:)
    end
  end
end

Clock = CountDownClock
