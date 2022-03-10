require_relative 'base'

module Directors
    # エンディング画面用ディレクター
    class EndingDirector < Base
        attr_accessor :score

        # 初期化
        def initialize(screen_width:, screen_height:, renderer:, score: nil)
            super(screen_width:, screen_height:, renderer:)

            if score.class.name == "Score"
                self.score = score
            else
                self.score = Score.new(screen_width, screen_height)
            end

            # テキスト表示用パネルを生成し、カメラから程よい距離に配置する
            @description = AnimatedPanel.new(
                width: 1,
                height: 0.25,
                start_frame: 15,
                map: TextureFactory.create_ending_description
            )
            @description.mesh.position.z = -0.5
            self.scene.add(@description.mesh)
        end

        # 1フレーム分の進行処理
        def play
            # テキスト表示用パネルを1フレーム分アニメーションさせる
            @description.play
        end

        # キー押下（単発）時のハンドリング
        def on_key_pressed(glfw_key:)
            case glfw_key
                # ESCキー押下で終了する
            when GLFW_KEY_ESCAPE
                puts "クリア!!! Score: #{self.score.points}"
                transition_to_next_director
                # NOTE:
                # self.next_directorがセットされていないので
                # メインループが終わる
            end
        end
    end
end
