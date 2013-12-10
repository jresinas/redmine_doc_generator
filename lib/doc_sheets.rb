class DocSheets
	# Genera la hoja "General" del Plan de proyecto
  def self.pp_general(sheet,project_id)
    sheet.setCurrentTable("General")
    project = Project.find(project_id)

    # Fecha del documento
    time = Time.new
    OdsManager.write_cell(sheet,4,2,'string',time.strftime("%d-%m-%Y"))
    # Proyecto
    OdsManager.write_cell(sheet,6,2,'string',project.name)

    # Expediente, Tecnología, Ciclo de vida, Observaciones
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
      result[i] << DocSheets.format_mysql_date(member.from_date)
      result[i] << DocSheets.format_mysql_date(member.to_date)
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
    wiki_headers = "| *Recurso Técnico* | *Características* | *Fecha Requerida* | *Fecha de caducidad* | Valor estimado (€) | Fecha recepción | Valor real (€) |"
    wiki_text = ""

    wiki_pages = Project.find(project_id).wiki.pages
    wiki_pages.each do |wiki_page|
      if wiki_page.title == "Recursos_Técnicos"
        wiki_text = wiki_page.content.text
      end
    end

    result = DocSheets.get_wiki_table(wiki_text, wiki_headers, "Entorno:", true)

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
    wiki_headers_ec = "| *Elemento* | *Código* | *Tipo* | *Realiza* | *Responsable Organización* | *Responsable Cliente* | *Método* | *Estado* | *Fecha Realizado* | *Fecha Aprobado*| *Fecha Linea Base (LB)* | *¿Se entraga al cliente?* | *Observaciones* |"
    # Parámetros para tabla "Aprobación Cambios a Requisito"
    init_row_acr = 13 #22
    init_col_acr = 1
    end_col_acr = 3
    key_word_acr = "Aprobación Cambios a Requisito"
    wiki_headers_acr = "| *Responsable Organización* | *Responsable Cliente* | *Método* |"
    # Parámetros para tabla "Actividades de gestión de configuración"
    init_row_agc = 19 #28
    init_col_agc = 1
    end_col_agc = 7
    key_word_agc = "Actividades de gestión de configuración"
    wiki_headers_agc = "| *Actividad* | *Responsable* | *Fecha prevista* | *Esfuerzo previsto* | *Fecha real* | *Esfuerzo real* | *Observaciones* |"
    # Parámetros para tabla "Recursos"
    init_row_r = 24 #37
    init_col_r = 1
    end_col_r = 7
    key_word_r = "Recursos"
    wiki_headers_r = "| *Recurso* | *Descripción / características* | *Observaciones* | *Fecha inicio de servicio* | *Fecha fin de servicio* |"
    # Parámetros para tabla "Derechos de acceso"
    init_row_da = 29 #45
    init_col_da = 1
    end_col_da = 6
    key_word_da = "Derechos de acceso"
    wiki_headers_da = "| *Perfil* | *Nombre* | *Entorno desarrollo* | *Entorno pruebas* | *Entorno producción* | *Observaciones* |"
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
    result = DocSheets.get_wiki_text(wiki_text,key_word_ne)
    OdsManager.write_cell(sheet,row_ne,col_ne,'string',result)

    # Obtenemos y escribimos los derechos de acceso
    result = Array.new
    result = DocSheets.get_wiki_table(wiki_text, wiki_headers_da, key_word_da, false)
    OdsManager.insert_table_rows(sheet,result,init_row_da,init_col_da,init_row_da+result.length-1,end_col_da)
    
    # Obtenemos y escribimos los recursos
    result = Array.new
    result = DocSheets.get_wiki_table(wiki_text, wiki_headers_r, key_word_r, false)
    OdsManager.insert_table_rows(sheet,result,init_row_r,init_col_r,init_row_r+result.length-1,end_col_r)
    
    # Obtenemos y escribimos las actividades de gestión de configuración
    result = Array.new
    result = DocSheets.get_wiki_table(wiki_text, wiki_headers_agc, key_word_agc, false)
    OdsManager.insert_table_rows(sheet,result,init_row_agc,init_col_agc,init_row_agc+result.length-1,end_col_agc)
    
    # Obtenemos y escribimos la aprobación de cambios a requisitos
    result = Array.new
    result = DocSheets.get_wiki_table(wiki_text, wiki_headers_acr, key_word_acr, false)
    OdsManager.insert_table_rows(sheet,result,init_row_acr,init_col_acr,init_row_acr+result.length-1,end_col_acr)
    
    # Obtenemos y escribimos los elementos de configuración
    result = Array.new
    result = DocSheets.get_wiki_table(wiki_text, wiki_headers_ec, key_word_ec, false)
    OdsManager.insert_table_rows(sheet,result,init_row_ec,init_col_ec,init_row_ec+result.length-1,end_col_ec)
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


  # Extrae la información de las tablas de la wiki y las formatea como un array de arrays
  # El argumento "multiple" permite indicar si se van a localizar varias tablas o solo una
  # En caso de identificar varias tablas, key_word hace referencia al texto que precede al título de cada tabla que va a ser tratada. En cada subarray del array generado, el primer elemento será el nombre de la tabla a la que pertenece la fila
  # En caso de identificar una única tabla, key_word hace referencia al título de la tabla a tratar.
  def self.get_wiki_table(wiki_content, table_headers, key_word, multiple = false)
    # Eliminamos las cabeceras de la tabla
    wiki_content = wiki_content.gsub(table_headers, "")

    # Eliminamos espacios entre "|"
    wiki_content = wiki_content.gsub(/\| /,"|")
    wiki_content = wiki_content.gsub(/ \|/,"|")

    # Añadimos "#" al comienzo de la cadena para poder tratar simultaneamente el comienzo de la cadena con el resto
    wiki_content = "#"+wiki_content

    # Sustituimos la palabra clave por el simbolo "@" para indicar el inicio de una tabla de interés
    wiki_content = wiki_content.gsub(key_word,"@")
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

  # Devuelve el parrafo de la wiki contenido bajo una cabecera identificada por "key_word"
  def self.get_wiki_text(wiki_content, key_word)
    result = ""

    wiki_content = wiki_content.gsub(key_word,"@@")
    result = wiki_content.gsub(/[^@]*@@\s*([^\n\r]+)[^@]*/) {$1.to_s}
    puts "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAa #{result}"
    return result
  end

end