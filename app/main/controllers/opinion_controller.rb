class OpinionController < Volt::ModelController
  
  def add_opinion
    page._opinions << { name: page._new_opinion }
    page._new_opinion = ''
  end
  
end