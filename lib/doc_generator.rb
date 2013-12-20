class DocGenerator
#########################################################################
###
### Funciones para la generación de Plan de Proyecto en fichero .ods
### 
#########################################################################
	# Genera la hoja "General" del Plan de proyecto
  def self.pp_general(sheet,project_id)
    sheet.setCurrentTable("General")
    project = Project.find(project_id)

    # Campo Fecha del documento
    time = Time.new
    OdsManager.write_cell(sheet,4,2,'string',time.strftime("%d-%m-%Y"))
    # Campo Proyecto
    OdsManager.write_cell(sheet,6,2,'string',project.name)

    # Campos Expediente, Tecnología, Ciclo de vida, Observaciones
    project.visible_custom_field_values.each do |element|
      case element.custom_field.name
        when "Expediente"
          OdsManager.write_cell(sheet,7,2,'string',element.value)
        when "Tecnologías"
          OdsManager.write_cell(sheet,8,2,'string',element.value)
        when "Ciclo de vida"
          OdsManager.write_cell(sheet,9,2,'string',element.value)
        when "Observaciones"
          OdsManager.write_cell(sheet,10,2,'string',element.value)
      end
    end
  end

  # Genera la hoja "RRHH" del Plan de proyecto
  def self.pp_rrhh(sheet,project_id)
    # Se establecen parametros de la página
    sheet.setCurrentTable("RRHH")
    init_row = 9
    init_col = 1
    end_col = 7

    # Se recorren los miembros del proyecto
    members = Project.find(project_id).members
    result = Array.new
    i = 0
    members.each do |member|
      result[i] = Array.new
      str_roles = ""

      # Si un miembro tiene varios roles en el proyecto, se separan con comas
      member.roles.each do |role|
        if str_roles != ""
          str_roles = str_roles + ", "
        end

        str_roles = str_roles + role.name
      end

      # Se crea array de arrays con la info de los miembros del proyecto
      result[i] << str_roles
      result[i] << member.name
      result[i] << "-"
      result[i] << DocGenerator.format_mysql_date(member.from_date)
      result[i] << DocGenerator.format_mysql_date(member.to_date)
      result[i] << member.allocation

      i = i + 1
    end

    # Se introduce el array de arrays con los datos de los miembros en el documento
    OdsManager.insert_table_rows(sheet,result,init_row,init_col,init_row+result.length-1,end_col)
  end


  # Genera la hoja "Recursos Técnicos" del Plan de proyecto
  def self.pp_recursos_tecnicos(sheet,project_id)
    # Se establecen parametros de la página
    sheet.setCurrentTable("Recursos Técnicos")
    init_row = 7
    init_col = 1
    end_col = 8
    wiki_text = ""

    wiki_pages = Project.find(project_id).wiki.pages
    wiki_pages.each do |wiki_page|
      if wiki_page.title == "Recursos_Técnicos"
        wiki_text = wiki_page.content.text
      end
    end

    result = DocGenerator.get_wiki_table(wiki_text, "Entorno:", true)

    OdsManager.insert_table_rows(sheet,result,init_row,init_col,init_row+result.length-1,end_col)
  end  


  # Genera la hoja "Plan Configuración" del Plan de proyecto
  def self.pp_plan_configuracion(sheet,project_id)
    # Se establecen parametros de la página
    sheet.setCurrentTable("Plan Configuración")
    # Parámetros para tabla "Elementos de configuración"
    init_row_ec = 9
    init_col_ec = 1
    end_col_ec = 13
    key_word_ec = "Elementos de configuración"
    # Parámetros para tabla "Aprobación Cambios a Requisito"
    init_row_acr = 13 #22
    init_col_acr = 1
    end_col_acr = 3
    key_word_acr = "Aprobación Cambios a Requisito"
    # Parámetros para tabla "Actividades de gestión de configuración"
    init_row_agc = 19 #28
    init_col_agc = 1
    end_col_agc = 7
    key_word_agc = "Actividades de gestión de configuración"
    # Parámetros para tabla "Recursos"
    init_row_r = 24 #37
    init_col_r = 1
    end_col_r = 7
    key_word_r = "Recursos"
    # Parámetros para tabla "Derechos de acceso"
    init_row_da = 29 #45
    init_col_da = 1
    end_col_da = 6
    key_word_da = "Derechos de acceso"
    # Parámetros para lista de nomenclatura de elementos
    row_ne = 31 #52
    col_ne = 2
    key_word_ne = "Nomenclatura de elementos"

    wiki_text = ""

    # Obtenemos el contenido de la wiki de plan de configuración
    wiki_pages = Project.find(project_id).wiki.pages
    wiki_pages.each do |wiki_page|
      if wiki_page.title == "Plan_de_Configuración"
        wiki_text = wiki_page.content.text
      end
    end

    # Obtenemos y escribimos la nomenclatura de elementos
    result = ""
    result = DocGenerator.get_wiki_text(wiki_text,key_word_ne)
    OdsManager.write_cell(sheet,row_ne,col_ne,'string',result)

    # Obtenemos y escribimos los derechos de acceso
    result = Array.new
    result = DocGenerator.get_wiki_table(wiki_text, key_word_da, false)
    OdsManager.insert_table_rows(sheet,result,init_row_da,init_col_da,init_row_da+result.length-1,end_col_da)
    
    # Obtenemos y escribimos los recursos
    result = Array.new
    result = DocGenerator.get_wiki_table(wiki_text, key_word_r, false)
    OdsManager.insert_table_rows(sheet,result,init_row_r,init_col_r,init_row_r+result.length-1,end_col_r)
    
    # Obtenemos y escribimos las actividades de gestión de configuración
    result = Array.new
    result = DocGenerator.get_wiki_table(wiki_text, key_word_agc, false)
    OdsManager.insert_table_rows(sheet,result,init_row_agc,init_col_agc,init_row_agc+result.length-1,end_col_agc)
    
    # Obtenemos y escribimos la aprobación de cambios a requisitos
    result = Array.new
    result = DocGenerator.get_wiki_table(wiki_text, key_word_acr, false)
    OdsManager.insert_table_rows(sheet,result,init_row_acr,init_col_acr,init_row_acr+result.length-1,end_col_acr)
    
    # Obtenemos y escribimos los elementos de configuración
    result = Array.new
    result = DocGenerator.get_wiki_table(wiki_text, key_word_ec, false)
    OdsManager.insert_table_rows(sheet,result,init_row_ec,init_col_ec,init_row_ec+result.length-1,end_col_ec)
  end  

  # Extrae la información de las tablas de la wiki y las formatea como un array de arrays
  # El argumento "multiple" permite indicar si se van a localizar varias tablas o solo una
  # En caso de identificar varias tablas, key_word hace referencia al texto que precede al título de cada tabla que va a ser tratada. En cada subarray del array generado, el primer elemento será el nombre de la tabla a la que pertenece la fila
  # En caso de identificar una única tabla, key_word hace referencia al título de la tabla a tratar.
  def self.get_wiki_table(wiki_content, key_word, multiple = false)
    # Eliminamos espacios entre "|"
    wiki_content = wiki_content.gsub(/\| /,"|")
    wiki_content = wiki_content.gsub(/ \|/,"|")

    # Añadimos "#" al comienzo de la cadena para poder tratar simultaneamente el comienzo de la cadena con el resto
    wiki_content = "#"+wiki_content

    # Sustituimos la palabra clave por el simbolo "@" para indicar el inicio de una tabla de interés
    wiki_content = wiki_content.gsub(key_word,"@")

    # Eliminamos cabeceras de las tablas que vamos a tratar
    if multiple
      wiki_content = wiki_content.gsub(/@[\s]*([^\|\r\n]+[\r\n]*)\|[^\r\n]+\|[\r\n]+/) {"@"+$1.to_s}
    else
      wiki_content = wiki_content.gsub(/@[\r\n|\n|\r]*\|[^\n\r]+\|[\r\n|\n|\r]/,"@")
    end

    # Borramos posibles espacios alrededor del simbolo "@"
    wiki_content = wiki_content.gsub(/\s*@\s*([^\s].*[^\s])/) {"@"+$1.to_s}

    # Marcamos con "#" el final de cada tabla
    wiki_content = wiki_content.gsub(/\|(\r\n\r\n|\n\n|\r\r)/,"|#")

    # Borramos todos los saltos de linea
    wiki_content = wiki_content.gsub(/\r\n/, '')

    # Borramos todo el contenido entre el final de cada tabla (o el inicio del texto) y el comienzo de cada tabla de interés
    wiki_content = wiki_content.gsub(/#[^@]*/,"")

    # Marcamos el cambio de fila en una tabla con "|@@[primer elemento de la siguiente fila]"
    wiki_content = wiki_content.gsub(/\|\|/,"|@@")

    # Creamos array dividiendo el string por "|"
    arr = wiki_content.split(/\|/)

    # Creamos el array de arrays para el resultado
    result = Array.new
    i = -1
    element = ""
    arr.each do |a|
      # Si el elemento es una nueva fila de una tabla, iniciamos un nuevo subarray y colocamos como primer elemento el titulo de la última tabla recorrida
      if a.match(/^@@[^@]+/)
        i = i +1
        result[i] = Array.new
        if multiple
          result[i] << element
        end
        result[i] << a[2..a.length]
      # Si el elemento es un titulo de tabla iniciamos un nuevo subarray y lo colocamos como última tabla recorrida
      elsif a.match(/^@[^@]*/)
        i = i + 1
        result[i] = Array.new
        if multiple
          element = a[1..a.length]
          result[i] << element
        end
      # Si el elemento es cualquier otro, lo introducimos como nuevo elemento en el subarray actual
      else
        result[i] << a
      end
    end

    return result
  end

  # Devuelve el parrafo de la wiki contenido bajo una cabecera identificada por los simbolos "@@"
  def self.get_wiki_text(wiki_content, key_word)
    result = ""

    wiki_content = wiki_content.gsub(key_word,"@@")
    result = wiki_content.gsub(/[^@]*@@\s*([^\n\r]+)[^@]*/) {$1.to_s}
    return result
  end


#########################################################################
###
### Funciones para la generación de Catalogo de objetivos en fichero .odt
### 
#########################################################################
  def self.aims_catalog(r, project_id, issues)
    # Obtenemos el id del campo personalizado "Código"
    codigo_id = CustomField.find_by_name('Código').id

    # Obtenemos le nombre del proyecto
    project = Project.find_by_id(project_id)
    project_title = project.name

    # Ponemos el titulo del proyecto en la primera página
    r.add_field :proy_titulo, project_title 

    # Si no habían tareas de tipo "Objetivo", imprimimos la tabla de ejemplo
    if issues.empty?
      r.add_field :obj_cod, 'OB-00X'
      r.add_field :obj_titulo, 'Título del objetivo.'
      r.add_field :obj_desc, 'Descripción del objetivo.'
    # Si no, creamos una tabla y su comentario para cada tarea de tipo "Objetivo"
    else
      r.add_section("Sección1", issues) do |s|
        s.add_field(:obj_cod) {|issue| 
          codigo = CustomValue.find_all_by_customized_id_and_custom_field_id(issue.id, codigo_id)
          if codigo.present?
            codigo
          else
            "#"+issue.id.to_s
          end
        }
        s.add_field :obj_titulo, :subject
        s.add_field(:obj_desc) {|issue| DocGenerator.parsing_wiki_text(issue.description)}
      end
    end
  end



#########################################################################
###
### Funciones para la generación de Análisis funcional en fichero .odt
### 
#########################################################################

  # Función para obtener y mostrar los actores del análisis funcional
  def self.functional_analysis_actors(r, project_id, actors)
    # Obtenemos el id del campo personalizado "Código"
    codigo_id = CustomField.find_by_name('Código').id

    # Si no habían requisitos de actores, imprimimos la tabla de ejemplo
    if actors.empty?
      r.add_field :act_cod, 'AC-00X'
      r.add_field :act_nombre, 'Nombre del Actor.'
      r.add_field :act_desc, 'Descripción del Actor.'
      r.add_field :act_coment, 'Comentario con información adicional.'
    # Si no, creamos una tabla y su comentario para cada requisito de actor
    else
      r.add_section("SecciónActor", actors) do |s|
        s.add_field(:act_cod) {|actor| 
          codigo = CustomValue.find_all_by_customized_id_and_custom_field_id(actor.id, codigo_id)
          if codigo.present?
            codigo
          else
            "#"+actor.id.to_s
          end
        }
        s.add_field :act_nombre, :subject
        s.add_field(:act_desc) {|actor| DocGenerator.parsing_wiki_text(actor.description)}
        s.add_field(:act_coment) {|actor| ""}
      end
    end
  end

  # Función para obtener y mostrar los casos de uso en el análisis funcional
  def self.functional_analysis_use_cases(r, project_id, use_cases)
    # Obtenemos el id de los trackers para requisitos, objetivos y casos de uso
    requisito_id = Tracker.find_by_name('Requisitos').id
    objetivo_id = Tracker.find_by_name('Objetivos').id
    caso_uso_id = Tracker.find_by_name('Casos de Uso').id

    # Obtenemos el id de los campos personalizados "Código", "Tipo de requisito", "Precondición", "Secuencia normal" y "Postcondición"
    codigo_id = CustomField.find_by_name('Código').id
    pre_id = CustomField.find_by_name('Precondición').id
    secuencia_id = CustomField.find_by_name('Secuencia normal').id
    post_id = CustomField.find_by_name('Postcondición').id
    excepciones_id = CustomField.find_by_name('Excepciones').id

    # Creamos dos subarrays para cada caso de uso: actors que incluye los actores relacionados al caso de uso y relations que incluye los casos de uso, objetivos y requisitos (no actores) relacionados con el caso de uso
    use_cases = DocGenerator.get_related_issues(use_cases, [requisito_id, caso_uso_id, objetivo_id], true)

    # Si no hay casos de uso, se muestra la tabla de ejemplo
    if use_cases.empty?
      r.add_field :cu_cod, "CU-00X"
      r.add_field :cu_titulo, "Título del caso de uso."
      r.add_field :cu_desc, "Descripción del caso de uso."
      r.add_field :cu_actores, "Actores que intervienen en el caso de uso."
      r.add_field :cu_relacion, "Relaciones del caso de uso: objetivos, otros casos de uso, requisitos."
      r.add_field :cu_pre, "Condición de necesario cumplimiento antes de producirse el caso de uso."
      r.add_field :cu_secuencia, "Título de casuística 1\n1. Paso 1\n2. Paso 2\nN. Paso N\n\nTítulo de casuística 2\n1. Paso 1\n2. Paso 2\nN. Paso N"
      r.add_field :cu_pre, "Condición consecuencia de la ejecución del caso de uso."
      r.add_field :cu_excepciones, "Excepciones"
    # En caso contrario, se muestra el contenido de los casos de uso
    else
      r.add_section("SecciónCU", use_cases) do |s|
        s.add_field(:cu_cod) {|use_case| 
          codigo = CustomValue.find_all_by_customized_id_and_custom_field_id(use_case.id, codigo_id)
          if codigo.present?
            codigo
          else
            "#"+use_case.id.to_s
          end
        }
        s.add_field :cu_titulo, :subject
        s.add_field(:cu_desc) {|use_case| DocGenerator.parsing_wiki_text(use_case.description)}
        s.add_section("SecciónCU_Actor", :i_actors) do |a|
          a.add_field(:cu_actor, :value)
        end
        s.add_section("SecciónCU_Relación", :i_relations) do |r|
          r.add_field(:cu_relacion, :value)
        end
        s.add_field(:cu_pre) {|use_case| CustomValue.find_all_by_customized_id_and_custom_field_id(use_case.id, pre_id)}
        s.add_field(:cu_secuencia) {|use_case| CustomValue.find_all_by_customized_id_and_custom_field_id(use_case.id, secuencia_id)}
        s.add_field(:cu_post) {|use_case| CustomValue.find_all_by_customized_id_and_custom_field_id(use_case.id, post_id)}
        s.add_field(:cu_excepciones) {|use_case| CustomValue.find_all_by_customized_id_and_custom_field_id(use_case.id, excepciones_id)}
      end
    end
  end

  # Función para obtener y mostrar los requisitos funcionales en el análisis funcional
  def self.functional_analysis_functional_requirements(r, project_id, func_req)
    # Obtenemos el id de los trackers para requisitos, objetivos y casos de uso
    requisito_id = Tracker.find_by_name('Requisitos').id
    objetivo_id = Tracker.find_by_name('Objetivos').id
    caso_uso_id = Tracker.find_by_name('Casos de Uso').id

    # Obtenemos el id de los campos personalizados "Código", "Tipo de requisito", "Precondición", "Secuencia normal" y "Postcondición"
    codigo_id = CustomField.find_by_name('Código').id

    # Creamos dos subarrays para cada caso de uso: actors que incluye los actores relacionados al caso de uso y relations que incluye los casos de uso, objetivos y requisitos (no actores) relacionados con el caso de uso
    func_req = DocGenerator.get_related_issues(func_req, [requisito_id, caso_uso_id, objetivo_id], true)

    # Si no hay requisitos funcionales, se muestra la tabla de ejemplo
    if func_req.empty?
      r.add_field :rf_cod, "RF-00X"
      r.add_field :rf_titulo, "Título del requisito funcional."
      r.add_field :rf_desc, "Descripción del requisito con lenguaje natural, basado en patrones linguisticos simples."
      r.add_field :rf_actor, ""
      r.add_field :rf_relacion, ""
    # En caso contrario, se muestra el contenido de los requisitos funcionales
    else
      r.add_section("SecciónRF", func_req) do |s|
        s.add_field(:rf_cod) {|req| 
          codigo = CustomValue.find_all_by_customized_id_and_custom_field_id(req.id, codigo_id)
          if codigo.present?
            codigo
          else
            "#"+req.id.to_s
          end
        }
        s.add_field :rf_titulo, :subject
        s.add_field(:rf_desc) {|req| DocGenerator.parsing_wiki_text(req.description)}
        s.add_section("SecciónRF_Actor", :i_actors) do |a|
          a.add_field(:rf_actor, :value)
        end
        s.add_section("SecciónRF_Relación", :i_relations) do |r|
          r.add_field(:rf_relacion, :value)
        end
      end
    end
  end

  # Función para obtener y mostrar los requisitos no funcionales en el análisis funcional
  def self.functional_analysis_non_functional_requirements(r, project_id, no_func_req)
    # Obtenemos el id de los trackers para requisitos, objetivos y casos de uso
    requisito_id = Tracker.find_by_name('Requisitos').id
    objetivo_id = Tracker.find_by_name('Objetivos').id
    caso_uso_id = Tracker.find_by_name('Casos de Uso').id

    # Obtenemos el id de los campos personalizados "Código", "Tipo de requisito", "Precondición", "Secuencia normal" y "Postcondición"
    codigo_id = CustomField.find_by_name('Código').id

    # Creamos dos subarrays para cada caso de uso: actors que incluye los actores relacionados al caso de uso y relations que incluye los casos de uso, objetivos y requisitos (no actores) relacionados con el caso de uso
    no_func_req = DocGenerator.get_related_issues(no_func_req, [requisito_id, caso_uso_id, objetivo_id], false)

    # Si no hay requisitos no funcionales, se muestra la tabla de ejemplo
    if no_func_req.empty?
      r.add_field :rnf_cod, "RNF-00X"
      r.add_field :rnf_titulo, "Título del requisito no funcional."
      r.add_field :rnf_desc, "Descripción breve del requisito, en lenguaje natural y sin entrar en demasiado detalle técnico."
      r.add_field :rnf_relacion, "Otros requisitos, casos de uso y objetivos relacionados con el requisito no funcional."
      r.add_field :rnf_prioridad, "Prioridad de cumplimiento de dicho requisito."
    # En caso contrario, se muestra el contenido de los requisitos no funcionales
    else
      r.add_section("SecciónRNF", no_func_req) do |s|
        s.add_field(:rnf_cod) {|req| 
          codigo = CustomValue.find_all_by_customized_id_and_custom_field_id(req.id, codigo_id)
          if codigo.present?
            codigo
          else
            "#"+req.id.to_s
          end
        }
        s.add_field :rnf_titulo, :subject
        s.add_field(:rnf_desc) {|req| DocGenerator.parsing_wiki_text(req.description)}
        s.add_section("SecciónRNF_Relación", :i_relations) do |r|
          r.add_field(:rnf_relacion, :value)
        end
        s.add_field(:rnf_prioridad) {|req| req.priority.name}
      end
    end
  end

  # Función para obtener y mostrar los requisitos de información en el análisis funcional
  def self.functional_analysis_information_requirements(r, project_id, info_req)
    # Obtenemos el id de los trackers para requisitos, objetivos y casos de uso
    requisito_id = Tracker.find_by_name('Requisitos').id
    objetivo_id = Tracker.find_by_name('Objetivos').id
    caso_uso_id = Tracker.find_by_name('Casos de Uso').id

    # Obtenemos el id de los campos personalizados "Código", "Tipo de requisito", "Precondición", "Secuencia normal" y "Postcondición"
    codigo_id = CustomField.find_by_name('Código').id

    # Creamos dos subarrays para cada caso de uso: actors que incluye los actores relacionados al caso de uso y relations que incluye los casos de uso, objetivos y requisitos (no actores) relacionados con el caso de uso
    info_req = DocGenerator.get_related_issues(info_req, [requisito_id, caso_uso_id, objetivo_id], false)

    # Si no hay requisitos de información, se muestra la tabla de ejemplo
    if info_req.empty?
      r.add_field :ri_cod, "RI-00X"
      r.add_field :ri_titulo, "Título del Requisito de Información."
      r.add_field :ri_desc, "Descripción del Requisito de Información."
      r.add_field :ri_relacion, "Objetivos, Casos de Uso, y otros Requisitos Funcionales, No Funcionales y de información relacionados con el requisito de información en cuestión."
      r.add_field :ri_prioridad, "Prioridad del requisito de información, para indicar su especial tratamiento en el diseño del modelo de datos posterior."
    # En caso contrario, se muestra el contenido de los requisitos de información
    else
      r.add_section("SecciónRI", info_req) do |s|
        s.add_field(:ri_cod) {|req| 
          codigo = CustomValue.find_all_by_customized_id_and_custom_field_id(req.id, codigo_id)
          if codigo.present?
            codigo
          else
            "#"+req.id.to_s
          end
        }
        s.add_field :ri_titulo, :subject
        s.add_field(:ri_desc) {|req| DocGenerator.parsing_wiki_text(req.description)}
        s.add_section("SecciónRI_Relación", :i_relations) do |r|
          r.add_field(:ri_relacion, :value)
        end
        s.add_field(:ri_prioridad) {|req| req.priority.name}
      end
    end
  end


#########################################################################
###
### Funciones para la generación de Casos de prueba en fichero .odt
### 
#########################################################################
  # Función para obtener y mostrar las pruebas funcionales en el documento de casos de prueba
  def self.test_case_functional_tests(r, project_id, tests)
    # Obtenemos el id de los trackers de requisitos y casos de uso
    requisito_id = Tracker.find_by_name('Requisitos').id
    caso_uso_id = Tracker.find_by_name('Casos de Uso').id

    # Obtenemos el id de los campos personalizados que necesitamos mostrar
    codigo_id = CustomField.find_by_name('Código').id
    proposito_id = CustomField.find_by_name('Propósito').id
    test_id = CustomField.find_by_name('Test').id
    res_esp_id = CustomField.find_by_name('Resultado esperado').id
    res_obt_id = CustomField.find_by_name('Resultado').id

    # Creamos un subarray para cada caso de uso en el que se listan los casos de uso, objetivos y requisitos relacionados con el caso de prueba
    tests = DocGenerator.get_related_issues(tests, [requisito_id, caso_uso_id], false)

    # Creamos un subarray para cada caso de prueba en el que se listan los entornos con los que está relacionado
    tests = DocGenerator.get_test_environments(tests)

    # Si no hay pruebas funcionales, se muestra la tabla de ejemplo
    if tests.empty?
      r.add_field :pf_cod, "PF-00X"
      r.add_field :pf_titulo, "Título del caso de prueba."
      r.add_field :pf_desc, "Descripción del caso de prueba."
      r.add_field :pf_proposito, "Proposito del caso de prueba."
      r.add_field :pf_relacion, "Relaciones del caso de prueba: Casos de Uso, Requisitos Funcionales, Requisitos de Información."
      r.add_field :pf_entorno, "Entornos del caso de prueba."
      r.add_field :pf_test, "Test del caso de prueba."
      r.add_field :pf_res_esp, "Resultado esperado para el caso de prueba."
      r.add_field :rpf_cod, "RPF-00X"
      r.add_field :rpf_titulo, "Título del caso de prueba"
      r.add_field :rpf_estado, "Estado del caso de prueba"
      r.add_field :rpf_fecha, "Fecha de realización del caso de prueba"
      r.add_field :rpf_res_esp, "Resultado esperado para el caso de prueba"
      r.add_field :rpf_res_obt, "Resultado obtenido del caso de prueba"
    # En caso contrario, se muestra el contenido de las pruebas funcionales y registros de pruebas funcionales
    else
      r.add_section("SecciónPF", tests) do |spf|
        spf.add_field(:pf_cod) {|test| 
          codigo = CustomValue.find_all_by_customized_id_and_custom_field_id(test.id, codigo_id)
          if codigo.present?
            codigo
          else
            "#"+test.id.to_s
          end
        }
        spf.add_field :pf_titulo, :subject
        spf.add_field(:pf_desc) {|test| DocGenerator.parsing_wiki_text(test.description)}
        spf.add_field(:pf_proposito) {|test| CustomValue.find_all_by_customized_id_and_custom_field_id(test.id, proposito_id)}
        spf.add_section("SecciónPF_Relación", :i_relations) do |spfr|
          spfr.add_field(:pf_relacion, :value)
        end
        spf.add_section("SecciónPF_Entorno", :i_environments) do |spfe|
          spfe.add_field(:pf_entorno, :value)
        end
        spf.add_field(:pf_test) {|test| CustomValue.find_all_by_customized_id_and_custom_field_id(test.id, test_id)}
        spf.add_field(:pf_res_esp) {|test| CustomValue.find_all_by_customized_id_and_custom_field_id(test.id, res_esp_id)}
      end
      r.add_section("SecciónRPF", tests) do |srpf|
        srpf.add_field(:rpf_cod) {|test| 
          codigo = CustomValue.find_all_by_customized_id_and_custom_field_id(test.id, codigo_id)
          if codigo.present?
            codigo
          else
            "#"+test.id.to_s
          end
        }
        srpf.add_field :rpf_titulo, :subject
        srpf.add_field(:rpf_estado) {|test| test.status.name}
        srpf.add_field(:rpf_fecha) {|test| DocGenerator.format_mysql_date(test.due_date)}
        srpf.add_field(:rpf_res_esp) {|test| CustomValue.find_all_by_customized_id_and_custom_field_id(test.id, res_esp_id)}
        srpf.add_field(:rpf_res_obt) {|test| CustomValue.find_all_by_customized_id_and_custom_field_id(test.id, res_obt_id)}
      end
    end
  end

  # Función para obtener y mostrar las pruebas unitarias en el documento de casos de prueba
  def self.test_case_unity_tests(r, project_id, tests)
    # Obtenemos el id de los trackers de requisitos y casos de uso
    requisito_id = Tracker.find_by_name('Requisitos').id
    caso_uso_id = Tracker.find_by_name('Casos de Uso').id

    # Obtenemos el id de los campos personalizados que necesitamos mostrar
    codigo_id = CustomField.find_by_name('Código').id
    proposito_id = CustomField.find_by_name('Propósito').id
    test_id = CustomField.find_by_name('Test').id
    tecnologia_id = CustomField.find_by_name_and_type('Tecnologías','IssueCustomField').id
    res_esp_id = CustomField.find_by_name('Resultado esperado').id
    res_obt_id = CustomField.find_by_name('Resultado').id

    # Creamos un subarray para cada caso de uso en el que se listan los casos de uso, objetivos y requisitos relacionados con el caso de prueba
    tests = DocGenerator.get_related_issues(tests, [requisito_id, caso_uso_id], false)

    # Creamos un subarray para cada caso de prueba en el que se listan los entornos con los que está relacionado
    tests = DocGenerator.get_test_environments(tests)

    # Si no hay pruebas unitarias, se muestra la tabla de ejemplo
    if tests.empty?
      r.add_field :pu_cod, "PU-00X"
      r.add_field :pu_titulo, "Título del caso de prueba."
      r.add_field :pu_tecn, "Técnologías relacionadas."
      r.add_field :pu_desc, "Descripción del caso de prueba."
      r.add_field :pu_proposito, "Proposito del caso de prueba."
      r.add_field :pu_relacion, "Relaciones del caso de prueba: Casos de Uso, Requisitos Funcionales, Requisitos de Información."
      r.add_field :pu_entorno, "Entornos del caso de prueba."
      r.add_field :pu_test, "Test del caso de prueba."
      r.add_field :rpu_cod, "RPU-00X"
      r.add_field :rpu_titulo, "Título del caso de prueba"
      r.add_field :rpu_estado, "Estado del caso de prueba"
      r.add_field :rpu_fecha, "Fecha de realización del caso de prueba"
      r.add_field :rpu_res_esp, "Resultado esperado para el caso de prueba"
      r.add_field :rpu_res_obt, "Resultado obtenido del caso de prueba"
    # En caso contrario, se muestra el contenido de las pruebas unitarias y registros de pruebas unitarias
    else
      r.add_section("SecciónPU", tests) do |spu|
        spu.add_field(:pu_cod) {|test| 
          codigo = CustomValue.find_all_by_customized_id_and_custom_field_id(test.id, codigo_id)
          if codigo.present?
            codigo
          else
            "#"+test.id.to_s
          end
        }
        spu.add_field :pu_titulo, :subject
        spu.add_field(:pu_tecn) {|test| CustomValue.find_all_by_customized_id_and_custom_field_id(test.id, tecnologia_id)}
        spu.add_field(:pu_desc) {|test| DocGenerator.parsing_wiki_text(test.description)}
        spu.add_field(:pu_proposito) {|test| CustomValue.find_all_by_customized_id_and_custom_field_id(test.id, proposito_id)}
        spu.add_section("SecciónPU_Relación", :i_relations) do |spur|
          spur.add_field(:pu_relacion, :value)
        end
        spu.add_section("SecciónPU_Entorno", :i_environments) do |spue|
          spue.add_field(:pu_entorno, :value)
        end
        spu.add_field(:pu_test) {|test| CustomValue.find_all_by_customized_id_and_custom_field_id(test.id, test_id)}
      end
      r.add_section("SecciónRPU", tests) do |srpu|
        srpu.add_field(:rpu_cod) {|test| 
          codigo = CustomValue.find_all_by_customized_id_and_custom_field_id(test.id, codigo_id)
          if codigo.present?
            codigo
          else
            "#"+test.id.to_s
          end
        }
        srpu.add_field :rpu_titulo, :subject
        srpu.add_field(:rpu_estado) {|test| test.status.name}
        srpu.add_field(:rpu_fecha) {|test| DocGenerator.format_mysql_date(test.due_date)}
        srpu.add_field(:rpu_res_esp) {|test| CustomValue.find_all_by_customized_id_and_custom_field_id(test.id, res_esp_id)}
        srpu.add_field(:rpu_res_obt) {|test| CustomValue.find_all_by_customized_id_and_custom_field_id(test.id, res_obt_id)}
      end
    end
  end

  # Función para obtener y mostrar las pruebas de sistema en el documento de casos de prueba
  def self.test_case_system_tests(r, project_id, tests)
    # Obtenemos el id de los trackers de requisitos y casos de uso
    requisito_id = Tracker.find_by_name('Requisitos').id
    caso_uso_id = Tracker.find_by_name('Casos de Uso').id

    # Obtenemos el id de los campos personalizados que necesitamos mostrar
    codigo_id = CustomField.find_by_name('Código').id
    proposito_id = CustomField.find_by_name('Propósito').id
    test_id = CustomField.find_by_name('Test').id
    tecnologia_id = CustomField.find_by_name_and_type('Tecnologías','IssueCustomField').id
    res_esp_id = CustomField.find_by_name('Resultado esperado').id
    res_obt_id = CustomField.find_by_name('Resultado').id

    # Creamos un subarray para cada caso de uso en el que se listan los casos de uso, objetivos y requisitos relacionados con el caso de prueba
    tests = DocGenerator.get_related_issues(tests, [requisito_id, caso_uso_id], false)

    # Creamos un subarray para cada caso de prueba en el que se listan los entornos con los que está relacionado
    tests = DocGenerator.get_test_environments(tests)

    # Si no hay pruebas de sistema, se muestra la tabla de ejemplo
    if tests.empty?
      r.add_field :ps_cod, "PS-00X"
      r.add_field :ps_titulo, "Título del caso de prueba."
      r.add_field :ps_tecn, "Técnologías relacionadas."
      r.add_field :ps_desc, "Descripción del caso de prueba."
      r.add_field :ps_proposito, "Proposito del caso de prueba."
      r.add_field :ps_relacion, "Relaciones del caso de prueba: Casos de Uso, Requisitos Funcionales, Requisitos de Información."
      r.add_field :ps_entorno, "Entornos del caso de prueba."
      r.add_field :ps_test, "Test del caso de prueba."
      r.add_field :rps_cod, "RPS-00X"
      r.add_field :rps_titulo, "Título del caso de prueba"
      r.add_field :rps_estado, "Estado del caso de prueba"
      r.add_field :rps_fecha, "Fecha de realización del caso de prueba"
      r.add_field :rps_res_esp, "Resultado esperado para el caso de prueba"
      r.add_field :rps_res_obt, "Resultado obtenido del caso de prueba"
    # En caso contrario, se muestra el contenido de las pruebas de sistema y registros de pruebas de sistema
    else
      r.add_section("SecciónPS", tests) do |sps|
        sps.add_field(:ps_cod) {|test| 
          codigo = CustomValue.find_all_by_customized_id_and_custom_field_id(test.id, codigo_id)
          if codigo.present?
            codigo
          else
            "#"+test.id.to_s
          end
        }
        sps.add_field :ps_titulo, :subject
        sps.add_field(:ps_tecn) {|test| CustomValue.find_all_by_customized_id_and_custom_field_id(test.id, tecnologia_id)}
        sps.add_field(:ps_desc) {|test| DocGenerator.parsing_wiki_text(test.description)}
        sps.add_field(:ps_proposito) {|test| CustomValue.find_all_by_customized_id_and_custom_field_id(test.id, proposito_id)}
        sps.add_section("SecciónPS_Relación", :i_relations) do |spsr|
          spsr.add_field(:ps_relacion, :value)
        end
        sps.add_section("SecciónPS_Entorno", :i_environments) do |spse|
          spse.add_field(:ps_entorno, :value)
        end
        sps.add_field(:ps_test) {|test| CustomValue.find_all_by_customized_id_and_custom_field_id(test.id, test_id)}
      end
      r.add_section("SecciónRPS", tests) do |srps|
        srps.add_field(:rps_cod) {|test| 
          codigo = CustomValue.find_all_by_customized_id_and_custom_field_id(test.id, codigo_id)
          if codigo.present?
            codigo
          else
            "#"+test.id.to_s
          end
        }
        srps.add_field :rps_titulo, :subject
        srps.add_field(:rps_estado) {|test| test.status.name}
        srps.add_field(:rps_fecha) {|test| DocGenerator.format_mysql_date(test.due_date)}
        srps.add_field(:rps_res_esp) {|test| CustomValue.find_all_by_customized_id_and_custom_field_id(test.id, res_esp_id)}
        srps.add_field(:rps_res_obt) {|test| CustomValue.find_all_by_customized_id_and_custom_field_id(test.id, res_obt_id)}
      end
    end
  end

  # Función para obtener y mostrar las pruebas de rendimiento en el documento de casos de prueba
  def self.test_case_performance_tests(r, project_id, tests)
    # Obtenemos el id de los trackers de requisitos y casos de uso
    requisito_id = Tracker.find_by_name('Requisitos').id
    caso_uso_id = Tracker.find_by_name('Casos de Uso').id

    # Obtenemos el id de los campos personalizados que necesitamos mostrar
    codigo_id = CustomField.find_by_name('Código').id
    proposito_id = CustomField.find_by_name('Propósito').id
    test_id = CustomField.find_by_name('Test').id
    tecnologia_id = CustomField.find_by_name_and_type('Tecnologías','IssueCustomField').id
    res_esp_id = CustomField.find_by_name('Resultado esperado').id
    res_obt_id = CustomField.find_by_name('Resultado').id

    # Creamos un subarray para cada caso de uso en el que se listan los casos de uso, objetivos y requisitos relacionados con el caso de prueba
    tests = DocGenerator.get_related_issues(tests, [requisito_id, caso_uso_id], false)

    # Creamos un subarray para cada caso de prueba en el que se listan los entornos con los que está relacionado
    tests = DocGenerator.get_test_environments(tests)

    # Si no hay pruebas de rendimiento, se muestra la tabla de ejemplo
    if tests.empty?
      r.add_field :pr_cod, "PR-00X"
      r.add_field :pr_titulo, "Título del caso de prueba."
      r.add_field :pr_tecn, "Técnologías relacionadas."
      r.add_field :pr_desc, "Descripción del caso de prueba."
      r.add_field :pr_proposito, "Proposito del caso de prueba."
      r.add_field :pr_relacion, "Relaciones del caso de prueba: Casos de Uso, Requisitos Funcionales, Requisitos de Información."
      r.add_field :pr_entorno, "Entornos del caso de prueba."
      r.add_field :pr_test, "Test del caso de prueba."
      r.add_field :rpr_cod, "RPR-00X"
      r.add_field :rpr_titulo, "Título del caso de prueba"
      r.add_field :rpr_estado, "Estado del caso de prueba"
      r.add_field :rpr_fecha, "Fecha de realización del caso de prueba"
      r.add_field :rpr_res_esp, "Resultado esperado para el caso de prueba"
      r.add_field :rpr_res_obt, "Resultado obtenido del caso de prueba"
    # En caso contrario, se muestra el contenido de las pruebas de rendimiento y registros de pruebas de rendimiento
    else
      r.add_section("SecciónPR", tests) do |spr|
        spr.add_field(:pr_cod) {|test| 
          codigo = CustomValue.find_all_by_customized_id_and_custom_field_id(test.id, codigo_id)
          if codigo.present?
            codigo
          else
            "#"+test.id.to_s
          end
        }
        spr.add_field :pr_titulo, :subject
        spr.add_field(:pr_tecn) {|test| CustomValue.find_all_by_customized_id_and_custom_field_id(test.id, tecnologia_id)}
        spr.add_field(:pr_desc) {|test| DocGenerator.parsing_wiki_text(test.description)}
        spr.add_field(:pr_proposito) {|test| CustomValue.find_all_by_customized_id_and_custom_field_id(test.id, proposito_id)}
        spr.add_section("SecciónPR_Relación", :i_relations) do |sprr|
          sprr.add_field(:pr_relacion, :value)
        end
        spr.add_section("SecciónPR_Entorno", :i_environments) do |spre|
          spre.add_field(:pr_entorno, :value)
        end
        spr.add_field(:pr_test) {|test| CustomValue.find_all_by_customized_id_and_custom_field_id(test.id, test_id)}
      end
      r.add_section("SecciónRPR", tests) do |srpr|
        srpr.add_field(:rpr_cod) {|test| 
          codigo = CustomValue.find_all_by_customized_id_and_custom_field_id(test.id, codigo_id)
          if codigo.present?
            codigo
          else
            "#"+test.id.to_s
          end
        }
        srpr.add_field :rpr_titulo, :subject
        srpr.add_field(:rpr_estado) {|test| test.status.name}
        srpr.add_field(:rpr_fecha) {|test| DocGenerator.format_mysql_date(test.due_date)}
        srpr.add_field(:rpr_res_esp) {|test| CustomValue.find_all_by_customized_id_and_custom_field_id(test.id, res_esp_id)}
        srpr.add_field(:rpr_res_obt) {|test| CustomValue.find_all_by_customized_id_and_custom_field_id(test.id, res_obt_id)}
      end
    end
  end

  # Función para obtener y mostrar las pruebas estáticas en el documento de casos de prueba
  def self.test_case_static_tests(r, project_id, tests)
    # Obtenemos el id de los trackers de requisitos y casos de uso
    requisito_id = Tracker.find_by_name('Requisitos').id
    caso_uso_id = Tracker.find_by_name('Casos de Uso').id

    # Obtenemos el id de los campos personalizados que necesitamos mostrar
    codigo_id = CustomField.find_by_name('Código').id
    proposito_id = CustomField.find_by_name('Propósito').id
    test_id = CustomField.find_by_name('Test').id
    tecnologia_id = CustomField.find_by_name_and_type('Tecnologías','IssueCustomField').id
    res_esp_id = CustomField.find_by_name('Resultado esperado').id
    res_obt_id = CustomField.find_by_name('Resultado').id

    # Creamos un subarray para cada caso de uso en el que se listan los casos de uso, objetivos y requisitos relacionados con el caso de prueba
    tests = DocGenerator.get_related_issues(tests, [requisito_id, caso_uso_id], false)

    # Creamos un subarray para cada caso de prueba en el que se listan los entornos con los que está relacionado
    tests = DocGenerator.get_test_environments(tests)

    # Si no hay pruebas estáticas, se muestra la tabla de ejemplo
    if tests.empty?
      r.add_field :pe_cod, "PE-00X"
      r.add_field :pe_titulo, "Título del caso de prueba."
      r.add_field :pe_tecn, "Técnologías relacionadas."
      r.add_field :pe_desc, "Descripción del caso de prueba."
      r.add_field :pe_proposito, "Proposito del caso de prueba."
      r.add_field :pe_relacion, "Relaciones del caso de prueba: Casos de Uso, Requisitos Funcionales, Requisitos de Información."
      r.add_field :pe_entorno, "Entornos del caso de prueba."
      r.add_field :pe_test, "Test del caso de prueba."
      r.add_field :rpe_cod, "RPE-00X"
      r.add_field :rpe_titulo, "Título del caso de prueba"
      r.add_field :rpe_estado, "Estado del caso de prueba"
      r.add_field :rpe_fecha, "Fecha de realización del caso de prueba"
      r.add_field :rpe_res_esp, "Resultado esperado para el caso de prueba"
      r.add_field :rpe_res_obt, "Resultado obtenido del caso de prueba"
    # En caso contrario, se muestra el contenido de las pruebas estáticas y registros de pruebas estáticas
    else
      r.add_section("SecciónPE", tests) do |spe|
        spe.add_field(:pe_cod) {|test| 
          codigo = CustomValue.find_all_by_customized_id_and_custom_field_id(test.id, codigo_id)
          if codigo.present?
            codigo
          else
            "#"+test.id.to_s
          end
        }
        spe.add_field :pe_titulo, :subject
        spe.add_field(:pe_tecn) {|test| CustomValue.find_all_by_customized_id_and_custom_field_id(test.id, tecnologia_id)}
        spe.add_field(:pe_desc) {|test| DocGenerator.parsing_wiki_text(test.description)}
        spe.add_field(:pe_proposito) {|test| CustomValue.find_all_by_customized_id_and_custom_field_id(test.id, proposito_id)}
        spe.add_section("SecciónPE_Relación", :i_relations) do |sper|
          sper.add_field(:pe_relacion, :value)
        end
        spe.add_section("SecciónPE_Entorno", :i_environments) do |spee|
          spee.add_field(:pe_entorno, :value)
        end
        spe.add_field(:pe_test) {|test| CustomValue.find_all_by_customized_id_and_custom_field_id(test.id, test_id)}
      end
      r.add_section("SecciónRPE", tests) do |srpe|
        srpe.add_field(:rpe_cod) {|test| 
          codigo = CustomValue.find_all_by_customized_id_and_custom_field_id(test.id, codigo_id)
          if codigo.present?
            codigo
          else
            "#"+test.id.to_s
          end
        }
        srpe.add_field :rpe_titulo, :subject
        srpe.add_field(:rpe_estado) {|test| test.status.name}
        srpe.add_field(:rpe_fecha) {|test| DocGenerator.format_mysql_date(test.due_date)}
        srpe.add_field(:rpe_res_esp) {|test| CustomValue.find_all_by_customized_id_and_custom_field_id(test.id, res_esp_id)}
        srpe.add_field(:rpe_res_obt) {|test| CustomValue.find_all_by_customized_id_and_custom_field_id(test.id, res_obt_id)}
      end
    end
  end

  # Función para obtener un subarray con los entornos en los que se desarrollan cada una de las pruebas pasadas como parametro
  def self.get_test_environments(tests)
    # Obtenemos la id de cada entorno
    ent_des_id = CustomField.find_by_name('Entorno Desarrollo').id
    ent_pre_id = CustomField.find_by_name('Entorno Preproducción').id
    ent_pro_id = CustomField.find_by_name('Entorno Producción').id

    # Para cada caso de prueba comprobamos si el campo personalizado "Entorno de XXX" está activado o no
    tests.each do |test|
      i_environments = Array.new
      if CustomValue.find_by_customized_id_and_custom_field_id(test.id, ent_des_id).value==1
        i_environments << {'value' => 'Desarrollo'}
      end

      if CustomValue.find_by_customized_id_and_custom_field_id(test.id, ent_pre_id).value==1
        i_environments << {'value' => 'Preproducción'}
      end

      if CustomValue.find_by_customized_id_and_custom_field_id(test.id, ent_pro_id).value==1
        i_environments << {'value' => 'Producción'}
      end

      test['i_environments'] = i_environments
    end

    return tests
  end




#########################################################################
###
### Funciones auxiliares comunes
### 
#########################################################################
  # Permite obtener el último expediente asociado a un proyecto o, en caso de no tener expediente, el nombre del proyecto
  def self.get_project_expedient(project_id)
    expedient_id = CustomField.find_by_name("Expediente")
    project = Project.find_by_id(project_id)

    expediente = project.name

    expedient_custom_value = CustomValue.find_by_customized_id_and_custom_field_id(project.id, expedient_id)

    if !expedient_custom_value.value.empty?
      expedient_custom_value.value.gsub(", ",",")
      arr = expedient_custom_value.value.split(",")
      expediente = arr[arr.length-1]
    end
    
    return expediente
  end

  # Devuelve un array con el id del proyecto y de todos sus proyectos relacionados
  def self.get_project_and_related_project_ids(project_id)
    aux_ids = Array.new
    project_ids = Array.new
    aux_ids << project_id.to_i
    
    while !aux_ids.empty?
      project = aux_ids.shift
      child_projects = Project.find_all_by_parent_id(project)
      
      child_projects.each do |child_project|
        if !project_ids.include?(child_project.id) && !aux_ids.include?(child_project.id)
          aux_ids << child_project.id
        end
      end
      
      project_ids << project
    end
    
    return project_ids
  end

  # Modifica la estructura de un array de peticiones para añadir una sección con los códigos de las peticiones y actores relacionados
  # issues es la lista de peticiones sobre la que se quieren buscar sus peticiones relacionadas
  # trackers consiste en un array con los identificadores de los distintos trackers que se consideran para las relaciones
  # actors consiste en un booleano que indica si se filtra entre relaciones y actores o solo relaciones
  def self.get_related_issues(issues, trackers, actors)
    requisito_id = Tracker.find_by_name('Requisitos').id
    tipo_requisito_id = CustomField.find_by_name('Tipo de requisito').id
    codigo_id = CustomField.find_by_name('Código').id

    issues.each do |iss|
      i_actors = Array.new
      i_relations = Array.new

      # Recorremos las peticiones relacionadas con la petición actual
      iss.relations_from.each do |related|
        issue = Issue.find(related.issue_to_id)
        code = CustomValue.find_by_customized_id_and_custom_field_id(issue.id, codigo_id)

        # Si esta activada la busqueda de actores y la petición relacionada es un requisito de tipo actor, lo incluimos en el array "i_actors"
        if actors && issue.tracker_id == requisito_id && CustomValue.find_by_customized_id_and_custom_field_id(issue.id, tipo_requisito_id).value == "De Actor"
          if code.present?
            i_actors << CustomValue.find_by_customized_id_and_custom_field_id(issue.id, codigo_id)
          else
            i_actors << {'value' => "#"+issue.id.to_s}
          end
        # Si la petición relacionada pertenece a uno de los trackers entre los que estamos buscando, lo incluimos en el array "i_relations"
        elsif trackers.include?(issue.tracker_id)
          if code.present?
            i_relations << CustomValue.find_by_customized_id_and_custom_field_id(issue.id, codigo_id)
          else
            i_relations << {'value' => "#"+issue.id.to_s}
          end
        end
      end

      # Añadimos los subarrays al elemento del array de peticiones
      iss['i_relations'] = i_relations
      iss['i_actors'] = i_actors
    end

    return issues
  end

  # Parsea los textos con formato de wiki para eliminar (o adaptar en la medida de lo posible) las distintas etiquetas al .odt
  def self.parsing_wiki_text(text)
    # Detectar negrita
    text = text.gsub(/([\s\r\n\,\.\;])\*([^\s\r\n][^\r\n]*?[^\s\r\n])\*([\s\r\n\,\.\;])/) {$1+$2+$3}
    # Detectar cursiva
    text = text.gsub(/([\s\r\n\,\.\;])_([^\s\r\n][^\r\n]*?[^\s\r\n])_([\s\r\n\,\.\;])/) {$1+$2+$3}
    # Detectar subrayados
    text = text.gsub(/([\s\r\n\,\.\;])\+([^\s\r\n][^\r\n]*?[^\s\r\n])\+([\s\r\n\,\.\;])/) {$1+$2+$3}
    # Detectar comentario tachado
    text = text.gsub(/([\s\r\n\,\.\;])-([^\s\r\n][^\r\n]*?[^\s\r\n])-([\s\r\n\,\.\;])/) {""}
    # Detectar cita
    text = text.gsub(/([\s\r\n\,\.\;])\?\?([^\s\r\n][^\r\n]*?[^\s\r\n])\?\?([\s\r\n\,\.\;])/) {$1+$2+$3}
    # Detectar codigo en linea
    text = text.gsub(/([\s\r\n\,\.\;])@([^\s\r\n][^\r\n]*?[^\s\r\n])@([\s\r\n\,\.\;])/) {$1+$2+$3}
    # Detectar fragmentos de código
    text = text.gsub(/\<pre\>(.+?)\<\/pre\>/m) {"\r\n"+$1+"\r\n"}
    # Detectar titulos
#    text = text.gsub(/(\r\n\r\n|\n\n|\r\r)h[1-6]\. (.+?)(\r\n\r\n|\n\n|\r\r|\Z)/) {$1+$2+$3}
    text = text.gsub(/^h[1-6]\. /) {$1}
    # Detectar tabulaciones
    text = text.gsub(/^\>(.*)$/) {"\t"+$1}
  end

  # Convierte fechas de tipo date de mysql (yyyy/mm/dd) en formato dd/mm/yyyy
  def self.format_mysql_date(date)
    new_date = ""
    date = date.to_s

    if date.length == 10
      new_date = date[8..9]+date[4..7]+date[0..3]
    end

    return new_date
  end


end