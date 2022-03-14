class Clock
  @@FPS = 60
  @@DEFAULT_TIMELIMIT = 30
  @@N_DIGITS = 3

  attr_accessor :scene, :camera, :time_left, :expired

  def initialize(screen_width, screen_height, time_left: @@DEFAULT_TIMELIMIT)
    @camera = Mittsu::OrthographicCamera.new(-screen_width / 2.0, screen_width / 2.0, screen_height / 2.0,
                                             -screen_height / 2.0, 0.0, 1.0)
    @scene = Mittsu::Scene.new
    @time_left = time_left
    @time_frame_spent = 0
    self.expired = false
    @digits = []
    @maps = []
    ds = 32

    (0..9).each do |index|
      map = Mittsu::ImageUtils.load_texture("images/#{index}.png")
      @maps << map
    end
    format("%0#{@@N_DIGITS}d", @time_left).chars.each_with_index do |point, index|
      map = @maps[point.to_i]
      material = Mittsu::SpriteMaterial.new(map:)
      Mittsu::Sprite.new(material).tap do |sprite|
        sprite.scale.set(2 * ds, 2 * ds, 1.0)
        sprite.position.set(
          (screen_width / 2.0) - (ds * (1 + @@N_DIGITS)) + (ds * index),
          (screen_height / 2.0) - ds,
          0.0
        )
        @scene.add(sprite)
        @digits << sprite
      end
    end
  end

  def update_by_frame
    return if expired

    @time_frame_spent += 1
    return if @time_frame_spent % @@FPS != 0

    @time_left -= 1
    self.expired = @time_left <= 0
    update_material
  end

  def update_material
    format("%0#{@@N_DIGITS}d", @time_left % (10**@@N_DIGITS)).chars.each_with_index do |point, index|
      map = @maps[point.to_i]
      sprite = @digits[index]
      sprite.material.set_values(map:)
    end
  end
end
