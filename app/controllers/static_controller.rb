class StaticController < ApplicationController
  def welcome
    @title = "Welcome"
  end

  def about
    @title = "About"
  end

  def community_guidelines
    @title = "Community Guidelines"
  end

  def faq
    @title = "FAQ"
  end
end
