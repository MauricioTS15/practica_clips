;; =============================================
;; SISTEMA EXPERTO PARA EVALUACIÓN DE RIESGOS MINEROS
;; =============================================

(deffacts hechos_iniciales
    (gases
        Oxigeno O2 nivel_exposicion 20.9 limite_inferior 19.5 limite_superior 23.5
        Metano CH4 nivel_exposicion 0.0 limite_inferior 0.5 limite_superior 1.0
        Monoxido-de-Carbono CO nivel_exposicion 0.0 limite_inferior 25 limite_superior 50
        Dioxido-de-Carbono CO2 nivel_exposicion 0.0 limite_inferior 0.5 limite_superior 1.0
        Sulfuro-de-Hidrogeno H2S nivel_exposicion 0.0 limite_inferior 1 limite_superior 5
        Dioxido-de-Nitrogeno NO2 nivel_exposicion 0.0 limite_inferior 3 limite_superior 6
    )
    
    (ambientes
        frente-trabajo-A temperatura 26.0 humedad 75 indice-calor 28 categoria APACIBLE
        frente-trabajo-B temperatura 31.0 humedad 85 indice-calor 42 categoria SEVERO
        galeria-principal temperatura 28.5 humedad 80 indice-calor 32 categoria MODERADO
        temperatura 26.0 humedad 75 indice-calor 28 categoria APACIBLE
    )
    
    (categorias-termicas SERENO SIN-DAÑOS APACIBLE MODERADO SEVERO MUY-SEVERO)
    (niveles-riesgo BAJO MODERADO ALTO MUY-ALTO CRITICO)
    (tipos-riesgo TERMICO GASES EXPLOSIVO ASFIXIA)
)

;; -----------------------------------------------------
;; 2. CASOS DE USO - HECHOS INDEPENDIENTES PARA ACTIVACIÓN
;; -----------------------------------------------------

(defrule activar-monitoreo-termico
    (monitoreo-solicitado tipo TERMICO ubicacion ?ubicacion)
    =>
    (printout t "=== INICIANDO MONITOREO TÉRMICO EN " ?ubicacion " ===" crlf)
    (assert (evaluar-ambiente-termico ubicacion ?ubicacion)))

(defrule activar-monitoreo-gases
    (monitoreo-solicitado tipo GASES ubicacion ?ubicacion)
    =>
    (printout t "=== INICIANDO MONITOREO DE GASES EN " ?ubicacion " ===" crlf)
    (assert (evaluar-gases-peligrosos ubicacion ?ubicacion)))

;; -----------------------------------------------------
;; 3. REGLAS GENÉRICAS CON COMODINES
;; -----------------------------------------------------

;; REGLA 1: Evaluación de riesgo por deficiencia de oxígeno
(defrule evaluar-riesgo-oxigeno-critico
    (gases Oxigeno O2 nivel_exposicion ?conc limite_inferior ?limite)
    (ambientes ?ubicacion temperatura ?ts humedad ?hr indice-calor ?ic categoria ?cat)
    (test (< ?conc 16.0))
    =>
    (bind ?msg "EVACUAR INMEDIATAMENTE - DEFICIENCIA DE OXÍGENO PELIGROSA")
    (assert (riesgo tipo ASFIXIA nivel MUY-ALTO ubicacion ?ubicacion recomendacion ?msg))
    (printout t "ALERTA: Oxígeno en " ?conc "% en " ?ubicacion " - " ?msg crlf))

(defrule evaluar-riesgo-oxigeno-alto
    (gases Oxigeno O2 nivel_exposicion ?conc limite_inferior ?limite)
    (ambientes ?ubicacion temperatura ?ts humedad ?hr indice-calor ?ic categoria ?cat)
    (test (and (>= ?conc 16.0) (< ?conc ?limite)))
    =>
    (bind ?msg "DEFICIENCIA DE OXÍGENO - VENTILAR ÁREA INMEDIATAMENTE")
    (assert (riesgo tipo ASFIXIA nivel ALTO ubicacion ?ubicacion recomendacion ?msg))
    (printout t "ALERTA: Oxígeno en " ?conc "% en " ?ubicacion " - " ?msg crlf))

;; REGLA 2: Evaluación de riesgo por gases combustibles
(defrule evaluar-riesgo-combustible-muy-alto
    (gases Metano CH4 nivel_exposicion ?conc limite_inferior ?lim-baja limite_superior ?lim-alta)
    (ambientes ?ubicacion temperatura ?ts humedad ?hr indice-calor ?ic categoria ?cat)
    (test (> ?conc ?lim-alta))
    =>
    (bind ?msg "SUSPENDER TRABAJOS - EVACUAR - METANO EN NIVEL EXPLOSIVO")
    (assert (riesgo tipo EXPLOSIVO nivel MUY-ALTO ubicacion ?ubicacion recomendacion ?msg))
    (printout t "ALERTA: Metano en " ?conc "% en " ?ubicacion " - NIVEL MUY ALTO" crlf))

