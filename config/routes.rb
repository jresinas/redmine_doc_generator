RedmineApp::Application.routes.draw do
  match '/generators/functional_analysis/:project_id' => 'generators#functional_analysis'
  match '/generators/aims_catalog/:project_id' => 'generators#aims_catalog'
  match '/generators/test_cases/:project_id' => 'generators#test_cases'
  match '/generators/project_plan/:project_id' => 'generators#project_plan'
  match '/generators/prueba/:project_id' => 'generators#prueba'
end
