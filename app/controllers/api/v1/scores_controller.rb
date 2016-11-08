module Api
  module V1
    class ScoresController < Api::V1::ApplicationController

      ##
      # 获取成绩属性列表
      #
      # GET /api/v1/scores
      #
      def index
        optional! :except
        except = params[:except].present? ? params[:except] : 0
        score_attributes = ScoreAttribute.where.not(id: except).select(:id, :name, :write_type)
        render json: score_attributes
      end

      # 获取某一项目的成绩属性
      # POST /api/v1/scores/upload_scores

      def upload_scores
        requires! :event_id, type: Integer
        requires! :schedule_id, type: Integer
        requires! :kind, type: Integer, desc: '对抗/评分'
        requires! :th, type: Integer, desc: '第几场'
        requires! :team1_id, type: Integer, desc: '队伍1'
        requires! :score_attribute, type: Hash, desc: '成绩属性'
        requires! :last_score, values: %w(0 1), desc: '是否是最终成绩'
        optional! :note, type: String, desc: '备注'
        requires! :device_no, type: String, desc: '设备号'
        requires! :confirm_sign, type: File, desc: '确认签名'
        requires! :operator_id, type: Integer, desc: '操作员'
        result = CompetitionService.post_team_scores(params[:event_id], params[:schedule_id], params[:kind], params[:th], params[:team1_id], params[:score_attribute], params[:last_score], params[:note], params[:device_no], params[:confirm_sign], params[:operator_id])
        render json: result
      end

    end
  end
end