(defrule evaluar-riesgo-combustible-alto
    (gases Metano CH4 nivel_exposicion ?conc limite_inferior ?lim-baja limite_superior ?lim-alta)
    (ambientes ?ubicacion temperatura ?ts humedad ?hr indice-calor ?ic categoria ?cat)
    (test (and (> ?conc ?lim-baja) (<= ?conc ?lim-alta)))
    =>
    (bind ?msg "SUSPENDER TRABAJOS CON FUENTES DE IGNICIÓN - VENTILAR ÁREA")
    (assert (riesgo tipo EXPLOSIVO nivel ALTO ubicacion ?ubicacion recomendacion ?msg))
    (printout t "ALERTA: Metano en " ?conc "% en " ?ubicacion " - NIVEL ALTO" crlf))

;; REGLA 3: Evaluación de riesgo térmico por índice de calor
(defrule evaluar-riesgo-termico-muy-alto
    (ambientes ?ubicacion temperatura ?ts humedad ?hr indice-calor ?ic categoria ?cat)
    (test (> ?ic 41))
    =>
    (bind ?msg "CONDICIONES TÉRMICAS EXTREMAS - EVACUAR ÁREA")
    (assert (riesgo tipo TERMICO nivel MUY-ALTO ubicacion ?ubicacion recomendacion ?msg))
    (printout t "ALERTA TÉRMICA: " ?ubicacion " - Índice de calor " ?ic "°C - NIVEL MUY ALTO" crlf))

(defrule evaluar-riesgo-termico-alto
    (ambientes ?ubicacion temperatura ?ts humedad ?hr indice-calor ?ic categoria ?cat)
    (test (and (> ?ic 32) (<= ?ic 41)))
    =>
    (bind ?msg "REDUCIR TIEMPOS DE EXPOSICIÓN - IMPLEMENTAR ROTACIÓN")
    (assert (riesgo tipo TERMICO nivel ALTO ubicacion ?ubicacion recomendacion ?msg))
    (printout t "ALERTA TÉRMICA: " ?ubicacion " - Índice de calor " ?ic "°C - NIVEL ALTO" crlf))

(defrule evaluar-riesgo-termico-moderado
    (ambientes ?ubicacion temperatura ?ts humedad ?hr indice-calor ?ic categoria ?cat)
    (test (and (> ?ic 28) (<= ?ic 32)))
    =>
    (bind ?msg "MONITOREAR CONSTANTEMENTE - MANTENER HIDRATACIÓN")
    (assert (riesgo tipo TERMICO nivel MODERADO ubicacion ?ubicacion recomendacion ?msg))
    (printout t "ALERTA TÉRMICA: " ?ubicacion " - Índice de calor " ?ic "°C - NIVEL MODERADO" crlf))

;; REGLA 4: Evaluación de riesgo por múltiples gases tóxicos
(defrule evaluar-riesgo-toxicidad-multiple
    (gases ?gas1 ?sigla1 nivel_exposicion ?conc1 limite_inferior ?lim1)
    (gases ?gas2 ?sigla2 nivel_exposicion ?conc2 limite_inferior ?lim2)
    (ambientes ?ubicacion temperatura ?ts humedad ?hr indice-calor ?ic categoria ?cat)
    (test (and (neq ?gas1 Oxigeno) (neq ?gas1 Metano) 
               (neq ?gas2 Oxigeno) (neq ?gas2 Metano) 
               (neq ?gas2 ?gas1) 
               (> ?conc1 ?lim1) (> ?conc2 ?lim2)))
    =>
    (bind ?msg "EVACUACIÓN INMEDIATA - MULTIPLES GASES TÓXICOS DETECTADOS")
    (assert (riesgo tipo GASES nivel MUY-ALTO ubicacion ?ubicacion recomendacion ?msg))
    (printout t "ALERTA CRÍTICA: " ?ubicacion " - Múltiples gases tóxicos " ?gas1 " y " ?gas2 " detectados" crlf))

;; REGLA 5: Evaluación de riesgo combinado temperatura y humedad alta
(defrule evaluar-riesgo-termico-extremo
    (ambientes ?ubicacion temperatura ?ts humedad ?hr indice-calor ?ic categoria ?cat)
    (test (and (>= ?ts 30) (>= ?hr 85)))
    =>
    (bind ?msg "CONDICIONES TÉRMICAS EXTREMAS - RIESGO DE GOLPE DE CALOR")
    (assert (riesgo tipo TERMICO nivel MUY-ALTO ubicacion ?ubicacion recomendacion ?msg))
    (printout t "ALERTA EXTREMA: " ?ubicacion " - Temp " ?ts "°C con HR " ?hr "% - " ?msg crlf))

;; -----------------------------------------------------
;; REGLA EXTRA PARA CONFLICTO (Estrategia de resolución)
;; -----------------------------------------------------

