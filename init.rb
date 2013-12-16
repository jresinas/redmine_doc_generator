require 'redmine'
require 'doc_generation_hook'
require 'rods'
require 'odf-report'

Redmine::Plugin.register :redmine_doc_generator do
  name 'Documentation Generator'
  author 'jresinas, ogonzalez'
  description 'Plugin to generate project documentation: Project Plan, Aims Catalog, Functional Analysis and Test Cases.'
  version '0.0.1'
  author_url 'http://www.emergya.es'

  settings :default => { :doc_generation_url => ''}, :partial => 'doc_generation/settings'
end
