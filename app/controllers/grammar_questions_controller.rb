# encoding: utf-8
require 'nokogiri'
class GrammarQuestionsController < ApplicationController
  def index

  end

  def new
    @unit = GrammarGroup.order("sequence_number asc")
  end

  def create

  end
end
