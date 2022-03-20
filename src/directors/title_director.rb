require_relative 'base'

module Directors
  # タイトル画面用ディレクター
  class TitleDirector < Base
    # 初期化
    def initialize(screen_width:, screen_height:, renderer:)
      super

      # タイトル画面の次に遷移するシーンのディレクターオブジェクトを用意
      self.next_director = TunnelStageDirector.new(
        screen_width:,
        screen_height:,
        renderer:
      )

      # タイトル画面の登場オブジェクト群を生成
      create_objects
    end

    # １フレーム分の進行処理
    def play
      # 錠剤を斜め方向に回転させる
      @bullet.rotate_x(0.001)
      @bullet.rotate_y(0.001)

      # タイトル文字パネル群をそれぞれ１フレーム分進行させる
      @panels.each(&:play)

      # 説明用文字パネルを１フレーム分進行させる
      @description.play

      # タイトル画面パネルを１フレーム分進行させる
      @background.play
    end

    # キー押下（単発）時のハンドリング
    def on_key_pressed(glfw_key:)
      case glfw_key
      when GLFW_KEY_SPACE # SPACEキー押下で錠剤を発射
        puts 'シーン遷移 → GameDirector'
        transition_to_next_director
      end
    end

    private

    # タイトル画面の登場オブジェクト群を生成
    def create_objects
      # 太陽光をセット
      @sun = LightFactory.create_sun_light
      scene.add(@sun)
      @sun.position.y = 2
      @sun.position.z = 1

      # 背景用の錠剤を作成
      @bullet = MeshFactory.create_bullet
      @bullet.position.z = -0.7
      @bullet.rotation.x = -0.25 * Math::PI
      @bullet.rotation.z = -0.25 * Math::PI
      scene.add(@bullet)

      # タイトル文字パネルの初期表示位置（X座標）を定義
      start_x = -0.4

      start = Time.now
      # 1文字1アニメーションパネルとして作成し、
      # 表示開始タイミングを微妙にずらす
      @panels = []
      threads = %w[u i r s b s t - z].map.with_index do |char, idx|
        Thread.new do
          puts "Beginning loading #{char} (#{idx})"
          @panels << create_title_panel(char, start_x + (idx * 0.1), idx * 2)
          puts "Finished loading #{char} (#{idx})"
        end
      end
      threads.each(&:join)
      @panels.each { |panel| scene.add(panel.mesh) }
      puts "Duration for loading TitlePanel: #{Time.now - start}"

      # 説明文字列用のパネル作成
      # タイトル画面表示開始から180フレーム経過で表示するように調整
      # 位置は適当に決め打ち
      @description = Panel.new(
        width: 1, height: 0.15, start_frame: 900,
        map: TextureFactory.create_title_description
      )
      @description.mesh.position.y = -0.25
      @description.mesh.position.z = -0.5
      scene.add(@description.mesh)

      # タイトル画面の背景パネルを作成
      @background = Panel.new(
        width: 4.07, height: 3.04, start_frame: 0,
        map: TextureFactory.create_title_background
      )
      @background.mesh.position.y = 0
      @background.mesh.position.z = -2
      scene.add(@background.mesh)
    end

    # タイトルロゴ用アニメーションパネル作成
    # タイトル画面の表示開始から30+delay_framesのフレームが経過してから、
    # 120フレーム掛けてアニメーションするよう設定
    def create_title_panel(char, x_pos, delay_frames)
      AnimatedPanel.new(
        start_frame: 30 + delay_frames,
        duration: 120,
        map: TextureFactory.create_letter(char)
      ).tap do |panel|
        panel.mesh.position.x = x_pos
        panel.mesh.position.y = 0.33
        panel.mesh.position.z = -0.5
      end
    end
  end
end
