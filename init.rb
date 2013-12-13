require 'redmine'
require 'doc_generation_hook'
require 'rods'
require 'odf-report'

Redmine::Plugin.register :redmine_doc_generator do
  name 'Doc Generation Hook'
  author 'jresinas, ogonzalez'
  description 'Connect with Doc Generation Servlet'
  version '0.0.1'
  author_url 'http://www.emergya.es'

  settings :default => { :doc_generation_url => ''}, :partial => 'doc_generation/settings'
end
