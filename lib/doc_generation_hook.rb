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
        url = '#' #Setting.plugin_redmine_doc_generator['doc_generation_url']
        content = content_tag(:h3, I18n.t("hook_title"))
        content << content_tag(:p, I18n.t("hook_instructions").html_safe)
#        content << content_tag(:a, "Análisis Funcional" , :href => url+'?doc=1&project_id='+context[:project].id.to_s+'&api_key="'+User.current.api_key+'"')
 #       content << link_to("Análisis Funcional" , {:controller => 'generators', :action => 'prueba', :project_id => context[:project].id.to_s, :api_key => User.current.api_key})
 #       content << "<br/>"
        content << link_to(I18n.t("label_functional_analysis"), {:controller => 'generators', :action => 'functional_analysis', :project_id => context[:project].id.to_s})
        content << "<br/>".html_safe
        content << link_to(I18n.t("label_aims_catalog"), {:controller => 'generators', :action => 'aims_catalog', :project_id => context[:project].id.to_s})
        content << "<br/>".html_safe
        content << link_to(I18n.t("label_test_cases"), {:controller => 'generators', :action => 'test_cases', :project_id => context[:project].id.to_s})
        content << "<br/>".html_safe
        content << link_to(I18n.t("label_project_plan"), {:controller => 'generators', :action => 'project_plan', :project_id => context[:project].id.to_s})
        content << "<br/>".html_safe
    #    content << content_tag(:a, "Catálogo de Objetivos" , :href => url+'?doc=2&project_id='+context[:project].id.to_s+'&api_key="'+User.current.api_key+'"')
    #    content << "<br/>"
    #    content << content_tag(:a, "Casos de Prueba" , :href => url+'?doc=3&project_id='+context[:project].id.to_s+'&api_key="'+User.current.api_key+'"')
    #    content << "<br/>"
    #    content << content_tag(:a, "Plan de Proyecto" , :href => Setting.plugin_redmine_doc_generator['pp_generation_url']+'?project_id='+(context[:project].id).to_s)
    #    content << "<br/>"
        #TODO: Meter un select con los documentos del proyecto que sean de tipo Plantilla, y un botón 'Generar' que envíe el id del documento al Servlet. Allí, coger el documento a partir del attachment_storage_path y procesarlo
        #content << content_tag(:select, "Plan de Proyecto" , :href => url+'?doc=4&project_id='+context[:project].id.to_s+'&api_key="'+User.current.api_key+'"')

        return content_tag(:div, content, :class  => 'box')
      end
    end
  end

end
