require_relative 'base'

module Directors
  # エンディング画面用ディレクター
  class EndingDirector < Base
    # 初期化
    def initialize(screen_width:, screen_height:, renderer:, score: nil)
      super(screen_width:, screen_height:, renderer:)

      @score = if score.instance_of?(Score)
        score
               else
        Score.new(screen_width, screen_height)
               end

      # テキスト表示用パネルを生成し、カメラから程よい距離に配置する
      @description = AnimatedPanel.new(
        width: 1,
        height: 0.25,
        start_frame: 15,
        map: TextureFactory.create_ending_description
      )
      @description.mesh.position.z = -0.5
      scene.add(@description.mesh)

      # タイトル画面の背景パネルを作成
      @background = Panel.new(
        width: 10, height: 10, start_frame: 0,
        color: 0x444444
      )
      @background.mesh.position.y = 0
      @background.mesh.position.z = -2
      scene.add(@background.mesh)
    end

    # 1フレーム分の進行処理
    def play
      postinitialize

      # テキスト表示用パネルを1フレーム分アニメーションさせる
      @description.play

      @background&.play

      # NOTE: ``score.update_points`` を呼び出す必要はない
    end

    # キー押下（単発）時のハンドリング
    def on_key_pressed(glfw_key:)
      case glfw_key
        # ESCキー押下で終了する
      when GLFW_KEY_ESCAPE
        puts "クリア!!! Score: #{@score.points}"
        transition_to_next_director
        # NOTE: -|
        #   self.next_directorがセットされていないので
        #   メインループが終わる
        predeinitialize
      end
    end

    def postinitialize
        return if postinitialized

        # Skymapを使用するために自動的な切り替えをしなくする
        renderer.auto_clear = false

        self.postinitialized = true
    end

    def predeinitialize
        return if predeinitialized

        # 自動的な切り替えをするようにする
        renderer.auto_clear = true

        self.predeinitialized = true
    end

    def render
      # ending-message とスコアを表示
      renderer.clear
      renderer.render(scene, camera)
      renderer.render(@score.scene, @score.camera) if @score&.scene && @score&.camera
    end
  end
end
