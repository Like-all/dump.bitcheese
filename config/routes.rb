Rails.application.routes.draw do
	slug_template = /[a-z]+/
	file_template = %r|[^/\s]+|
	# The priority is based upon order of creation: first created -> highest priority.
	# See how all your routes lay out with "rake routes".

	# You can have the root of your site routed with "root"
	root 'application#index'
	
	get 'files/:slug/:filename', to: 'files#download', slug: slug_template, filename: file_template
	get 'files/:filename', to: 'files#download', filename: file_template
	get 'files/:filename/preview', to: 'files#preview', filename: file_template
	get 'images/:slug/:filename', to: 'images#download', slug: slug_template, filename: file_template
	get 'images/:filename', to: 'images#download', filename: file_template
	get 'images/:slug/thumb/:filename', to: 'images#thumb', slug: slug_template, filename: file_template
	get 'images/:slug/:filename/preview', to: 'images#preview', slug: slug_template, filename: file_template
	get 'files/:slug/:filename/preview', to: 'files#preview', slug: slug_template, filename: file_template
	
	post 'upload-file', to: 'files#upload'
	post 'upload-image', to: 'images#upload'
	# /
	# Example of regular route:
	#   get 'products/:id' => 'catalog#view'

	# Example of named route that can be invoked with purchase_url(id: product.id)
	#   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

	# Example resource route (maps HTTP verbs to controller actions automatically):
	#   resources :products

	# Example resource route with options:
	#   resources :products do
	#     member do
	#       get 'short'
	#       post 'toggle'
	#     end
	#
	#     collection do
	#       get 'sold'
	#     end
	#   end

	# Example resource route with sub-resources:
	#   resources :products do
	#     resources :comments, :sales
	#     resource :seller
	#   end

	# Example resource route with more complex sub-resources:
	#   resources :products do
	#     resources :comments
	#     resources :sales do
	#       get 'recent', on: :collection
	#     end
	#   end

	# Example resource route with concerns:
	#   concern :toggleable do
	#     post 'toggle'
	#   end
	#   resources :posts, concerns: :toggleable
	#   resources :photos, concerns: :toggleable

	# Example resource route within a namespace:
	#   namespace :admin do
	#     # Directs /admin/products/* to Admin::ProductsController
	#     # (app/controllers/admin/products_controller.rb)
	#     resources :products
	#   end
end
