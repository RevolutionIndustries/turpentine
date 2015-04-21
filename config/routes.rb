Rails.application.routes.draw do
  get 'esi/partials/:partial'      => 'turpentine/esi#view', as: :partial
  get 'esi/user-partials/:partial' => 'turpentine/esi#view', as: :user_partial
end