;; =============================================
;; SISTEMA EXPERTO PARA CASCO INTELIGENTE MINERO
;; =============================================

(deffacts hechos_iniciales
    ;; Sensores del casco - estado inicial
    (sensor-ultrasonico estado activo distancia 5.0 unidad metros)
    (sensor-temperatura-humedad estado activo temperatura 26.0 humedad 75)
    (sensor-casco estado activo)
    (sensor-oxigeno estado activo concentracion 20.9 unidad porcentaje)
    
    ;; Límites de seguridad basados en documentos
    (limites-seguridad
        Oxigeno O2 nivel_minimo 19.5 nivel_maximo 23.5
        Metano CH4 nivel_maximo 1.0
        Monoxido-de-Carbono CO nivel_maximo 25
        Dioxido-de-Carbono CO2 nivel_maximo 0.5
        Sulfuro-de-Hidrogeno H2S nivel_maximo 5
        Dioxido-de-Nitrogeno NO2 nivel_maximo 3
        temperatura_maxima 32.0
        humedad_maxima 85.0
        indice_calor_maximo 41.0
    )

    (gas Oxigeno Metano Monoxido-de-Carbono Dioxido-de-Carbono Sulfuro-de-Hidrogeno Dioxido-de-Nitrogeno)
    (gas-toxico Monoxido-de-Carbono Dioxido-de-Carbono Sulfuro-de-Hidrogeno Dioxido-de-Nitrogeno)
    (gas-combustible Metano Hidrogeno)
    
    ;; Alertas y notificaciones
    (sistema-alertas 
        buzzer estado inactivo 
        led-rojo estado inactivo 
        pantalla-oled estado activo
        equipo-medico notificacion inactiva
    )

    ;; Mediciones actuales de gases
    (concentracion-gas Oxigeno 20.9)
    (concentracion-gas Metano 0.2)
    (concentracion-gas Monoxido-de-Carbono 15)
    (concentracion-gas Dioxido-de-Carbono 0.3)
    (concentracion-gas Sulfuro-de-Hidrogeno 1)
    (concentracion-gas Dioxido-de-Nitrogeno 1)
)

;; -----------------------------------------------------
;; 2. CASOS DE USO - HECHOS INDEPENDIENTES PARA ACTIVACIÓN
;; -----------------------------------------------------

(defrule activar-monitoreo-continuo
    (iniciar-monitoreo-continuo)
    =>
    (printout t "=== SISTEMA DE MONITOREO CONTINUO ACTIVADO ===" crlf)
    (assert (evaluar-riesgos-gases))
    (assert (evaluar-riesgos-termicos)))

(defrule activar-protocolo-emergencia
    (protocolo-emergencia tipo ?tipo)
    =>
    (printout t "=== PROTOCOLO DE EMERGENCIA ACTIVADO: " ?tipo " ===" crlf)
    (assert (activar-sistema-alertas-completo)))

;; -----------------------------------------------------
;; 3. REGLAS GENÉRICAS CON COMODINES
;; -----------------------------------------------------

;; REGLA 1: Evaluación de riesgo por deficiencia de oxígeno CRÍTICA
(defrule evaluar-riesgo-deficiencia-oxigeno-critica
    (concentracion-gas Oxigeno ?conc-oxigeno)
    (limites-seguridad Oxigeno O2 nivel_minimo ?limite-min)
    (test (< ?conc-oxigeno 16.0))
    =>
    (assert (alerta tipo asfixia nivel critico valor ?conc-oxigeno mensaje "DEFICIENCIA CRÍTICA DE OXÍGENO - EVACUAR INMEDIATAMENTE"))
    (assert (activar-buzzer frecuencia maxima))
    (assert (activar-led-rojo color rojo-parpadeante))
    (printout t "ALERTA OXÍGENO CRÍTICA: " ?conc-oxigeno "% < 16%" crlf))

;; REGLA 1b: Evaluación de riesgo por deficiencia de oxígeno ALTA
(defrule evaluar-riesgo-deficiencia-oxigeno-alta
    (concentracion-gas Oxigeno ?conc-oxigeno)
    (limites-seguridad Oxigeno O2 nivel_minimo ?limite-min)
    (test (and (>= ?conc-oxigeno 16.0) (< ?conc-oxigeno ?limite-min)))
    =>
    (assert (alerta tipo asfixia nivel alto valor ?conc-oxigeno mensaje "DEFICIENCIA DE OXÍGENO - VENTILAR ÁREA"))
    (assert (activar-buzzer frecuencia alta))
    (assert (activar-led-rojo color rojo))
    (printout t "ALERTA OXÍGENO: " ?conc-oxigeno "% < " ?limite-min "%" crlf))

