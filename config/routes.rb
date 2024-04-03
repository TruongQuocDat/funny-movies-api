# frozen_string_literal: true

Rails.application.routes.draw do
  Rails.application.routes.draw do
    devise_for :users,
               controllers: {
                 sessions: 'users/sessions',
                 registrations: 'users/registrations'
               }
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  namespace :api do
    namespace :v1 do
      resources :videos, only: %i[index create]
    end
  end

  mount LetterOpenerWeb::Engine, at: '/letter_opener_web' if Rails.env.development?
end
