; ============================================================================
;                               BASES DE HECHOS
; ============================================================================
(deffacts hechos_iniciales
    ; Límites de seguridad basados en documentos
    (limites-seguridad
        Oxigeno O2 nivel_minimo 19.5 nivel_maximo 23.5
        Metano CH4 nivel_minimo 0.5 nivel_maximo 1.0 
        Monoxido-de-Carbono CO nivel_minimo 25.0 nivel_maximo 50.0
        Dioxido-de-Carbono CO2 nivel_minimo 0.5 nivel_maximo 1.0
        Sulfuro-de-Hidrogeno H2S nivel_minimo 1.0 nivel_maximo 5.0
        Oxido-de-Nitrogeno NO2 nivel_minimo 1.0 nivel_maximo 20.0
        Temperatura T nivel_minimo 15.0 nivel_maximo 32.0
        Humedad H nivel_minimo 30.0 nivel_maximo 85.0
    )
    ; Tipos de gases
    (gas Oxigeno)
    (gas-toxico Monoxido-de-Carbono Dioxido-de-Carbono Sulfuro-de-Hidrogeno Oxido-de-Nitrogeno)
    (gas-combustible Metano Sulfuro-de-Hidrogeno)
    (ambiente Temperatura Humedad)
    
    ; Alertas y notificaciones
    (sistema-alertas 
        buzzer estado inactivo 
        led-rojo estado inactivo 
        pantalla-oled estado inactivo
        info_equipo-medico estado inactivo 
    )

    ; Mediciones actuales de gases
    (concentracion-gas Oxigeno 17)
    (concentracion-gas Metano 0.2)
    (concentracion-gas Monoxido-de-Carbono 15.0)
    (concentracion-gas Dioxido-de-Carbono 0.3)
    (concentracion-gas Sulfuro-de-Hidrogeno 1.0)
    (concentracion-gas Dioxido-de-Nitrogeno 1.0)
    (concentracion-ambiente Temperatura 15.0)
    (concentracion-ambiente Humedad 30.0)
)

; ============================================================================
;                     HECHOS INDEPENDIENTES PARA ACTIVACIÓN
; ============================================================================
; Prioridad de reglas
; set-strategy <complexity>
; Sensores del casco - estado inicial
    ; (assert
            ; (sensor-ultrasonico estado activo)
            ; (sensor-temperatura-humedad estado activo)
            ; (sensor-casco estado activo)
    ; )
; REGLA 2: Evaluación de riesgo por gases combustibles
;1.El Metano es inflamable, mezclado con aire en
;concentraciones entre el 5% y el 10% puede formar mezclas explosivas
;lo que puede llevar a producir Hidrogeno como subproducto.
;2.El Hidrogeno es altamente inflamable, mezclado con aire en
;concentraciones entre el 4% y el 76% puede formar mezclas explosivas.
;3.El polvo puede acumularse en suspensiones en el aire, creando 
;un riesgo de explosiones de polvo.

;Conflicto
;Avisa al trabajador activando otra alerta de sistema-alertas
(defrule gases-combustibles-avisa-trabajador
(limites-seguridad $? ?nombre ?simbolo nivel_minimo ?minimo nivel_maximo ?maximo)
(gas-combustible $? ?nombre $?)
(concentracion-gas ?nombre ?valor_medido)
(test (> ?valor_medido ?maximo))
=>
(assert (alerta gases_alta_combustión))
(printout t "Aviso al trabajador que esta en zona de altos gases de combustión" crlf)
)

;Avisa al medico que el trabajador esta en zona peligrosa
(defrule gases-combustibles-aviso-medico
(limites-seguridad $? ?nombre ?simbolo nivel_minimo ?minimo nivel_maximo ?maximo)
(gas-combustible $? ?nombre $?)
(concentracion-gas ?nombre ?valor_medido)
(test (> ?valor_medido ?maximo))
=>
(printout t "Aviso al medico que el trabajador esta en zona de altos gases de combustión" crlf)
)
