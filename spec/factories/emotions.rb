# frozen_string_literal: true

FactoryBot.define do
  factory :emotion do
    kind { 'like' }
    user
    
    trait :like do
      kind { 'like' }
    end
    
    trait :love do
      kind { 'love' }
    end
    
    trait :angry do
      kind { 'angry' }
    end
    
    trait :dislike do
      kind { 'dislike' }
    end
    
    trait :for_video do
      association :emotionable, factory: :video
    end
    
    trait :for_comment do
      association :emotionable, factory: :comment
    end
  end
end