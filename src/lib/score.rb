class Score
    attr_accessor :scene, :camera, :points

    def initialize(screen_width, screen_height)
        @camera = Mittsu::OrthographicCamera.new(-screen_width / 2.0, screen_width / 2.0, screen_height / 2.0, -screen_height / 2.0, 0.0, 1.0)
        @scene = Mittsu::Scene.new
        @points = 0
        @digits = []
        @maps = []
        dx = 64

        (0..9).each do | index |
            map = Mittsu::ImageUtils.load_texture("images/#{index}.png")
            @maps << map
        end
        sprintf("%03d", @points).chars.each_with_index do |point, index|
            map = @maps[point.to_i]
            material = Mittsu::SpriteMaterial.new(map: map)
            Mittsu::Sprite.new(material).tap do |sprite|
                sprite.scale.set(128, 128, 1.0)
                sprite.position.set(-(screen_width / 2.0) + 64 + dx * index, (screen_height / 2.0) - 64, 0.0)
                @scene.add(sprite)
                @digits << sprite
            end
        end
    end

    def update_points
        sprintf("%03d", @points).chars.each_with_index do |point, index|
            map = @maps[point.to_i]
            sprite = @digits[index]
            sprite.material.set_values(map: map)
            material = Mittsu::SpriteMaterial.new(map: map)
        end
    end
end