;; REGLA 6: Priorización de riesgos críticos (CONFLICTO)
(defrule priorizar-riesgo-critico
    ?r1 <- (riesgo tipo ?tipo1 nivel MUY-ALTO ubicacion ?ubicacion recomendacion ?rec1)
    ?r2 <- (riesgo tipo ?tipo2 nivel ALTO ubicacion ?ubicacion recomendacion ?rec2)
    (test (neq ?tipo1 ?tipo2))
    =>
    (retract ?r2)
    (printout t "PRIORIZACIÓN: " ?ubicacion " - Riesgo " ?tipo1 " (MUY-ALTO) tiene precedencia sobre " 
             ?tipo2 " (ALTO)" crlf)
    (assert (riesgo tipo ?tipo2 nivel ALTO ubicacion ?ubicacion 
                   recomendacion "ACCIÓN DIFERIDA - ATENDER PRIMERO RIESGO CRÍTICO")))

;; -----------------------------------------------------
;; REGLAS AUXILIARES PARA ACTUALIZAR MEDICIONES
;; -----------------------------------------------------

(defrule actualizar-medicion-oxigeno
    ?g <- (gases Oxigeno O2 nivel_exposicion ?old-conc limite_inferior ?lim-inf limite_superior ?lim-sup)
    (nueva-medicion-gas nombre Oxigeno concentracion ?new-conc)
    =>
    (retract ?g)
    (assert (gases Oxigeno O2 nivel_exposicion ?new-conc limite_inferior 19.5 limite_superior 23.5))
    (printout t "Actualizada medición de Oxigeno: " ?old-conc " -> " ?new-conc crlf))

(defrule actualizar-medicion-metano
    ?g <- (gases Metano CH4 nivel_exposicion ?old-conc limite_inferior ?lim-inf limite_superior ?lim-sup)
    (nueva-medicion-gas nombre Metano concentracion ?new-conc)
    =>
    (retract ?g)
    (assert (gases Metano CH4 nivel_exposicion ?new-conc limite_inferior 0.5 limite_superior 1.0))
    (printout t "Actualizada medición de Metano: " ?old-conc " -> " ?new-conc crlf))

(defrule actualizar-medicion-monoxido
    ?g <- (gases Monoxido-de-Carbono CO nivel_exposicion ?old-conc limite_inferior ?lim-inf limite_superior ?lim-sup)
    (nueva-medicion-gas nombre Monoxido-de-Carbono concentracion ?new-conc)
    =>
    (retract ?g)
    (assert (gases Monoxido-de-Carbono CO nivel_exposicion ?new-conc limite_inferior 25 limite_superior 50))
    (printout t "Actualizada medición de Monoxido-de-Carbono: " ?old-conc " -> " ?new-conc crlf))

(defrule calcular-indice-calor-alto
    ?a <- (ambientes ?ubicacion temperatura ?temp humedad ?hr indice-calor ?old-ic categoria ?old-cat)
    (nueva-medicion-ambiente ubicacion ?ubicacion temperatura ?temp humedad ?hr)
    (test (and (>= ?temp 27) (>= ?hr 80)))
    =>
    (bind ?nuevo-indice (+ ?temp 10))
    (retract ?a)
    (assert (ambientes ?ubicacion temperatura ?temp humedad ?hr indice-calor ?nuevo-indice categoria SEVERO))
    (printout t "Calculado índice de calor: " ?nuevo-indice "°C para " ?ubicacion crlf))

(defrule calcular-indice-calor-moderado
    ?a <- (ambientes ?ubicacion temperatura ?temp humedad ?hr indice-calor ?old-ic categoria ?old-cat)
    (nueva-medicion-ambiente ubicacion ?ubicacion temperatura ?temp humedad ?hr)
    (test (and (>= ?temp 30) (>= ?hr 70)))
    =>
    (bind ?nuevo-indice (+ ?temp 15))
    (retract ?a)
    (assert (ambientes ?ubicacion temperatura ?temp humedad ?hr indice-calor ?nuevo-indice categoria SEVERO))
    (printout t "Calculado índice de calor: " ?nuevo-indice "°C para " ?ubicacion crlf))

(defrule calcular-indice-calor-normal
    ?a <- (ambientes ?ubicacion temperatura ?temp humedad ?hr indice-calor ?old-ic categoria ?old-cat)
    (nueva-medicion-ambiente ubicacion ?ubicacion temperatura ?temp humedad ?hr)
    (test (or (< ?temp 27) (< ?hr 70)))
    =>
    (bind ?nuevo-indice ?temp)
    (retract ?a)
    (assert (ambientes ?ubicacion temperatura ?temp humedad ?hr indice-calor ?nuevo-indice categoria APACIBLE))
    (printout t "Calculado índice de calor: " ?nuevo-indice "°C para " ?ubicacion crlf))


(assert
            (sensor-ultrasonico estado activo)
            (sensor-temperatura-humedad estado activo)
            (sensor-casco estado activo)
            (protocolo-emergencia protocolo estado activo)
    )