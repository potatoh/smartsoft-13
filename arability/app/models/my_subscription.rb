class MySubscription < ActiveRecord::Base
  attr_accessible :developer_id, :word_add, :word_follow, :word_search
  belongs_to :developer
  belongs_to :subscription_model

#author:Noha hesham
# Description:
#  takes the developer id and checks wether the developer's word search 
#  limit has been reached ,if its not then it is greater than zero and permission 
#  is given to search for words by returning true else 
#  return false and permission denied.
# params:
#  developer id
# success:
#  permission is given if the developer didnt exceed the search limit
# fail:
#  none
  class << self
   def search_word_permission(dev_id) 
    my_subscription = 
     MySubscription.joins(:developer).where(:developer_id => dev_id).first
  	if my_subscription.word_search > 0 
  		return true
  	else
  		return false
    end
   end

# author:Noha hesham
# Description:
#  takes the developer id and checks wether the developer's word add limit has been 
#  reached ,if its not then it is greater than zero and permission is given to add 
#  and visual stats for words by returning true else return false
#  and permission denied.
# params:
#  developer id
# success:
#  permission is given if the developer didnt exceed the add limit
# fail:
#  none
   def add_word_permission(dev_id)
     my_subscription = 
      MySubscription.joins(:developer).where(:developer_id => dev_id).first
  	if my_subscription.word_add > 0
  		return true
  	else 
  		return false
    end  	
   end
  
# author:Noha hesham
# Description:
#  takes the developer id and checks wether the developer's word follow 
#  limit has been reached ,if its not then it is greater than zero 
#  and permission is given to follow words by returning true else 
#  return false and permission denied.
# params:
#  developer id
# success: 
#  permission is given if the developer didnt exceed the follow word limit
# fail:
#   none
   def follow_word_permission(dev_id)
    my_subscription = 
     MySubscription.joins(:developer).where(:developer_id => dev_id).first
  	if my_subscription.word_follow > 0
  	  return true
  	else
  		return false
    end
   end
  end  
end

