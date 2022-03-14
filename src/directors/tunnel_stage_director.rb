require_relative 'base'

module Directors
  # トンネルのシーンのディレクター
  class TunnelStageDirector < Base
    @@CAMERA_ROTATE_SPEED_X = 0.01
    @@CAMERA_ROTATE_SPEED_Y = 0.01
    @@NUM_MAX_ENEMIES = 20
    @@DEFAULT_ASSET_DIRECTORY = File.join File.dirname(__FILE__), '..', '..', 'images'
    @@TONNEL_SHAPE = { width: 5, height: 5, depth: 100 }

    attr_accessor :skybox_scene, :skybox_camera

    # 初期化
    def initialize(
      screen_width:,
      screen_height:,
      renderer:,
      floor: true
    )

    # current_directorがデフォルトで自分自身を返すように設定
    self.current_director = self
    self.renderer = renderer

    # 画面解像度情報・アスペクト比を設定
    self.screen_width = screen_width
    self.screen_height = screen_height
    aspect = screen_width / screen_height.to_f

    # 当該ディレクターが扱うシーンとカメラを作成
    self.scene = Mittsu::Scene.new
    self.skybox_scene = Mittsu::Scene.new
    self.camera = Mittsu::PerspectiveCamera.new(75.0, aspect, 0.1, 1000.0)
    self.skybox_camera = Mittsu::PerspectiveCamera.new(75.0, aspect, 1.0, 100.0)

    create_tunnel(floor:)

    self.renderer.window.on_resize do |width, height|
      self.renderer.set_viewport(0, 0, width, height)
      camera.aspect = skybox_camera.aspect = width.to_f / height
      camera.update_projection_matrix
      skybox_camera.update_projection_matrix
    end

    @score = Score.new screen_width, screen_height
    @clock = Clock.new screen_width, screen_height

    # トンネルのシーンの次に遷移するシーンのディレクターオブジェクトを用意
    self.next_director = EndingDirector.new(
      screen_width:,
      screen_height:,
      renderer:,
      score: @score
    )

    # トンネルのシーンの登場オブジェクト群を生成
    create_objects

    # ボスを生成
    @boss_enemy = BossEnemy.new(x: 0.0, y: 40.0, z: -100.0)
    scene.add(@boss_enemy.mesh)

    # 弾丸の詰め合わせ用配列
    @bullets = []

    # 敵の詰め合わせ用配列
    @enemies = []

    # 現在のフレーム数をカウントする
    @frame_counter = 0

    @camera_rotate_x = 0.0
    @camera_rotate_y = 0.0
    end

  # １フレーム分の進行処理
    def play
      if @clock&.expired
        transition_to_next_director
        return
      end

      postinitialize

      # 壁を少しずつ移動させ、体内を移動してる雰囲気を醸し出す
      @floor&.position&.z += 0.1
      @tunnel&.position&.z += 0.1

      # 現在発射済みの弾丸を一通り動かす
      @bullets.each(&:play)

      # 現在登場済みの敵を一通り動かす
      @boss_enemy.play
      @enemies.each(&:play)

      # 各弾丸について当たり判定実施
      @bullets.each { |bullet| hit_any_enemies(bullet) }

      # 消滅済みの弾丸及び敵を配列とシーンから除去(わざと複雑っぽく記述しています)
      rejected_bullets = []
      @bullets.delete_if { |bullet| bullet.expired ? rejected_bullets << bullet : false }
      rejected_bullets.each { |bullet| scene.remove(bullet.mesh) }
      rejected_enemies = []
      @enemies.delete_if { |enemy| enemy.expired ? rejected_enemies << enemy : false }
      rejected_enemies.each { |enemy| scene.remove(enemy.mesh) }

      # 一定のフレーム数経過毎に規定の数以下なら敵キャラを出現させる
      if (@frame_counter % 180).zero? && (@enemies.length < @@NUM_MAX_ENEMIES)
        enemy = Enemy.new
        @enemies << enemy
        scene.add(enemy.mesh)
      end

      @frame_counter += 1

      camera.rotate_x(@@CAMERA_ROTATE_SPEED_X) if renderer.window.key_down?(GLFW_KEY_UP)
      camera.rotate_x(-@@CAMERA_ROTATE_SPEED_X) if renderer.window.key_down?(GLFW_KEY_DOWN)
      camera.rotate_y(@@CAMERA_ROTATE_SPEED_Y) if renderer.window.key_down?(GLFW_KEY_LEFT)
      camera.rotate_y(-@@CAMERA_ROTATE_SPEED_Y) if renderer.window.key_down?(GLFW_KEY_RIGHT)

      @score&.update_points
      @clock&.update_by_frame
    end

    def postinitialize
      return if postinitialized

      # Skymapを使用するために自動的な切り替えをしなくする
      renderer.auto_clear = false
      renderer.shadow_map_enabled = true
      renderer.shadow_map_type = Mittsu::PCFSoftShadowMap

      self.postinitialized = true
    end

    def predeinitialize
      return if predeinitialized

      # 自動的な切り替えをするようにする
      renderer.auto_clear = true
      renderer.shadow_map_enabled = false

      self.predeinitialized = true
    end

  # キー押下（単発）時のハンドリング
    def on_key_pressed(glfw_key:)
      case glfw_key

      when GLFW_KEY_ESCAPE
        puts "シーン遷移 → #{@next_director.class.name or 'nothing'}"
        transition_to_next_director

        # SPACEキー押下で弾丸を発射
      when GLFW_KEY_SPACE
        shoot
      end
    end

    def transition_to_next_director
      super
      predeinitialize
    end

    def render
      skybox_camera.quaternion.copy(
        camera.get_world_quaternion
      )

      renderer.clear
      renderer.render(
        skybox_scene,
        skybox_camera
      )
      renderer.clear_depth
      renderer.render(
        scene,
        camera
      )

      renderer.render(@score.scene, @score.camera) if @score
      renderer.render(@clock.scene, @clock.camera) if @clock
    end

    private

  # トンネルを設置
    def create_tunnel(floor: nil)
      cube_map_texture = Mittsu::ImageUtils.load_texture_cube(
        %w[rt lf up dn bk ft].map do |_path|
          File.join @@DEFAULT_ASSET_DIRECTORY, 'desert.png'
        end
      )

      shader = Mittsu::ShaderLib[:cube]
      shader.uniforms['tCube'].value = cube_map_texture

      skybox_material = Mittsu::ShaderMaterial.new(
        {
          fragment_shader: shader.fragment_shader,
          vertex_shader: shader.vertex_shader,
          uniforms: shader.uniforms,
          depth_write: false,
          side: Mittsu::BackSide
        }
      )

      @skybox = Mittsu::Mesh.new(
        Mittsu::BoxGeometry.new(
          @@TONNEL_SHAPE[:width],
          @@TONNEL_SHAPE[:height],
          @@TONNEL_SHAPE[:depth]
        ),
        skybox_material
      )
      skybox_scene.add(@skybox)

      def set_repeat(tex)
        tex.wrap_s = Mittsu::RepeatWrapping
        tex.wrap_t = Mittsu::RepeatWrapping
        tex.repeat.set(1000, 1000)
      end

      if floor.instance_of?(Mittsu::Mesh)
        @floor = floor
      elsif floor
        @floor = Mittsu::Mesh.new(
          Mittsu::BoxGeometry.new(1.0, 1.0, 1.0),
          Mittsu::MeshPhongMaterial.new(
            map: Mittsu::ImageUtils.load_texture(
              File.join(@@DEFAULT_ASSET_DIRECTORY, 'desert.png')
            ).tap { |t| set_repeat(t) },
            normal_map: Mittsu::ImageUtils.load_texture(
              File.join(@@DEFAULT_ASSET_DIRECTORY, 'desert-normal.png')
            ).tap { |t| set_repeat(t) }
          )
        )
        @floor.scale.set(10_000.0, 10.0, 10_000.0)
        @floor.position.y = -8.0
      else
        @floor = nil
      end
      scene.add(@floor) if @floor
    end

    # トンネルのシーンの登場オブジェクト群を生成
    def create_objects(tunnel: nil)
      # 太陽光を設置
      @sunlight = Mittsu::HemisphereLight.new(0xd3c0e8, 0xd7ad7e, 0.7)
      scene.add(@sunlight)
      @sunlight.position.y = 0.9
      @sun = LightFactory.create_sun_light
      scene.add(@sun)
      @sun.position.y = 0.9

      @light = Mittsu::SpotLight.new(0xffffff, 1.0)
      @light.position.set(0.0, 30.0, -30.0)

      @light.cast_shadow = true
      @light.shadow_darkness = 0.5

      @light.shadow_map_width = 2048
      @light.shadow_map_height = 2048

      @light.shadow_camera_near = 1.0
      @light.shadow_camera_far = 100.0
      @light.shadow_camera_fov = 60.0

      @light.shadow_camera_visible = false
      scene.add(@light)

      # トンネルを設置
      if tunnel
        @tunnel = MeshFactory.create_tunnel
        @tunnel.rotate_y(-90)
        scene.add(@tunnel)
      else
        @tunnel = nil
      end
    end

    # 弾丸発射
    def shoot
      # 現在カメラが向いている方向を進行方向とし、進行方向に対しBullet::SPEED分移動する単位単位ベクトルfを作成する
      f = Mittsu::Vector4.new(0, 0, 1, 0)
      f.apply_matrix4(camera.matrix).normalize
      f.multiply_scalar(Bullet::SPEED)

      # 弾丸オブジェクト生成
      bullet = Bullet.new(f)
      scene.add(bullet.mesh)
      @bullets << bullet
    end

    # 弾丸と敵の当たり判定
    def hit_any_enemies(bullet)
      return if bullet.expired

      @enemies.each do |enemy|
        next if enemy.expired

        distance = bullet.position.distance_to(enemy.position)
        next unless distance < 0.2

        puts 'Hit!'
        @score&.points += 1
        bullet.expired = true
        enemy.expired = true
      end
    end
  end
end
