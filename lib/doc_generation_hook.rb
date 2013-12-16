#require 'dispatcher'

if Rails::VERSION::MAJOR >= 3
  ActionDispatch::Callbacks.to_prepare do
    # use require_dependency if you plan to utilize development mode
    require_dependency 'project'
    Project.send(:include, DocGenerationHook)
  end
else
  Dispatcher.to_prepare do
    require_dependency 'project'
    Project.send(:include, DocGenerationHook)
  end
end

module DocGenerationHook

  def self.included(base) # :nodoc:
    #unloadable

    base.send(:include, InstanceMethods)


  end


  module InstanceMethods
    # Para no tener que reiniciar el servidor cada vez que se modifica algo
    #unloadable

    class ProjectsDocGenerationHookListener < Redmine::Hook::ViewListener
      def view_projects_show_right(context)
        content = content_tag(:h3, I18n.t("hook_title"))
        content << content_tag(:p, I18n.t("hook_instructions").html_safe)

        content << link_to(I18n.t("label_functional_analysis"), {:controller => 'generators', :action => 'functional_analysis', :project_id => context[:project].id.to_s})
        content << "<br/>".html_safe
        content << link_to(I18n.t("label_aims_catalog"), {:controller => 'generators', :action => 'aims_catalog', :project_id => context[:project].id.to_s})
        content << "<br/>".html_safe
        content << link_to(I18n.t("label_test_cases"), {:controller => 'generators', :action => 'test_cases', :project_id => context[:project].id.to_s})
        content << "<br/>".html_safe
        content << link_to(I18n.t("label_project_plan"), {:controller => 'generators', :action => 'project_plan', :project_id => context[:project].id.to_s})
        content << "<br/>".html_safe
 
        return content_tag(:div, content, :class  => 'box')
      end
    end
  end

end