;; REGLA 2: Evaluación de riesgo por gases combustibles CRÍTICO
(defrule evaluar-riesgo-gases-combustibles-critico
    (concentracion-gas ?gas ?concentracion)
    (gas-combustible ?gas)
    (limites-seguridad ?gas ?formula nivel_maximo ?limite)
    (test (> ?concentracion (* ?limite 2.0)))
    =>
    (assert (alerta tipo explosion nivel critico valor ?concentracion mensaje "GAS COMBUSTIBLE CRÍTICO - EVACUAR INMEDIATAMENTE"))
    (assert (activar-buzzer frecuencia maxima))
    (assert (activar-led-rojo color rojo-parpadeante))
    (printout t "ALERTA GAS COMBUSTIBLE CRÍTICO: " ?gas " = " ?concentracion crlf))

;; REGLA 2b: Evaluación de riesgo por gases combustibles ALTO
(defrule evaluar-riesgo-gases-combustibles-alto
    (concentracion-gas ?gas ?concentracion)
    (gas-combustible ?gas)
    (limites-seguridad ?gas ?formula nivel_maximo ?limite)
    (test (and (> ?concentracion ?limite) (<= ?concentracion (* ?limite 2.0))))
    =>
    (assert (alerta tipo explosion nivel alto valor ?concentracion mensaje "GAS COMBUSTIBLE DETECTADO - ELIMINAR FUENTES DE IGNICIÓN"))
    (assert (activar-buzzer frecuencia alta))
    (assert (activar-led-rojo color rojo))
    (printout t "ALERTA GAS COMBUSTIBLE: " ?gas " = " ?concentracion " > " ?limite crlf))

;; REGLA 3: Evaluación de riesgo térmico por índice de calor CRÍTICO
(defrule evaluar-riesgo-termico-indice-calor-critico
    (sensor-temperatura-humedad estado activo temperatura ?temp humedad ?hr)
    (limites-seguridad indice_calor_maximo ?limite-ic)
    (test (> ?temp 35))
    =>
    (assert (alerta tipo termico nivel critico valor ?temp mensaje "CONDICIONES TÉRMICAS CRÍTICAS - EVACUAR"))
    (assert (activar-buzzer frecuencia maxima))
    (assert (activar-led-rojo color rojo-parpadeante))
    (printout t "ALERTA TÉRMICA CRÍTICA: Temperatura " ?temp "°C" crlf))

;; REGLA 3b: Evaluación de riesgo térmico por índice de calor ALTO
(defrule evaluar-riesgo-termico-indice-calor-alto
    (sensor-temperatura-humedad estado activo temperatura ?temp humedad ?hr)
    (limites-seguridad indice_calor_maximo ?limite-ic)
    (test (and (> ?temp 32) (<= ?temp 35)))
    =>
    (assert (alerta tipo termico nivel alto valor ?temp mensaje "CONDICIONES TÉRMICAS PELIGROSAS - REDUCIR EXPOSICIÓN"))
    (assert (activar-buzzer frecuencia alta))
    (assert (activar-led-rojo color rojo))
    (printout t "ALERTA TÉRMICA: Temperatura " ?temp "°C > " ?limite-ic "°C" crlf))

;; REGLA 4: Evaluación de riesgo por múltiples gases tóxicos
(defrule evaluar-riesgo-multiples-gases-toxicos
    (concentracion-gas ?gas1 ?conc1)
    (concentracion-gas ?gas2 ?conc2)
    (gas-toxico ?gas1)
    (gas-toxico ?gas2)
    (limites-seguridad ?gas1 ?formula1 nivel_maximo ?limite1)
    (limites-seguridad ?gas2 ?formula2 nivel_maximo ?limite2)
    (test (and (neq ?gas1 ?gas2) (> ?conc1 ?limite1) (> ?conc2 ?limite2)))
    =>
    (assert (alerta tipo toxicidad-multiple nivel critico valor 0 mensaje "MÚLTIPLES GASES TÓXICOS DETECTADOS - EVACUACIÓN INMEDIATA"))
    (assert (activar-buzzer frecuencia maxima))
    (assert (activar-led-rojo color rojo-parpadeante))
    (printout t "ALERTA MÚLTIPLE: " ?gas1 " (" ?conc1 ") + " ?gas2 " (" ?conc2 ") - EVACUAR" crlf))

;; REGLA 5: Evaluación de riesgo combinado temperatura y humedad alta CRÍTICO
(defrule evaluar-riesgo-combinado-temperatura-humedad-critico
    (sensor-temperatura-humedad estado activo temperatura ?temp humedad ?hr)
    (limites-seguridad temperatura_maxima ?limite-temp humedad_maxima ?limite-hr)
    (test (and (> ?temp 35) (> ?hr 90)))
    =>
    (assert (alerta tipo ambiental nivel critico temperatura ?temp humedad ?hr mensaje "CONDICIONES AMBIENTALES CRÍTICAS - EVACUAR"))
    (assert (activar-buzzer frecuencia maxima))
    (assert (activar-led-rojo color rojo-parpadeante))
    (printout t "ALERTA AMBIENTAL CRÍTICA: Temp " ?temp "°C + HR " ?hr "%" crlf))

