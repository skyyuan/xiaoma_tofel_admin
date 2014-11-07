# encoding: utf-8
class GrammarGroupsController < ApplicationController
  def new
    @types = GrammarType.all
  end

  def create
    if params[:unit].present? && params[:type_id].present?
      group = GrammarGroup.new
      group.sequence_number = params[:unit]
      group.grammar_type_id = params[:type_id]
      if group.save
        redirect_to new_grammar_group_path, notice: "保存成功!"
      else
        redirect_to new_grammar_group_path, notice: group.errors.full_messages
      end
    else
      redirect_to new_grammar_group_path, notice: "类型和Unit不能为空!"
    end
  end
end