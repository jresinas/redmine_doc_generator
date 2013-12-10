class GeneratorsController < ApplicationController
  unloadable

  def functional_analysis
  end

  def aims_catalog
  end

  def test_cases
  end

  def project_plan
    project = Project.find(params[:project_id])
    expediente = project.name

    project.visible_custom_field_values.each do |element|
      if element.custom_field.name == "Expediente"
        element.value.gsub(", ",",")
        arr = element.value.split(",")
        expediente = arr[arr.length-1]
      end
    end

    template = 'plugins/redmine_doc_generator/templates/Plan_de_Proyecto.ods'
    filename = 'pp_prueba'
    sheet = OdsManager.load(template,filename)

    DocSheets.pp_general(sheet,params[:project_id])
    DocSheets.pp_rrhh(sheet,params[:project_id])
    DocSheets.pp_recursos_tecnicos(sheet,params[:project_id])
    DocSheets.pp_plan_configuracion(sheet,params[:project_id])

    sheet.save()
    send_file 'tmp/'+filename+'.ods' ,:x_sendfile => true, :filename => 'P_PRO-'+expediente+'-Plan_Proyecto.ods'
  end


  def prueba
#    require 'rods'
        puts "@@@@@@@@Abierto!!!"

 #   mySheet=Rods.new("prueba.ods")

 #   mySheet.save();
#    	require 'odf/spreadsheet'

#ODF::Spreadsheet.file("simple_spreadsheet.ods") do
#  table 'My first table from Ruby' do
#    row {cell 'Hello, rODF world!' }
#  end
#end
  end

  def prueba2
    report = ODFReport::Report.new("/home/jresinas/Documentos/odt/plantilla.odt") do |r|
      r.add_field :user_name, params[:api_key]
    end

    report.generate("/home/jresinas/Documentos/odt/plantilla2.odt")

    send_file '/home/jresinas/Documentos/odt/plantilla2.odt', :x_sendfile => true
  end
end
