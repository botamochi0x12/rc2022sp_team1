require_relative 'bullet'

class Player
  attr_accessor :mesh

  def initialize(x, y, z, renderer, scene, score)
    @mesh = Mittsu::Mesh.new(
      Mittsu::BoxGeometry.new(1.0, 1.0, 1.0),
      Mittsu::MeshBasicMaterial.new(color: 0x00ff00)
    )
    @mesh.position.set(x, y, z)

    @renderer = renderer
    @scene = scene
    
    @bullets = []
    @renderer.window.on_key_typed do |key|
      case key
      when GLFW_KEY_SPACE
        bullet = Bullet.new(@mesh.position.x, @mesh.position.y, @mesh.position.z)
        @scene.add(bullet.mesh)
        @bullets << bullet
      end
    end
    
    @score = score
  end

  def update
    @mesh.position.y += 0.1 if @renderer.window.key_down?(GLFW_KEY_UP)
    @mesh.position.y -= 0.1 if @renderer.window.key_down?(GLFW_KEY_DOWN)
    @mesh.position.x -= 0.1 if @renderer.window.key_down?(GLFW_KEY_LEFT)
    @mesh.position.x += 0.1 if @renderer.window.key_down?(GLFW_KEY_RIGHT)
    @mesh.position.z += 0.1 if @renderer.window.key_down?(GLFW_KEY_Z)
    @mesh.position.z -= 0.1 if @renderer.window.key_down?(GLFW_KEY_A)

    @bullets.each do |bullet|
      bullet.update
    end
  end

  def check(enemies)
    enemies.each do |enemy|
      @bullets.each do |bullet|
        if bullet.mesh.position.distance_to(enemy.mesh.position) <= 0.1 + 0.5
          enemy.mesh.material.color.set(0xff0000)
          @scene.remove(bullet.mesh)
          @bullets.delete(bullet)
          @score.points += 1
        else
          # 衝突してない
        end
      end
    end
  end
end