;; REGLA 5b: Evaluación de riesgo combinado temperatura y humedad alta ALTO
(defrule evaluar-riesgo-combinado-temperatura-humedad-alto
    (sensor-temperatura-humedad estado activo temperatura ?temp humedad ?hr)
    (limites-seguridad temperatura_maxima ?limite-temp humedad_maxima ?limite-hr)
    (test (and (>= ?temp ?limite-temp) (>= ?hr ?limite-hr)))
    =>
    (assert (alerta tipo ambiental nivel alto temperatura ?temp humedad ?hr mensaje "CONDICIONES AMBIENTALES EXTREMAS - ALTA TEMPERATURA Y HUMEDAD"))
    (assert (activar-buzzer frecuencia alta))
    (assert (activar-led-rojo color rojo))
    (printout t "ALERTA AMBIENTAL: Temp " ?temp "°C + HR " ?hr "%" crlf))

;; -----------------------------------------------------
;; REGLA EXTRA PARA CONFLICTO (Estrategia de resolución)
;; -----------------------------------------------------

;; REGLA 6: Priorización de alertas por nivel de criticidad
(defrule priorizacion-alertas-criticas
    ?a1 <- (activar-buzzer frecuencia maxima)
    ?a2 <- (activar-buzzer frecuencia ?freq2)
    (test (neq ?freq2 'maxima))
    =>
    (retract ?a2)
    (printout t "PRIORIZACIÓN: Alerta MÁXIMA tiene precedencia sobre frecuencia " ?freq2 crlf)
    (assert (activar-buzzer frecuencia ?freq2 prioridad baja)))

;; -----------------------------------------------------
;; REGLAS DE ACTUALIZACIÓN SENSORES
;; -----------------------------------------------------

(defrule actualizar-concentracion-oxigeno
    ?g <- (concentracion-gas Oxigeno ?old-conc)
    (nueva-concentracion-gas Oxigeno ?new-conc)
    =>
    (retract ?g)
    (assert (concentracion-gas Oxigeno ?new-conc))
    (printout t "Oxígeno actualizado: " ?old-conc "% -> " ?new-conc "%" crlf))

(defrule actualizar-concentracion-gas-combustible
    ?g <- (concentracion-gas ?gas ?old-conc)
    (gas-combustible ?gas)
    (nueva-concentracion-gas ?gas ?new-conc)
    =>
    (retract ?g)
    (assert (concentracion-gas ?gas ?new-conc))
    (printout t "Gas combustible " ?gas " actualizado: " ?old-conc " -> " ?new-conc crlf))

(defrule actualizar-concentracion-gas-toxico
    ?g <- (concentracion-gas ?gas ?old-conc)
    (gas-toxico ?gas)
    (nueva-concentracion-gas ?gas ?new-conc)
    =>
    (retract ?g)
    (assert (concentracion-gas ?gas ?new-conc))
    (printout t "Gas tóxico " ?gas " actualizado: " ?old-conc " -> " ?new-conc crlf))

(defrule actualizar-temperatura-humedad
    ?s <- (sensor-temperatura-humedad estado ?estado temperatura ?old-temp humedad ?old-hr)
    (nueva-medicion-temperatura-humedad temperatura ?new-temp humedad ?new-hr)
    =>
    (retract ?s)
    (assert (sensor-temperatura-humedad estado ?estado temperatura ?new-temp humedad ?new-hr))
    (printout t "Temperatura actualizada: " ?old-temp "°C -> " ?new-temp "°C" crlf)
    (printout t "Humedad actualizada: " ?old-hr "% -> " ?new-hr "%" crlf))

;; -----------------------------------------------------
;; REGLAS DE CONTROL DE ACTUADORES
;; -----------------------------------------------------

(defrule controlar-buzzer
    (activar-buzzer frecuencia ?freq)
    ?s <- (sistema-alertas buzzer estado inactivo ?resto)
    =>
    (retract ?s)
    (assert (sistema-alertas buzzer estado activo frecuencia ?freq ?resto))
    (printout t "BUZZER: Activado [Frecuencia: " ?freq "]" crlf))

(defrule controlar-led-rojo
    (activar-led-rojo color ?color)
    ?s <- (sistema-alertas led-rojo estado inactivo ?resto)
    =>
    (retract ?s)
    (assert (sistema-alertas led-rojo estado activo color ?color ?resto))
    (printout t "LED ROJO: Activado [Color: " ?color "]" crlf))

(defrule controlar-pantalla-oled
    (activar-pantalla-oled mensaje ?msg)
    ?s <- (sistema-alertas pantalla-oled estado activo mensaje ?old-msg ?resto)
    =>
    (retract ?s)
    (assert (sistema-alertas pantalla-oled estado activo mensaje ?msg ?resto))
    (printout t "PANTALLA OLED: " ?msg crlf))